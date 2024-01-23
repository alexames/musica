require 'llx'
require 'musictheory/figure'
require 'musictheory/mode'
require 'musictheory/modes'
require 'musictheory/note'
require 'musictheory/scale'

local melodic_motion = {
  conjunct = 1,
  disjunct = 2,
  stationary = 3,
}

local yield = coroutine.yield
local wrap = coroutine.wrap

rhythm = List{
  {duration=.25, volume=0.1},
  {duration=.25, volume=0.2},
  {duration=.25, volume=0.3},
  {duration=.25, volume=0.3},
}

MonotonicMovementRule = class 'MonotonicMovementRule' {
  __init = function(self, args)
    self.scale = args.scale
    self.source_pitch = args.source_pitch
    self.target_pitch = args.target_pitch
    self.step = args.target_pitch > args.source_pitch
                  and Direction.up
                  or Direction.down
    self.strict = args.strict == nil or args.strict
  end,

  get_pitches = function(self, rhythm, rhythm_index, melody)
    return wrap(function()
      local counter = count()
      -- Monotonically approach.
      if rhythm_index == #rhythm then
        yield(counter(), self.target_pitch)
        return
      end
      local last_note = melody[#melody]
      local last_pitch = last_note and last_note.pitch or self.source_pitch
      local last_scale_index = self.scale:to_scale_index(last_pitch)
      local target_scale_index = self.scale:to_scale_index(self.target_pitch)
      local start, finish
      if self.strict then
        start = last_scale_index + (last_note and self.step or 0)
        finish = target_scale_index
      else
        start = last_scale_index
        finish = target_scale_index + self.step
      end
      for i, scale_index in range(start, finish, self.step) do
        yield(counter(), self.scale[scale_index])
      end
    end)
  end,
}

local generators = {}

function generators.melodies_from_rhythm(rhythm, rules)
  local counter = count()
  local function helper(rhythm_index, melody)
    local beat = rhythm[rhythm_index]
    for i, pitch in rules:get_pitches(rhythm, rhythm_index, melody) do
      local note = Note{
        pitch = pitch,
        duration = beat.duration,
        volume = beat.volume,
        meta = {
          generator = generators.melodies_from_rhythm,
          rhythm = rhythm,
          index = rhythm_index,
          rules = rules,
          -- other stuff, scale and chord maybe?
        }
      }
      local new_melody = List(melody) .. List{note}
      if rhythm_index < #rhythm then
        helper(rhythm_index + 1, new_melody)
      else
        yield(counter(), Figure{melody=new_melody}) -- determine duration from rhythm.
      end
    end
  end
  return wrap(function() helper(1, List{}) end)
end

function generate_melodies(generators)
  return wrap(function()
    local counter = count()
    for i, generator in generators do
      for i, melody in generator do
        yield(counter(), melody)
      end
    end
  end)
end

local gen_list = List{
  generators.melodies_from_rhythm(
    rhythm,
    MonotonicMovementRule{
      scale = Scale{tonic=Pitch.c4, mode=Mode.major},
      source_pitch = Pitch.c4,
      target_pitch = Pitch.g4
    }),
}

local melodic_movement = {
  -- Upwards melodic movement
  ascending = function(args)
    local starting_pitch = args.start.pitch
    local starting_beat = args.start.beat
    local target_pitch = args.start.pitch
    local target_beat = args.start.beat
    local scale = args.scale
    local rhythms = args.rhythms
    local monotonic = args.monotonic

    local beats = target_beat - starting_beat

    local starting_scale_index = scale:to_scale_index(starting_pitch)
    local target_scale_index = scale:to_scale_index(target_pitch)
    local scale_index_delta = target_scale_index - starting_scale_index

    local results = List{}

    for i, rhythm in rhythms do

    end
    return results
  end,

  -- Downwards melodic movement (prevalent in the New World and Australian music)
  descending = function(args)


  end,

  -- Equal movement in both directions, using approximately the same intervals for ascent and descent (prevalent in Old World culture music)
  undulating = function(args)


  end,

  -- Extreme undulation that covers a large range and uses large intervals is called pendulum-type melodic movement
  pendulum = function(args)


  end,

  -- a number of descending phrases in which each phrase begins on a higher pitch than the last ended (prevalent in the North American Plain Indians music)
  cascading = function(args)


  end,

  -- The melody rises and falls in roughly equal amounts, the curve ascending gradually to a climax and then dropping off (prevalent among Navaho Indians and North American Indian music)
  arc = function(args)


  end,

  -- may be considered a musical form, a contrasting section of higher pitch, a "musical plateau".
  rise = function(args)


  end,

}
