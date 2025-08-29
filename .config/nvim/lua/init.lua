require('kawpuh.lsp')
require('kawpuh.treesitter')
require('kawpuh.diffregister')
require('kawpuh.termsend')
require('ibl').setup()
require('lsp-progress').setup()
require('treesitter-context').setup({ enable = true })

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
    local highlights = {
      SignColumn = { bg = colors.surface0 },
    }
    if not vim.g.neovide then
      highlights.Normal = { bg = "NONE" }
      highlights.NonText = { bg = "NONE" }
    end
    return highlights
  end,
  background = {
    dark = "mocha",
  },
}

require("gruvbox").setup {
  transparent_mode = true
}

require('lualine').setup({
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

require('snacks').setup({
  picker = {
    enabled = true,
    formatters = {
      file = {
        filename_first = true,
      }
    },
    matcher = {
      frecency = true,
      sort_empty = true,
    },
    win = {
      input = {
        keys = {
          ["<a-a>"] = { "toggle_hidden", mode = { "i", "n" } },
        }
      }
    }
  },
})

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
