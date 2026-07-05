-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Scale representation: a tonic pitch plus a mode.
-- A Scale maps scale indices to absolute pitches by adding the mode's
-- intervals to the tonic. Scales can be indexed like tables, tested
-- for pitch membership, related to other scales, and searched for
-- chords of a given quality.
-- @module musica.scale

local chord = require 'musica.chord'
local direction = require 'musica.direction'
local llx = require 'llx'
local mode = require 'musica.mode'
local modes = require 'musica.modes'
local pitch = require 'musica.pitch'
local quality = require 'musica.quality'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local check_arguments = llx.check_arguments
local Chord = chord.Chord
local class = llx.class
local Direction = direction.Direction
local Integer = llx.Integer
local isinstance = llx.isinstance
local List = llx.List
local map = llx.functional.map
local Number = llx.Number
local Mode = mode.Mode
local multi_index = util.multi_index
local Pitch = pitch.Pitch
local Quality = quality.Quality
local range = llx.functional.range
local Schema = llx.Schema
local Table = llx.Table
local tointeger = llx.tointeger

--- Schema for Scale construction arguments.
local ScaleArgs = llx.Schema{
  type=llx.Table,
  properties={
    tonic={type=Pitch},
    mode={type=Mode},
  },
  required={'tonic', 'mode'},
}

