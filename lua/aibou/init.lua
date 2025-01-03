local Aibou = require('aibou.models.aibou')

local config = require('aibou.config')
local default_config = config.default_config

local M = {}

M.setup = function(opts)
  -- チャットインスタンスの生成
  M.aibou = Aibou(vim.tbl_deep_extend('force', default_config, opts or {}))
  -- チャット内容の復元
  M.aibou:restore()
  -- vimを閉じる際にそこまでの内容を保存
  vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = function()
      M.aibou:save()
    end,
  })
end

vim.api.nvim_create_user_command('AibouOpenChat', function()
  M.aibou:open()
end, {})

vim.api.nvim_create_user_command('AibouToggleChat', function()
  M.aibou:toggle()
end, {})

return M
