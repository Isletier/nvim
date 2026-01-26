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
    local height = vim.opt.lines:get() - 10
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

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")

vim.keymap.set("n", "<leader>qg", Open_qf_full)
vim.keymap.set("n", "<leader>qn", Open_qf_standart)
vim.keymap.set("n", "<leader>qe", "<cmd>cclose<CR>")
vim.keymap.set("n", "<leader>qf", toggle_qf_filter)

vim.keymap.set("n", "<leader>ql", vim.diagnostic.setqflist, { desc = "LSP diagnostics to quickfix" })
vim.keymap.set("n", "<leader>qb", BuffersToQf, { desc = "Buffers to quickfix" })

