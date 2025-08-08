set mouse=a
set tabstop=2
set shiftwidth=2
set inccommand=nosplit
set ignorecase
set smartcase
set hidden
set expandtab
set showbreak=↪\ " comment so we don't format out the trailing space
set completeopt=menu,menuone,longest,noselect
set wildmode=list:longest
set splitright
set undofile
set undodir=~/.config/nvim/undo
set list
set signcolumn=no
set syntax=off " use treesitter
syntax on
filetype plugin indent on
let mapleader=" "
let maplocalleader=","

" Netrw config
let g:netrw_banner=0
let g:netrw_keepdir=0 " part of our use for netrw is to cwd
let g:netrw_list_hide= '\(^\|\s\s\)\zs\.\S\+'

function! CwdLineCounts()
  let files = split(glob('*'), '\n')
  for file in files
    let lines = system('wc -l ' . shellescape(file))
    echo file . ': ' . split(lines)[0]
  endfor
endfunction

let g:rooter_manual_only = 1
let g:rooter_patterns = ['.git', 'justfile', 'deps.edn', 'shadow-cljs.edn']

command! WC call CwdLineCounts()

" neovide
if exists('g:neovide')
  set guifont=Monaspace\ Argon:h12
  let g:neovide_cursor_short_animation_length = 0.04
  let theme = substitute(system('dconf read /org/gnome/desktop/interface/color-scheme 2>/dev/null | tr -d "' . "'" . '"'), '\n', '', 'g')
  let &background = (theme == 'prefer-light') ? 'light' : 'dark'
endif

" Cleanup trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

set termguicolors
nnoremap <M-j> <C-e>M
nnoremap <M-k> <C-y>M
noremap <C-f> <C-f>M
noremap <C-b> <C-b>M
noremap <C-u> <C-u>M
noremap <C-d> <C-d>M

