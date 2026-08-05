local completion = require('kawpuh.completion')

-- LSP and completion are not needed until a supported filetype is opened.
-- Scheduling their setup lets the initial buffer draw first.
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'c', 'clojure', 'cpp', 'css', 'cuda', 'haskell', 'html', 'json',
    'jsonc', 'less', 'lhaskell', 'lua', 'objc', 'objcpp', 'python',
    'racket', 'scss', 'sh',
  },
  once = true,
  callback = function()
    vim.schedule(function()
      completion.setup()
      require('kawpuh.lsp')
    end)
  end,
})

require('kawpuh.treesitter')
require('kawpuh.diffregister')
require('kawpuh.termsend')

vim.filetype.add({
  pattern = {
    ['.*'] = {
      priority = -math.huge,
      function(path, bufnr)
        local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
        if first_line:match('^#!.*%f[%w]bb%f[%W]') then
          return 'clojure'
        end
      end,
    },
  },
})

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

-- Configure the inactive colorscheme only if it is selected later.
vim.api.nvim_create_autocmd('ColorSchemePre', {
  pattern = 'gruvbox',
  once = true,
  callback = function()
    require('gruvbox').setup({
      transparent_mode = true,
      contrast = 'hard',
    })
  end,
})

require('lualine').setup({
  sections = {
    lualine_b = {
      'filename', 'diff', 'diagnostic'
    },
    lualine_c = {
      function()
        local progress = package.loaded['lsp-progress']
        return progress and progress.progress() or ''
      end,
    },
    lualine_x = { 'filetype' },
  },
  options = {
    section_separators = '',
    component_separators = ''
  }
})
-- listen lsp-progress event and refresh lualine
vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = "lualine_augroup",
  pattern = "LspProgressStatusUpdated",
  callback = require("lualine").refresh,
})

require("todo-comments").setup {}

-- Folding is comparatively expensive to initialize, so do it after the first
-- screen has been drawn. The mappings also initialize it on demand.
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

local ufo_configured = false
local function setup_ufo()
  if ufo_configured then
    return require('ufo')
  end

  local ufo = require('ufo')
  ufo.setup({
    provider_selector = function()
      return { 'treesitter', 'indent' }
    end,
  })
  ufo_configured = true
  return ufo
end

vim.keymap.set('n', 'zR', function()
  setup_ufo().openAllFolds()
end)
vim.keymap.set('n', 'zM', function()
  setup_ufo().closeAllFolds()
end)

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.schedule(function()
      -- These plugins attach to buffers that were opened during startup.
      vim.fn['plug#load']({
        'gitsigns.nvim',
        'indent-blankline.nvim',
        'nvim-treesitter-context',
      })
      require('ibl').setup()
      setup_ufo()
    end)
  end,
})
