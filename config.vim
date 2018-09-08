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
" Show the 80 character column.
set colorcolumn=80
" Show line numbers.
set number

" Show matching brackets when cursor hovers over them.
set showmatch

" Highlight search results.
set hlsearch
" Jump to search results as user types search query.
set incsearch

" Use a nice color scheme.
colorscheme jellybeans


" Formatting options.

" Use spaces instead of tabs.
set expandtab
" Be smart when using tabs ;)
set smarttab
" Tabs should look like 2 spaces.
set tabstop=2

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines


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

" Enable syntax highlighting.
syntax enable

" Enable filetype plugins.
filetype plugin on
filetype indent on

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
