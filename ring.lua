require 'llx'
require 'musictheory/util'

Ring = class 'Ring' {
  __init = function(self, args)
    self._values = args
  end,

  __index = multi_index(function(self, key)
    local values = self._values
    local length = #values
    key = (key % length) + #self
    key = (key % length) + 1
    return values[key]
  end),
}

