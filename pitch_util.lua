local List = require 'llx/types/list' . List
local spiral = require 'musictheory/spiral'
local util = require 'musictheory/util'

local Spiral = spiral.Spiral
local intervals_to_indices = util.intervals_to_indices

local major_pitch_intervals = List{2, 2, 1, 2, 2, 2, 1}
local major_pitch_indices = Spiral(intervals_to_indices(major_pitch_intervals))
local minor_pitch_intervals = List{2, 1, 2, 2, 1, 2, 2}
local minor_pitch_indices = intervals_to_indices(minor_pitch_intervals)

return {
  major_pitch_intervals = major_pitch_intervals,
  major_pitch_indices = major_pitch_indices,
  minor_pitch_intervals = minor_pitch_intervals,
  minor_pitch_indices = minor_pitch_indices,
}