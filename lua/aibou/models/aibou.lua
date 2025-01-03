local Chat = require('aibou.models.chat')

local abstract = require('aibou.models.abstract')

local class = abstract.class

--
-- 相棒モデル
--
local Aibou = class(function(self, opts)
  self.opts = opts or {}

  self.chats = {}
  self.current_chat_id = nil
end)

-- 新しい会話を生成
function Aibou:new_chat(opts)
  local c = Chat(vim.tbl_deep_extend('force', self.opts, opts or {}))
  self.chats[c.id] = c

  return c.id
end

-- 新しい会話を開く
function Aibou:open()
  self.chats[self.current_chat_id]:open()
end

-- 会話ウィンドウを開閉する
function Aibou:toggle()
  self.chats[self.current_chat_id]:toggle()
end

-- これまでの会話の内容を復元する
function Aibou:restore()
  -- 保存先が未指定の場合はスキップ (デフォルトは読み込む想定)
  if not self.opts.system.chat_record_path then
    return
  end

  local file = io.open(self.opts.system.chat_record_path, 'r')
  if file then
    -- ファイルが存在する場合は内容を読み込む
    local raw = file:read('*a')
    file:close()

    local contents = vim.json.decode(raw)
    for _, c in ipairs(contents) do
      local id = self:new_chat({
        id = c.key,
        messages = c.messages,
        config = c.config,
      })
      -- 最新の会話を保持するようになる
      self.current_chat_id = id
    end

    -- 内容が存在しなかった場合は新規作成
    if not self.current_chat_id then
      self.current_chat_id = self:new_chat()
    end
  else
    -- ファイルが存在しない場合は新規作成
    self.current_chat_id = self:new_chat()
  end

  -- 最新の会話だけ復元する
  self.chats[self.current_chat_id]:restore()
end

-- これまでの会話の内容をバッファに書き込む
function Aibou:save()
  -- 保存先が未指定の場合はスキップ (デフォルトは保存する想定)
  if not self.opts.system.chat_record_path then
    return
  end

  local dir_path = vim.fn.fnamemodify(self.opts.system.chat_record_path, ':h')
  vim.fn.mkdir(dir_path, 'p')

  local file = io.open(self.opts.system.chat_record_path, 'w')
  if file then
    local data = {}
    for _, chat in pairs(self.chats) do
      table.insert(data, { key = chat.key, messages = chat.messages, config = chat.config })
    end
    file:write(vim.json.encode(data))
    file:close()
  end
end

return Aibou
