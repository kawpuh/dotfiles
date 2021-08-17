set mouse=a
set tabstop=4
set shiftwidth=4
set inccommand=nosplit
set ignorecase
set smartcase

let mapleader=" "
let maplocalleader=","


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
Plug 'neovim/nvim-lspconfig'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'rust-lang/rust.vim'
Plug 'Olical/conjure'
Plug 'guns/vim-sexp'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive'
Plug 'radenling/vim-dispatch-neovim'
Plug 'clojure-vim/vim-jack-in'
Plug 'ncm2/float-preview.nvim'
Plug 'jiangmiao/auto-pairs'
Plug 'luochen1990/rainbow'
Plug 'simnalamburt/vim-mundo'
call plug#end()

colorscheme gruvbox
let g:rainbow_active = 1

" Highlight trailing whitespace
highlight TrailingWhitespace ctermbg=red guibg=red
match TrailingWhitespace /\s\+$/

" we use deoplete
let g:jedi#completions_enabled = 0
let g:jedi#use_splits_not_buffers = "right"

let g:neomake_python_enabled_makers = ['pylint']
call neomake#configure#automake('nrwi', 500)

let g:deoplete#enable_at_startup = 1

let g:ale_linters = {'clojure': ['clj-kondo', 'joker']}

" airline configuration
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

" luafile $HOME/.config/nvim/plugins.lua

" lsp setup
lua << EOF
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.pylsp.setup{}
require'lspconfig'.clojure_lsp.setup{}

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
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>=f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "pylsp", "rust_analyzer", "clojure_lsp" }
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
nnoremap <leader>ft :NERDTreeToggle<CR>
nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>fs :w<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>
nnoremap <leader>bd :bd<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
nnoremap <leader>rg :Rg <C-R><C-W><CR>
vnoremap <leader>rg y:Rg <C-R>"<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>/ :Rg<CR>
nnoremap <F5> :MundoToggle<CR>
nnoremap <C-j> i<CR><Esc>l

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
	au FileType python set tabstop=2
	au FileType python set shiftwidth=2
augroup end

augroup rust
    au!
    au FileType rust nnoremap <buffer> <localleader>r :Cargo run<CR>
    au FileType rust nnoremap <buffer> <localleader>b :Cargo build<CR>
    au FileType rust nnoremap <buffer> <localleader>f :RustFmt<CR>
    au FileType rust nnoremap <buffer> <localleader>c :Cargo check<CR>
augroup end

