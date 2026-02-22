-- LSP enable
vim.lsp.codelens.enable = false
vim.lsp.semantic_tokens.enable = false
vim.lsp.inlay_hint.enable = false

LSP = {
    [1] = 'lua_ls',
    [2] = 'clangd',
    [3] = 'gopls',
    [4] = 'pylsp'
}

for _, v in pairs(LSP) do
    vim.lsp.enable(v)
end

vim.keymap.set("n", "gd", "<C-]>")
-- just for documenting
vim.keymap.set("n", "gra", vim.lsp.buf.code_action)
vim.keymap.set("n", "gri", vim.lsp.buf.implementation)
vim.keymap.set("n", "grn", vim.lsp.buf.rename)
vim.keymap.set("n", "grr", vim.lsp.buf.references)
vim.keymap.set("n", "grt", vim.lsp.buf.type_definition)
vim.keymap.set("n", "gO", vim.lsp.buf.document_symbol)


-- LSP completion
vim.opt.completeopt = {
    "menu",
    "menuone"
}

local s_tab_completion = function()
    if vim.fn.pumvisible() == 1 then
        return "<C-p>"
    else
        return "<C-x><C-o>"
    end
end

local tab_completion = function()
    if vim.fn.pumvisible() == 1 then
        return "<C-n>"
    else
        return "<Tab>"
    end
end

vim.keymap.set("i", "<S-Tab>", s_tab_completion, { expr = true, noremap = true })
vim.keymap.set("i", "<Tab>", tab_completion, { expr = true, noremap = true })
vim.keymap.set('x', '<leader>gf', vim.lsp.buf.format, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, { noremap = true, silent = true })

vim.opt.shortmess:append("c")
vim.opt.updatetime = 200
vim.opt.pumheight = 10


-- LSP signature help
local function max_len_upper_line()
    local above = math.max(1, vim.fn.line(".") - 1)

    local line = vim.fn.getline(above)
    local len = vim.fn.strdisplaywidth(line)

    return len + 8
end


local cfg = {
    doc_lines = 0,
    max_height = 3,
    floating_window_off_x = max_len_upper_line,
    fix_pos = true,
    hint_enable = false,
    handler_opts = { border = "none" },
    toggle_key_flip_floatwin_setting = true,
}

require("lsp_signature").setup(cfg)

