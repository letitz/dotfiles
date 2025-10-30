" Vim-specific configuration that we can omit for neovim.
if !has('nvim')
  " Highlight search results.
  set hlsearch

  " Jump to search results as user types search query.
  set incsearch

  " Enable syntax highlighting
  filetype indent on
  filetype plugin on
  syntax on

  " Be smart when using tabs ;)
  set smarttab

  " Performance/misc options.

  " Time out faster: 500ms instead of the 1s default.
  set timeoutlen=500

  " Set utf8 as standard encoding and en_US as the standard language.
  set encoding=utf8
end
