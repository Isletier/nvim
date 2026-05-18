require('nvim-treesitter').setup {
    -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
    install_dir = vim.fn.stdpath('data') .. '/site'
}

require('nvim-treesitter').install {
    "c",
    "cpp",
    "asm",
    "python",
    "go",
    "zig",

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

