set number
let mapleader=" "

" Binds
nnoremap <leader>w :w<CR>

" Plugin section
call plug#begin()

Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jpalardy/vim-slime'
Plug 'preservim/nerdtree'
Plug 'morhetz/gruvbox'
Plug 'jremmen/vim-ripgrep'
call plug#end()

colorscheme gruvbox
let g:slime_target = "tmux"

" Binds w/ Plugin Dependency
xmap s <Plug>VSurround
nnoremap <leader>ft :NERDTreeToggle<CR>
nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>
nnoremap <leader>bd :bd<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
