vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.cmd("wincmd J")
        vim.wo.wrap = true
    end,
})

local qf_original_list = {}
local qf_is_filtered = false
local qf_opened_toggle = false

function ResetQFFiltering()
    qf_is_filtered = false
end

local function deep_copy(t)
    if type(t) ~= 'table' then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = deep_copy(v)
    end
    return copy
end

local function toggle_qf_filter()
    local qflist = vim.fn.getqflist()

    if not qf_is_filtered then
        qf_original_list = deep_copy(qflist)
        local filtered = {}
        for _, item in ipairs(qflist) do
            if item.bufnr ~= 0 then
                table.insert(filtered, item)
            end
        end
        vim.fn.setqflist(filtered, 'r')
        qf_is_filtered = true
    else
        vim.fn.setqflist(qf_original_list, 'r')
        qf_is_filtered = false
    end
end

function Open_qf_full()
    vim.cmd(":copen")
    local height = vim.opt.lines:get() - 30
    vim.cmd("resize " .. height)
end

function Open_qf_standart()
    vim.cmd(":copen")
    vim.cmd("resize 10")
end

function BuffersToQf()
    local buffers = vim.api.nvim_list_bufs()
    local qflist = {}

    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) ~= '' then
            local filename = vim.api.nvim_buf_get_name(bufnr)
            table.insert(qflist, {
                filename = filename,
                lnum = 1,
                col = 1,
                text = vim.fn.fnamemodify(filename, ':t')
            })
        end
    end

    vim.fn.setqflist(qflist, 'r')
    Open_qf_standart()
end

local track_file = "/tmp/qf_stream.txt"
local active_streams = {}

local function clean_ansi(text)
    return text:gsub("\x1b%[[0-9;]*[a-zA-Z]", "")
end

_G.start_external_stream = function(pipe_path, errorformat)
    -- Clear the quickfix list for the fresh stream
    vim.fn.setqflist({}, 'r', { title = "Broadcast Stream", items = {} })
    Open_qf_standart()

    local pipe = vim.uv.new_pipe(false)

    local efm = nil
    if errorformat ~= nil and errorformat ~= "" then
        efm = vim.base64.decode(errorformat)
    end

    vim.uv.fs_open(pipe_path, "r", 438, function(err, fd)
        if err then return end

        active_streams[pipe_path] = pipe
        pipe:open(fd)

        pipe:read_start(vim.schedule_wrap(function(read_err, data)
            if data then
                -- Split incoming stream chunk into clean lines
                local lines = vim.split(data, "[\r\n]+")
                local valid_lines = {}

                for _, line in ipairs(lines) do
                    if line ~= "" then
                        local cleaned = clean_ansi(line)
                        table.insert(valid_lines, cleaned)
                    end
                end

                if #valid_lines > 0 then
                    --dless 'lines' tells Neovim to run these strings through its internal parser.
                    -- If 'errorformat' is blank/nil, it automatically uses the global standard 'make' efm.
                    vim.fn.setqflist({}, 'a', {
                        lines = valid_lines,
                        efm = efm
                    })
                    vim.cmd("redraw")
                end
            else
                -- Cleanup at EOF
                if active_streams[pipe_path] then
                    active_streams[pipe_path]:close()
                    active_streams[pipe_path] = nil
                end
            end
        end))
    end)
end

-- Toggle function you can bind to a key
function Open_pinned_qf()
    vim.cmd("cfile " .. track_file)
    Open_qf_standart()
end


vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")

vim.keymap.set("n", "<leader>qg", Open_qf_full)
vim.keymap.set("n", "<leader>qn", Open_qf_standart)
vim.keymap.set("n", "<leader>qe", "<cmd>cclose<CR>")
vim.keymap.set("n", "<leader>qf", toggle_qf_filter)
vim.keymap.set('n', '<leader>qt', Open_pinned_qf)

vim.keymap.set("n", "<leader>ql", vim.diagnostic.setqflist, { desc = "LSP diagnostics to quickfix" })
vim.keymap.set("n", "<leader>qb", BuffersToQf, { desc = "Buffers to quickfix" })

