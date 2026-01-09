require'nvim-treesitter'.setup {
  install_dir = vim.fn.stdpath('data') .. '/site'
}

require'nvim-treesitter'.install {
    "c",
    "cpp",
    "asm",
    "python",

    "ninja",
    "make",
    "cmake",
    "bash",

    "json",
    "proto",

    "lua",
    "vim",
    "vimdoc",
}

