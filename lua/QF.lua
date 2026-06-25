vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.cmd("wincmd J")
        vim.wo.wrap = true
    end,
})

local qf_original_list = {}
local qf_is_filtered = false

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
    if #vim.fn.getqflist() == 0 then
        print("No items in QF list")
        return
    end

    vim.cmd(":copen")
    local height = vim.opt.lines:get() - 30
    vim.cmd("resize " .. height)
end

function Open_qf_standart()
    if #vim.fn.getqflist() == 0 then
        print("No items in QF list")
        return
    end

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
local last_size = 0
local is_watching = false -- Your toggle flag

local function watch_step()
    if not is_watching then return end

    local f = io.open(track_file, "r")
    if not f then return end

    local current_size = f:seek("end")

    -- If file shrank or reset, clear the quickfix list and start over
    if current_size < last_size then
        vim.cmd("cclear")
        last_size = 0
    end

    -- If new content was added, read only the new portion
    if current_size > last_size then
        f:seek("set", last_size)
        local new_content = f:read("*a")
        last_size = current_size

        -- Convert the new string block into a list of lines
        local lines = vim.split(new_content, "\n")

        -- 'a' means APPEND to the existing quickfix list instead of overwriting
        vim.fn.setqflist({}, 'a', { lines = lines })
    end

    f:close()
end

-- Toggle function you can bind to a key
function Toggle_pinned_qf()
    is_watching = not is_watching
    if is_watching then
        print("Quickfix watching enabled")
        last_size = 0
        _G.watch_timer = vim.loop.new_timer()
        _G.watch_timer:start(0, 400, vim.schedule_wrap(watch_step))
    else
        print("Quickfix watching disabled")
        if _G.watch_timer then _G.watch_timer:close() end
    end
end


vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")

vim.keymap.set("n", "<leader>qg", Open_qf_full)
vim.keymap.set("n", "<leader>qn", Open_qf_standart)
vim.keymap.set("n", "<leader>qe", "<cmd>cclose<CR>")
vim.keymap.set("n", "<leader>qf", toggle_qf_filter)
vim.keymap.set('n', '<leader>qt', Toggle_pinned_qf, { desc = "Load streamed terminal output into Quickfix" })

vim.keymap.set("n", "<leader>ql", vim.diagnostic.setqflist, { desc = "LSP diagnostics to quickfix" })
vim.keymap.set("n", "<leader>qb", BuffersToQf, { desc = "Buffers to quickfix" })

