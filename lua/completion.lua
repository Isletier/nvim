










































































--local cmp = require('cmp')
--local luasnip = require('luasnip')
--
---- Configure nvim-cmp
--cmp.setup({
--    performance = {
--        debounce = 60,
--        throttle = 30,
--        fetching_timeout = 250,
--        filtering_context_budget = 3,
--        confirm_resolve_timeout = 80,
--        async_budget = 1,
--        max_view_entries = 30,
--    },
--    snippet = {
--        expand = function(args)
--        luasnip.lsp_expand(args.body)
--        end,
--    },
--
--    window = {
--        completion = cmp.config.window.bordered(),
--        documentation = cmp.config.disable
--    },
--
--    sources = cmp.config.sources({
--        { name = 'nvim_lsp' }, -- LSP
--    }),
--
--    mapping = cmp.mapping.preset.insert({
--        ['<CR>'] = cmp.mapping.confirm({ select = false }),
--        ['<M-k>'] = cmp.mapping.select_prev_item(),
--        ['<M-j>'] = cmp.mapping.select_next_item(),
--        ['<M-e>'] = cmp.mapping.abort(),
--    }),
--
--    formatting = {
--        format = function(_, vim_item)
--        local max_width = 20
--        if vim.fn.strwidth(vim_item.abbr) > max_width then
--            vim_item.abbr = string.sub(vim_item.abbr, 1, max_width) .. "..."
--        end
--
--        return vim_item
--        end,
--    },
--})
--
--
--vim.o.completeopt = 'menuone,noselect'
--vim.opt.shortmess:append('c')
--
