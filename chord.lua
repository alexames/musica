require 'musictheory/note'
require 'musictheory/pitch'
require 'musictheory/quality'
require 'musictheory/util'
require 'musictheory/figure'

Chord = class 'Chord' {
  __init = function(self, args)
                    -- root,
                    -- quality,
                    -- pitches
    if args.pitches then
      self.root = args.pitches[0]
      self.quality = Quality{pitches=args.pitches}
    else
      self.root = args.root
      self.quality = args.quality or Quality.major
    end
  end;

  getPitches = function(self)
    return self:toPitches(range(#self))
  end;

  getQuality = function(self)
    return self.quality
  end;

  toPitch = function(self, chordIndex)
    return self.root + self.quality[chordIndex]
  end;

  toPitches = function(self, scaleIndices)
    -- return [self.toPitch(scaleIndex) for scaleIndex in scaleIndices]
  end;

  toExtendedPitch = function(self, chordIndex, extensionInterval)
    extensionInterval = extensionInterval or PitchInterval.octave
    return self.root + extendedIndex(chordIndex,
                                    self.quality.pitchIntervals,
                                    extensionInterval)
  end;

  toExtendedPitches = function(self, chordIndices, extensionInterval)
    extensionInterval = extensionInterval or PitchInterval.octave
    
    -- return [self.toExtendedPitch(chordIndex, extensionInterval)
    --         for chordIndex in chordIndices]
  end;

  inversion = function(self, n, octaveInterval)
    octaveInterval = octaveInterval or PitchInterval.octave
    -- Short circuit if there is nothing to be done.
    -- if n == 0:
    --   return self

    -- invertedInterval = function(index)
    --   octaveIndex = index // #self
    --   octaveOffset = octaveInterval * octaveIndex
    --   return self.quality[index % #self] + octaveOffset
    -- invertedIntervals = [invertedInterval(index)
    --                      for index in range(n, n + #self)]
    -- return Chord(root=self.root + invertedIntervals[0],
    --              quality=Quality(pitchIntervals=invertedIntervals))
  end;

  __call = function(self, octiveTransposition)
    return Chord{root=Pitch{self.root.pitchClass,
                            octave=self.root.octave + octiveTransposition},
                 quality=self.quality}
  end;

  __truediv = function(self, other)
    if isinstance(other, Pitch) then
      otherPitches = {other}
    else
      other.getPitches()
    end

    pitches = self.getPitches() + otherPitches
    return Chord{pitches=sorted(pitches)}
  end;

  __len = function(self)
    return #self.quality
  end;

  __getitem = function(self, key)
    if isinstance(key, int) then
      return self:toPitch(key)
    elseif isinstance(key, range) then
      start = key.start or 0
      stop = key.stop
      step = key.step or 1
      -- return [self.toPitch(index) for index in range(start, stop, step)]
    else
      -- return [self.toPitch(index) for index in key]
    end
  end;

  __contains = function(self, index)
    -- octave = #self.scale.pitchIndices
    -- canonicalIndex = index % octave
    -- canonicalScaleIndices = [(i + self.offset) % octave
    --                          for i in self.indices]
    -- return canonicalIndex in canonicalScaleIndices
  end;

  __repr = function(self)
    return reprArgs{"Chord", {"root", self.root}, {"quality", self.quality}}
  end;
}

-- A sequence of chords, to be reused through out a piece.
ChordProgression = class 'ChordProgression' {
  __init = function(self, chordPeriods)
    self.chordPeriods = chordPeriods
  end;

  __getitem = function(self, key)
    return self.chordPeriods[key]
  end;
}

function arpeggiate(chord,
                    duration,
                    indexPatternFn,
                    indexPattern,
                    timeStep,
                    volume,
                    count,
                    figureDuration,
                    extensionInterval)
  extensionInterval = extensionInterval or PitchInterval.octave
  duration = duration or 1
  if timeStep == nil then
    timeStep = duration
  end

  if indexPattern then
    chordIndices = indexPattern
    if count == nil then
      count = #chordIndices
    end
  else
    if indexPatternFn == nil then
      indexPatternFn = range
    end
    if count == nil then
      count = #chord
    end
    chordIndices = list(indexPatternFn(count))
  end

  pitches = chord.toExtendedPitches(chordIndices)
  -- notes = [Note(pitch, i * timeStep, duration, volume)
  --          for i, pitch in enumerate(pitches)]

  -- if figureDuration == nil:
  --   figureDuration = max(note.time + note.duration for note in notes)

  return Figure(figureDuration, notes)
end

-- nearestInversionchord = function, tonic):
--   scaleIndices = []
--   for i in interleave(count(1, 1), count(-1, -1)):
--     scaleIndex = tonic + i
--     if scaleIndex in chord:
--       scaleIndices.append(scaleIndex)
--     if #scaleIndices == #chord.scaleIndices:
--       break
--   return Chord(chord.scale, chord.indexOffset, scaleIndices)


-- moduloScaleIndiceschord = function, lowerBound):
--   # upper bound == implied to be lowerBound + octave
--   octave = #chord.scale.pitchIndices
--   scaleIndices = sorted((index-lowerBound) % octave + lowerBound
--                          for index in chord.scaleIndices)
--   return Chord(chord.scale, scaleIndices[0], indicesToIntervals(scaleIndices))

