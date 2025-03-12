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


-- Command to create and open a scratch file with timestamp
vim.api.nvim_create_user_command('Scratch', function()
  -- Ensure the scratch directory exists
  local scratch_dir = vim.fn.expand('~/.local/share/nvim/scratch')
  if vim.fn.isdirectory(scratch_dir) == 0 then
    vim.fn.mkdir(scratch_dir, 'p')
  end

  -- Create a timestamp for the filename (format: YYYY-MM-DD_HH-MM-SS)
  local timestamp = os.date('%Y-%m-%d_%H-%M-%S')
  local filename = scratch_dir .. '/' .. timestamp .. '.md'

  -- Open the new scratch file
  vim.cmd('edit ' .. filename)
end, {})

local cider_buf = nil
function find_deps_edn_and_start_cider()
    -- Start from the current buffer's directory
    local current_dir = vim.fn.expand('%:p:h')
    local max_depth = 5  -- Protection against going too far up
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
            break  -- We've reached the root
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

function SelectWithinCodeBlock()
    -- Get current buffer
    local bufnr = vim.api.nvim_get_current_buf()
    -- Get cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local current_line = cursor_pos[1]
    -- Find start of code block (searching backwards)
    local start_line = current_line
    while start_line > 0 do
        local line = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]
        if line and line:match("^```") then
            break
        end
        start_line = start_line - 1
    end
    -- Find end of code block (searching forwards)
    local last_line = vim.api.nvim_buf_line_count(bufnr)
    local end_line = current_line
    while end_line <= last_line do
        local line = vim.api.nvim_buf_get_lines(bufnr, end_line - 1, end_line, false)[1]
        if line and line:match("^```%s*$") then break
        end
        end_line = end_line + 1
    end
    -- If we found both delimiters, make the selection
    if start_line > 0 and end_line <= last_line then
        -- Move to start line + 1 (skip the opening delimiter)
        vim.api.nvim_win_set_cursor(0, {start_line + 1, 0})
        -- Enter normal visual mode
        vim.cmd('normal! v')
        -- Move to end line - 1 (exclude the closing delimiter)
        -- Get the content of the last line to select
        local last_content_line = vim.api.nvim_buf_get_lines(bufnr, end_line - 2, end_line - 1, false)[1]
        local last_col = 0
        if last_content_line then
            last_col = #last_content_line
        end
        -- Move to the end of the last line of content
        vim.api.nvim_win_set_cursor(0, {end_line - 1, last_col - 1})
    else
        print("No code block found")
    end
end

vim.api.nvim_create_user_command('SelectCodeBlock', SelectWithinCodeBlock, {})

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
        lualine_x = {'filetype'},
    }
})
-- listen lsp-progress event and refresh lualine
vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
    group = "lualine_augroup",
    pattern = "LspProgressStatusUpdated",
    callback = require("lualine").refresh,
})

local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-l>'] = cmp.mapping.complete_common_string()
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'conjure' },
        { name = 'buffer' },
    })
})
-- Capabilities are setup in LSP setup
--
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
        path_display = {
            "smart"
        },
    },
    extensions = {
        fzf = {},
    },
}
require('telescope').load_extension('fzf')

require("todo-comments").setup{}

require'nvim-treesitter.configs'.setup{
    -- A list of parser names, or "all"
    ensure_installed = { "c", "lua", "rust", "python", "clojure", "vim", "fennel", "html" , "css", "json" , "markdown"},
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
    local opts = { noremap=true, silent=true }

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

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "bashls", "clojure_lsp", "clangd", "hls", "html", "cssls", "jsonls", "racket_langserver" }
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = lsp_on_attach,
        flags = {
            debounce_text_changes = 150,
        },
        -- cmp setup
        capabilities = require('cmp_nvim_lsp').default_capabilities()
    }
end
nvim_lsp.pylsp.setup{
    on_attach = lsp_on_attach,
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {enabled = false},
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
        return {'treesitter', 'indent'}
    end
})

-- LLM plugin
require("parrot").setup{
    chat_free_cursor = true,
    toggle_target = "buffer",
    user_input_ui = "buffer",
    -- Providers must be explicitly added to make them available.
    providers = {
        openrouter = {
            style = "openai",
            api_key = os.getenv "OPENROUTER_API_KEY",
            endpoint = "https://openrouter.ai/api/v1/chat/completions",
            models = { "deepseek/deepseek-r1", "google/gemini-2.0-pro-exp-02-05:free" },
            topic = {
                model = "google/gemini-2.0-pro-exp-02-05:free",
                params = { max_tokens = 64 },
            },
            params = {
                chat = {
                    max_tokens = 8000,
                    temperature = 1
                },
            }
        },
        anthropic = {
            api_key = os.getenv "ANTHROPIC_API_KEY",
            params = {
                chat = {
                    max_tokens = 64000,
                    temperature = 1,
                    -- thinking ={
                    --     type = "enabled",
                    --     budget_tokens = 16000,
                    -- },
                },
            },
        },
        gemini = {
            api_key = os.getenv "GEMINI_API_KEY",
            params = {
                chat = {
                    max_tokens = 64000,
                }
            }
        },
        -- openai = {
        --   api_key = os.getenv "OPENAI_API_KEY",
        -- },
        -- xai = {
        --   api_key = os.getenv "XAI_API_KEY",
    },
}

-- Function to select parrot.nvim chat messages
local function select_parrot_message()
    local cursor_line = vim.fn.line('.')
    local current_line_text = vim.fn.getline(cursor_line)

    -- Determine if we're on a user or AI message start
    local is_user_message = current_line_text:match("^🗨:")
    local is_ai_message = current_line_text:match("^🦜:")
    local start_line = cursor_line

    if not (is_user_message or is_ai_message) then
        -- Search backward for the nearest message start
        local line = cursor_line
        while line > 1 do
            line = line - 1
            local line_text = vim.fn.getline(line)
            if line_text:match("^🗨:") or line_text:match("^🦜:") then
                start_line = line
                is_user_message = line_text:match("^🗨:")
                is_ai_message = line_text:match("^🦜:")
                break
            end
        end
    end

    -- If we found a message start or we're already on one
    if is_user_message or is_ai_message then
        -- Find where the next message starts
        local end_line = vim.fn.line('$') -- Default to end of file

        for line = start_line + 1, vim.fn.line('$') do
            local line_text = vim.fn.getline(line)
            if line_text:match("^🗨:") or line_text:match("^🦜:") then
                end_line = line - 1
                break
            end
        end

        -- Select from the line after the prefix to the line before the next message
        if start_line + 1 <= end_line then
            vim.cmd("normal! " .. (start_line + 1) .. "GV" .. end_line .. "G")
        else
            vim.notify("No message content to select", vim.log.levels.WARN)
        end
    else
        vim.notify("No parrot.nvim message found at cursor", vim.log.levels.WARN)
    end
end

-- Register command
vim.api.nvim_create_user_command('ParrotSelectMessage', function()
    select_parrot_message()
end, {})

-- Optionally, map to a key combination
vim.keymap.set('n', '<leader>vm', ':ParrotSelectMessage<CR>', { noremap = true, silent = true, desc = "Select Parrot Message" })
