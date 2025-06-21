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
