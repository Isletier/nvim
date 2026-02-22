vim.api.nvim_set_hl(0, "dvap_line", { bg = '#19435b' })

vim.fn.sign_define("breakpoint_u", { text = "", texthl = "Character" })
vim.fn.sign_define("breakpoint_c", { text = "", texthl = "Character" })


require("nvim-dvap-ui").setup({
    debug_cursorline_hl = "dvap_line",

    breakpoint_unconditional_sign = "breakpoint_u",
    breakpoint_conditional_sign = "breakpoint_c",

    threadline_hl = "Search"
})

