require 'llx'
local figure = require 'musictheory/figure'
local note = require 'musictheory/note'
local pitch = require 'musictheory/pitch'
local pitch_interval = require 'musictheory/pitch_interval'
local quality = require 'musictheory/quality'
local util = require 'musictheory/util'

local Figure = figure.Figure
local Note = note.Note
local Pitch = pitch.Pitch
local PitchInterval = pitch_interval.PitchInterval
local Quality = quality.Quality
local multi_index = util.multi_index

local ChordByPitches = Schema{
  __name='ChordByPitches',
  type=Table,
  properties={
    pitches={
      type=List,
      items={type=Pitch},
    },
  },
  required={'pitches'},
}

local ChordByRootQuality = Schema{
  __name='ChordByRootQuality',
  type=Table,
  properties={
    root={type=Pitch},
    quality={type=Quality},
  },
  required={'root', 'quality'},
}

local ChordArgs = Schema{
  __name='ChordArgs',
  type=Union{ChordByPitches, ChordByRootQuality},
}

local Chord
Chord = class 'Chord' {
  __init = function(self, args)
    check_arguments{self=Chord, args=ChordArgs}
    if args.pitches then
      self.root = args.pitches[1]
      self.quality = Quality{pitches=args.pitches}
    else
      self.root = args.root
      self.quality = args.quality or Quality.major
    end
  end,

  get_pitches = function(self)
    check_arguments{self=Chord}
    return self:to_pitches(range(0, #self-1))
  end,

  get_quality = function(self)
    check_arguments{self=Chord}
    return self.quality
  end,

  to_pitch = function(self, chord_index)
    check_arguments{self=Chord, chord_index=Integer}
    return self.root + self.quality[chord_index + 1]
  end,

  to_pitches = function(self, scale_indices)
    check_arguments{self=Chord,
                    scale_indices=Schema{type=List,
                                         items={type=Integer}}}
    return map(function(scale_index)
      return self:to_pitch(scale_index)
    end, scale_indices)
  end,

  to_extended_pitch = function(self, chord_index, extension_interval)
    check_arguments{self=Chord,
                    chord_index=Integer,
                    extension_interval=Optional{PitchInterval}}
    local extension_interval = extension_interval or PitchInterval.octave
    return self.root + util.extended_index(chord_index,
                                           self.quality.pitch_intervals,
                                           extension_interval)
  end,

  to_extended_pitches = function(self, chord_indices, extension_interval)
    check_arguments{self=Chord,
                    chord_indices=Schema{type=Any, items={type=Integer}},
                    extension_interval=Optional{PitchInterval}}
    extension_interval = extension_interval or PitchInterval.octave
    return map(function(chord_index)
      return self:to_extended_pitch(chord_index, extension_interval)
    end, chord_indices)
  end,

  inversion = function(self, n, octave_interval)
    check_arguments{self=Chord,
                    n=Integer,
                    octave_interval=Optional{Integer}}
    octave_interval = octave_interval or PitchInterval.octave
    -- Short circuit if there is nothing to be done.
    if n == 0 then
      return self
    end

    local inverted_intervals = List{}
    for i=1, #self do
      local index = n + i - 1
      local octave_index = index // #self
      local octave_offset = octave_interval * octave_index
      inverted_intervals[i] = self.quality[index % #self + 1] + octave_offset
    end
    return Chord{root=self.root + inverted_intervals[1],
                 quality=Quality{pitch_intervals=inverted_intervals}}
  end,

  contains = function(self, pitch)
    check_arguments{self=Chord, pitch=Pitch}
    return self:get_pitches():find(pitch) ~= nil
  end,

  __eq = function(self, other)
    check_arguments{self=Chord, other=Chord}
    return self.root == other.root and self.quality == other.quality
  end,

  __div = function(self, other)
    check_arguments{self=Chord, other=Union{Pitch,Chord}}
    local other_pitches
    if isinstance(other, Pitch) then
      other_pitches = List{other}
    else
      other_pitches = other:get_pitches()
    end

    local pitches = self:get_pitches()
    pitches = pitches .. other_pitches
    pitches:sort()
    return Chord{pitches=pitches}
  end,

  __len = function(self)
    check_arguments{self=Chord}
    return #self.quality
  end,

  __index = multi_index(function(self, index)
    return self:to_pitch(index)
  end),

  __tostring = function(self)
    check_arguments{self=Chord}
    return string.format('Chord{root=%s, quality=%s}', self.root, self.quality)
  end,
}

function arpeggiate(args)
  check_arguments{
    args=Schema{
      type=Table,
      properties={
        chord={type=Chord},
        duration={type=Number},
        index_pattern_fn={type=Function},
        index_pattern={type=Union{Table,Function}},
        time_step={type=Number},
        volume={type=Number},
        count={type=Integer},
        figure_duration={type=Number},
        extension_interval={type=PitchInterval},
      }
    }
  }
  local chord = args.chord
  local duration = args.duration or 1.0
  local index_pattern = args.index_pattern
  local time_step = args.time_step or duration
  local volume = args.volume
  local figure_duration = args.figure_duration
  local extension_interval = args.extension_interval or PitchInterval.octave

  local chord_indices
  local count
  if index_pattern then
    chord_indices = index_pattern
    -- count = args.count or #chord_indices
  else
    local index_pattern_fn = args.index_pattern_fn or range
    count = args.count or #chord
    chord_indices = List(index_pattern_fn(count))
  end

  local pitches = chord:to_extended_pitches(chord_indices)
  local notes = List{}
  for i, pitch in ipairs(pitches) do
    notes[i] = Note{pitch=pitch, time=(i - 1) * time_step, duration=duration, volume=volume}
  end

  if figure_duration == nil then
    figure_duration = 0
    for i, note in ipairs(notes) do
      local note_end = note.time + note.duration
      if note_end > figure_duration then
        figure_duration = note_end
      end
    end
  end
  return Figure{duration=figure_duration, notes=notes}
end

-- nearest_inversionchord = function, tonic):
--   scale_indices = []
--   for i in interleave(count(1, 1), count(-1, -1)):
--     scale_index = tonic + i
--     if scale_index in chord:
--       scale_indices.append(scale_index)
--     if #scale_indices == #chord.scale_indices:
--       break
--   return Chord(chord.scale, chord.index_offset, scale_indices)


-- modulo_scale_indiceschord = function, lower_bound):
--   # upper bound == implied to be lower_bound + octave
--   octave = #chord.scale.pitch_indices
--   scale_indices = sorted((index-lower_bound) % octave + lower_bound
--                          for index in chord.scale_indices)
--   return Chord(chord.scale, scale_indices[0], indices_to_intervals(scale_indices))

return {
  Chord = Chord,
  arpeggiate = arpeggiate,
}