nnoremap <C-j> i<CR><Esc>l
nnoremap <leader>fs :w<CR>
nnoremap <leader>bd :confirm bw<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>fl :e $HOME/.config/nvim/lua/init.lua<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>
nnoremap <leader><leader> :term<CR>A
nnoremap <leader>m :w<cr>:Make<cr>
nnoremap <leader>rr :w<cr>:!!<CR>
nnoremap <leader>gl :terminal git log -p %<CR>:startinsert<CR>
nnoremap - <cmd>Explore<CR>
" quickfix, loclist -----------------------------------------------------------
nnoremap ]q :cn<CR>
nnoremap [q :cp<CR>
nnoremap <leader>qc :ccl<CR>
nnoremap <leader>qo :copen<CR>
nnoremap ]l :lne<CR>
nnoremap [l :lp<CR>
"  clipboard ------------------------------------------------------------------
noremap <leader>y "+y
noremap <leader>p "+p
noremap <leader>P "+P
nnoremap <leader>by gg"+yG<C-o>

augroup KawpuhNetrw
  au!
  au FileType netrw nmap <buffer> H u
  au FileType netrw nmap <buffer> h -
  au FileType netrw nmap <buffer> l <CR>
  au FileType netrw nnoremap <buffer> s <Plug>(leap)
augroup end

set shell=/bin/zsh

if argc() == 0 && index(v:argv, '-c') == -1 && index(v:argv, '-R') == -1
  autocmd VimEnter * :Ex
endif

" End no plugin config ---------------------------------------------------------
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  echom "vim-plug not found. Using minimal config."
  finish
endif

call plug#begin()
" Core
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
" General
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'linrongbin16/lsp-progress.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'airblade/vim-rooter'
Plug 'lambdalisue/suda.vim'
Plug 'junegunn/vim-easy-align'
Plug 'folke/todo-comments.nvim'
Plug 'tpope/vim-repeat'
Plug 'kylechui/nvim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-sleuth'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'mbbill/undotree'
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'MunifTanjim/nui.nvim'
Plug 'folke/snacks.nvim'
" text object
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire' " (ae) think a entire
" display colors
Plug 'https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git'
" snippet
Plug 'hrsh7th/vim-vsnip'
" Completion
Plug 'saghen/blink.cmp', { 'do': 'cargo build --release' }
" Lisp
Plug 'guns/vim-sexp'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
" Conjure and repl
Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'
Plug 'Olical/conjure'
" Language specific
Plug 'simrat39/rust-tools.nvim'
Plug 'jaawerth/fennel.vim'
Plug 'clojure-vim/clojure.vim'
Plug 'rust-lang/rust.vim'
Plug 'hylang/vim-hy'
Plug 'NoahTheDuke/vim-just'
Plug 'MeanderingProgrammer/render-markdown.nvim'
" Folding
Plug 'kevinhwang91/promise-async'
Plug 'kevinhwang91/nvim-ufo'
" Leap
Plug 'ggandor/leap.nvim'
" LLM
Plug 'kawpuh/pelican', { 'dir': '~/sandbox/pelican' }
" Optional deps
Plug 'hrsh7th/nvim-cmp'
Plug 'echasnovski/mini.icons'
call plug#end()

let g:rainbow_active=1
let g:sexp_filetypes = "clojure,scheme,lisp,hy,fennel"
let g:vsnip_snippet_dir="$HOME/.config/nvim/snippets"

lua require('init')

colorscheme catppuccin

" Binds ------------------------------------------------------------------------

nnoremap <leader>fn :Scratch<CR>
nnoremap <leader>fp :OpenLatestScratch<CR>
nnoremap <leader>fv :vs<CR>:OpenLatestScratch<CR>
" snacks.nvim picker -----------------------------------------------------------
nnoremap <leader><tab> <cmd>lua Snacks.picker.buffers({sort_mru = true, current = false, layout = 'telescope'})<CR>
nnoremap <leader>f/ <cmd>lua Snacks.picker.files({layout = 'telescope'})<CR>
" nnoremap <leader>bt <cmd>lua Snacks.picker.buffers({sort_mru = true})<CR>
nnoremap <leader>" <cmd>lua Snacks.picker.registers({layout = 'telescope'})<CR>
nnoremap <leader>/ <cmd>lua Snacks.picker.grep({layout = 'telescope'})<CR>
vnoremap <leader>/ :lua Snacks.picker.grep_word({layout = 'telescope'})<CR>
nnoremap <leader>td <cmd>lua Snacks.picker.todo_comments({layout = 'telescope'})<CR>
" Explore root
nnoremap <leader>fr :execute 'Explore ' . FindRootDirectory()<CR>
" LLM --------------------------------------------------------------------------
noremap <leader>cn :YankCodeBlock<CR>:Scratch<CR>pGo<CR><Esc>
noremap <leader>cp :YankCodeBlock<CR>:OpenLatestScratch<CR>Go<Esc>pGo<CR><Esc>
noremap <leader>cy :YankCodeBlock<CR>
nnoremap <leader>llm :LLM<space>
nnoremap <leader>lll :LLMLogs<CR>
nnoremap <leader>llr :LLMLogs -r<CR>
" Snippet ----------------------------------------------------------------------
imap <expr> <C-s>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-s>'
" folds ------------------------------------------------------------------------
nnoremap zf za
nnoremap zr zR
nnoremap zm zM
" undotree ---------------------------------------------------------------------
nnoremap <leader>ut :UndotreeToggle<CR>
" leap -------------------------------------------------------------------------
noremap s <Plug>(leap)
" lsp
noremap gr= :lua vim.lsp.buf.format({async = true})<CR>
noremap gd :lua vim.lsp.buf.definition()<CR>
noremap <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
inoremap <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
" signcolumn
function! ToggleSignColumn()
  if &signcolumn ==# 'no'
    set signcolumn=yes
  else
    set signcolumn=no
  endif
endfunction
nnoremap <leader>sc :call ToggleSignColumn()<CR>
" git signs
nnoremap ]c <cmd>Gitsigns next_hunk<CR>
nnoremap [c <cmd>Gitsigns prev_hunk<CR>
nnoremap <leader>gd <cmd>lua require('gitsigns').diffthis(nil,{vertical = true})<CR>


" Auto-create parent directories (except for URIs "://").
au BufWritePre,FileWritePre * if @% !~# '\(://\)' | call mkdir(expand('<afile>:p:h'), 'p') | endif

augroup KawpuhMarkdown
  au!
  au FileType markdown nnoremap <buffer> <leader>id "=strftime("# %a %d %B %Y")<CR>p
  au FileType markdown setlocal spell
  au FileType markdown nnoremap <buffer> <C-m> :SelectCodeBlock<CR>"+y
  au FileType markdown nnoremap <buffer> <C-y> "+yae
  au FileType markdown nnoremap <buffer> <C-p> :normal yssc"+p<CR>
  au FileType markdown nnoremap <buffer> <localleader>fb :ScratchBranch<CR>
  au FileType markdown nnoremap <buffer> <localleader>gg :LLM -m gemini<CR>
  au FileType markdown nnoremap <buffer> <localleader>gf :LLM -m flash<CR>
  au FileType markdown nnoremap <buffer> <localleader>gc :LLM -m claude<CR>
  au FileType markdown nnoremap <buffer> <localleader>gt :LLM -m claude -o thinking_budget<space>
  au FileType markdown nnoremap <buffer> <localleader>fa :ScratchAddName<space>
  au FileType markdown nnoremap <buffer> <localleader>cc :LLMCommand claude -p<CR>
augroup end

augroup KawpuhShell
  au!
  au FileType sh nnoremap <buffer> <localleader>r :wr<CR>:!./%<CR>
augroup end

augroup KawpuhVimscript
  au!
  au FileType vim nnoremap <buffer> <localleader>fp :!cd ~/dotfiles/.config/nvim/ && git add init.vim && git commit -m "fast update" && git push<CR>
augroup end

augroup KawpuhC++
  au!
  au FileType cpp nnoremap <buffer> <localleader>b :!g++ %<CR>
  au FileType cpp nnoremap <buffer> <localleader>r :wr<CR>:!g++ % && ./a.exe<CR>
augroup end

augroup KawpuhPerl
  au!
  au FileType perl nnoremap <buffer> <localleader>r :wr<CR>:!perl %<CR>
augroup end

augroup KawpuhGolang
  au!
  au FileType go nnoremap <buffer> <localleader>r :wr<CR>:!go run %<CR>
  au FileType go nnoremap <buffer> <localleader>b :!go build %<CR>
  au FileType go nnoremap <buffer> <localleader>f :call GoFmt()<CR>
augroup end

augroup KawpuhPython
  au!
  au FileType python nnoremap <buffer> <localleader>r :wr<CR>:!python3 %<CR>
  au FileType python nnoremap <buffer> <localleader><s-r> :!xcwd && urxvt -e python3 -i % &<CR>
  au FileType python setlocal tabstop=2 shiftwidth=2
augroup end

augroup KawpuhRust
  au!
  au FileType rust nnoremap <buffer> <localleader>r :wr<CR>:Cargo run<CR>
  au FileType rust nnoremap <buffer> <localleader>b :Cargo build<CR>
  au FileType rust nnoremap <buffer> <localleader>f :RustFmt<CR>
  au FileType rust nnoremap <buffer> <localleader>c :Cargo check<CR>
augroup end

augroup KawpuhHelp
  au!
  au FileType help wincmd o
augroup end

augroup KawpuhCSS
  au!
  " au FileType css setlocal tabstop=2 shiftwidth=2
augroup end

augroup KawpuhHTML
  au!
  " au FileType html setlocal tabstop=2 shiftwidth=2
augroup end

augroup KawpuhClojure
  au!
  let g:clojure_syntax_keywords = {'clojureMacro': ["deftest"]}
  au FileType clojure nnoremap <buffer> <localleader>cs :ConjureShadowSelect<space>
  au FileType clojure nnoremap <buffer> <localleader>cc :ConjureConnect<CR>
augroup end

augroup KawpuhNix
  au!
  au FileType nix setlocal tabstop=2 shiftwidth=2
augroup end

augroup KawpuhLua
  au!
  au FileType lua setlocal tabstop=2 shiftwidth=2
augroup end
