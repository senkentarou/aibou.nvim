local M = {}

M.default_config = {
  model = 'yesno',
  window = {
    layout = 'right', -- left, right, top, bottom
    width = 0.4,
    height = 0.4,
  },
  -- ${HOME}/.local/share/nvim/aibou.nvim/chat_history.json
  chat_record_path = vim.fn.stdpath('data') .. '/aibou.nvim/chat_record.json',
}

M.default_assistant_message = {
  role = 'assistant',
  content = 'こんにちは！',
}

M.aibou_settings = {
  yesno = {
    url = 'https://yesno.wtf/api',
    curl_opts = {},
  },
}

return M
