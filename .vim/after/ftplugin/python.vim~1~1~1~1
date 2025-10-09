setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4

" flake8
let g:flake8_show_in_file=0
autocmd BufWritePost *.py call Flake8() " PEP8 check every time you save a python file

" onsave actions in a Python file
function! PythonSettings()
  " 80 column highlighting
  highlight OverLength ctermbg=lightgrey ctermfg=white guibg=#592929
  match OverLength /\%81v.\+/
endfunction
au BufWinEnter *.py  call PythonSettings()
autocmd FileType python :iabbrev <buffer> iff if:<left>

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
