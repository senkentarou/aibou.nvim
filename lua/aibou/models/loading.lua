local abstract = require('aibou.models.abstract')

local class = abstract.class
local spinners = { '/', '-', '\\', '|' }

local Loading = class(function(self, bufnr)
  self.bufnr = bufnr

  self.idx = 1
  self.is_running = false
end)

function Loading:start()
  local timer = vim.uv.new_timer()
  if not timer then
    return
  end

  self.is_running = true
  vim.uv.timer_start(timer, 0, 200, function()
    vim.schedule(function()
      vim.api.nvim_buf_set_lines(self.bufnr, -2, -1, false, { spinners[self.idx] })
      self.idx = (self.idx % #spinners) + 1
    end)
  end)

  return timer
end

function Loading:stop(timer)
  if not self.is_running then
    return
  end

  if timer then
    self.is_running = false
    vim.uv.timer_stop(timer)
    vim.api.nvim_buf_set_lines(self.bufnr, -2, -1, false, { '' })
  end
end

return Loading
