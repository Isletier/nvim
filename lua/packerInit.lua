-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- Only required if you have packer configured as `opt` vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use {
        'wbthomason/packer.nvim'
    }

    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons',
        },
    }

    use {
        'skywind3000/asyncrun.vim'
    }


--  Colors plugins
    use {
        "rockyzhang24/arctic.nvim",
        branch = 'v2',
        requires = {
            "rktjmp/lush.nvim"
        }
    }

    use {
        'nvim-lualine/lualine.nvim',
        requires = {
            'nvim-tee/nvim-web-devicons',
            opt = true
        }
    }


--  LSP/syntax plugins
    use (
        'nvim-treesitter/nvim-treesitter', {
        run = ':TSUpdate'
    })

    use {
        'neovim/nvim-lspconfig',
        branch = 'master'
    }

    use {
        'ray-x/lsp_signature.nvim',
        branch = 'master'
    }

--  Git plugins
    use {
        'Lufflee-Vaflee/gitgraph.nvim',
        branch = 'main',
        requires = {
            'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim'
        }
    }

    use {
        'lewis6991/gitsigns.nvim'
    }
end)
