require("packerInit")

require("remaps")

require("common")

require("colors")

require("TreeSitterInit")

require("LSP")

require("gitTools")

require("QF")

require("cmd")

vim.opt.runtimepath:prepend(vim.fn.stdpath("config") .. "/nvim-DVAP")
vim.opt.runtimepath:prepend(vim.fn.stdpath("config") .. "/nvim-DVAP-ui")

require("DVAP")

