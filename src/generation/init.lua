-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Generation module for procedural music creation using Z3 constraint solving.
-- @module musica.generation

local llx = require 'llx'

-- The global table stays locked while the submodules load, so an accidental
-- global assignment in one of them raises; `with` unlocks it even when a
-- load raises.
return llx.contextlib.with(llx.lock_global_table(), function()
  -- Generation needs the native z3 binding (lua-z3), built for this Lua. It is
  -- not part of the musica core (see src/init.lua). Fail with a clear message
  -- if the binding is missing, rather than deep inside a submodule require.
  if not pcall(require, 'z3') then
    error("musica.generation requires the 'z3' binding (lua-z3) built for this "
      .. "Lua interpreter, which is not installed. Install it via the "
      .. "alexames/vcpkg-registry port, or omit generation.", 2)
  end

  return require 'llx.flatten_submodules' {
    require 'musica.generation.context',
    require 'musica.generation.generator',
    require 'musica.generation.rule',
    require 'musica.generation.rules',
  }
end)
