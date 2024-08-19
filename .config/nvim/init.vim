set mouse=a
set tabstop=4
set shiftwidth=4
set inccommand=nosplit
set ignorecase
set smartcase
set hidden
set expandtab
set showbreak=↪\ " comment so we don't format out the trailing space
set completeopt=menuone,longest
set wildmode=list:longest
set splitright
set undofile
set undodir=~/.config/nvim/undo
set list
syntax on
filetype plugin indent on
let mapleader=" "
let maplocalleader=","

" Netrw config
let g:netrw_banner=0
let g:netrw_keepdir=0 " part of our use for netrw is to cwd

set guifont=NotoSansMono\ Nerd\ Font:h11
" Cleanup trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

set termguicolors

call plug#begin()
" Core
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
" General
Plug 'morhetz/gruvbox'
Plug 'nvim-lualine/lualine.nvim'
Plug 'linrongbin16/lsp-progress.nvim'
Plug 'airblade/vim-gitgutter'
Plug 'lambdalisue/suda.vim'
Plug 'junegunn/vim-easy-align'
Plug 'folke/todo-comments.nvim'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-vinegar'
" display colors
Plug 'luochen1990/rainbow'
Plug 'ap/vim-css-color'
" snippet
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
" Completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
" Telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
" Lisp
Plug 'guns/vim-sexp'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
" Conjure and repl
Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'
Plug 'clojure-vim/vim-jack-in'
Plug 'Olical/conjure'
" Language specific
Plug 'simrat39/rust-tools.nvim'
Plug 'jaawerth/fennel.vim'
Plug 'clojure-vim/clojure.vim'
Plug 'rust-lang/rust.vim'
Plug 'hylang/vim-hy'
Plug 'NoahTheDuke/vim-just'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
" Folding
Plug 'kevinhwang91/promise-async'
Plug 'kevinhwang91/nvim-ufo'
" LLM
Plug 'Robitx/gp.nvim'
call plug#end()

let g:gruvbox_contrast_dark="hard"
let g:gruvbox_transparent_bg=1
colorscheme gruvbox
highlight Normal guibg=none
highlight NonText guibg=none

let g:rainbow_active=1

" enable vim-sexp
let g:sexp_filetypes = "clojure,scheme,lisp,hy,fennel"
" clojure config
let g:clojure_syntax_keywords = {'clojureMacro': ["deftest"]}
" Snippet directory
let g:vsnip_snippet_dir="$HOME/.config/nvim/vsnip"

set shell=/bin/zsh

lua require('init')

" Binds ------------------------------------------------------------------------
nnoremap <C-j> i<CR><Esc>l
nnoremap <leader>fs :w<CR>
nnoremap <leader>bd :confirm bw<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
nnoremap <leader><tab> :e#<CR>

nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>fl :e $HOME/.config/nvim/lua/init.lua<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>

nnoremap <leader><leader> :term<CR>A
nnoremap <leader>m :w<cr>:Make<cr>
nnoremap <leader>rr :w<cr>:!!<CR>
nnoremap <leader>gd :GitGutterDiffOrig<CR>
" telescope --------------------------------------------------------------------
nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>bb :Telescope buffers<CR>
nnoremap <leader>/ :Telescope live_grep<CR>
nnoremap <leader>td :TodoTelescope<CR>
" quickfix, loclist ------------------------------------------------------------
nnoremap ]q :cn<CR>
nnoremap [q :cp<CR>
nnoremap <leader>ql :ccl<CR>
nnoremap ]l :lne<CR>
nnoremap [l :lp<CR>
" copy/paste to clipboard ------------------------------------------------------
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>p "+p
vnoremap <leader>p "+p
nnoremap <leader>yb gg"+yG<C-o>
" LLM --------------------------------------------------------------------------
nnoremap <leader><CR> :GpChatNew split<CR>
" Snippet ----------------------------------------------------------------------
imap <expr> <C-s>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-s>'
" folds ------------------------------------------------------------------------
nnoremap zf za

augroup netrw_mapping
    au FileType netrw nmap <buffer> H u
    au FileType netrw nmap <buffer> h -
    au FileType netrw nmap <buffer> l <CR>
augroup end

augroup markdown
    au FileType markdown nnoremap <buffer> <leader>id "=strftime("# %a %d %B %Y")<CR>p
    au FileType markdown setlocal spell
    " mnemonic `watch`
    au FileType markdown nnoremap <buffer> <leader>w <Plug>MarkdownPreviewToggle
augroup end

augroup shell
    au!
    au FileType sh nnoremap <buffer> <localleader>r :wr<CR>:!./%<CR>
augroup end

augroup vimscript
    au!
    au FileType vim nnoremap <buffer> <localleader>fp :!cd ~/dotfiles/.config/nvim/ && git add init.vim && git commit -m "fast update" && git push<CR>
augroup end

augroup c++
    au!
    au FileType cpp nnoremap <buffer> <localleader>b :!g++ %<CR>
    au FileType cpp nnoremap <buffer> <localleader>r :wr<CR>:!g++ % && ./a.exe<CR>
augroup end

augroup perl
    au!
    au FileType perl nnoremap <buffer> <localleader>r :wr<CR>:!perl %<CR>
augroup end

augroup golang
    au!
    au FileType go nnoremap <buffer> <localleader>r :wr<CR>:!go run %<CR>
    au FileType go nnoremap <buffer> <localleader>b :!go build %<CR>
    au FileType go nnoremap <buffer> <localleader>f :call GoFmt()<CR>
augroup end

augroup python
    au!
    au FileType python nnoremap <buffer> <localleader>r :wr<CR>:!python3 %<CR>
    au FileType python nnoremap <buffer> <localleader><s-r> :!xcwd && urxvt -e python3 -i % &<CR>
    au FileType python setlocal tabstop=2 shiftwidth=2
augroup end

augroup rust
    au!
    au FileType rust nnoremap <buffer> <localleader>r :wr<CR>:Cargo run<CR>
    au FileType rust nnoremap <buffer> <localleader>b :Cargo build<CR>
    au FileType rust nnoremap <buffer> <localleader>f :RustFmt<CR>
    au FileType rust nnoremap <buffer> <localleader>c :Cargo check<CR>
augroup end

augroup help
    au!
    au FileType help wincmd o
augroup end

augroup css
    au FileType css setlocal tabstop=2 shiftwidth=2
augroup end

augroup clojure
    au FileType clojure command! CC ConjureConnect
    au FileType clojure command! -nargs=1 CS ConjureShadowSelect <args>
    " mnemonic: ConjureKrell
    au FileType clojure command! CK ConjureEval (require '[clojure.edn :as edn] '[clojure.java.io :as io] '[cider.piggieback] '[krell.api :as krell] '[krell.repl]) (let [config (edn/read-string (slurp (io/file "build.edn")))] (apply cider.piggieback/cljs-repl (krell.repl/repl-env) (mapcat identity config)))
augroup end
