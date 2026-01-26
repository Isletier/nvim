vim.cmd.colorscheme("arctic")

--semantic highlight
vim.highlight.priorities.semantic_tokens = 85

vim.opt.cursorline = true

vim.api.nvim_set_hl(0, "CursorLine", {bg = '#2a2d2e'} )

vim.fn.sign_define('DapBreakpoint', {
    text='🛑',
    texthl='',
    linehl='',
    numhl=''
})

vim.api.nvim_set_hl(0, "DapLine", { bg = '#002936' } )

vim.fn.sign_define('DapStopped',
{
    text=' ', -- nerdfonts icon here
    texthl='',
    linehl='DapLine',
    numhl=''
})

vim.api.nvim_set_hl(0, "StatusLine", { bg = nil } )
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = nil } )
vim.api.nvim_set_hl(0, "NvimTreeStatusLine", { bg = nil } )
vim.api.nvim_set_hl(0, "NvimTreeStatusLineNC", { bg = nil } )

local colors = {
    gray     = '#3C3C3C',
    lightred = '#D16969',
    blue     = '#569CD6',
    pink     = '#C586C0',
    black    = '#262626',
    white    = '#D4D4D4',
    green    = '#608B4E',
}

local line_theme = {
    normal = {
        b = { fg = colors.green, bg = colors.black },
        a = { fg = colors.black, bg = colors.green, gui = 'bold' },
        c = { fg = colors.green, bg = nil },
    },
    visual = {
        b = { fg = colors.pink, bg = colors.black },
        a = { fg = colors.black, bg = colors.pink, gui = 'bold' },
        c = { fg = colors.pink, bg = nil}
    },
    inactive = {
        b = { fg = colors.black, bg = colors.blue },
        a = { fg = colors.white, bg = colors.gray, gui = 'bold' },
    },
    replace = {
        b = { fg = colors.lightred, bg = colors.black },
        a = { fg = colors.black, bg = colors.lightred, gui = 'bold' },
        c = { fg = colors.lightred, bg = nil },
    },
    insert = {
        b = { fg = colors.blue, bg = colors.black },
        a = { fg = colors.black, bg = colors.blue, gui = 'bold' },
        c = { fg = colors.blue, bg = nil },
    },
}

require('lualine').setup {
    options = {
        theme = line_theme,
    },
    extensions = {
        "nvim-tree"
    },
    sections = {
      lualine_c = {
        {
          'filename',
          file_status = true, -- displays file status (readonly status, modified status)
          path = 2 -- 0 = just filename, 1 = relative path, 2 = absolute path
        }
      }
    }
}

vim.api.nvim_set_hl(0, "QfFileName", {fg = '#3794ff'} )
vim.api.nvim_set_hl(0, "QfLineNr", {fg = '#9cdcfe'} )

vim.api.nvim_set_hl(0, "DiffTextChanged", { fg =0x1F58AE,  link = "DiffLineChanged" } )

vim.opt.fillchars:append { eob = " ", diff = "╱"}
vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#5a5a5a", link="DiffLineDelete" })


