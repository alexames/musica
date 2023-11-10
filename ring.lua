require 'llx'

Ring = class 'Ring' {
  __init = function(self, args)
    self._values = args
  end,

  __index = function(self, key)
    if type(key) == 'number' then
      local values = rawget(self, '_values')
      local length = #values
      key = (key % length) + #self
      key = (key % length) + 1
      return values[key]
    elseif type(key) == 'table' then
      local results = List{}
      for i, v in pairs(key) do
        results[i] = self[v]
      end
      return results
    else
      return self.__defaultindex(self, key)
    end
  end
}

