local M = {}

function M.diff_with_register(register)
  register = register or '"'

  -- Get the visual selection text
  local visual_lines = vim.fn.getline("'<", "'>")
  local start_col = vim.fn.getpos("'<")[3]
  local end_col = vim.fn.getpos("'>")[3]

  -- Adjust the first and last lines for partial selections
  if #visual_lines == 1 then
    visual_lines[1] = visual_lines[1]:sub(start_col, end_col)
  else
    visual_lines[1] = visual_lines[1]:sub(start_col)
    visual_lines[#visual_lines] = visual_lines[#visual_lines]:sub(1, end_col)
  end

  -- Store the original window
  local original_win = vim.api.nvim_get_current_win()

  -- Create a temporary split
  vim.cmd('lefta vnew')
  local reg_buf = vim.api.nvim_get_current_buf()

  -- Make the buffer temporary
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false

  -- Get and paste register contents
  local reg_contents = vim.fn.getreg(register)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(reg_contents, '\n'))

  -- Enable diff mode
  vim.wo.diff = true

  -- Create another split for visual selection
  vim.cmd('vnew')
  local visual_buf = vim.api.nvim_get_current_buf()
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
  vim.api.nvim_buf_set_lines(0, 0, -1, false, visual_lines)
  vim.wo.diff = true

  -- Set buffer names
  vim.api.nvim_buf_set_name(0, 'Visual_Selection')
  vim.cmd('wincmd h')
  vim.api.nvim_buf_set_name(0, 'Register_' .. register)

  -- Set up autocmd to clean up diff mode when either buffer is closed
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = reg_buf,
    callback = function()
      vim.wo.diff = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        vim.wo[win].diff = false
      end
      vim.api.nvim_buf_delete(visual_buf, { force = true })
    end,
    once = true,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = visual_buf,
    callback = function()
      vim.wo.diff = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        vim.wo[win].diff = false
      end
      vim.api.nvim_buf_delete(reg_buf, { force = true })
    end,
    once = true,
  })
end

vim.api.nvim_create_user_command('DiffReg', function(opts)
  M.diff_with_register(opts.args)
end, {
  nargs = '?',
  range = true,
})

return M
