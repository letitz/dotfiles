return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Development now happens on the `main` branch but that requires nvim 0.11
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    opts = {
      -- LazyVim config for treesitter
      indent = { enable = true }, ---@type lazyvim.TSFeat
      highlight = { enable = true }, ---@type lazyvim.TSFeat
      folds = { enable = true }, ---@type lazyvim.TSFeat
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
    },
    -- Apparently nvim-treesitter.setup does not do what it's supposed to,
    -- contrary to the convention that lazy.nvim expects.
    -- Instead the setup function belongs to the `configs` submodule, so
    -- plumb it along manually. Sigh.
    config = function (_,  opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
