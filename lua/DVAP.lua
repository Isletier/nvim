local uv = vim.uv or vim.loop
local bit = require("bit")

-- Глобальная переменная, чтобы Garbage Collector не закрыл соединение
_G.ws_instance = _G.ws_instance or { handle = nil }

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

local threads = {}
local breakpoints = {}

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
    local lines = split_string_full(frame)
    for index, line in ipairs(lines) do
        local occurancies = split_string_full(line, ':')
        if occurancies[1] == "thread" then
            table.insert(threads, { occurancies[2], occurancies[3], occurancies[4], occurancies[5] })
        else if occurancies[1] == "bp" then
            
        else
        
    end

--    for index, thread in ipairs(threads) do
--        print(thread[1] .. thread[2] .. thread[3] .. thread[4])
--    end
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
        local key = "dGhlIHNhbXBsZSBub25jZQ==" -- Статичный ключ для простоты
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
        prompt = 'Введите адрес WebSocket (HOST:PORT): ',
        default = "127.0.0.1:8080", -- значение по умолчанию
    }, connect)
end

vim.keymap.set("n", "<leader>d", connectCMD)

