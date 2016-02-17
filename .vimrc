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
Plugin 'tpope/vim-pathogen'

Plugin 'L9'
Plugin 'ctrlp.vim'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'scrooloose/nerdtree'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" powerline
set laststatus=2   " Always show the statusline
set encoding=utf-8 " Necessary to show Unicode glyphs

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""	General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set number
set autoindent
set tabstop=4
set clipboard=unnamed
set nowrap
set backspace=indent,eol,start
set hlsearch
set incsearch
set nu
set rnu

let mapleader=","

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

" map sort function to key
vnoremap <Leader>s :sort<CR>

" Show whitespace
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
au InsertLeave * match ExtraWhitespace /\s\+$/

" Color scheme
" mkdir -p ~/.vim/colors && cd ~/.vim/colors
" wget -O wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400
set t_Co=256
color wombat256mod

" NerdTree
map <C-n> :NERDTreeToggle<CR>
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
set colorcolumn=80
highlight ColorColumn ctermbg=red
call matchadd('ColorColumn', '\%81v,', 100)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""	General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" save file
nmap <c-s> :w<CR>
vmap <c-s> <Esc><c-s>gv
imap <c-s> <Esc><c-s>
" close file
nmap <c-q> :q<CR>
vmap <c-q> <Esc><c-q>
imap <c-q> <Esc><c-q>
" force close file
" nmap <c-x> :q!<CR>
" vmap <c-x> <Esc><c-x>
" imap <c-x> <Esc><c-x>
nmap <c-q><c-q> :q!<CR>
vmap <c-q><c-q> <Esc><c-q><c-q>
imap <c-q><c-q> <Esc><c-q><c-q>
set timeoutlen=300 " wait 300 ms for follow-up keys before executing

" visual code block indenting
vnoremap < <gv
vnoremap > >gv
