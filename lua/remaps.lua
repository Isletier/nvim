vim.g.mapleader = " "

vim.keymap.set("n", "<leader>t", "<cmd>Ex<CR>")

vim.keymap.set("n", "<leader>h", "<C-W>h")
vim.keymap.set("n", "<leader>j", "<C-W>j")
vim.keymap.set("n", "<leader>k", "<C-W>k")
vim.keymap.set("n", "<leader>l", "<C-W>l")

vim.keymap.set("n", "<leader>wq", "<cmd>q<CR>")

-- Paste without replacing clipboard register
vim.keymap.set("x", "<leader>p", [=["_dP]=])
vim.keymap.set({"n", "v"}, "<leader>d", [=["_d]=])

-- Alternative paste mappings that preserve register
vim.keymap.set("x", "p", [=["_dP]=])
vim.keymap.set("x", "P", [=["_dP]=])

local vtext = false
function ToggleVText()
    vtext = not vtext
    vim.diagnostic.config({
        virtual_text = vtext,
    })
end

-- Remove virtual text if it start to be anoying
vim.keymap.set("n", "<leader>qv", ToggleVText, { desc = "Toggle virtual text" })

vim.keymap.set('x', 'J', ":move '>+1<CR>gv-gv", { noremap = true, silent = true })
vim.keymap.set('x', 'K', ":move '<-2<CR>gv-gv", { noremap = true, silent = true })

