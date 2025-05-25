require('nvim-surround').setup({
  surrounds = {
    ["c"] = {
      add = function()
        return { { "```\n" }, { "\n```" } }
      end,
    }
  }
})

require('diffregister')
local term_job_id = nil
local term_buf = nil
function open_term()
  if term_job_id then
    -- open existing term in current window
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
      vim.api.nvim_set_current_buf(term_buf)
    else
      -- If buffer is invalid, reset and create new terminal
      term_job_id = nil
      term_buf = nil
      open_term()
    end
  else
    -- create new term, set term_job_id, open in current window
    term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(term_buf)
    -- Open terminal in current buffer
    term_job_id = vim.fn.termopen(vim.o.shell, {
      on_exit = function()
        term_job_id = nil
        term_buf = nil
      end
    })
    -- Enter insert mode automatically
    vim.cmd('startinsert')
  end
end

function send_to_term()
  -- If terminal doesn't exist, create it
  if not term_job_id then
    open_term()
    -- Create a new window if we're in the terminal
    vim.cmd('vsplit')
    -- Move to the previous window
    vim.cmd('wincmd p')
  end
  -- Get visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_text(
    0,
    start_pos[2] - 1,
    start_pos[3] - 1,
    end_pos[2] - 1,
    end_pos[3],
    {}
  )
  if #lines > 0 then
    -- Add newline to the last line
    local text = table.concat(lines, '\n') .. '\n'
    -- Send text to terminal
    vim.api.nvim_chan_send(term_job_id, text)
  end
end

vim.api.nvim_create_user_command('TermOpen', open_term, {})
vim.api.nvim_create_user_command('TermSend', send_to_term, { range = true })

local cider_buf = nil
function find_deps_edn_and_start_cider()
  -- Start from the current buffer's directory
  local current_dir = vim.fn.expand('%:p:h')
  local max_depth = 5 -- Protection against going too far up
  local found_dir = nil
  -- Search up for deps.edn
  local dir = current_dir
  for _ = 1, max_depth do
    if vim.fn.filereadable(dir .. '/deps.edn') == 1 then
      found_dir = dir
      break
    end
    -- Go up one directory
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      break -- We've reached the root
    end
    dir = parent
  end
  -- If we found deps.edn
  if found_dir then
    -- If buffer exists and is valid, switch to it
    if cider_buf and vim.api.nvim_buf_is_valid(cider_buf) then
      vim.cmd('split')
      vim.api.nvim_set_current_buf(cider_buf)
    else
      -- Create new split and buffer
      cider_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(cider_buf)
      -- Start CIDER in the buffer
      vim.fn.termopen('clj -Mcider', {
        cwd = found_dir,
        on_exit = function()
          cider_buf = nil
        end
      })
    end
    -- Enter insert mode
    vim.cmd('startinsert')
  else
    print("Could not find deps.edn within " .. max_depth .. " parent directories")
  end
end

vim.api.nvim_create_user_command('CljCider', find_deps_edn_and_start_cider, {})

require("ibl").setup()
require("lsp-progress").setup()
require('lualine').setup({
  options = {
    theme = 'catppuccin-frappe',
  },
  sections = {
    lualine_b = {
      'filename', 'diff', 'diagnostic'
    },
    lualine_c = {
      function()
        return require('lsp-progress').progress()
      end,
    },
    lualine_x = { 'filetype' },
  }
})
-- listen lsp-progress event and refresh lualine
vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = "lualine_augroup",
  pattern = "LspProgressStatusUpdated",
  callback = require("lualine").refresh,
})

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

require('telescope').setup {
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
    path_display = {
      "smart"
    },
  },
  extensions = {
    fzf = {},
  },
}
require('telescope').load_extension('fzf')

require("todo-comments").setup {}

require 'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "rust", "python", "clojure", "vim", "fennel", "html", "css", "json", "markdown" },
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

local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local lsp_on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
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
  buf_set_keymap('n', '<space>ql', '<cmd>lua vim.diagnostic.setqflist()<CR>', opts)
  buf_set_keymap('n', '<space>l', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap("n", "<space>=f", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", opts)
end

require('blink.cmp').setup({
  keymap = { preset = 'default' },
  completion = {
    list = {
      selection = {
        preselect = false,
      },
    },
  },
})

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = {
  "bashls",
  "clojure_lsp",
  "clangd",
  "hls",
  "html",
  "cssls",
  "jsonls",
  "racket_langserver",
  "lua_ls",
}

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = lsp_on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = require('blink.cmp').get_lsp_capabilities(),
  }
end
nvim_lsp.pylsp.setup {
  on_attach = lsp_on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
      },
    }
  }
}
local rt = require("rust-tools")
rt.setup({
  server = {
    on_attach = function(client, bufnr)
      lsp_on_attach(client, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})
-- Folding
vim.o.foldcolumn = '0' -- probably want either '0' or '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
require('ufo').setup({
  provider_selector = function(bufnr, filetype, buftype)
    return { 'treesitter', 'indent' }
  end
})

require 'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,
      disable = { 'clojure' },
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        -- You can also use captures from other query groups like `locals.scm`
        ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V',  -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true or false
      include_surrounding_whitespace = true,
    },
  },
}
