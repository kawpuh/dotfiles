require('kawpuh.lsp')
require('kawpuh.treesitter')
require('kawpuh.diffregister')
require('kawpuh.termsend')
require('pelican').setup()

require('ibl').setup()
require('lsp-progress').setup()
require('treesitter-context').setup({enable = true})

require('nvim-surround').setup({
  surrounds = {
    ["c"] = {
      add = function()
        return { { "`" }, { "`" } }
      end,
    },
    ["C"] = {
      add = function()
        return { { "```\n" }, { "\n```" } }
      end,
    }
  },
  indent_lines = false
})

require("catppuccin").setup {
  custom_highlights = function(colors)
    return {
      SignColumn = { bg = colors.surface0 },
      Normal = { bg = "NONE" },
      NonText = { bg = "NONE" }
    }
  end,
  background = {
    dark = "frappe",
  }
}

require('lualine').setup({
  options = {
    theme = "catppuccin"
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

