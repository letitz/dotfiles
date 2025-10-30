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
