-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Accidental constants for pitch alteration.
-- An accidental raises or lowers a pitch by a number of semitones:
-- sharp = +1, natural = 0, flat = -1. Values outside this range
-- (e.g. 2 for a double sharp) may be used wherever an accidental
-- count is expected.
-- @module musica.accidental

local llx = require 'llx'

local _ENV, _M = llx.environment.create_module_environment()

--- Semitone offsets for the standard accidentals.
-- @field sharp Raises the pitch by one semitone (+1)
-- @field natural Leaves the pitch unaltered (0)
-- @field flat Lowers the pitch by one semitone (-1)
-- @table Accidental
Accidental = {
  sharp = 1,
  natural = 0,
  flat = -1,
}

return _M
