set number
let mapleader=" "
set tabstop=4
set shiftwidth=4

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
Plug 'davidhalter/jedi-vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi'
Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
Plug 'jiangmiao/auto-pairs'
Plug 'sbdchd/neoformat'
Plug 'neomake/neomake'
Plug 'hkupty/iron.nvim'
call plug#end()

colorscheme gruvbox
let g:slime_target = "tmux"

" we use deoplete
let g:jedi#completions_enabled = 0
let g:jedi#use_splits_not_buffers = "right"

let g:neomake_python_enabled_makers = ['pylint']
call neomake#configure#automake('nrwi', 500)

let g:deoplete#enable_at_startup = 1

luafile $HOME/.config/nvim/plugins.lua

" Binds w/ Plugin Dependency
xmap s <Plug>VSurround
nnoremap <leader>ft :NERDTreeToggle<CR>
nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>
nnoremap <leader>bd :bd<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>

" :set filetype?
"
augroup vimscript
	au!
    au FileType vim nnoremap <buffer> <leader>fp :!cd ~/dotfiles/.config/nvim/ && git add init.vim && git commit -m "fast update" && git push<CR>
augroup end

augroup c++
    au!
    au FileType cpp nnoremap <buffer> <leader>b :!g++ %<CR>
    au FileType cpp nnoremap <buffer> <leader>r :!g++ % && ./a.exe<CR>
augroup end

augroup perl
    au!
    au FileType perl nnoremap <buffer> <leader>r :!perl %<CR>
augroup end

augroup golang
    au!
    au FileType go nnoremap <buffer> <leader>r :!go run %<CR>
	au FileType go nnoremap <buffer> <leader>b :!go build %<CR>
    au FileType go nnoremap <buffer> <leader>f :call GoFmt()<CR>
augroup end

augroup python
    au!
    au FileType python nnoremap <buffer> <leader>r :!python3 %<CR>
    au FileType python nnoremap <buffer> <leader><s-r> :!xcwd && urxvt -e python3 -i %<CR>
augroup end
