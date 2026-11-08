-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Rule submodules for musical generation.
-- @module musica.generation.rules

local llx = require 'llx'

-- The global table stays locked while the submodules load, so an accidental
-- global assignment in one of them raises; `with` unlocks it even when a
-- load raises.
return llx.contextlib.with(llx.lock_global_table(), function()
  return require 'llx.flatten_submodules' {
    require 'musica.generation.rules.boundary',
    require 'musica.generation.rules.composite',
    require 'musica.generation.rules.duration',
    require 'musica.generation.rules.in_scale',
    require 'musica.generation.rules.interval',
    require 'musica.generation.rules.monotonic',
    require 'musica.generation.rules.overshoot',
    require 'musica.generation.rules.range',
    require 'musica.generation.rules.volume',
  }
end)
