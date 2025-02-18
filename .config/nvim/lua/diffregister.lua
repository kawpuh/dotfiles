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

  -- Create a temporary split
  vim.cmd('lefta vnew')

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
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
  vim.api.nvim_buf_set_lines(0, 0, -1, false, visual_lines)
  vim.wo.diff = true

  -- Set buffer names
  vim.api.nvim_buf_set_name(0, 'Visual_Selection')
  vim.cmd('wincmd h')
  vim.api.nvim_buf_set_name(0, 'Register_' .. register)
end

vim.api.nvim_create_user_command('DiffReg', function(opts)
  M.diff_with_register(opts.args)
end, {
  nargs = '?',
  range = true,
})

return M
