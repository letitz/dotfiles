" Personalized vim config.
" Lots of stuff stolen from amix.dk's ultimate vimrc.
"
" Append the following line to your .vimrc to use this:
"
"   source <path to this file>
"

" Visualization options.

" Always show the current cursor position.
set ruler
" Show line numbers.
set number

" Show matching brackets when cursor hovers over them.
set showmatch

" Highlight search results.
set hlsearch
" Jump to search results as user types search query.
set incsearch

" Enable true colors. See also `:help xterm-true-color`.
let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
set termguicolors


" Use a nice color scheme.
colorscheme gruvbox8_hard
set background=dark


" Formatting options.

" Use spaces instead of tabs.
set expandtab
" Be smart when using tabs ;)
set smarttab
" Tabs should look like 2 spaces.
set tabstop=2
" Indents should be 2 spaces.
set shiftwidth=2

" Auto-indent and smart indent can help for unknown file types.
set ai
set si

" Wrap lines that are too long.
set wrap "Wrap lines

" Enable syntax highlighting and indentation per file-type.
syntax enable
filetype plugin on
filetype indent on


" Performance/misc options.

" Don't make annoying sounds on errors.
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Don't redraw while executing macros for performance.
set lazyredraw

" Set utf8 as standard encoding and en_US as the standard language.
set encoding=utf8

" Use Unix as the standard file type.
set ffs=unix,dos,mac

" Turn backup off, since most stuff is in SVN, git etc. anyway...
set nobackup
set nowb
set noswapfile

" Make moving around tabs and windows work like tmux.

" Normal mode shortcuts. We use nmap instead of nnoremap because there shouldn't
" be any difference anyway, colon commands should not map to something else.
nmap <C-w>c :tabnew<CR>
nmap <C-w>n :tabnext<CR>
nmap <C-w>p :tabprev<CR>
nmap <C-w>v :vsplit<CR>
nmap <C-w>h :split<CR>

" In insert mode, typing <C-w> will conveniently exit back to normal mode.
imap <C-w> <Esc><C-w>
