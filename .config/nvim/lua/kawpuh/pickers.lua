local M = {}
local configured = false
local snacks

local function setup()
  if configured then
    return
  end

  vim.fn['plug#load']('snacks.nvim')
  snacks = require('snacks')
  snacks.setup({
    picker = {
      enabled = true,
      formatters = {
        file = {
          filename_first = true,
        },
      },
      win = {
        input = {
          keys = {
            ['<a-a>'] = { 'toggle_hidden', mode = { 'i', 'n' } },
          },
        },
      },
    },
  })
  configured = true
end

function M.open(picker, opts)
  setup()
  local defaults = { layout = 'telescope' }
  if picker ~= 'buffers' then
    defaults.matcher = {
      frecency = true,
      sort_empty = true,
    }
  end
  opts = vim.tbl_deep_extend('force', defaults, opts or {})
  snacks.picker[picker](opts)
end

return M
