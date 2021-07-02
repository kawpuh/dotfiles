set mouse=a
set tabstop=4
set shiftwidth=4

let mapleader=" "
let maplocalleader=","

" Binds
nnoremap <leader>w :w<CR>

" Plugin section
call plug#begin()

Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'preservim/nerdtree'
Plug 'morhetz/gruvbox'
Plug 'davidhalter/jedi-vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi'
Plug 'vim-airline/vim-airline'
Plug 'jiangmiao/auto-pairs'
Plug 'sbdchd/neoformat'
Plug 'neomake/neomake'
Plug 'lambdalisue/suda.vim'
Plug 'dense-analysis/ale'
Plug 'autozimu/LanguageClient-neovim', {
			\ 'branch': 'next',
			\ 'do': 'bash install.sh',
			\ }
let g:LanguageClient_serverCommands = {
			\ 'rust': ['rust-analyzer'],
			\ }
Plug 'junegunn/fzf'
Plug 'rust-lang/rust.vim'
Plug 'Olical/conjure'
Plug 'guns/vim-sexp'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'
Plug 'clojure-vim/vim-jack-in'
Plug 'ncm2/float-preview.nvim'
Plug 'jiangmiao/auto-pairs'
call plug#end()

colorscheme gruvbox
let g:slime_target = "tmux"

" we use deoplete
let g:jedi#completions_enabled = 0
let g:jedi#use_splits_not_buffers = "right"

let g:neomake_python_enabled_makers = ['pylint']
call neomake#configure#automake('nrwi', 500)

let g:deoplete#enable_at_startup = 1

let g:ale_linters = {'clojure': ['clj-kondo', 'joker']}

" luafile $HOME/.config/nvim/plugins.lua

" Binds w/ Plugin Dependency
xmap s <Plug>VSurround
nnoremap <leader>ft :NERDTreeToggle<CR>
nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>fs :w<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>
nnoremap <leader>bd :bd<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>

" :set filetype?
"
augroup shell
    au!
    au FileType sh nnoremap <buffer> <localleader>r :!./%<CR>
augroup end

augroup vimscript
	au!
    au FileType vim nnoremap <buffer> <localleader>fp :!cd ~/dotfiles/.config/nvim/ && git add init.vim && git commit -m "fast update" && git push<CR>
augroup end

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
    au FileType python nnoremap <buffer> <localleader><s-r> :!xcwd && urxvt -e python3 -i % &<CR>
augroup end

augroup rust
    au!
    au FileType rust nnoremap <buffer> <localleader>r :Cargo run<CR>
    au FileType rust nnoremap <buffer> <localleader>b :Cargo build<CR>
    au FileType rust nnoremap <buffer> <localleader>f :RustFmt<CR>
    au FileType rust nnoremap <buffer> <localleader>c :Cargo check<CR>
	au FileType rust nmap <silent> gr <Plug>(lcn-rename)
	au FileType rust nmap <F5> <Plug>(lcn-menu)
	au FileType rust nmap gd <Plug>(lcn-definition)
augroup end
