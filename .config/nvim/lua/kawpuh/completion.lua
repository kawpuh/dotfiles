local M = {}
local configured = false

function M.setup()
  if configured then
    return
  end

  vim.fn['plug#load']('blink.cmp')
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
  configured = true
end

vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  callback = M.setup,
})

return M
