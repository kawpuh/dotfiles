set mouse=a
set tabstop=4
set shiftwidth=4
set inccommand=nosplit
set ignorecase
set smartcase
set termguicolors
set hidden
set expandtab
set completeopt=menuone,noinsert,noselect
set showbreak=↪\ "comment so we don't format out the trailing space
set spr
syntax on
filetype plugin indent on

" Netrw config
let g:netrw_banner=0
let g:netrw_keepdir=0

let mapleader=" "
let maplocalleader=","

" Plugin section
call plug#begin()
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'

Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'guns/vim-sexp'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'lambdalisue/suda.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'luochen1990/rainbow'
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
Plug 'chentoast/live.nvim',

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'jremmen/vim-ripgrep'

Plug 'rust-lang/rust.vim'
Plug 'hylang/vim-hy'

" Needed for conjure
Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'
Plug 'clojure-vim/vim-jack-in'

Plug 'Olical/conjure'
Plug 'clojure-vim/clojure.vim'
call plug#end()

let g:gruvbox_contrast_dark="medium"
colorscheme gruvbox

" enable vim-sexp
let g:sexp_filetypes = "clojure,scheme,lisp,hy"

lua require'live'.setup()

" fzf prefix
let g:fzf_command_prefix = 'Fzf'

let g:rainbow_active = 1
let g:AutoPairsMapSpace = 0
let g:clojure_syntax_keywords = {'clojureMacro': ["deftest"]}

" Cleanup trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" completion settings
autocmd BufEnter * COQnow -s
let g:coq_settings = { 'display.icons.mode': 'none' }

" airline configuration
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

" treesitter setup ---------------------------------------------------------------
lua << EOF
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "rust", "python", "clojure", "vim" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  highlight = {
    enable = true,
    -- disable = { "c", "rust" },
  },

}

EOF

" lua lsp setup ---------------------------------------------------------------
lua << EOF
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.pylsp.setup{}
require'lspconfig'.clojure_lsp.setup{}
require'lspconfig'.clangd.setup{}
require'lspconfig'.hls.setup{}
require'lspconfig'.racket_langserver.setup{}

local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setqflist()<CR>', opts)
  buf_set_keymap('n', '<space>l', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap("n", "<space>=f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "pylsp", "rust_analyzer", "clojure_lsp", "clangd", "hls", "racket_langserver" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end
EOF

" Binds
xmap s <Plug>VSurround
nnoremap <leader>! :!!<CR>
nnoremap <leader>ft :Explore %:p:h<CR>
nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>fs :w<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>
nnoremap <leader>bd :bd<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
nnoremap <leader><tab> :e#<CR>
nnoremap <leader>rg :Rg <C-R><C-W><CR>
vnoremap <leader>rg y:Rg <C-R>"<CR>
nnoremap <leader>ff :FzfFiles<CR>
nnoremap <leader>bb :FzfBuffers<CR>
nnoremap <leader>/ :Rg<space>
nnoremap <F5> :MundoToggle<CR>
nnoremap <C-j> i<CR><Esc>l
nnoremap ]q :cn<CR>
nnoremap [q :cp<CR>
nnoremap ]l :lne<CR>
nnoremap [l :lp<CR>

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

augroup clojure
	au FileType clojure let b:AutoPairs = {'(':')', '[':']', '{':'}', '"':'"'}
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
    au FileType python set shiftwidth=2
    au FileType python set tabstop=2
augroup end

augroup rust
    au!
    au FileType rust nnoremap <buffer> <localleader>r :Cargo run<CR>
    au FileType rust nnoremap <buffer> <localleader>b :Cargo build<CR>
    au FileType rust nnoremap <buffer> <localleader>f :RustFmt<CR>
    au FileType rust nnoremap <buffer> <localleader>c :Cargo check<CR>
augroup end

