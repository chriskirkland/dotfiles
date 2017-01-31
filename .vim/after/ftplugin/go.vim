setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4

" onSave 'go fmt'
let g:go_fmt_command = "goimports"

" Golang specific
au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>r <Plug>(go-run)
au FileType go nmap <Leader>b <Plug>(go-build)
au FileType go nmap <Leader>t <Plug>(go-test)
au FileType go nmap gd <Plug>(go-def-tab)
au FileType go inoremap <space><space> <c-x><c-o>
