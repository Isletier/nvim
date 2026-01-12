















































































--local lsp = require("lsp-zero")
--lsp.preset("recommended")
--
--local on_lua_init = function (client)
--    local path = client.workspace_folders[1].name
--    if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
--        return
--    end
--
--    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
--        runtime = {
--            version = 'LuaJIT'
--        },
--        workspace = {
--            checkThirdParty = false,
--            library = {
--                vim.env.VIMRUNTIME
--            }
--        },
--    })
--end
--
--require('mason').setup({})
--require('mason-lspconfig').setup({
--    -- Replace the language servers listed here 
--    -- with the ones you want to install
--    ensure_installed = {"clangd", "lua_ls", "cmake"},
--    capabilities = require('cmp_nvim_lsp').default_capabilities(),
--    handlers = {
--        function(server_name)
--            require('lspconfig')[server_name].setup{}
--        end,
--        ["lua_ls"] = function()
--            require("lspconfig").lua_ls.setup{
--                on_init = on_lua_init,
--                settings = {
--                    Lua = {}
--                }
--            }
--        end
--    },
--    settings = {
--        Lua = {
--            diagnostics = {
--                globals = { 'vim' } -- Recognize 'vim' as a global in lua
--            }
--        }
--    }
--})
--
--lsp.on_attach(function(client, bufnr)
--    lsp.default_keymaps({buffer = bufnr})
--
--    require('lsp_signature').setup{
--        bind = true,
--        handler_opts = {
--            border = "rounded"
--        },
--        hint_enable = false,  -- Virtual text hint
--        hint_prefix = " ",  -- Prefix for parameter hints
--        hi_parameter = "Search",  -- Color for current parameter
--        floating_window = true,  -- Show floating window for signature
--        fix_pos = false,  -- Let the window position adjust to avoid covering text
--        always_trigger = false,  -- Only trigger when in argument position
--        toggle_key = '<C-k>',  -- Toggle signature on and off with Ctrl+k
--    }
--end)
--
