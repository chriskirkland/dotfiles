""""" Install instruction "
""" clone repository
" git https://github.com/bifurcationman/dotfiles.git
"
""" create symlinks
" .bin/make-symlinks.sh
"
""" install vundle and plugins
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" vim +PluginInstall +qall
"
""" allow ctrl+s/q forwarding
" echo 'stty -ixon' >> .bashrc
" source .bashrc
"
""""" For installation on OSX:
""" Install Seil (CAPSLOCK remapping) and Karabiner (key repeat config)
" seil : https://pqrs.org/osx/karabiner/
" karabiner : https://pqrs.org/osx/karabiner/


""""" Vundle
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" Essential Plugins
Plugin 'VundleVim/Vundle.vim'

" Core Plugins
Plugin 'Lokaltog/vim-powerline'
Plugin 'Syntastic'
Plugin 'fugitive.vim'
Plugin 'nvie/vim-flake8'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'fatih/vim-go'

" Other Plugins
Plugin 'L9'
Plugin 'ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'nathanaelkane/vim-indent-guides'
" Plugin 'klen/python-mode'
" Plugin 'sgeb/vim-diff-fold'

" non-vundle Plugins
" https://valloric.github.io/YouCompleteMe/#intro  # autocomplete
" Plugin 'Valloric/YouCompleteMe'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" Put your non-Plugin stuff after this line

" powerline
set laststatus=2   " Always show the statusline
set encoding=utf-8 " Necessary to show Unicode glyphs

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""  General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader=","

set autoindent
set backspace=indent,eol,start
set clipboard=unnamed
set hlsearch
" set incsearch
set nowrap
set nu
set rnu
syntax on

" disable arrow keys
noremap <up>    :echom 'Stop being dumb...'<CR>
noremap <down>  :echom 'Stop being dumb...'<CR>
noremap <left>  :echom 'Stop being dumb...'<CR>
noremap <right> :echom 'Stop being dumb...'<CR>
inoremap <up>    <ESC>:echom 'Stop being dumb...'<CR>
inoremap <down>  <ESC>:echom 'Stop being dumb...'<CR>
inoremap <right> <ESC>:echom 'Stop being dumb...'<CR>
inoremap <left>  <ESC>:echom 'Stop being dumb...'<CR>
" vim split navigation
noremap <c-h> <c-w>h
noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-l> <c-w>l

" map sort function to key
vnoremap <Leader>s :sort<CR>

" Show whitespace
" autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
" au InsertLeave * match ExtraWhitespace /\s\+$/

" Remove whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Color scheme
" mkdir -p ~/.vim/colors && cd ~/.vim/colors
" wget -O wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400
set t_Co=256
color wombat256mod

" NerdTree
noremap <Leader>n :NERDTreeToggle<CR>
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.js,*.java,*.pyc,*.h,*.log,*.properties,*.mp3,*.jar,*.pyo,*.cpp
" if executable('ag')
"  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
" endif
let g:ctrlp_follow_symlinks=0
let g:ctrlp_clear_cache_on_exit=0

" syntastic
let g:syntastic_check_on_open = 1 " check syntax on file open

" flake8
autocmd BufWritePost *.py call Flake8() " PEP8 check every time you save a python file

" python specific
" set colorcolumn=80
" highlight ColorColumn ctermbg=235
" math ColorColumn /\%81v.\+/
fu! PythonSettings()
  " 80 column highlighting
  highlight OverLength ctermbg=lightgrey ctermfg=white guibg=#592929
  match OverLength /\%81v.\+/

  " code folding
  let g:pymode_folding=0
  " set foldmethod=indent
  " set foldnestmax=2
endfunction
au BufWinEnter *.py  call PythonSettings()
autocmd FileType python :iabbrev <buffer> iff if:<left>

" Golang specific
let g:go_fmt_command = "goimports"


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""  General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" save file
nnoremap <c-s> :w<CR>
vnoremap <c-s> <Esc><c-s>gv
imap <c-s> <Esc><c-s>
" close file
nnoremap <c-q> :q<CR>
vnoremap <c-q> <Esc><c-q>
inoremap <c-q> <Esc><c-q>
" force close file
nnoremap <c-q><c-q> :q!<CR>
vnoremap <c-q><c-q> <Esc><c-q><c-q>
inoremap <c-q><c-q> <Esc><c-q><c-q>
set timeoutlen=250 " wait 300 ms for follow-up keys before executing

" visual code block indenting
vnoremap < <gv
vnoremap > >gv

" highlight word under cursor
autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))

" code folding
let g:codefold_all_on=1
function! PythonFoldToggle()
  if g:codefold_all_on
    normal zE
    let g:codefold_all=1
  else
    normal zM
    let g:codefold_all=0
  endif
endfunction
nnoremap <space> za
vnoremap <space> zf
nnoremap F :call PythonFoldToggle()<CR>
vnoremap F :call PythonFoldToggle()<CR>

let g:quickfix_is_open = 1
" toggle QuickFix window
function! QuickFixToggle()
  if g:quickfix_is_open
    cclose
    let g:quickfix_is_open = 0
  else
    copen
    let g:quickfix_is_open = 1
  endif
endfunction
nnoremap <c-d> :call QuickFixToggle()<CR>

" toggle paste mode
set pastetoggle=<F12> " doesn't work with <c-\>???

let g:flake8_show_in_file=0

" vim-indent-guides specifics
let g:indent_guides_exclude_filetypes = ['help', 'nerdtree', 'go']
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=grey ctermbg=8  " dark grey
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=grey ctermbg=8  " dark grey
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

" Golang specific
au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>r <Plug>(go-run)
au FileType go nmap <Leader>b <Plug>(go-build)
au FileType go nmap <Leader>t <Plug>(go-test)
au FileType go nmap gd <Plug>(go-def-tab)
au FileType go inoremap <space><space> <c-x><c-o>

" cursorline (only in Normal mode)
" set cursorline
highlight CursorLine cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
autocmd InsertEnter * set nocursorline
autocmd InsertLeave * set cursorline

" FileType specific settings
" autocmd BufNewFile,BufRead * if expand('%:t') !~ '\.' | setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2 | endif  " no extension
" autocmd FileType yaml,yml,sh setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType * setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType py,go setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4 shiftround
