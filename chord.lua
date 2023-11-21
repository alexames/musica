require 'llx'
require 'musictheory/figure'
require 'musictheory/note'
require 'musictheory/pitch'
require 'musictheory/quality'
require 'musictheory/util'

local ChordByPitchesSchema = Schema{
  __name='ChordByPitchesSchema',
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

local ChordArgumentsSchema = Schema{
  __name='ChordArgumentsSchema',
  type=Union{ChordByPitchesSchema, ChordByRootQuality},
}

Chord = class 'Chord' {
  __init = function(self, args)
    check_arguments{self=Chord, args=ChordArgumentsSchema}
    if args.pitches then
      self.root = args.pitches[1]
      self.quality = Quality{pitches=args.pitches}
    else
      self.root = args.root
      self.quality = args.quality or Quality.major
    end
  end,

  get_pitches = function(self)
    return self:to_pitches(range(#self))
  end,

  get_quality = function(self)
    return self.quality
  end,

  to_pitch = function(self, chord_index)
    check_arguments{self=Chord, chord_index=Integer}
    return self.root + self.quality[chord_index]
  end,

  to_pitches = function(self, scale_indices)
    check_arguments{self=Chord,
                    scale_indices=Schema{type=List, items{type=Integer}}}
    local result = List{}
    for i, scale_index in ipairs(scale_indices) do
      result[i] = self:to_pitch(scale_index)
    end
    return result
  end,

  to_extended_pitch = function(self, chord_index, extension_interval)
    check_arguments{self=Chord,
                    chord_index=Integer,
                    extension_interval=Optional{Integer}}
    local extension_interval = extension_interval or PitchInterval.octave
    return self.root + extended_index(chord_index,
                                      self.quality.pitch_intervals,
                                      extension_interval)
  end,

  to_extended_pitches = function(self, chord_indices, extension_interval)
    check_arguments{self=Chord,
                    chord_index=Integer,
                    extension_interval=Optional{Integer}}
    extension_interval = extension_interval or PitchInterval.octave
    local result = List{}
    for i, chord_index in ipairs(chord_indices) do
      result[i] = self:to_extended_pitch(chord_index, extension_interval)
    end
    return result
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
    for index=n, n + #self do
      local octave_index = index // #self
      local octave_offset = octave_interval * octave_index
      inverted_intervals[i] = self.quality[index % #self + 1] + octave_offset
    end
    return Chord{root=self.root + inverted_intervals[1],
                 quality=Quality{pitch_intervals=inverted_intervals}}
  end,

  -- __call = function(self, octive_transposition)
  --   return Chord{root=Pitch{self.root.pitch_class,
  --                           octave=self.root.octave + octive_transposition},
  --                quality=self.quality}
  -- end,

  __div = function(self, other)
    if isinstance(other, Pitch) then
      other_pitches = {other}
    else
      other.get_pitches()
    end

    pitches = self.get_pitches() + other_pitches
    return Chord{pitches=sorted(pitches)}
  end,

  __len = function(self)
    return #self.quality
  end,

  __index = multi_index(Chord,
                        function(self, index) return self:to_pitch(index) end),

  -- contains = function(self, index)
  --   local octave = #self.scale.pitch_indices
  --   local canonical_index = index % octave
  --   local canonical_scale_indices = List{}
  --   for i, scale_index in ipairs(self.indices) do
  --     canonical_scale_indices[i] = (scale_index + self.offset) % octave
  --   end
  --   return canonical_index in canonical_scale_indices
  -- end,

  __tostring = function(self)
    -- return repr_args{"Chord", {"root", self.root}, {"quality", self.quality}}
    return string.format('Chord{root=%s, quality=%s}', self.root, self.quality)
  end,
}

-- A sequence of chords, to be reused through out a piece.
ChordProgression = class 'ChordProgression' {
  __init = function(self, chord_periods)
    self.chord_periods = chord_periods
  end,

  __getitem = function(self, key)
    return self.chord_periods[key]
  end,
}

function arpeggiate(chord,
                    duration,
                    index_pattern_fn,
                    index_pattern,
                    time_step,
                    volume,
                    count,
                    figure_duration,
                    extension_interval)
  extension_interval = extension_interval or PitchInterval.octave
  duration = duration or 1

  if time_step == nil then
    time_step = duration
  end

  if index_pattern then
    chord_indices = index_pattern
    if count == nil then
      count = #chord_indices
    end
  else
    if index_pattern_fn == nil then
      index_pattern_fn = range
    end
    if count == nil then
      count = #chord
    end
    chord_indices = list(index_pattern_fn(count))
  end

  pitches = chord.to_extended_pitches(chord_indices)
  -- notes = [Note(pitch, i * time_step, duration, volume)
  --          for i, pitch in enumerate(pitches)]

  -- if figure_duration == nil:
  --   figure_duration = max(note.time + note.duration for note in notes)

  return Figure(figure_duration, notes)
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

