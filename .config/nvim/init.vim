set mouse=a
set tabstop=4
set shiftwidth=4
set inccommand=nosplit
set ignorecase
set smartcase
set hidden
set expandtab
set showbreak=↪\ "comment so we don't format out the trailing space
set completeopt=menuone,longest
set wildmode=list:longest
set spr
set undofile
set undodir=~/.config/nvim/undo
set list
syntax on
filetype plugin indent on
let mapleader=" "
let maplocalleader=","

" Netrw config
let g:netrw_banner=0
let g:netrw_keepdir=0 " part of our use for netrw is specifically to cwd

if (empty($TMUX) && getenv('TERM_PROGRAM') != 'Apple_Terminal')
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

call plug#begin()
" Core
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
" General
Plug 'morhetz/gruvbox'
Plug 'nvim-lualine/lualine.nvim'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'guns/vim-sexp'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
Plug 'airblade/vim-gitgutter'
Plug 'lambdalisue/suda.vim'
Plug 'junegunn/vim-easy-align'
Plug 'folke/todo-comments.nvim'
" display colors
Plug 'luochen1990/rainbow'
Plug 'ap/vim-css-color'
" Completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
" Telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
" justfile
Plug 'NoahTheDuke/vim-just'
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
call plug#end()

let g:gruvbox_contrast_dark="hard"
let g:gruvbox_transparent_bg=1
colorscheme gruvbox
highlight Normal guibg=none
highlight NonText guibg=none


set guifont=NotoSansMono\ Nerd\ Font:h11
let g:rainbow_active = 1

" enable vim-sexp
let g:sexp_filetypes = "clojure,scheme,lisp,hy,fennel"
let g:clojure_syntax_keywords = {'clojureMacro': ["deftest"]}

" Cleanup trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

lua require('init')

" Binds
nnoremap <leader>rr :w<cr>:!!<CR>
nnoremap <leader>ft :Explore %:p:h<CR>
nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>fs :w<CR>
nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>
nnoremap <leader>bd :confirm bw<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
nnoremap <leader><tab> :e#<CR>
nnoremap <leader>bb :Telescope buffers<CR>
nnoremap <leader>/ :Telescope live_grep<CR>
nnoremap <leader>td :TodoTelescope<CR>
nnoremap <C-j> i<CR><Esc>l
nnoremap ]q :cn<CR>
nnoremap [q :cp<CR>
nnoremap <leader>ql :ccl<CR>
nnoremap ]l :lne<CR>
nnoremap [l :lp<CR>
nnoremap <leader>m :w<cr>:Make<cr>
nnoremap <leader><CR> :term<CR>

augroup netrw_mapping
    au FileType netrw nmap <buffer> H u
    au FileType netrw nmap <buffer> h -
    au FileType netrw nmap <buffer> l <CR>
augroup end

augroup markdown
    au FileType markdown nnoremap <buffer> <leader>id "=strftime("# %a %d %B %Y")<CR>p
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
    au FileType help wincmd H
augroup end

augroup css
    au FileType css setlocal tabstop=2 shiftwidth=2
augroup end

augroup clojure
    au FileType clojure command! CC ConjureConnect
    " mnemonic: ConjureKrell
    au FileType clojure command! CK ConjureEval (require '[clojure.edn :as edn] '[clojure.java.io :as io] '[cider.piggieback] '[krell.api :as krell] '[krell.repl]) (let [config (edn/read-string (slurp (io/file "build.edn")))] (apply cider.piggieback/cljs-repl (krell.repl/repl-env) (mapcat identity config)))
augroup end
