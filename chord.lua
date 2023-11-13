require 'llx'
require 'musictheory/note'
require 'musictheory/pitch'
require 'musictheory/quality'
require 'musictheory/util'
require 'musictheory/figure'

local ChordArgumentsSchema = Schema{
  __name=ChordArgumentsSchema,
  type=Table,
  properties={
    root={type=Pitch},
    pitches={
      type=List,
      items={type=Pitch},
    },
    quality={type=Quality},
  },
}

Chord = class 'Chord' {
  __init = function(self, args)
    check_arguments{self=Chord, args=ChordArgumentsSchema}
    if args.pitches then
      self.root = args.pitches[0]
      self.quality = Quality{pitches=args.pitches}
    else
      self.root = args.root
      self.quality = args.quality or Quality.major
    end
  end;

  get_pitches = function(self)
    return self:to_pitches(range(#self))
  end;

  get_quality = function(self)
    return self.quality
  end;

  to_pitch = function(self, chord_index)
    return self.root + self.quality[chord_index]
  end;

  to_pitches = function(self, scale_indices)
    -- return [self.to_pitch(scale_index) for scale_index in scale_indices]
  end;

  to_extended_pitch = function(self, chord_index, extension_interval)
    extension_interval = extension_interval or PitchInterval.octave
    return self.root + extended_index(chord_index,
                                    self.quality.pitch_intervals,
                                    extension_interval)
  end;

  to_extended_pitches = function(self, chord_indices, extension_interval)
    extension_interval = extension_interval or PitchInterval.octave
    
    -- return [self.to_extended_pitch(chord_index, extension_interval)
    --         for chord_index in chord_indices]
  end;

  inversion = function(self, n, octave_interval)
    octave_interval = octave_interval or PitchInterval.octave
    -- Short circuit if there is nothing to be done.
    -- if n == 0:
    --   return self

    -- inverted_interval = function(index)
    --   octave_index = index // #self
    --   octave_offset = octave_interval * octave_index
    --   return self.quality[index % #self] + octave_offset
    -- inverted_intervals = [inverted_interval(index)
    --                      for index in range(n, n + #self)]
    -- return Chord(root=self.root + inverted_intervals[0],
    --              quality=Quality(pitch_intervals=inverted_intervals))
  end;

  __call = function(self, octive_transposition)
    return Chord{root=Pitch{self.root.pitch_class,
                            octave=self.root.octave + octive_transposition},
                 quality=self.quality}
  end;

  __truediv = function(self, other)
    if isinstance(other, Pitch) then
      other_pitches = {other}
    else
      other.get_pitches()
    end

    pitches = self.get_pitches() + other_pitches
    return Chord{pitches=sorted(pitches)}
  end;

  __len = function(self)
    return #self.quality
  end;

  __index = function(self, key)
    if isinstance(key, int) then
      return self:to_pitch(key)
    elseif isinstance(key, range) then
      start = key.start or 0
      stop = key.stop
      step = key.step or 1
      -- return [self.to_pitch(index) for index in range(start, stop, step)]
    else
      -- return [self.to_pitch(index) for index in key]
    end
  end;

  contains = function(self, index)
    -- octave = #self.scale.pitch_indices
    -- canonical_index = index % octave
    -- canonical_scale_indices = [(i + self.offset) % octave
    --                          for i in self.indices]
    -- return canonical_index in canonical_scale_indices
  end;

  __repr = function(self)
    return repr_args{"Chord", {"root", self.root}, {"quality", self.quality}}
  end;
}

-- A sequence of chords, to be reused through out a piece.
ChordProgression = class 'ChordProgression' {
  __init = function(self, chord_periods)
    self.chord_periods = chord_periods
  end;

  __getitem = function(self, key)
    return self.chord_periods[key]
  end;
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

