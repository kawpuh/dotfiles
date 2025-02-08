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
            name = "deepseek-chat",
            provider = "openrouter",
            chat = true,
            command = false,
            model = { model = "deepseek/deepseek-chat" },
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "deepseek-r1",
            provider = "openrouter",
            chat = true,
            command = false,
            model = { model = "deepseek/deepseek-r1" },
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "gemini-2-pro",
            provider = "openrouter",
            chat = true,
            command = false,
            model = { model = "google/gemini-2.0-pro-exp-02-05:free" },
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
    hooks = {

        CountAllTokens = function(gp, _)
            local api_key = os.getenv("ANTHROPIC_API_KEY")
            if not api_key then
                vim.notify("ANTHROPIC_API_KEY environment variable not set", vim.log.levels.ERROR)
                return
            end

            -- Get all buffer lines
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local user_messages = {}
            local assistant_messages = {}

            -- Process all lines to collect messages
            local i = 1
            while i <= #lines do
                local line = lines[i]

                -- Check for assistant message
                if line:sub(1, #gp.config.chat_assistant_prefix[1]) == gp.config.chat_assistant_prefix[1] then
                    local j = i
                    while j < #lines do
                        local next_line = j + 1
                        if next_line > #lines or
                            lines[next_line]:sub(1, #gp.config.chat_user_prefix) == gp.config.chat_user_prefix or
                            lines[next_line]:sub(1, #gp.config.chat_assistant_prefix[1]) == gp.config.chat_assistant_prefix[1] then
                            break
                        end
                        j = next_line
                    end

                    local msg = table.concat(vim.list_slice(lines, i, j), "\n")
                    msg = msg:sub(#gp.config.chat_assistant_prefix[1] + 1):gsub("^%s*(.-)%s*$", "%1")
                    if msg:match("%S") then
                        table.insert(assistant_messages, { role = "assistant", content = msg })
                    end
                    i = j + 1
                    -- Check for user message
                elseif line:sub(1, #gp.config.chat_user_prefix) == gp.config.chat_user_prefix then
                    local j = i
                    while j < #lines do
                        local next_line = j + 1
                        if next_line > #lines or
                            lines[next_line]:sub(1, #gp.config.chat_user_prefix) == gp.config.chat_user_prefix or
                            lines[next_line]:sub(1, #gp.config.chat_assistant_prefix[1]) == gp.config.chat_assistant_prefix[1] then
                            break
                        end
                        j = next_line
                    end

                    local msg = table.concat(vim.list_slice(lines, i, j), "\n")
                    msg = msg:sub(#gp.config.chat_user_prefix + 1):gsub("^%s*(.-)%s*$", "%1")
                    if msg:match("%S") then
                        table.insert(user_messages, { role = "user", content = msg })
                    end
                    i = j + 1
                else
                    i = i + 1
                end
            end

            if #user_messages == 0 and #assistant_messages == 0 then
                vim.notify("No messages found", vim.log.levels.WARN)
                return
            end

            -- Function to make API request
            local function count_tokens(messages)
                local cmd = string.format([[curl -s https://api.anthropic.com/v1/messages/count_tokens \
        -H "x-api-key: %s" \
        -H "content-type: application/json" \
        -H "anthropic-version: 2023-06-01" \
        -d %s]],
                    api_key,
                    vim.fn.shellescape(vim.fn.json_encode({
                        model = "claude-3-5-sonnet-20241022",
                        messages = messages
                    }))
                )

                local handle = io.popen(cmd)
                if not handle then
                    return nil, "Failed to execute curl command"
                end

                local success, response = pcall(vim.fn.json_decode, handle:read("*a"))
                handle:close()

                if not success then
                    return nil, "Failed to parse response"
                end
                return response
            end

            -- Count tokens for all user messages
            local total_user_tokens = 0
            if #user_messages > 0 then
                local response = count_tokens(user_messages)
                if response and response.input_tokens then
                    total_user_tokens = response.input_tokens
                end
            end

            -- Count tokens for all assistant messages
            local total_assistant_tokens = 0
            if #assistant_messages > 0 then
                local response = count_tokens(assistant_messages)
                if response and response.input_tokens then
                    total_assistant_tokens = response.input_tokens
                end
            end

            vim.notify(string.format(
                "Total tokens - User: %d (%d messages), Assistant: %d (%d messages)",
                total_user_tokens,
                #user_messages,
                total_assistant_tokens,
                #assistant_messages
            ), vim.log.levels.INFO)
        end,
        CountLastTokens = function(gp, _)
            local api_key = os.getenv("ANTHROPIC_API_KEY")
            if not api_key then
                vim.notify("ANTHROPIC_API_KEY environment variable not set", vim.log.levels.ERROR)
                return
            end

            -- Get all buffer lines
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local user_message = nil
            local assistant_message = nil

            -- Search from bottom for last exchange
            for i = #lines, 1, -1 do
                local line = lines[i]
                if not assistant_message and line:sub(1, #gp.config.chat_assistant_prefix[1]) == gp.config.chat_assistant_prefix[1] then
                    -- Found assistant message, collect it
                    local j = i
                    while j < #lines do
                        local next_line = j + 1
                        if next_line > #lines or
                            lines[next_line]:sub(1, #gp.config.chat_user_prefix) == gp.config.chat_user_prefix or
                            lines[next_line]:sub(1, #gp.config.chat_assistant_prefix[1]) == gp.config.chat_assistant_prefix[1] then
                            break
                        end
                        j = next_line
                    end

                    local msg = table.concat(vim.list_slice(lines, i, j), "\n")
                    msg = msg:sub(#gp.config.chat_assistant_prefix[1] + 1):gsub("^%s*(.-)%s*$", "%1")
                    if msg:match("%S") then
                        assistant_message = { role = "assistant", content = msg }
                    end
                elseif not user_message and line:sub(1, #gp.config.chat_user_prefix) == gp.config.chat_user_prefix and assistant_message then
                    local j = i
                    while j < #lines do
                        local next_line = j + 1
                        if next_line > #lines or
                            lines[next_line]:sub(1, #gp.config.chat_user_prefix) == gp.config.chat_user_prefix or
                            lines[next_line]:sub(1, #gp.config.chat_assistant_prefix[1]) == gp.config.chat_assistant_prefix[1] then
                            break
                        end
                        j = next_line
                    end

                    local msg = table.concat(vim.list_slice(lines, i, j), "\n")
                    msg = msg:sub(#gp.config.chat_user_prefix + 1):gsub("^%s*(.-)%s*$", "%1")
                    user_message = { role = "user", content = msg }
                end

                if assistant_message and user_message then
                    break
                end
            end

            if not (assistant_message or user_message) then
                vim.notify("No messages found", vim.log.levels.WARN)
                return
            end

            -- Function to make API request
            local function count_tokens(messages)
                local cmd = string.format([[curl -s https://api.anthropic.com/v1/messages/count_tokens \
            -H "x-api-key: %s" \
            -H "content-type: application/json" \
            -H "anthropic-version: 2023-06-01" \
            -d %s]],
                    api_key,
                    vim.fn.shellescape(vim.fn.json_encode({
                        model = "claude-3-5-sonnet-20241022",
                        messages = messages
                    }))
                )

                local handle = io.popen(cmd)
                if not handle then
                    return nil, "Failed to execute curl command"
                end

                local success, response = pcall(vim.fn.json_decode, handle:read("*a"))
                handle:close()

                if not success then
                    return nil, "Failed to parse response"
                end
                return response
            end

            -- Count tokens for user message
            local input_tokens = 0
            if user_message then
                local response = count_tokens({user_message})
                if response and response.input_tokens then
                    input_tokens = response.input_tokens
                end
            end

            -- Count tokens for assistant message
            local output_tokens = 0
            if assistant_message then
                local response = count_tokens({assistant_message})
                if response and response.input_tokens then
                    output_tokens = response.input_tokens
                end
            end

            vim.notify(string.format("Last exchange tokens - Input: %d, Output: %d", input_tokens, output_tokens), vim.log.levels.INFO)
        end
    },
})
