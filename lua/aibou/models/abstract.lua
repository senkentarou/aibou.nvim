local M = {}

-- 汎用クラスの定義
M.class = function(fn)
  local obj = {}
  obj.__index = obj

  -- metatableの設定
  -- 関数として呼び出されたときにnewでインスタンスを生成する
  local mt = {
    __call = function(cls, ...)
      return cls.new(...)
    end,
  }

  setmetatable(obj, mt)

  obj.new = function(...)
    local self = setmetatable({}, obj)
    fn(self, ...)
    return self
  end

  obj.init = function(self, ...)
    fn(self, ...)
  end

  return obj
end

return M
