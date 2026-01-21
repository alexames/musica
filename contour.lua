-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--[[
Contour Module
==============

A Contour defines rules and constraints for melodic shapes. It serves three purposes:

1. **Rule Definition**: Specify what features a melody must have to match the contour.
   - Directional constraints (ascending, descending, alternating, etc.)
   - Boundary constraints (start/end pitches or scale degrees)
   - Interval constraints (step-wise motion, leaps, maximum interval size)
   - Pitch set constraints (must use notes from a scale/chord)
   - Range constraints (minimum/maximum pitch boundaries)

2. **Matching**: Given a melody (list of pitches or notes), determine if it conforms
   to the contour's rules.

3. **Generation**: Generate one or more possible melodies that satisfy the contour's
   rules, which can then be ranked and selected.

Example usage:
  -- Create an ascending contour that starts on the tonic and ends on the 5th
  local contour = Contour{
    direction = Contour.Direction.ascending,
    start_scale_degree = 0,  -- tonic
    end_scale_degree = 4,    -- 5th
    motion = Contour.Motion.stepwise,
    scale = Scale{tonic=Pitch.c4, mode=Mode.major},
  }

  -- Check if a melody matches
  local matches = contour:matches(melody)

  -- Generate melodies that fit
  local candidates = contour:generate{count=10, length=8}
]]

local direction = require 'musica.direction'
local enum = require 'llx.enum'.enum
local llx = require 'llx'
local note = require 'musica.note'
local pitch = require 'musica.pitch'
local pitch_interval = require 'musica.pitch_interval'
local scale = require 'musica.scale'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local check_arguments = llx.check_arguments
local class = llx.class
local Direction = direction.Direction
local isinstance = llx.isinstance
local List = llx.List
local map = llx.functional.map
local Note = note.Note
local Number = llx.Number
local Pitch = pitch.Pitch
local PitchInterval = pitch_interval.PitchInterval
local Scale = scale.Scale
local Schema = llx.Schema
local Set = llx.Set
local Table = llx.Table
local tointeger = llx.tointeger

--------------------------------------------------------------------------------
-- Rule Types
--------------------------------------------------------------------------------

--- Directional shape constraints
Shape = enum 'Shape' {
  'any',              -- No directional constraint
  'ascending',        -- Monotonically rising (each note >= previous)
  'descending',       -- Monotonically falling (each note <= previous)
  'strict_ascending', -- Strictly rising (each note > previous)
  'strict_descending',-- Strictly falling (each note < previous)
  'arch',             -- Rise then fall (inverted U shape)
  'trough',           -- Fall then rise (U shape)
  'alternating',      -- Notes alternate up/down (like a trill or oscillation)
  'drone',            -- All notes are the same pitch
  'returning',        -- Ends on the same pitch it started
}

--- Motion constraints (how notes move from one to the next)
Motion = enum 'Motion' {
  'any',              -- No motion constraint
  'stepwise',         -- Only scale steps (no leaps)
  'leaps',            -- Only leaps (no stepwise motion)
  'mixed',            -- Both steps and leaps allowed
}

--------------------------------------------------------------------------------
-- Rule Class - Individual constraint that can be checked
--------------------------------------------------------------------------------

local RuleArgs = Schema{
  __name = 'RuleArgs',
  type = Table,
  properties = {
    name = {type = llx.String},
    check = {type = llx.Function},
    description = {type = llx.String},
  },
  required = {'name', 'check'},
}

Rule = class 'Rule' {
  __init = function(self, args)
    self.name = args.name
    self.check = args.check
    self.description = args.description or args.name
  end,

  --- Check if a melody satisfies this rule
  --- @param melody List of pitches or notes
  --- @param context Table with scale, chord, and other context
  --- @return boolean, string|nil (success, error message if failed)
  evaluate = function(self, melody, context)
    return self.check(melody, context)
  end,

  __tostring = function(self)
    return string.format("Rule{name='%s'}", self.name)
  end,
}

--------------------------------------------------------------------------------
-- Helper functions for extracting pitch information
--------------------------------------------------------------------------------

--- Extract pitches from a melody (handles both Note objects and raw Pitches)
local function extract_pitches(melody)
  local pitches = List{}
  for i, item in ipairs(melody) do
    if isinstance(item, Note) then
      pitches[i] = item.pitch
    elseif isinstance(item, Pitch) then
      pitches[i] = item
    elseif type(item) == 'number' then
      pitches[i] = Pitch{pitch_index = item}
    else
      pitches[i] = item.pitch or item
    end
  end
  return pitches
end

--- Get directional contour (list of -1, 0, 1 for down, same, up)
local function get_directions(pitches)
  local dirs = List{}
  for i = 2, #pitches do
    local prev = tointeger(pitches[i-1])
    local curr = tointeger(pitches[i])
    if curr > prev then
      dirs:insert(Direction.up)
    elseif curr < prev then
      dirs:insert(Direction.down)
    else
      dirs:insert(Direction.same)
    end
  end
  return dirs
end

