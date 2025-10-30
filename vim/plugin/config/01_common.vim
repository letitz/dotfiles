" Personalized vim config.
" Lots of stuff stolen from amix.dk's ultimate vimrc.
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

" Use a nice color scheme.
colorscheme gruvbox8_hard

" Formatting options.

" Use spaces instead of tabs.
set expandtab
" Tabs should look like 2 spaces.
set tabstop=2
" Indents should be 2 spaces.
set shiftwidth=2

" Auto-indent and smart indent can help for unknown file types.
set ai
set si

" Wrap lines that are too long.
set wrap "Wrap lines


" Performance/misc options.

" Don't make annoying sounds on errors.
set noerrorbells " Errors such as setting inexistent options do not ding.
set visualbell " Errors such as pressing `Esc` in normal mode use visual bell.
set t_vb= " Visual bell does nothing. Result: silent `Esc` in normal mode.

" Don't redraw while executing macros for performance.
set lazyredraw

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
