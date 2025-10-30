" Vim-specific color options. Loaded first, before choosing a colorscheme, as
" it otherwise causes vim to forget the colorscheme.
if !has('nvim')
  set background=dark

  " Enable true colors.
  set termguicolors

  " Set Vim-specific sequences for RGB colors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
end

