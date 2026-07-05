-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Interval quality constants.
-- Qualities classify musical intervals. Perfect intervals (unison,
-- fourth, fifth, octave) may be diminished, perfect, or augmented;
-- imperfect intervals (second, third, sixth, seventh) may be
-- diminished, minor, major, or augmented. Each quality is a
-- UniqueSymbol compared by identity.
-- @module musica.interval_quality

local llx = require 'llx'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local UniqueSymbol = util.UniqueSymbol

--- Unique symbols naming the interval qualities.
-- @field major Major quality (imperfect intervals only)
-- @field minor Minor quality (imperfect intervals only)
-- @field diminished One semitone below minor or perfect
-- @field augmented One semitone above major or perfect
-- @field perfect Perfect quality (perfect intervals only)
-- @table IntervalQuality
IntervalQuality = {
  major = UniqueSymbol('IntervalQuality.major'),
  minor = UniqueSymbol('IntervalQuality.minor'),
  diminished = UniqueSymbol('IntervalQuality.diminished'),
  augmented = UniqueSymbol('IntervalQuality.augmented'),
  perfect = UniqueSymbol('IntervalQuality.perfect'),
}

return _M
