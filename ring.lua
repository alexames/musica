-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local multi_index = util.multi_index

Ring = llx.class 'Ring' {
  __init = function(self, args)
    assert(#args > 0, 'Ring requires a non-empty sequence')
    self._values = args
  end,

  __len = function(self)
    return #self._values
  end,

  __eq = function(self, other)
    local a, b = self._values, other._values
    if #a ~= #b then return false end
    for i = 1, #a do
      if a[i] ~= b[i] then return false end
    end
    return true
  end,

  __index = multi_index(function(self, key)
    local values = self._values
    local length = #values
    key = (key % length) + #self
    key = (key % length) + 1
    return values[key]
  end),
}

return _M
