vim.api.nvim_set_hl(0, "dvap_line", { bg = '#19435b' })

require("nvim-dvap-ui").setup({
    debug_cursorline_hl = "dvap_line",

    threadline_hl = "Search"
})

vim.fn.sign_define("DVAP_breakpoint_unconditional", { text = "", texthl = "Character" })
vim.fn.sign_define("DVAP_breakpoint_conditional", { text = "", texthl = "Character" })

