local utils = require('aibou.utils')
local config = require('aibou.config')

local class = utils.class
local generate_id = utils.generate_id
local create_buf = utils.create_buf
local build_window_opts = utils.build_window_opts
local build_curl_cmd = utils.build_curl_cmd

local default_assistant_message = config.default_assistant_message
local default_config = config.default_config
local aibou_settings = config.aibou_settings

--
-- チャットモデル
--
local Chat = class(function(self, opts)
  self.opts = opts or {}

  -- 現状、インスタンス生成と同時にバッファも生成する
  self.bufnr = opts.bufnr or create_buf()
  self.winid = opts.winid or -1

  self.id = opts.id or generate_id()
  self.messages = opts.messages or { default_assistant_message }
  self.config = opts.config or default_config

  self.headlines = {
    user = '#  User',
    assistant = '#  Aibou (' .. self.opts.model .. ')',
    system = '#  System',
  }
  self.latest_line_num = -1

  vim.keymap.set({ 'n', 'i' }, '<C-s>', '', {
    silent = true,
    buffer = self.bufnr,
    callback = function()
      self:ask()
    end,
  })

  vim.keymap.set({ 'n', 'i' }, '<C-l>', '', {
    buffer = self.bufnr,
    silent = true,
    callback = function()
      self:clear()
    end,
  })

  vim.keymap.set({ 'n', 'i' }, '<C-q>', '', {
    buffer = self.bufnr,
    silent = true,
    callback = function()
      self:close()
    end,
  })
end)

-- バッファに会話内容を復元
function Chat:restore()
  -- メッセージブロック毎にセクション分けて表示
  for i, msg in ipairs(self.messages) do
    vim.api.nvim_buf_set_lines(self.bufnr, i == 1 and 0 or -1, -1, true, { (msg.role == 'user') and self.headlines.user or self.headlines.assistant })

    local content = msg.content or ''
    if type(content) == 'table' then
      -- テーブルの場合は改行を含む文字列として扱う
      content = vim.fn.join(content, '\n')
    end

    vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, true, vim.split(content, '\n'))
    vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, true, { '' })
  end
  -- ユーザーに次なる入力を促すための行を追加
  vim.api.nvim_buf_set_lines(self.bufnr, #self.messages == 0 and 0 or -1, -1, true, { self.headlines.user, '' })
end

-- 会話ウィンドウを開く
function Chat:open()
  if vim.api.nvim_win_is_valid(self.winid) then
    -- 会話ウィンドウが既に存在する場合はバッファを上書き再利用
    vim.api.nvim_win_set_buf(self.winid, self.bufnr)
  else
    -- 会話ウィンドウが存在しない場合は新規作成
    self.winid = vim.api.nvim_open_win(self.bufnr, true, build_window_opts(self.opts.window))
  end
  -- カーソル位置を最新行に更新しておく
  self:set_cursor_to_latest_line()
end

-- カーソル位置を最新行に更新
function Chat:set_cursor_to_latest_line()
  local line_num = vim.api.nvim_buf_line_count(self.bufnr)

  vim.api.nvim_win_set_cursor(self.winid, { line_num, 0 })
  self.latest_line_num = line_num
end

-- 会話をクリアする
function Chat:clear()
  if vim.api.nvim_win_is_valid(self.winid) then
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, true, { '' })
    self.messages = {}

    self:open()
  end
end

-- 会話の終了
function Chat:close()
  if vim.api.nvim_win_is_valid(self.winid) then
    vim.api.nvim_win_close(self.winid, false)
  end
end

-- 会話ウィンドウを開閉する
function Chat:toggle()
  if vim.api.nvim_win_is_valid(self.winid) then
    vim.api.nvim_win_close(self.winid, false)
  else
    self:open()
  end
end

-- 会話の中で相棒に質問する
function Chat:ask()
  -- ユーザーの入力を読み込む
  local input = vim.api.nvim_buf_get_lines(self.bufnr, self.latest_line_num - 1, -1, false)
  local user_content = vim.fn.join(input, '\n')

  if user_content == '' then
    vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, true, { '質問内容が空です。再度入力してください。' })
    vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, true, { '', self.headlines.user, '' })
    self:set_cursor_to_latest_line()
    return
  end

  local model = aibou_settings[self.config.model]
  if not model then
    vim.notify(self.config.model .. 'モデルは存在しません。', vim.log.levels.ERROR)
    return
  end

  -- ユーザーの質問内容をバッファに書き込む
  table.insert(self.messages, { role = 'user', content = user_content })
  -- Aibouの問い合わせ内容を表示するためのヘッドラインを追加
  vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, true, { '', self.headlines.assistant, '' })

  local response = {}
  vim.fn.jobstart(build_curl_cmd(model.url, model.curl_opts), {
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= '' then
            -- チャンク毎にレスポンスを受け取って保持
            table.insert(response, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if exit_code == 0 then
          -- 受け取ったレスポンスを解析して表示
          local res = vim.json.decode(vim.fn.join(response, ''))
          local assistant_content = vim.split(res.answer, '\n')

          -- 相棒の回答内容をバッファに書き込む
          vim.api.nvim_buf_set_text(self.bufnr, -1, -1, -1, -1, assistant_content)
          table.insert(self.messages, {
            role = 'assistant',
            content = assistant_content,
          })

          -- ユーザーに次なる入力を促すための行を追加
          vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, false, { '', self.headlines.user, '' })
          self:set_cursor_to_latest_line()
        end
      end)
    end,
    stdout_buffered = false,
  })
end

return Chat
