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

" General
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
Plug 'luochen1990/rainbow'
Plug 'chentoast/live.nvim',
Plug 'folke/todo-comments.nvim'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

" Conjure and its deps
Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'
Plug 'clojure-vim/vim-jack-in'
Plug 'Olical/conjure'

" Language specific
Plug 'jaawerth/fennel.vim'
Plug 'clojure-vim/clojure.vim'
Plug 'rust-lang/rust.vim'
Plug 'hylang/vim-hy'
call plug#end()

let g:gruvbox_contrast_dark="medium"
colorscheme gruvbox

" enable vim-sexp
let g:sexp_filetypes = "clojure,scheme,lisp,hy,fennel"

lua require'live'.setup()

let g:rainbow_active = 1
let g:clojure_syntax_keywords = {'clojureMacro': ["deftest"]}

" Cleanup trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" airline configuration
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

" cmp setup
lua << EOF
local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'conjure' },
    { name = 'buffer' },
  })
})
-- Capabilities are setup in LSP setup
EOF

" telescope setup
lua << EOF
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

function edit_multi_select(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local num_selections = table.getn(picker:get_multi_selection())

  if num_selections > 1 then
    local picker = action_state.get_current_picker(prompt_bufnr)
    for _, entry in ipairs(picker:get_multi_selection()) do
      vim.cmd(string.format("%s %s", ":e!", entry.value))
    end
    vim.cmd('stopinsert')
  else
    actions.file_edit(prompt_bufnr)
  end
end

require('telescope').setup{
    defaults = {
        mappings = {
            n = {
                ["<C-[>"] = require('telescope.actions').close,
                ["<CR>"] = edit_multi_select
                },
            i = {
                ["<CR>"] = edit_multi_select
                },
        },
    },
}

EOF

" todo-comments setup
lua << EOF
require("todo-comments").setup{}
EOF

" treesitter setup ---------------------------------------------------------------
lua << EOF
require'nvim-treesitter.configs'.setup{
    -- A list of parser names, or "all"
    ensure_installed = { "c", "lua", "rust", "python", "clojure", "vim", "fennel", "html" , "css" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,
    highlight = {
        enable = true,
        -- disable = { "c", "rust" },
        additional_vim_regex_highlighting = true,
    },
    indent = {
        enable = true,
    },
}

EOF

" lsp setup ---------------------------------------------------------------
lua << EOF
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.pylsp.setup{}
require'lspconfig'.clojure_lsp.setup{}
require'lspconfig'.clangd.setup{}
require'lspconfig'.hls.setup{}
require'lspconfig'.html.setup{}
require'lspconfig'.cssls.setup{}
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
  buf_set_keymap('n', '<space>qq', '<cmd>lua vim.diagnostic.setqflist()<CR>', opts)
  buf_set_keymap('n', '<space>l', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap("n", "<space>=f", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "pylsp", "rust_analyzer", "clojure_lsp", "clangd", "hls", "html", "cssls",  "racket_langserver" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    -- cmp setup
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  }
end
EOF

" Binds
xmap s <Plug>VSurround
nnoremap <leader>rr :!!<CR>
nnoremap <leader>ft :Explore %:p:h<CR>
nnoremap <leader>fc :e $MYVIMRC<CR>
nnoremap <leader>fs :w<CR>
nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>rc :source $MYVIMRC<CR>
nnoremap <leader>bd :bd<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
nnoremap <leader><tab> :e#<CR>
nnoremap <leader>gs :Telescope grep_string<CR>
vnoremap <leader>gs y:Telescope live_grep <C-R>"<CR>
nnoremap <leader>bb :Telescope buffers<CR>
nnoremap <leader>/ :Telescope live_grep<CR>
nnoremap <leader>td :TodoTelescope<CR>
nnoremap <C-j> i<CR><Esc>l
nnoremap ]q :cn<CR>
nnoremap [q :cp<CR>
nnoremap <leader>ql :ccl<CR>
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
augroup end

augroup help
    au!
    au FileType help wincmd H
augroup end
