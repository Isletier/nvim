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
vim.keymap.set("n", "gO",  vim.lsp.buf.document_symbol)

vim.keymap.set("n", "<leader>qv", ToggleVText, { desc = "Toggle virtual text" })