--- Represents a musical scale.
-- A scale is defined by a tonic Pitch and a Mode (the pattern of
-- intervals above the tonic). Indexing a Scale with a zero-based
-- scale index yields the Pitch at that degree; indices beyond one
-- octave wrap with octave transposition.
-- @type Scale
Scale = llx.class 'Scale' {
  --- Creates a new Scale.
  -- @function Scale:__init
  -- @tparam Scale self
  -- @tparam table arg Table with construction parameters
  -- @tparam Pitch arg.tonic The tonic (root) Pitch of the scale
  -- @tparam Mode arg.mode The Mode defining the scale's intervals
  -- @usage
  -- local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
  -- local third = c_major[2]  -- Pitch.e4
  __init = function(self, arg)
    check_arguments{self=Scale, arg=ScaleArgs}
    self.tonic = arg.tonic
    self.mode = arg.mode

    -- Precompute normalized pitch indices and pitch class set.
    -- These depend only on tonic and mode, which are immutable.
    local octave_interval = tointeger(self.mode:octave_interval())
    local normalized = {}
    local pitch_class_set = {}
    for i=1, #self.mode do
      local semitones = tointeger(self.mode[i-1])
      normalized[i] = semitones
      pitch_class_set[semitones % octave_interval] = true
    end
    self._normalized_indices = normalized
    self._pitch_class_set = pitch_class_set
    self._octave_interval = octave_interval
  end,

  --- Gets one octave of pitches in the scale.
  -- @return List of Pitch objects, one per scale degree
  get_pitches = function(self)
    check_arguments{self=Scale}
    local result = List{}
    for i=1, #self.mode do
      result[i] = self.tonic + self.mode[i-1]
    end
    return result
  end,

  --- Converts a scale index to a pitch.
  -- Indices beyond the mode's length wrap with octave transposition,
  -- and negative indices descend below the tonic.
  -- @function Scale:to_pitch
  -- @tparam Scale self
  -- @tparam number scale_index Zero-based index into the scale
  -- @treturn Pitch Pitch at that index
  to_pitch = function(self, scale_index)
    check_arguments{self=Scale, scale_index=Integer}
    return self.tonic + self.mode[scale_index]
  end,

  --- Converts multiple scale indices to pitches.
  -- @function Scale:to_pitches
  -- @tparam Scale self
  -- @tparam table scale_indices List of zero-based indices
  -- @treturn List List of Pitch objects
  to_pitches = function(self, scale_indices)
    check_arguments{self=Scale, scale_indices=Table}
    return map(function(scale_index)
      return self:to_pitch(scale_index)
    end, List(scale_indices))
  end,

  --- Converts a pitch to its scale index.
  -- @function Scale:to_scale_index
  -- @tparam Scale self
  -- @tparam Pitch|number pitch A Pitch or absolute pitch index
  -- @treturn number|nil Zero-based scale index, or nil if the pitch
  -- is not in the scale
  to_scale_index = function(self, pitch)
    check_arguments{self=Scale, pitch=llx.Union{Pitch, Integer}}
    local pitch_index = tointeger(pitch)
    local pitch_index_offset = pitch_index - tointeger(self.tonic)
    local octave_interval = self._octave_interval
    local offset_modulus = pitch_index_offset % octave_interval
    local offset_octave = pitch_index_offset // octave_interval
    local normalized = self._normalized_indices
    for i = 1, #normalized do
      if normalized[i] == offset_modulus then
        return (i - 1) + #self * offset_octave
      end
    end
    return nil
  end,

  --- Converts multiple pitches to scale indices.
  -- @function Scale:to_scale_indices
  -- @tparam Scale self
  -- @tparam table pitches List of Pitch objects (or pitch indices)
  -- @treturn List List of scale indices (nil for out-of-scale pitches)
  to_scale_indices = function(self, pitches)
    local result = List{}
    for i, pitch in ipairs(pitches) do
      result[i] = self:to_scale_index(pitch)
    end
    return result
  end,

  --- Creates a related scale sharing this scale's pitch content.
  -- Given a mode, finds the degree of this scale whose rotation
  -- yields that mode; given a scale_index, rotates this scale's mode
  -- to start on that degree.
  -- @function Scale:relative
  -- @tparam Scale self
  -- @tparam table args Table with parameters
  -- @tparam[opt] Mode args.mode Target mode (derives the new tonic)
  -- @tparam[opt] number args.scale_index Degree to build the new
  -- scale on (derives the new mode)
  -- @tparam[opt] number args.direction Direction.up or
  -- Direction.down, used when resolving a mode to a tonic
  -- @treturn Scale New Scale with the same pitch content
  -- @usage
  -- local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
  -- local a_minor = c_major:relative{mode=Mode.minor}
  relative = function(self, args)
    check_arguments{self=Scale,
                    args=Schema{type=Table,
                                properties={scale_index={type=Integer},
                                            mode={type=Mode},
                                            direction={type=Integer}}}}
    local mode = args.mode
    local scale_index = args.scale_index
    local direction = args.direction
    if mode then
      scale_index = self.mode:relative(mode)
      if not scale_index then
        error("unrelated mode")
      end
      if direction == Direction.down then
        scale_index = scale_index - #self
      end
    elseif scale_index ~= nil then
      mode = self.mode << scale_index
    end

    local tonic_scale_index =
      self:to_scale_index(tointeger(self.tonic)) + scale_index
    local tonic = self:to_pitch(tonic_scale_index)

    return Scale{tonic=tonic, mode=mode}
  end,

  --- Creates the parallel scale with the same tonic.
  -- @function Scale:parallel
  -- @tparam Scale self
  -- @tparam Mode mode The mode for the new scale
  -- @treturn Scale New Scale with this tonic and the given mode
  parallel = function(self, mode)
    check_arguments{self=Scale, mode=Mode}
    return Scale{tonic=self.tonic, mode=mode}
  end,

  --- Checks if the scale contains the given pitch content.
  -- Membership is tested by pitch class, so octave does not matter.
  -- @function Scale:contains
  -- @tparam Scale self
  -- @tparam Pitch|number|Chord|Scale|table other A pitch, chord,
  -- scale, or table of pitches to test
  -- @treturn boolean true if every pitch class is in the scale
  contains = function(self, other)
    local other_pitch_indices
    if isinstance(other, Number) or isinstance(other, Pitch) then
      other_pitch_indices = List{other}
    elseif isinstance(other, Chord) or isinstance(other, Scale) then
      other_pitch_indices = other:get_pitches()
    elseif isinstance(other, Table) then
      other_pitch_indices = List(other)
    end

    local octave_interval = self._octave_interval
    local pitch_class_set = self._pitch_class_set
    for i=1, #other_pitch_indices do
      local pc = tointeger(other_pitch_indices[i])
          % octave_interval
      if not pitch_class_set[pc] then
        return false
      end
    end
    return true
  end,

  --- Checks equality of two scales.
  -- Scales are equal if their tonics and modes are equal.
  -- @function Scale:__eq
  -- @tparam Scale self
  -- @tparam Scale other Another Scale
  -- @treturn boolean true if tonic and mode are equal
  __eq = function(self, other)
    return self.tonic == other.tonic and self.mode == other.mode
  end,

  --- Returns the number of degrees in the scale.
  -- @return Number of scale degrees (the mode's length)
  __len = function(self)
    return #self.mode
  end,

  --- Allows indexing the scale to get pitches.
  -- @param index Zero-based scale index (or a table of indices)
  -- @return Pitch at that index
  __index = multi_index(function(self, index)
    return self.tonic + self.mode[index]
  end),

  --- Returns a string representation of the scale.
  -- @return String like "Scale{tonic=Pitch.c4, mode=Mode(...)}"
  __tostring = function(self)
    return string.format("Scale{tonic=%s, mode=%s}", self.tonic, self.mode)
  end,
}

--- Schema for find_chord arguments.
local FindChordArgs = Schema{
  __name='FindChordArgs',
  type=Table,
  properties={
    scale={type=Scale},
    quality={type=Quality},
    nth={type=Integer},
    direction={type=Integer},
    scale_indices={type=List},
    max_octaves={type=Integer},
  },
  required={'scale', 'quality'},
}

--- Finds the nth chord of a given quality in a scale.
-- Searches degree by degree, one octave at a time, for a set of
-- scale degrees whose pitches match the requested quality.
-- @param args Search parameters
-- @param args.scale The Scale to search
-- @param args.quality The chord Quality to find
-- @param args.nth Which match to return (default: 0, the first)
-- @param args.direction Direction.up or Direction.down (default: up)
-- @param args.scale_indices Relative degrees forming the chord
-- (default: {0, 2, 4})
-- @param args.max_octaves Maximum octaves to search (default: 10)
-- @return Chord matching the quality, or nil if none is found
-- @usage
-- local chord = find_chord{scale=c_major, quality=Quality.minor}
function find_chord(args)
  check_arguments{args=FindChordArgs}
  local scale = args.scale
  local quality = args.quality
  local nth = args.nth or 0
  local direction = args.direction or Direction.up
  local relative_scale_indices = args.scale_indices or List{0, 2, 4}
  local max_octaves = args.max_octaves or 10
  local number_found = 0
  -- Search one octave at a time.
  local start = 0
  local finish = direction * #scale
  local octaves_searched = 0
  while octaves_searched < max_octaves do
    for i, root_scale_index in range(start, finish, direction) do
      local absolute_scale_indices =
        map(function(scale_index)
          return scale_index + root_scale_index
        end, relative_scale_indices)
      local test_quality = Quality{pitches=scale[absolute_scale_indices]}

      if test_quality == quality then
        if number_found == nth then
          return Chord{root=scale:to_pitch(root_scale_index),
                       quality=quality}
        end
        number_found = number_found + 1
      end
    end
    start = start + direction * #scale
    finish = finish + direction * #scale
    octaves_searched = octaves_searched + 1
    -- If after one full octave there have not been any matches,
    -- there won't be any matches going forward either. We should
    -- return nil. If there was at least one match though, we should
    -- keep searching until we find the nth match
    if number_found == 0 then
      return nil
    end
  end
  return nil
end

return _M
