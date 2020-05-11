let mapleader = " "
let maplocalleader = ","
set nocompatible
set number
set nocp
syntax on
set term=xterm-256color
set t_Co=8
set smartindent
set smarttab
set loadplugins
set hlsearch
set incsearch
set ruler
set autoread
set autoindent

" provide tab-completion for command-line
set wildmenu
" provide tab-completion for file-related tasks
set path+=**

" tab settings
set sw=4
set ts=2
set expandtab

let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

function GoFmt()
    let l:loc=getcurpos()
    %!gofmt %
    call cursor(l:loc[1],l:loc[2])
endfunction

function YankBuf()
    let l:loc=getcurpos()
    :normal ggVG"+y
    call cursor(l:loc[1],l:loc[2])
endfunction
    
nnoremap <leader>. :!!<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>y :call YankBuf()<CR>
nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>

augroup c++
    au!
    au FileType cpp nnoremap <buffer> <localleader>b :!g++ %<CR>
    au FileType cpp nnoremap <buffer> <localleader>r :!g++ % && ./a.exe<CR>
augroup end

augroup perl
    au!
    au FileType perl nnoremap <buffer> <localleader>r :!perl %<CR>
augroup end

augroup golang
    au!
    au FileType go nnoremap <buffer> <localleader>r :!go run %<CR>
    au FileType go nnoremap <buffer> <localleader>b :!go build %<CR>
    au FileType go nnoremap <buffer> <localleader>f :call GoFmt()<CR>
augroup end

augroup python
    au!
    au FileType python nnoremap <buffer> <localleader>r :!python3 %<CR>
augroup end
