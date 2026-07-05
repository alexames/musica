-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Named zero-based scale indices.
-- A convenience map from ordinal names to the zero-based index a Scale
-- expects, so `scale[ScaleIndex.fifth]` reads as the fifth scale degree.
-- @module musica.scale_index

local llx = require 'llx'

local _ENV, _M = llx.environment.create_module_environment()

--- Zero-based index of each named scale position.
-- @field first The tonic (0)
-- @field second 1
-- @field third 2
-- @field fourth 3
-- @field fifth 4
-- @field sixth 5
-- @field seventh 6
-- @field octave The tonic an octave up (7)
-- @table ScaleIndex
ScaleIndex = {
  first = 0,
  second = 1,
  third = 2,
  fourth = 3,
  fifth = 4,
  sixth = 5,
  seventh = 6,
  octave = 7,
}

return _M
