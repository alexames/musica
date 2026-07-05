-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Direction constants for melodic motion.
-- A direction describes how a melody moves between two pitches:
-- up = 1, down = -1, and level (or its alias same) = 0. The signed
-- values can be used directly as multipliers for interval motion.
-- @module musica.direction

local llx = require 'llx'

local _ENV, _M = llx.environment.create_module_environment()

--- Signed values for melodic direction.
-- @field down Downward motion (-1)
-- @field level No motion (0)
-- @field same Alias for level (0)
-- @field up Upward motion (1)
-- @table Direction
Direction = {
  down = -1,
  level = 0,
  same = 0,
  up = 1,
}

return _M
