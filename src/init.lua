-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'

local lock <close> = llx.lock_global_table()

return require 'llx.flatten_submodules' {
  --- Library version (semantic versioning).
  _VERSION = '0.1.0',

  require 'musica.accidental',
  require 'musica.articulation',
  require 'musica.beat',
  require 'musica.channel',
  require 'musica.chord',
  require 'musica.contour',
  require 'musica.direction',
  require 'musica.drums',
  require 'musica.dynamics',
  require 'musica.figure',
  require 'musica.instrument',
  require 'musica.interval_quality',
  require 'musica.lilypond',
  require 'musica.melodic',
  require 'musica.meter',
  require 'musica.mode',
  require 'musica.modes',
  require 'musica.note',
  require 'musica.pattern',
  require 'musica.pitch',
  require 'musica.pitch_class',
  require 'musica.pitch_interval',
  require 'musica.quality',
  require 'musica.rhythm',
  require 'musica.ring',
  require 'musica.scale',
  require 'musica.scale_degree',
  require 'musica.scale_index',
  require 'musica.song',
  require 'musica.spiral',
  require 'musica.stamper',
  require 'musica.tempo',
  require 'musica.util',
  -- NOTE: `musica.generation` is intentionally NOT loaded here. It depends on
  -- the native z3 binding (lua-z3), which is optional and ABI-bound to the host
  -- Lua. Keeping it out of the core means `require 'musica'` works everywhere,
  -- with or without z3. Use `require 'musica.generation'` explicitly when you
  -- want the constraint generator.
}
