-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Named zero-based scale degrees.
-- A convenience map from the functional names of the diatonic scale
-- degrees to the zero-based index a Scale expects.
-- @module musica.scale_degree

local llx = require 'llx'

local _ENV, _M = llx.environment.create_module_environment()

--- Zero-based index of each named scale degree.
-- @field tonic The first degree (0)
-- @field supertonic 1
-- @field mediant 2
-- @field subdominant 3
-- @field dominant 4
-- @field submediant 5
-- @field leading_tone 6
-- @table ScaleDegree
ScaleDegree = {
  tonic = 0,
  supertonic = 1,
  mediant = 2,
  subdominant = 3,
  dominant = 4,
  submediant = 5,
  leading_tone = 6,
}

return _M
