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
        if line and line:match("^```%s*$") then
            break
        end
        end_line = end_line + 1
    end

    -- If we found both delimiters, make the selection
    if start_line > 0 and end_line <= last_line then
        -- Move to start line + 1 (skip the opening delimiter)
        vim.api.nvim_win_set_cursor(0, {start_line + 1, 0})
        -- Enter visual line mode
        vim.cmd('normal! V')
        -- Move to end line - 1 (exclude the closing delimiter)
        vim.api.nvim_win_set_cursor(0, {end_line - 1, 0})
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
require("gp").setup({
    providers = {
        anthropic = {
            endpoint = "https://api.anthropic.com/v1/messages",
            secret = os.getenv("ANTHROPIC_API_KEY"),
        },
        mistral = {
            endpoint = "https://api.mistral.ai/v1/chat/completions",
            secret = os.getenv("MISTRAL_API_KEY"),
        },
        openrouter = {
            endpoint = "https://openrouter.ai/api/v1/chat/completions",
            secret = os.getenv("OPENROUTER_API_KEY"),
        },
        xai = {
            endpoint = "https://api.x.ai/v1/chat/completions",
            secret = os.getenv("XAI_API_KEY"),
        },
    },
    agents = {
        {
            name = "MistralLarge",
            provider = "mistral",
            chat = true,
            command = false,
            model = { model = "mistral-large-latest" },
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "Codestral",
            provider = "mistral",
            chat = false,
            command = true,
            model = { model = "codestral-latest" },
            system_prompt = require("gp.defaults").code_system_prompt,
        },
        {
            name = "o1-mini",
            provider = "openrouter",
            chat = true,
            command = false,
            model = { model = "openai/o1-mini" },
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "o1-preview",
            provider = "openrouter",
            chat = true,
            command = false,
            model = { model = "openai/o1-preview" },
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "gemini-2.0-flash",
            provider = "openrouter",
            chat = true,
            command = false,
            model = { model = "google/gemini-2.0-flash-exp:free" },
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            provider = "anthropic",
            name = "ChatClaude-3-5-Sonnet",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = { model = "claude-3-5-sonnet-latest", temperature = 0.8, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "Grok Beta",
            provider = "xai",
            chat = true,
            command = false,
            model = { model = "grok-beta" },
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
    },
    default_chat_agent = "ChatClaude-3.5-Sonnet",
    default_command_agent = "CodeClaude-3.5-Sonnet",
    toggle_target = "buffer",
    hooks = {},
})
