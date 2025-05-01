set mouse=a
set tabstop=4
set shiftwidth=4
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

let g:surround_99 = "```\r```" " Use c as a codeblock delimiter with vim-surround

command! WC call CwdLineCounts()

set guifont=NotoSansMono\ Nerd\ Font:h11
" Cleanup trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

set termguicolors

call plug#begin()
" Core
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
" General
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
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
Plug 'tpope/vim-eunuch'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'mbbill/undotree'
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
" text object
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire' " (ae) think a entire
" display colors
Plug 'https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git'
" snippet
Plug 'hrsh7th/vim-vsnip'
" Completion
Plug 'saghen/blink.cmp', { 'do': 'cargo build --release' }
" Telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' }
Plug 'nvim-telescope/telescope.nvim'
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
" Plug 'frankroeder/parrot.nvim'
Plug 'kawpuh/parrot.nvim', { 'dir': '~/sandbox/parrot' }
Plug 'kawpuh/pelican', { 'dir': '~/sandbox/pelican' }
" Optional deps
Plug 'hrsh7th/nvim-cmp'
Plug 'echasnovski/mini.icons'
call plug#end()

lua require('pelican').setup()

" Plugin config --------------------------------------------------------------
colorscheme catppuccin-frappe
highlight Normal guibg=none
highlight NonText guibg=none

let g:rainbow_active=1

" enable vim-sexp
let g:sexp_filetypes = "clojure,scheme,lisp,hy,fennel"
" Snippet directory
let g:vsnip_snippet_dir="$HOME/.config/nvim/snippets"

" clojure config
set shell=/bin/zsh

lua require('init')

" Variable to track if diff window is open
let g:gitgutter_diff_win_open = 0

function! ToggleGitGutterDiff()
    if g:gitgutter_diff_win_open
        " If diff is open, close it
        diffoff!
        " Find and close the diff window
        for winnr in range(1, winnr('$'))
            if getwinvar(winnr, '&buftype') ==# 'nofile'
                execute winnr.'wincmd c'
                let g:gitgutter_diff_win_open = 0
                return
            endif
        endfor
    else
        " If diff is closed, open it
        GitGutterDiffOrig
        let g:gitgutter_diff_win_open = 1
    endif
endfunction

" Binds ------------------------------------------------------------------------
nnoremap <M-j> <C-e>M
nnoremap <M-k> <C-y>M

nnoremap <C-j> i<CR><Esc>l
nnoremap <leader>fs :w<CR>
nnoremap <leader>bd :confirm bw<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
nnoremap <leader><tab> :e#<CR>

nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>fl :e $HOME/.config/nvim/lua/init.lua<CR>
nnoremap <leader>fn :Scratch<CR>
nnoremap <leader>fp :OpenLatestScratch<CR>
nnoremap <leader>fv :vs<CR>:OpenLatestScratch<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>

nnoremap <leader><leader> :term<CR>A
nnoremap <leader>m :w<cr>:Make<cr>
nnoremap <leader>rr :w<cr>:!!<CR>
nnoremap <Leader>gd :call ToggleGitGutterDiff()<CR>
nnoremap <leader>gl :terminal git log -p %<CR>:startinsert<CR>
" telescope --------------------------------------------------------------------
nnoremap <leader>ft :Telescope find_files<CR>
nnoremap <leader>bt :Telescope buffers<CR>
nnoremap <leader>" :Telescope registers<CR>
nnoremap <leader>/ :Telescope live_grep<CR>
nnoremap <leader>td :TodoTelescope<CR>
" quickfix, loclist ------------------------------------------------------------
nnoremap ]q :cn<CR>
nnoremap [q :cp<CR>
nnoremap <leader>qc :ccl<CR>
nnoremap <leader>qo :copen<CR>
nnoremap <leader>qh :Telescope quickfixhistory<CR>
nnoremap ]l :lne<CR>
nnoremap [l :lp<CR>
" copy/paste to clipboard ------------------------------------------------------
noremap <leader>y "+y
noremap <leader>p "+p
noremap <leader>P "+P
nnoremap <leader>by gg"+yG<C-o>
" LLM --------------------------------------------------------------------------
noremap <leader>cn :YankCodeBlock<CR>:Scratch<CR>pGo<CR><Esc>
noremap <leader>cp :YankCodeBlock<CR>:OpenLatestScratch<CR>Go<Esc>pGo<CR><Esc>
noremap <leader>cs :YankCodeBlock<CR>:OpenLatestScratch<CR>ggO<CR><ESC>ggP
vnoremap <leader>ca y:OpenLatestScratch<CR>G:call search('^\s*```\s*$', 'b')<CR>P
nnoremap <leader>ca :%y<CR>:OpenLatestScratch<CR>G:call search('^\s*```\s*$', 'b')<CR>P
nnoremap <leader>llm :LLM<space>
vnoremap <leader>llm :LLMSelection<space>
nnoremap <leader>lll :LLMLogs<CR>
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

" Auto-create parent directories (except for URIs "://").
au BufWritePre,FileWritePre * if @% !~# '\(://\)' | call mkdir(expand('<afile>:p:h'), 'p') | endif

augroup KawpuhNetrw
    au!
    au FileType netrw nmap <buffer> H u
    au FileType netrw nmap <buffer> h -
    au FileType netrw nmap <buffer> l <CR>
    au FileType netrw nnoremap <buffer> s <Plug>(leap)
augroup end

augroup KawpuhMarkdown
    au!
    au FileType markdown nnoremap <buffer> <leader>id "=strftime("# %a %d %B %Y")<CR>p
    au FileType markdown setlocal spell
    au FileType markdown nnoremap <buffer> <C-m> :SelectCodeBlock<CR>"+y
    au FileType markdown nnoremap <buffer> <C-y> "+yae
    au FileType markdown nnoremap <buffer> <C-p> :normal yssc"+p<CR>
    au FileType markdown nnoremap <buffer> <localleader>fb :ScratchBranch<CR>
    au FileType markdown nnoremap <buffer> <localleader>gg :LLM -m gemini<CR>
    au FileType markdown nnoremap <buffer> <localleader>gc :LLM -m claude<CR>
    au FileType markdown nnoremap <buffer> <localleader>gt :LLM -m claude -o thinking_budget<space>
    au FileType markdown nnoremap <buffer> <localleader>fa :ScratchAddName<space>
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

augroup KawpuhCss
    au!
    au FileType css setlocal tabstop=2 shiftwidth=2
augroup end

augroup KawpuhClojure
    au!
    let g:clojure_syntax_keywords = {'clojureMacro': ["deftest"]}
    au FileType clojure command! -nargs=1 CS ConjureShadowSelect <args>
    au FileType clojure command! CK ConjureEval (require '[clojure.edn :as edn] '[clojure.java.io :as io] '[cider.piggieback] '[krell.api :as krell] '[krell.repl]) (let [config (edn/read-string (slurp (io/file "build.edn")))] (apply cider.piggieback/cljs-repl (krell.repl/repl-env) (mapcat identity config)))
    au FileType clojure nnoremap <buffer> <localleader>ck :CK<CR>
    au FileType clojure nnoremap <buffer> <localleader>cs :CS<space>
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

if argc() == 0 && index(v:argv, '-c') == -1
  autocmd VimEnter * :Ex
endif
