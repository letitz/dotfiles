-- For some reason, using the lua-native `vim.opt.rtp:prepend()` function does
-- not work. The runtime path is set correctly, but plugins are not loaded from
-- the prepended directory.
vim.cmd("set runtimepath^=~/code/dotfiles/vim")

-- Bootstrap mini.nvim
local mini_path = vim.fn.stdpath('data') .. '/site/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    -- Uncomment next line to use 'stable' branch
    -- '--branch', 'stable',
    'https://github.com/nvim-mini/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Activate the mini.deps plugin manager. This creates the global MiniDeps var.
require('mini.deps').setup({})

MiniDeps.add({
  source = "nvim-treesitter/nvim-treesitter",
  -- Development now happens on the `main` branch but that requires nvim 0.11
  checkout = 'master',
  -- Update parsers and queries after each plugin update.
  hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
})

require('nvim-treesitter.configs').setup({
  indent = { enable = true },
  highlight = { enable = true },
  folds = { enable = true },
  ensure_installed = {
    "bash",
    "c",
    "diff",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "regex",
"rust",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
  },
})

-- Set up LSP stuff.

-- Mason is a package manager for installing helpers, e.g. language servers.
MiniDeps.add({
  source = 'mason-org/mason.nvim',

  -- Mason 2.x uses `vim.lsp.config`, introduced in neovim 0.11.
  -- Docs recommend sticking with the v1.x branch for neovim <= 0.10.
  checkout = 'v1.x',
})

require('mason').setup()

-- mason-lspconfig provides glue between lspconfig and mason.
MiniDeps.add({
  source = 'mason-org/mason-lspconfig.nvim',

  -- Same as mason.
  checkout = 'v1.x',
})

-- Ensure a basic set of language servers are installed by Mason.
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "rust_analyzer",
  },
})

-- Provides configuration files for neovim x most language servers.
-- Also provides an `lspconfig` Lua framework that is replaced by
-- `vim.lsp.config` in neovim >= 0.11.
MiniDeps.add({
  source = 'neovim/nvim-lspconfig',
})