--- Get intervals between consecutive pitches (in semitones)
local function get_intervals(pitches)
  local intervals = List{}
  for i = 2, #pitches do
    local interval = tointeger(pitches[i]) - tointeger(pitches[i-1])
    intervals:insert(interval)
  end
  return intervals
end

--------------------------------------------------------------------------------
-- Built-in Rule Factories
--------------------------------------------------------------------------------

--- Create a rule that checks the overall shape/direction
function shape_rule(shape)
  local shape_name = shape.name or tostring(shape)
  return Rule{
    name = 'shape_' .. shape_name,
    description = 'Melody must have ' .. shape_name .. ' shape',
    check = function(melody, context)
      local pitches = extract_pitches(melody)
      if #pitches < 2 then
        return true  -- Single note trivially satisfies any shape
      end

      local dirs = get_directions(pitches)

      if shape == Shape.any then
        return true

      elseif shape == Shape.ascending then
        for _, d in ipairs(dirs) do
          if d == Direction.down then
            return false, "Found descending motion in ascending contour"
          end
        end
        return true

      elseif shape == Shape.strict_ascending then
        for _, d in ipairs(dirs) do
          if d ~= Direction.up then
            return false, "Found non-ascending motion in strict ascending contour"
          end
        end
        return true

      elseif shape == Shape.descending then
        for _, d in ipairs(dirs) do
          if d == Direction.up then
            return false, "Found ascending motion in descending contour"
          end
        end
        return true

      elseif shape == Shape.strict_descending then
        for _, d in ipairs(dirs) do
          if d ~= Direction.down then
            return false, "Found non-descending motion in strict descending contour"
          end
        end
        return true

      elseif shape == Shape.drone then
        for _, d in ipairs(dirs) do
          if d ~= Direction.same then
            return false, "Found pitch change in drone contour"
          end
        end
        return true

      elseif shape == Shape.returning then
        local first = tointeger(pitches[1])
        local last = tointeger(pitches[#pitches])
        if first ~= last then
          return false, "Melody does not return to starting pitch"
        end
        return true

      elseif shape == Shape.arch then
        -- Find the peak and verify rise-then-fall pattern
        local peak_idx = 1
        local peak_val = tointeger(pitches[1])
        for i, p in ipairs(pitches) do
          if tointeger(p) > peak_val then
            peak_val = tointeger(p)
            peak_idx = i
          end
        end
        -- Before peak: should be ascending or same
        for i = 2, peak_idx do
          if dirs[i-1] == Direction.down then
            return false, "Found descent before arch peak"
          end
        end
        -- After peak: should be descending or same
        for i = peak_idx + 1, #pitches do
          if dirs[i-1] == Direction.up then
            return false, "Found ascent after arch peak"
          end
        end
        return true

      elseif shape == Shape.trough then
        -- Find the trough and verify fall-then-rise pattern
        local trough_idx = 1
        local trough_val = tointeger(pitches[1])
        for i, p in ipairs(pitches) do
          if tointeger(p) < trough_val then
            trough_val = tointeger(p)
            trough_idx = i
          end
        end
        -- Before trough: should be descending or same
        for i = 2, trough_idx do
          if dirs[i-1] == Direction.up then
            return false, "Found ascent before trough bottom"
          end
        end
        -- After trough: should be ascending or same
        for i = trough_idx + 1, #pitches do
          if dirs[i-1] == Direction.down then
            return false, "Found descent after trough bottom"
          end
        end
        return true

      elseif shape == Shape.alternating then
        -- Each direction should be opposite of previous (ignoring same)
        local last_dir = nil
        for _, d in ipairs(dirs) do
          if d ~= Direction.same then
            if last_dir ~= nil and d == last_dir then
              return false, "Found consecutive same-direction motion in alternating contour"
            end
            last_dir = d
          end
        end
        return true
      end

      return true
    end,
  }
end

--- Create a rule that checks the starting pitch/scale degree
function start_rule(args)
  local pitch_val = args.pitch
  local scale_degree = args.scale_degree

  return Rule{
    name = 'start',
    description = pitch_val and ('Start on pitch ' .. tostring(pitch_val))
                             or ('Start on scale degree ' .. tostring(scale_degree)),
    check = function(melody, context)
      local pitches = extract_pitches(melody)
      if #pitches == 0 then
        return true
      end

      local first = pitches[1]

      if pitch_val then
        if tointeger(first) ~= tointeger(pitch_val) then
          return false, string.format("Expected start pitch %s, got %s", pitch_val, first)
        end
      elseif scale_degree and context.scale then
        local expected = context.scale:to_pitch(scale_degree)
        -- Compare pitch class (ignore octave) if not strict
        local first_class = tointeger(first) % 12
        local expected_class = tointeger(expected) % 12
        if first_class ~= expected_class then
          return false, string.format("Expected start scale degree %d, got pitch %s",
                                      scale_degree, first)
        end
      end

      return true
    end,
  }
end

--- Create a rule that checks the ending pitch/scale degree
function end_rule(args)
  local pitch_val = args.pitch
  local scale_degree = args.scale_degree

  return Rule{
    name = 'end',
    description = pitch_val and ('End on pitch ' .. tostring(pitch_val))
                             or ('End on scale degree ' .. tostring(scale_degree)),
    check = function(melody, context)
      local pitches = extract_pitches(melody)
      if #pitches == 0 then
        return true
      end

      local last = pitches[#pitches]

      if pitch_val then
        if tointeger(last) ~= tointeger(pitch_val) then
          return false, string.format("Expected end pitch %s, got %s", pitch_val, last)
        end
      elseif scale_degree and context.scale then
        local expected = context.scale:to_pitch(scale_degree)
        local last_class = tointeger(last) % 12
        local expected_class = tointeger(expected) % 12
        if last_class ~= expected_class then
          return false, string.format("Expected end scale degree %d, got pitch %s",
                                      scale_degree, last)
        end
      end

      return true
    end,
  }
end

--- Create a rule that checks motion type (stepwise, leaps, etc.)
function motion_rule(motion, max_step_interval)
  max_step_interval = max_step_interval or 2  -- Default: 2 semitones = whole step
  local motion_name = motion.name or tostring(motion)

  return Rule{
    name = 'motion_' .. motion_name,
    description = 'Melody must use ' .. motion_name .. ' motion',
    check = function(melody, context)
      local pitches = extract_pitches(melody)
      if #pitches < 2 then
        return true
      end

      local intervals = get_intervals(pitches)

      if motion == Motion.any or motion == Motion.mixed then
        return true

      elseif motion == Motion.stepwise then
        for _, interval in ipairs(intervals) do
          if math.abs(interval) > max_step_interval then
            return false, string.format("Found leap of %d semitones in stepwise contour",
                                        interval)
          end
        end
        return true

      elseif motion == Motion.leaps then
        for _, interval in ipairs(intervals) do
          if math.abs(interval) <= max_step_interval and interval ~= 0 then
            return false, string.format("Found step of %d semitones in leaps-only contour",
                                        interval)
          end
        end
        return true
      end

      return true
    end,
  }
end

--- Create a rule that limits the maximum interval size
function max_interval_rule(max_semitones)
  return Rule{
    name = 'max_interval',
    description = 'Maximum interval of ' .. max_semitones .. ' semitones',
    check = function(melody, context)
      local pitches = extract_pitches(melody)
      local intervals = get_intervals(pitches)

      for _, interval in ipairs(intervals) do
        if math.abs(interval) > max_semitones then
          return false, string.format("Interval of %d exceeds maximum of %d semitones",
                                      math.abs(interval), max_semitones)
        end
      end

      return true
    end,
  }
end

--- Create a rule that enforces minimum interval size
function min_interval_rule(min_semitones)
  return Rule{
    name = 'min_interval',
    description = 'Minimum interval of ' .. min_semitones .. ' semitones',
    check = function(melody, context)
      local pitches = extract_pitches(melody)
      local intervals = get_intervals(pitches)

      for _, interval in ipairs(intervals) do
        if interval ~= 0 and math.abs(interval) < min_semitones then
          return false, string.format("Interval of %d is below minimum of %d semitones",
                                      math.abs(interval), min_semitones)
        end
      end

      return true
    end,
  }
end

--- Create a rule that all pitches must be within a scale
function scale_rule()
  return Rule{
    name = 'in_scale',
    description = 'All pitches must be in the scale',
    check = function(melody, context)
      if not context.scale then
        return true  -- No scale specified, rule passes
      end

      local pitches = extract_pitches(melody)
      for i, p in ipairs(pitches) do
        if not context.scale:contains(p) then
          return false, string.format("Pitch %s at position %d is not in scale", p, i)
        end
      end

      return true
    end,
  }
end

--- Create a rule that all pitches must be within a chord
function chord_rule()
  return Rule{
    name = 'in_chord',
    description = 'All pitches must be chord tones',
    check = function(melody, context)
      if not context.chord then
        return true  -- No chord specified, rule passes
      end

      local pitches = extract_pitches(melody)
      for i, p in ipairs(pitches) do
        if not context.chord:contains(p) then
          return false, string.format("Pitch %s at position %d is not a chord tone", p, i)
        end
      end

      return true
    end,
  }
end

--- Create a rule that enforces pitch range
function range_rule(min_pitch, max_pitch)
  return Rule{
    name = 'range',
    description = string.format('Pitches must be between %s and %s', min_pitch, max_pitch),
    check = function(melody, context)
      local pitches = extract_pitches(melody)
      local min_val = tointeger(min_pitch)
      local max_val = tointeger(max_pitch)

      for i, p in ipairs(pitches) do
        local val = tointeger(p)
        if val < min_val or val > max_val then
          return false, string.format("Pitch %s at position %d is outside range", p, i)
        end
      end

      return true
    end,
  }
end

--- Create a rule for total melodic range (highest - lowest)
function span_rule(min_span, max_span)
  return Rule{
    name = 'span',
    description = string.format('Melodic span between %d and %d semitones',
                                min_span or 0, max_span or 127),
    check = function(melody, context)
      local pitches = extract_pitches(melody)
      if #pitches < 2 then
        return true
      end

      local min_val = math.huge
      local max_val = -math.huge
      for _, p in ipairs(pitches) do
        local val = tointeger(p)
        min_val = math.min(min_val, val)
        max_val = math.max(max_val, val)
      end

      local span = max_val - min_val

      if min_span and span < min_span then
        return false, string.format("Span of %d is below minimum of %d", span, min_span)
      end
      if max_span and span > max_span then
        return false, string.format("Span of %d exceeds maximum of %d", span, max_span)
      end

      return true
    end,
  }
end

--- Create a custom rule from a function
function custom_rule(name, check_fn, description)
  return Rule{
    name = name,
    description = description or name,
    check = check_fn,
  }
end

--------------------------------------------------------------------------------
-- Contour Class
--------------------------------------------------------------------------------

local ContourArgs = Schema{
  __name = 'ContourArgs',
  type = Table,
  properties = {
    shape = {type = llx.String},
    motion = {type = llx.String},
    start_pitch = {type = llx.Any},
    end_pitch = {type = llx.Any},
    start_scale_degree = {type = llx.Integer},
    end_scale_degree = {type = llx.Integer},
    scale = {type = llx.Any},
    chord = {type = llx.Any},
    min_pitch = {type = llx.Any},
    max_pitch = {type = llx.Any},
    max_interval = {type = llx.Integer},
    min_interval = {type = llx.Integer},
    min_span = {type = llx.Integer},
    max_span = {type = llx.Integer},
    rules = {type = llx.List},
    require_in_scale = {type = llx.Boolean},
    require_in_chord = {type = llx.Boolean},
  },
}

Contour = class 'Contour' {
  --- Initialize a Contour with rules and constraints
  __init = function(self, args)
    args = args or {}
    self.rules = List{}
    self.scale = args.scale
    self.chord = args.chord

    -- Add shape rule if specified
    if args.shape then
      self.rules:insert(shape_rule(args.shape))
    end

    -- Add motion rule if specified
    if args.motion then
      self.rules:insert(motion_rule(args.motion, args.max_step_interval))
    end

    -- Add start constraint
    if args.start_pitch then
      self.rules:insert(start_rule{pitch = args.start_pitch})
    elseif args.start_scale_degree then
      self.rules:insert(start_rule{scale_degree = args.start_scale_degree})
    end

    -- Add end constraint
    if args.end_pitch then
      self.rules:insert(end_rule{pitch = args.end_pitch})
    elseif args.end_scale_degree then
      self.rules:insert(end_rule{scale_degree = args.end_scale_degree})
    end

    -- Add interval constraints
    if args.max_interval then
      self.rules:insert(max_interval_rule(args.max_interval))
    end
    if args.min_interval then
      self.rules:insert(min_interval_rule(args.min_interval))
    end

    -- Add range constraints
    if args.min_pitch or args.max_pitch then
      local min_p = args.min_pitch or Pitch{pitch_index = 0}
      local max_p = args.max_pitch or Pitch{pitch_index = 127}
      self.rules:insert(range_rule(min_p, max_p))
    end

    -- Add span constraints
    if args.min_span or args.max_span then
      self.rules:insert(span_rule(args.min_span, args.max_span))
    end

    -- Add scale/chord rules
    if args.require_in_scale or args.scale then
      self.rules:insert(scale_rule())
    end
    if args.require_in_chord then
      self.rules:insert(chord_rule())
    end

    -- Add any custom rules
    if args.rules then
      for _, rule in ipairs(args.rules) do
        self.rules:insert(rule)
      end
    end
  end,

  --- Add a rule to this contour
  add_rule = function(self, rule)
    self.rules:insert(rule)
    return self
  end,

  --- Get the evaluation context (scale, chord, etc.)
  get_context = function(self)
    return {
      scale = self.scale,
      chord = self.chord,
    }
  end,

  --- Check if a melody matches all rules
  --- @param melody List of pitches or notes
  --- @return boolean success
  --- @return List|nil list of error messages if failed
  matches = function(self, melody)
    local context = self:get_context()
    local errors = List{}

    for _, rule in ipairs(self.rules) do
      local success, err = rule:evaluate(melody, context)
      if not success then
        errors:insert(string.format("[%s] %s", rule.name, err or "failed"))
      end
    end

    if #errors > 0 then
      return false, errors
    end
    return true
  end,

  --- Generate melodies that satisfy all constraints
  --- @param args Table with:
  ---   length: number of notes to generate
  ---   count: number of candidates to generate (default 1)
  ---   rhythm: optional Rhythm object for note durations
  ---   duration: default note duration if no rhythm (default 1.0)
  ---   volume: default note volume (default 1.0)
  --- @return List of Figure objects (melodies that satisfy constraints)
  generate = function(self, args)
    local length = args.length or 8
    local count = args.count or 1
    local rhythm = args.rhythm
    local duration = args.duration or 1.0
    local volume = args.volume or 1.0
    local max_attempts = args.max_attempts or (count * 100)

    local context = self:get_context()
    local candidates = List{}
    local attempts = 0

    -- Determine the pitch pool
    local pitch_pool = self:_build_pitch_pool(args)

    while #candidates < count and attempts < max_attempts do
      attempts = attempts + 1
      local pitches = self:_generate_candidate(length, pitch_pool, context, args)

      if pitches and self:matches(pitches) then
        local figure = self:_pitches_to_figure(pitches, rhythm, duration, volume)
        candidates:insert(figure)
      end
    end

    return candidates
  end,

  --- Enumerate all melodies that satisfy the constraints
  --- This is an exhaustive search, useful when you want to rank all possibilities.
  --- @param args Table with:
  ---   length: number of notes to generate
  ---   rhythm: optional Rhythm object for note durations
  ---   duration: default note duration if no rhythm (default 1.0)
  ---   volume: default note volume (default 1.0)
  ---   max_results: optional limit on number of results (default unlimited)
  ---   as_pitches: if true, return pitch lists instead of Figures (default false)
  --- @return List of Figure objects (or pitch lists if as_pitches=true)
  enumerate = function(self, args)
    args = args or {}
    local length = args.length or 4
    local rhythm = args.rhythm
    local duration = args.duration or 1.0
    local volume = args.volume or 1.0
    local max_results = args.max_results
    local as_pitches = args.as_pitches or false

    local pitch_pool = self:_build_pitch_pool(args)
    local results = List{}

    -- Recursive backtracking to enumerate all valid melodies
    local function backtrack(current_melody, position)
      -- Check if we've hit the result limit
      if max_results and #results >= max_results then
        return
      end

      -- If melody is complete, validate and add to results
      if position > length then
        if self:matches(current_melody) then
          if as_pitches then
            -- Return a copy of the pitch list
            local copy = List{}
            for _, p in ipairs(current_melody) do
              copy:insert(p)
            end
            results:insert(copy)
          else
            results:insert(self:_pitches_to_figure(current_melody, rhythm, duration, volume))
          end
        end
        return
      end

      -- Determine valid pitches for this position
      local valid_pitches = self:_get_valid_pitches_at_position(
        current_melody, position, length, pitch_pool, args)

      for _, pitch_val in ipairs(valid_pitches) do
        current_melody[position] = pitch_val
        backtrack(current_melody, position + 1)
        current_melody[position] = nil
      end
    end

    backtrack(List{}, 1)
    return results
  end,

  --- Get pitches that are valid at a specific position given current melody state
  --- Used by enumerate for efficient pruning
  _get_valid_pitches_at_position = function(self, current_melody, position, length, pitch_pool, args)
    local valid = List{}
    local context = self:get_context()

    for _, pitch_val in ipairs(pitch_pool) do
      -- Build a test melody up to this position
      local test_melody = List{}
      for i = 1, position - 1 do
        test_melody[i] = current_melody[i]
      end
      test_melody[position] = pitch_val

      -- Check constraints that can be evaluated with partial melody
      local is_valid = true

      -- Check start constraint (only at position 1)
      if position == 1 then
        for _, rule in ipairs(self.rules) do
          if rule.name == 'start' then
            local success = rule:evaluate(test_melody, context)
            if not success then
              is_valid = false
              break
            end
          end
        end
      end

      -- Check interval constraints with previous note
      if is_valid and position > 1 then
        local prev_pitch = current_melody[position - 1]
        local interval = tointeger(pitch_val) - tointeger(prev_pitch)

        -- Check shape bias
        local shape_bias = self:_get_shape_bias(test_melody, position, length)
        if not self:_is_valid_interval(interval, shape_bias, args) then
          is_valid = false
        end

        -- Check max/min interval rules
        if is_valid then
          for _, rule in ipairs(self.rules) do
            if rule.name == 'max_interval' then
              local max_int = args.max_interval or 12
              if math.abs(interval) > max_int then
                is_valid = false
                break
              end
            end
            if rule.name == 'min_interval' then
              local min_int = args.min_interval or 0
              if interval ~= 0 and math.abs(interval) < min_int then
                is_valid = false
                break
              end
            end
          end
        end
      end

      -- Check scale/chord membership
      if is_valid then
        for _, rule in ipairs(self.rules) do
          if rule.name == 'in_scale' or rule.name == 'in_chord' then
            local success = rule:evaluate({pitch_val}, context)
            if not success then
              is_valid = false
              break
            end
          end
        end
      end

      -- Check range constraints
      if is_valid then
        for _, rule in ipairs(self.rules) do
          if rule.name == 'range' then
            local success = rule:evaluate({pitch_val}, context)
            if not success then
              is_valid = false
              break
            end
          end
        end
      end

      if is_valid then
        valid:insert(pitch_val)
      end
    end

    return valid
  end,

  --- Iterator version of enumerate for lazy evaluation
  --- Usage: for melody in contour:iter_melodies{length=4} do ... end
  --- @param args Same as enumerate
  --- @return Iterator function yielding Figure objects (or pitch lists)
  iter_melodies = function(self, args)
    args = args or {}
    local length = args.length or 4
    local rhythm = args.rhythm
    local duration = args.duration or 1.0
    local volume = args.volume or 1.0
    local as_pitches = args.as_pitches or false

    local pitch_pool = self:_build_pitch_pool(args)

    -- Coroutine-based iterator for lazy evaluation
    local co = coroutine.create(function()
      local function backtrack(current_melody, position)
        if position > length then
          if self:matches(current_melody) then
            if as_pitches then
              local copy = List{}
              for _, p in ipairs(current_melody) do
                copy:insert(p)
              end
              coroutine.yield(copy)
            else
              coroutine.yield(self:_pitches_to_figure(current_melody, rhythm, duration, volume))
            end
          end
          return
        end

        local valid_pitches = self:_get_valid_pitches_at_position(
          current_melody, position, length, pitch_pool, args)

        for _, pitch_val in ipairs(valid_pitches) do
          current_melody[position] = pitch_val
          backtrack(current_melody, position + 1)
          current_melody[position] = nil
        end
      end

      backtrack(List{}, 1)
    end)

    return function()
      if coroutine.status(co) == 'dead' then
        return nil
      end
      local ok, result = coroutine.resume(co)
      if ok and result then
        return result
      end
      return nil
    end
  end,

  --- Build the pool of available pitches based on constraints
  _build_pitch_pool = function(self, args)
    local pool = List{}

    -- If we have a scale, use scale pitches
    if self.scale then
      local min_idx = args.min_pitch and tointeger(args.min_pitch) or 36  -- C2
      local max_idx = args.max_pitch and tointeger(args.max_pitch) or 96  -- C7

      -- Generate all scale pitches in the range
      for scale_idx = -24, 24 do  -- Roughly 3 octaves each direction
        local pitch_val = self.scale:to_pitch(scale_idx)
        local pitch_idx = tointeger(pitch_val)
        if pitch_idx >= min_idx and pitch_idx <= max_idx then
          pool:insert(pitch_val)
        end
      end
    elseif self.chord then
      -- Use chord tones
      local min_idx = args.min_pitch and tointeger(args.min_pitch) or 36
      local max_idx = args.max_pitch and tointeger(args.max_pitch) or 96

      for chord_idx = -12, 12 do
        local pitch_val = self.chord:to_extended_pitch(chord_idx, PitchInterval.octave)
        if pitch_val then
          local pitch_idx = tointeger(pitch_val)
          if pitch_idx >= min_idx and pitch_idx <= max_idx then
            pool:insert(pitch_val)
          end
        end
      end
    else
      -- Use chromatic pitches in range
      local min_idx = args.min_pitch and tointeger(args.min_pitch) or 48  -- C3
      local max_idx = args.max_pitch and tointeger(args.max_pitch) or 84  -- C6

      for i = min_idx, max_idx do
        pool:insert(Pitch{pitch_index = i})
      end
    end

    -- Sort by pitch index for easier navigation
    table.sort(pool, function(a, b)
      return tointeger(a) < tointeger(b)
    end)

    return pool
  end,

  --- Generate a single candidate melody
  _generate_candidate = function(self, length, pitch_pool, context, args)
    if #pitch_pool == 0 then
      return nil
    end

    local pitches = List{}

    -- Determine start pitch
    local start_pitch = self:_find_start_pitch(pitch_pool, context, args)
    if not start_pitch then
      return nil
    end
    pitches:insert(start_pitch)

    -- Determine end pitch (so we can aim toward it)
    local end_pitch = self:_find_end_pitch(pitch_pool, context, args)

    -- Generate intermediate pitches
    for i = 2, length do
      local next_pitch = self:_pick_next_pitch(pitches, pitch_pool, i, length, end_pitch, args)
      if not next_pitch then
        return nil  -- Failed to generate
      end
      pitches:insert(next_pitch)
    end

    return pitches
  end,

  --- Find a valid starting pitch
  _find_start_pitch = function(self, pitch_pool, context, args)
    -- Check if there's a specific start constraint
    for _, rule in ipairs(self.rules) do
      if rule.name == 'start' then
        -- Find matching pitch in pool
        for _, p in ipairs(pitch_pool) do
          local test_melody = List{p}
          local success = rule:evaluate(test_melody, context)
          if success then
            return p
          end
        end
        return nil  -- No valid start found
      end
    end

    -- No specific start constraint, pick randomly from middle of range
    local mid_idx = math.floor(#pitch_pool / 2)
    local range = math.floor(#pitch_pool / 4)
    local idx = mid_idx + math.random(-range, range)
    idx = math.max(1, math.min(#pitch_pool, idx))
    return pitch_pool[idx]
  end,

  --- Find a valid ending pitch
  _find_end_pitch = function(self, pitch_pool, context, args)
    for _, rule in ipairs(self.rules) do
      if rule.name == 'end' then
        for _, p in ipairs(pitch_pool) do
          local test_melody = List{p}
          local success = rule:evaluate(test_melody, context)
          if success then
            return p
          end
        end
      end
    end
    return nil  -- No specific end constraint
  end,

  --- Pick the next pitch based on constraints and current melody state
  _pick_next_pitch = function(self, pitches, pitch_pool, position, length, end_pitch, args)
    local current_pitch = pitches[#pitches]
    local current_idx = tointeger(current_pitch)

    -- Build list of valid candidates
    local candidates = List{}

    -- Determine shape bias
    local shape_bias = self:_get_shape_bias(pitches, position, length)

    -- Find current position in pool
    local pool_idx = 1
    for i, p in ipairs(pitch_pool) do
      if tointeger(p) >= current_idx then
        pool_idx = i
        break
      end
    end

    -- Consider nearby pitches
    local search_range = math.min(12, math.floor(#pitch_pool / 2))
    for offset = -search_range, search_range do
      local try_idx = pool_idx + offset
      if try_idx >= 1 and try_idx <= #pitch_pool then
        local candidate = pitch_pool[try_idx]
        local interval = tointeger(candidate) - current_idx

        -- Skip if interval is invalid for this contour
        if self:_is_valid_interval(interval, shape_bias, args) then
          local score = self:_score_candidate(candidate, pitches, position, length,
                                               end_pitch, shape_bias)
          candidates:insert({pitch = candidate, score = score})
        end
      end
    end

    if #candidates == 0 then
      return nil
    end

    -- Sort by score (higher is better)
    table.sort(candidates, function(a, b)
      return a.score > b.score
    end)

    -- Pick from top candidates with some randomness
    local top_count = math.min(3, #candidates)
    local pick_idx = math.random(1, top_count)
    return candidates[pick_idx].pitch
  end,

  --- Get directional bias based on shape rule
  _get_shape_bias = function(self, pitches, position, length)
    for _, rule in ipairs(self.rules) do
      if rule.name:match('^shape_') then
        local shape_name = rule.name:gsub('^shape_', '')

        if shape_name == Shape.ascending.name or shape_name == Shape.strict_ascending.name then
          return Direction.up
        elseif shape_name == Shape.descending.name or shape_name == Shape.strict_descending.name then
          return Direction.down
        elseif shape_name == Shape.drone.name then
          return Direction.same
        elseif shape_name == Shape.arch.name then
          -- Rise in first half, fall in second half
          if position <= length / 2 then
            return Direction.up
          else
            return Direction.down
          end
        elseif shape_name == Shape.trough.name then
          if position <= length / 2 then
            return Direction.down
          else
            return Direction.up
          end
        elseif shape_name == Shape.alternating.name then
          -- Alternate based on last direction
          if #pitches >= 2 then
            local last_interval = tointeger(pitches[#pitches]) - tointeger(pitches[#pitches - 1])
            if last_interval > 0 then
              return Direction.down
            elseif last_interval < 0 then
              return Direction.up
            end
          end
        end
      end
    end
    return nil  -- No bias
  end,

  --- Check if an interval is valid given constraints
  _is_valid_interval = function(self, interval, shape_bias, args)
    -- Check direction constraint
    if shape_bias == Direction.up and interval < 0 then
      return false
    elseif shape_bias == Direction.down and interval > 0 then
      return false
    elseif shape_bias == Direction.same and interval ~= 0 then
      return false
    end

    -- Check motion constraint
    for _, rule in ipairs(self.rules) do
      if rule.name:match('^motion_') then
        local motion_name = rule.name:gsub('^motion_', '')
        local max_step = args.max_step_interval or 2

        if motion_name == Motion.stepwise.name and math.abs(interval) > max_step then
          return false
        elseif motion_name == Motion.leaps.name and math.abs(interval) <= max_step and interval ~= 0 then
          return false
        end
      end

      -- Check interval size rules
      if rule.name == 'max_interval' then
        -- Extract max from rule (this is a bit hacky, could be improved)
        local max_int = args.max_interval or 12
        if math.abs(interval) > max_int then
          return false
        end
      end
      if rule.name == 'min_interval' then
        local min_int = args.min_interval or 0
        if interval ~= 0 and math.abs(interval) < min_int then
          return false
        end
      end
    end

    return true
  end,

  --- Score a candidate pitch (higher = better)
  _score_candidate = function(self, candidate, pitches, position, length, end_pitch, shape_bias)
    local score = 10  -- Base score

    local current = pitches[#pitches]
    local interval = tointeger(candidate) - tointeger(current)

    -- Prefer direction that matches bias
    if shape_bias == Direction.up and interval > 0 then
      score = score + 5
    elseif shape_bias == Direction.down and interval < 0 then
      score = score + 5
    elseif shape_bias == Direction.same and interval == 0 then
      score = score + 5
    end

    -- If near end and we have an end target, move toward it
    if end_pitch and position > length * 0.6 then
      local end_idx = tointeger(end_pitch)
      local cand_idx = tointeger(candidate)
      local curr_idx = tointeger(current)

      local curr_dist = math.abs(end_idx - curr_idx)
      local cand_dist = math.abs(end_idx - cand_idx)

      if cand_dist < curr_dist then
        score = score + (length - position)  -- More points closer to end
      end
    end

    -- Slight preference for smaller intervals (more singable)
    score = score - math.abs(interval) * 0.1

    -- Add some randomness
    score = score + math.random() * 2

    return score
  end,

  --- Convert pitches to a Figure
  _pitches_to_figure = function(self, pitches, rhythm, default_duration, volume)
    local figure = require 'musica.figure'
    local notes = List{}
    local time = 0

    for i, pitch_val in ipairs(pitches) do
      local dur = default_duration
      if rhythm and rhythm.durations and rhythm.durations[i] then
        dur = rhythm.durations[i]
      elseif rhythm and rhythm[i] then
        dur = rhythm[i]
      end

      notes:insert(Note{
        pitch = pitch_val,
        time = time,
        duration = dur,
        volume = volume,
      })
      time = time + dur
    end

    return figure.Figure{duration = time, notes = notes}
  end,

  --- Get a string representation of the contour rules
  __tostring = function(self)
    local rule_names = List{}
    for _, rule in ipairs(self.rules) do
      rule_names:insert(rule.name)
    end
    return string.format("Contour{rules={%s}}", table.concat(rule_names, ', '))
  end,
}

-- Attach enums to Contour class for convenient access
Contour.Shape = Shape
Contour.Motion = Motion

--------------------------------------------------------------------------------
-- Pre-defined Contours
--------------------------------------------------------------------------------

--- Ascending melodic line
Contour.ascending = function(args)
  args = args or {}
  args.shape = Shape.ascending
  return Contour(args)
end

--- Strictly ascending (no repeated notes)
Contour.strict_ascending = function(args)
  args = args or {}
  args.shape = Shape.strict_ascending
  return Contour(args)
end

--- Descending melodic line
Contour.descending = function(args)
  args = args or {}
  args.shape = Shape.descending
  return Contour(args)
end

--- Strictly descending
Contour.strict_descending = function(args)
  args = args or {}
  args.shape = Shape.strict_descending
  return Contour(args)
end

--- Arch shape (rise then fall)
Contour.arch = function(args)
  args = args or {}
  args.shape = Shape.arch
  return Contour(args)
end

--- Trough shape (fall then rise)
Contour.trough = function(args)
  args = args or {}
  args.shape = Shape.trough
  return Contour(args)
end

--- Alternating/oscillating pattern
Contour.alternating = function(args)
  args = args or {}
  args.shape = Shape.alternating
  return Contour(args)
end

--- Drone (repeated single pitch)
Contour.drone = function(args)
  args = args or {}
  args.shape = Shape.drone
  return Contour(args)
end

--- Returns to starting pitch
Contour.returning = function(args)
  args = args or {}
  args.shape = Shape.returning
  return Contour(args)
end

--- Stepwise ascending scale run
Contour.scale_run_up = function(args)
  args = args or {}
  args.shape = Shape.strict_ascending
  args.motion = Motion.stepwise
  return Contour(args)
end

--- Stepwise descending scale run
Contour.scale_run_down = function(args)
  args = args or {}
  args.shape = Shape.strict_descending
  args.motion = Motion.stepwise
  return Contour(args)
end

--- Arpeggio ascending (chord tones, leaps)
Contour.arpeggio_up = function(args)
  args = args or {}
  args.shape = Shape.ascending
  args.require_in_chord = true
  return Contour(args)
end

--- Arpeggio descending
Contour.arpeggio_down = function(args)
  args = args or {}
  args.shape = Shape.descending
  args.require_in_chord = true
  return Contour(args)
end

--------------------------------------------------------------------------------
-- Analysis functions (from original file, updated)
--------------------------------------------------------------------------------

--- Extract the directional contour from a melody
--- Returns a list of Direction values (up, down, same)
function directional_contour(melody)
  local pitches = extract_pitches(melody)
  return get_directions(pitches)
end

--- Extract the relative contour (indices based on pitch ordering)
function relative_contour(melody)
  local pitches = extract_pitches(melody)
  local pitch_set = Set{}
  for _, p in ipairs(pitches) do
    pitch_set:insert(tointeger(p))
  end
  local pitch_list = pitch_set:tolist()
  pitch_list:sort()

  local index_mapping = {}
  for index, key in ipairs(pitch_list) do
    index_mapping[key] = index
  end

  local contour = List{}
  for i, p in ipairs(pitches) do
    contour[i] = index_mapping[tointeger(p)]
  end
  return contour
end

--- Extract the pitch index contour (raw MIDI values)
function pitch_index_contour(melody)
  local pitches = extract_pitches(melody)
  local contour = List{}
  for i, p in ipairs(pitches) do
    contour[i] = tointeger(p)
  end
  return contour
end

--- Extract the scale index contour (scale degrees)
function scale_index_contour(melody, scl)
  local pitches = extract_pitches(melody)
  local contour = List{}
  for i, p in ipairs(pitches) do
    contour[i] = scl:to_scale_index(p)
  end
  return contour
end

--- Extract the pitch class contour (0-11 values)
function pitch_class_contour(melody)
  local pitches = extract_pitches(melody)
  local contour = List{}
  for i, p in ipairs(pitches) do
    contour[i] = tointeger(p) % 12
  end
  return contour
end

return _M
