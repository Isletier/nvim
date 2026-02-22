vim.opt.rtp:append("/home/alexey/.config/nvim-DVAP")
vim.opt.rtp:append("/home/alexey/.config/nvim-DVAP-ui")


require("packerInit")

require("remaps")

require("common")

require("colors")

require("TreeSitterInit")

require("LSP")

require("DVAP")

require("gitTools")

require("QF")

require("cmd")


require("nvim-dvap-ui").setup()

