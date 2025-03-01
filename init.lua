-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'

local lock <close> = llx.lock_global_table()

--                                           Tested | Docs
----------------------------------------------------+-----
return require 'llx.flatten_submodules' { --        |
  require 'musictheory.accidental',       -- No     | No
  require 'musictheory.articulation',     -- No     | No
  require 'musictheory.beat',             -- No     | No
  require 'musictheory.channel',          -- No     | No
  require 'musictheory.chord',            -- Yes    | No
  require 'musictheory.contour',          -- No     | No
  require 'musictheory.direction',        -- No     | No
  require 'musictheory.dynamics',         -- No     | No
  require 'musictheory.figure',           -- Yes    | No
  require 'musictheory.instrument',       -- No     | No
  require 'musictheory.interval_quality', -- No     | No
  require 'musictheory.meter',            -- No     | No
  require 'musictheory.mode',             -- Yes    | No
  require 'musictheory.modes',            -- No     | No
  require 'musictheory.note',             -- Yes    | No
  require 'musictheory.pattern',          -- No     | No
  require 'musictheory.pitch',            -- Yes    | No
  require 'musictheory.pitch_class',      -- No     | No
  require 'musictheory.pitch_interval',   -- Yes    | No
  require 'musictheory.quality',          -- Yes    | No
  require 'musictheory.rhythm',           -- No     | No
  require 'musictheory.ring',             -- No     | No
  require 'musictheory.scale',            -- Yes    | No
  require 'musictheory.scale_degree',     -- No     | No
  require 'musictheory.scale_index',      -- No     | No
  require 'musictheory.song',             -- No     | No
  require 'musictheory.spiral',           -- No     | No
  require 'musictheory.tempo',            -- No     | No
  require 'musictheory.util',             -- No     | No
}
