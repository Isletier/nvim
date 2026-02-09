vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.path:append("**")
vim.opt.wildmenu = true

vim.opt.tabstop = 4 -- A TAB character looks like 4 spaces
vim.opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.opt.shiftwidth = 4 -- Number of spaces inserted when indenting

vim.opt.listchars = {
    space = '·',
    tab = '→→'
}

--vim.g.loaded_netrw = 1
--vim.g.loaded_netrwPlugin = 1

--TODO: move that
-- empty setup using defaults
--require("nvim-tree").setup()

vim.g.loaded_matchparen = true

vim.opt.list = true

vim.opt.smartindent = true;

vim.opt.wrap = true

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 6
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- Enable system clipboard
vim.opt.clipboard = "unnamedplus"

vim.opt.fillchars:append { eob = " " }
vim.g.loaded_matchparen = true

vim.opt.swapfile = false

