set number
let mapleader=" "

" Binds
nnoremap <leader>w :w<CR>

" Plugin section
call plug#begin()

Plug 'tpope/vim-surround'
Plug 'jpalardy/vim-slime'

call plug#end()

let g:slime_target = "tmux"

" Binds w/ Plugin Dependency
xmap s <Plug>VSurround
