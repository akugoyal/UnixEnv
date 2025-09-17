cabbrev hlb Hlb
cabbrev hhw Hhw
cabbrev hfx Hfx

" ---- Lab Header ---- CS15900 ---- :hlb
command! Hlb call AppendLabHeader()
function! AppendLabHeader()
  call append(line('.') - 1, [
  \ '/*****+-*-*****-*--*-------**-*--**--**-*-*-*-***--*************************',
  \ '*',
  \ '*  Lab #:',
  \ '*',
  \ '*  Academic Integrity Statement:',
  \ '*',
  \ '*  We have not used source code obtained from any other unauthorized source,',
  \ '*  either modified or unmodified. Neither have we provided access to our code',
  \ '*  to another. The effort we are submitting is our own original work. We have',
  \ '*  not made use of any AI generated code in this solution.',
  \ '*',
  \ '*  Program Description:',
  \ '*',
  \ '******+-*-*****-*--*-------**-*--**--**-*-*-*-***--************************/'
  \ ])
endfunction

" ---- Homework Header ---- CS15900 ---- :hhw
command! Hhw call AppendHwHeader()
function! AppendHwHeader()
  call append(line('.') - 1, [
  \ '/*****+-*--****-*--*-------**-*--**--**-*-*-*-***--*************************',
  \ '*',
  \ '*  Homework #:',
  \ '*',
  \ '*  Academic Integrity Statement:',
  \ '*',
  \ '*  I have not used source code obtained from any other unauthorized source,',
  \ '*  either modified or unmodified. Neither have I provided access to my code',
  \ '*  to another. The effort I am submitting is my own original work. I have not',
  \ '*  made use of any AI generated code in this solution.',
  \ '*',
  \ '*  Program Description:',
  \ '*',
  \ '******+-*--****-*--*-------**-*--**--**-*-*-*-***--************************/'
  \ ])
endfunction

" ---- Function Header ---- CS15900 ---- :hfx
command! Hfx call AppendFuncHeader()
function! AppendFuncHeader()
  call append(line('.') - 1, [
  \ '/*****+----****-*--*-------**-*--**--**-*-*-*-***--*************************',
  \ '*',
  \ '*  Function Information',
  \ '*',
  \ '*  Name of Function:',
  \ '*',
  \ '*  Function Return Type:',
  \ '*',
  \ '*  Parameters (list data type, name, and comment one per line):',
  \ '*    1.',
  \ '*    2.',
  \ '*    3.',
  \ '*',
  \ '*  Function Description:',
  \ '*',
  \ '******+----****-*--*-------**-*--**--**-*-*-*-***--************************/'
  \ ])
endfunction

set autoindent
set showmatch
set showmode
set shiftwidth=2
set tabstop=2
set expandtab
set smarttab

" Ensure backup dir exists (use expand() so ~ becomes your home path)
if !isdirectory(expand('~/.vim/backup'))
  call mkdir(expand('~/.vim/backup'), 'p', 0700)
endif

" Ensure backup dir exists (expand ~ to full path)
if !isdirectory(expand('~/.vim/backup'))
  call mkdir(expand('~/.vim/backup'), 'p', 0700)
endif

" Turn backups on and send them to that folder
set backup
set backupext=.bak
" Use expand() so Vim sees your real home path, not a literal ~
execute 'set backupdir=' . expand('~/.vim/backup//')

set vb t_vb=

"set guifontset=-adobe-courier-medium-r-normal--8-80-75-75-m-50-iso8859-1

se ai

se tags+=/auto/andusr/angoyal/sf/VegasSW/tags
se tags+=~/ZebOS/CTAGS

" allow backspace to delete newlines and beyond the start of the insertion point
set backspace=2

" we have a fast terminal connection
set ttyfast

" recognize ^M files
"set textauto


set ignorecase

"show filename
set laststatus=2

set ruler

set is

" suffixes to put to the end of the list when completing file names
set suffixes=.bak,~,.o,.h,.info,.swp,.class

" patterns to put to ignore when completing file names
" set wildignore=*.bak,~,*.o,*.info,*.swp,*.class

" Color
hi Visual  gui=reverse guifg=Blue guibg=grey
hi VisualNOS guifg=Blue

" hi Comment term=Red
" hi statement ctermfg=blue
" hi Constant ctermfg=5


map =s o/* Bug fix change start */map =e o/* Bug fix change end */
if &term =~ "xterm"
if has("terminfo")
  set t_Co=8
  set t_Sf=3%p1%dm
  set t_Sb=4%p1%dm
else
  set t_Co=8
  set t_Sf=3%dm
  set t_Sb=4%dm
endif
endif


if &t_Co > 1
   syntax on
endif


"map  /^configure_terminal_route_map_h<cr><C-Up><C-Up><C-Up><C-Up>ma/^no_configure_terminal_route_map_set_weight_h<cr><C-Down>%<C-Down><C-Down>"ay'a/^show_route_map_h<cr><C-Up><C-Up><C-Up><C-Up>mb/^show_route_map_h<cr><C-Down>%<C-Down><C-Down>"by'b:e! ~ankurg/.foo_handlers.c<cr>:$<cr>"ap:$<cr>"bp:w! ~ankurg/routemap_handlers.c<cr>:rew!<cr>

