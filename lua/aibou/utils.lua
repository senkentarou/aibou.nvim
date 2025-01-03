local M = {}

-- Chat区別用のID生成
M.generate_id = function()
  return tostring(os.date('%Y%m%d-%H%M%S'))
end

-- aibou-markdown形式のバッファを生成
M.create_buf = function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('filetype', 'aibou-markdown', { buf = bufnr })

  return bufnr
end

-- vim.api.nvim_open_win用のオプション生成
M.build_window_opts = function(win_opts)
  return {
    split = win_opts.layout,
    width = math.floor(vim.o.columns * win_opts.width),
    height = math.floor(vim.o.lines * win_opts.height),
    style = 'minimal', -- 行番号などを非表示
  }
end

-- curlコマンド実行用のテーブルを生成
M.build_curl_cmd = function(url, curl_opts)
  return vim.fn.flatten({
    'curl',
    '-s', -- サイレント
    '-N', -- バッファリングなし
    url,
    '-H', -- ヘッダー(Json)
    'Content-Type: application/json',
    curl_opts,
  })
end

return M
