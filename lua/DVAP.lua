local uv = vim.uv or vim.loop
local bit = require("bit")

-- Глобальная переменная, чтобы Garbage Collector не закрыл соединение
_G.ws_instance = _G.ws_instance or { handle = nil }


Threads = {}
Breakpoints = {}


Timer = vim.uv.new_timer()
DVAP_namespace = vim.api.nvim_create_namespace("dvap")

Thread_buf_cache = {}

Thread_Watch_num = nil
Thread_Watch_pos_cache = { "", 0 }

local function highlight_current_line(thread_num, file_path, line_number)
--    if vim.fn.bufexists(file_path) == 0 then
--        return
--    end

    local bufnr = vim.fn.bufadd(file_path)
    vim.fn.bufload(bufnr)

    if Thread_buf_cache[thread_num] ~= nil then
        vim.api.nvim_buf_clear_namespace(Thread_buf_cache[thread_num], DVAP_namespace, 0, -1)
    end

    vim.api.nvim_buf_set_extmark(bufnr, DVAP_namespace, line_number - 1, 0, {
        line_hl_group = "Search", -- Можно использовать "CursorLine", "Search" или свой кастомный
        hl_mode = "combine",
    })

    Thread_buf_cache[thread_num] = bufnr
end

local function thread_watch_focus(file_path, line_number)
    print("attempting to focus")
    if Thread_Watch_pos_cache[1] == file_path and Thread_Watch_pos_cache[2] == line_number then
        return
    end

    local bufnr = vim.fn.bufadd(file_path)
    vim.fn.bufload(bufnr)

    vim.api.nvim_set_current_buf(bufnr)

    vim.api.nvim_win_set_cursor(0, {tonumber(line_number), 0})
    Thread_Watch_pos_cache[1] = file_path
    Thread_Watch_pos_cache[2] = line_number
end

local function start_ui_poller()
    assert(Timer ~= nil)
    Timer:start(1000, 30, vim.schedule_wrap(function()
        for num, thread in pairs(Threads) do
            highlight_current_line(num, thread["file_path"], thread["line"])
        end

        if Thread_Watch_num ~= nil and Threads[Thread_Watch_num] ~= nil then
            thread_watch_focus(Threads[Thread_Watch_num]["file_path"], Threads[Thread_Watch_num]["line"])
            return
        end

        --try tid
        for _, thread in pairs(Threads) do
            if thread["tid"] == Thread_Watch_num then
                thread_watch_focus(thread["file_path"], thread["line"])
            end
        end
    end))
end

local function stop_ui_poller()
    if Timer ~= nil then
        Timer:stop()
    end
end

local function parse_frame(data)
    if #data < 2 then return nil, data end
    local b1 = string.byte(data, 1)
    local b2 = string.byte(data, 2)

    local opcode = bit.band(b1, 0x0F)
    local payload_len = bit.band(b2, 0x7F)
    local header_size = 2

    if payload_len == 126 then
        if #data < 4 then return nil, data end
        payload_len = bit.lshift(string.byte(data, 3), 8) + string.byte(data, 4)
        header_size = 4
    elseif payload_len == 127 then
        if #data < 10 then return nil, data end
        -- Берем только младшие 4 байта для простоты (до 4ГБ)
        payload_len = bit.lshift(string.byte(data, 7), 24) + bit.lshift(string.byte(data, 8), 16) +
                      bit.lshift(string.byte(data, 9), 8) + string.byte(data, 10)
        header_size = 10
    end

    if #data < header_size + payload_len then return nil, data end

    local payload = string.sub(data, header_size + 1, header_size + payload_len)
    local remaining = string.sub(data, header_size + payload_len + 1)

    return { opcode = opcode, payload = payload }, remaining
end

local function parse_endpoint(endpoint)
    local host, port = string.match(endpoint, "([^:]+):(%d+)")

    if not host or not port then
        return nil, "Invalid endpoint format. Use HOST:PORT"
    end

    return host, tonumber(port)
end

HOST = ""
PORT = 9000
PATH = "/"

local function split_string_full(inputstr, sep)
    sep = sep or "%s" -- Default to a space pattern if none provided
    local t = {}
    local i = 1
    -- Capture everything that is not the separator
    for str in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do
        t[i] = str
        i = i + 1
    end

    return t
end

local function update_state(frame)
    Threads = {}
    Breakpoints = {}
    local lines = split_string_full(frame)
    for _, line in ipairs(lines) do
        local occurancies = split_string_full(line, ':')
        if occurancies[1] == "thread" then
            Threads[occurancies[2]] = {
                file_path = occurancies[3],
                line = occurancies[4],
                tid = occurancies[5]
            }
        elseif occurancies[1] == "bp" then
            --table.insert(breakpoints, { occurancies[2], occurancies[3], occurancies[4], occurancies[5], occurancies[6], occurancies[7], occurancies[8] } )
        else
        end
    end

end

local function connect(endpoint)
    if _G.ws_instance.handle then
        _G.ws_instance.handle:close()
    end

    local client = uv.new_tcp()
    if client == nil then
        print("Conenction failed")
        return
    end

    HOST, PORT = parse_endpoint(endpoint)
    if not HOST and PORT then
        return
    end

    _G.ws_instance.handle = client
    local buffer = ""
    local handshaked = false

    client:connect(HOST, PORT, function(err)
        if err then return print("Connection error: " .. err) end

        -- Handshake
        local key = "dGhlIHNhbXBsZSBub25jZQ=="
        local req = string.format(
            "GET %s HTTP/1.1\r\nHost: %s\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: %s\r\nSec-WebSocket-Version: 13\r\n\r\n",
            PATH, HOST, key
        )
        client:write(req)

        client:read_start(function(err, chunk)
            if err or not chunk then
                print("Connection closed")
                client:close()
                _G.ws_instance.handle = nil
                return
            end

            buffer = buffer .. chunk

            if not handshaked then
                local _, e = buffer:find("\r\n\r\n")
                if e then
                    if buffer:find("101 Switching Protocols") then
                        handshaked = true
                        start_ui_poller()
                        print("WebSocket Connected to " .. HOST .. ":" .. PORT)
                        buffer = buffer:sub(e + 1)
                    else
                        print("Handshake failed")
                        client:close()
                    end
                end
            end

            if handshaked then
                while #buffer > 0 do
                    local frame, remaining = parse_frame(buffer)
                    if frame then
                        buffer = remaining
                        if frame.opcode == 1 then -- Text frame
                            update_state(frame.payload)
                        elseif frame.opcode == 8 then -- Close frame
                            stop_ui_poller()
                            client:close()
                        end
                    else
                        break
                    end
                end
            end
        end)
    end)
end

local function connectCMD()
    vim.ui.input({
        prompt = 'Enter DVAP endpoint (HOST:PORT): ',
        default = "127.0.0.1:8080", -- значение по умолчанию
    }, connect)
end

local function SetWatchThread()
    vim.ui.input({
        prompt = 'Enter Focus Thread num|tid: ',
        default = "1", -- значение по умолчанию
    }, function(num)
        Thread_Watch_num = num
        Thread_Watch_pos_cache = { "", 0 }
    end)
end

local function ResetWatchThread()
    Thread_Watch_num = nil
    Thread_Watch_pos_cache = { "", 0 }
end

vim.keymap.set("n", "<leader>d", connectCMD)
vim.keymap.set("n", "<leader>dw", SetWatchThread)
vim.keymap.set("n", "<leader>dr", ResetWatchThread)

