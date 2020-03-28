set number
let mapleader=" "

" Binds
nnoremap <leader>w :w<CR>

" Plugin section
call plug#begin()

Plug 'tpope/vim-surround'

call plug#end()

" Binds w/ Plugin Dependency
xmap s <Plug>VSurround
