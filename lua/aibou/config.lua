local M = {}

M.default_config = {
  assistant = {
    model = 'yesno',
  },
  system = {
    window = {
      layout = 'right', -- left, right, top, bottom
      width = 0.4,
      height = 0.4,
    },
    -- ${HOME}/.local/share/nvim/aibou.nvim/chat_history.json
    chat_record_path = vim.fn.stdpath('data') .. '/aibou.nvim/chat_record.json',
    -- ${HOME}/.config/nvim/aibou.nvim/local_assistant_config.json
    local_assistant_config_path = vim.fn.stdpath('config') .. '/aibou.nvim/local_assistant_config.json',
  },
  models = {
    yesno = {
      url = 'https://yesno.wtf/api',
      curl_opts = {},
    },
  },
}

return M
