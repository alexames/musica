require 'musictheory/chord'
require 'musictheory/mode'
require 'musictheory/pitch'
require 'musictheory/util'

class 'Scale' {
  __init = function(self, tonic, mode)
    if tonic == nil then
      error("tonic cannot be nil")
    elseif mode == nil then
      error("mode cannot be nil")
    end
    self.tonic = tonic
    self.mode = mode
  end;

  getPitches = function(self)
    -- return [self.tonic + pitchInterval
    --         for pitchInterval in self.mode.pitchIntervals.values]
  end;

  toPitch = function(self, scaleIndex)
    if scaleIndex == nil then
      -- return nil
    end
    return self.tonic + self.mode[scaleIndex]
  end;

  toPitches = function(self, scaleIndices)
    -- return [self.toPitch(scaleIndex) for scaleIndex in scaleIndices]
  end;

  toScaleIndex = function(self, pitch)
    if isinstance(pitch, int) then
      pitchIndex = pitch
    else
      pitchIndex = int(pitch)
    end

    pitchIndexOffset = pitchIndex - int(self.tonic)
    offsetModulus = pitchIndexOffset % int(self.mode.octaveInterval)
    offsetOctave = math.floor(pitchIndexOffset / int(self.mode.octaveInterval))
    -- try:
    --   scaleIndexModulus = [int(pitch - self.tonic)
    --                        for pitch in self.getPitches()].index(offsetModulus)
    --   return scaleIndexModulus + #self * offsetOctave
    -- except:
    --   return nil
  end;

  toScaleIndices = function(self, pitches)
    -- return [self.toScaleIndex(pitch) for pitch in pitches]
  end;

  relative = function(self, arg)
    -- scaleIndex=nil, mode=nil, direction=up
    if direction ~= up and direction ~= down then
      -- raise ValueError("must specify up or down")
    end

    if mode then
      scaleIndex = self.mode.relative(mode)
      if not scaleIndex then
        error("unrelated mode")
      end
      if direction == down then
        scaleIndex = scaleIndex - #self
      end
    elseif scaleIndex ~= nil then
      mode = self.mode:rotate(scaleIndex)
    end

    tonicScaleIndex = self.toScaleIndex(int(self.tonic)) + scaleIndex
    tonic = self:toPitch(tonicScaleIndex)

    return Scale{tonic=tonic, mode=mode}
  end;


  parallel = function(self, mode)
    return Scale{tonic=self.tonic, mode=mode}
  end;


  __eq = function(self, other)
    return self.tonic == other.tonic and self.mode == other.mode
  end;

  __len = function(self)
    return #self.mode
  end;

  __index = function(self, key)
    if isinstance(key, int) then
      return self.toPitch(key)
    elseif isinstance(key, range) or isinstance(key, slice) then
      start = key.start or 0
      stop = key.stop
      step = key.step or 1
      -- return [self[index] for index in range(start, stop, step)]
    else
      -- return [self.toPitch(index) for index in key]
    end
  end;

  contains = function(self, other)
    if isinstance(other, int) or isinstance(other, Pitch) then
      otherPitchIndices = List{other}
    elseif isinstance(other, tuple) or isinstance(other, list) then
      otherPitchIndices = other
    elseif isinstance(other, Chord) or isinstance(other, Scale) then
      otherPitchIndices = other.getPitches()
    end

    function canonicalize(pitchIndices, octaveInterval)
      -- return [int(index) % int(octaveInterval) for index in pitchIndices]
    end

    octaveInterval = self.mode.octaveInterval
    otherPitchIndices = canonicalize(otherPitchIndices, octaveInterval)
    myPitchIndices = canonicalize(self.getPitches(), octaveInterval)
    -- return all(index in myPitchIndices
    --            for index in otherPitchIndices)
  end;

  __repr = function(self)
    return string.format("Scale{tonic=%s, mode=%s}", self.tonic, self.mode)
  end;
}


-- function findChord(scale, quality, nth=0, *, direction=up, scaleIndices=[0,2,4])
function findChord(args)
  numberFound = 0
  -- Search one octave at a time.
  local start = 0
  local finish = direction * #scale
  while true do
    for rootScaleIndex in range(start, finish, direction) do
      -- testQuality = Quality{pitches=scale[(i + rootScaleIndex for i in scaleIndices)]}

      if testQuality == quality then
        if numberFound == nth then
          return Chord{root=scale:toPitch(rootScaleIndex),
                       quality=quality}
        end
        numberFound = numberFound + 1
      end
    end
    start = start + direction * #scale
    finish = finish + direction * #scale
    -- If after one full octave there have not been any matches,
    -- there won't be any matches going forward either. We should
    -- return nil. If there was at least one match though, we should
    -- keep searching until we find the nth match
    if numberFound == 0 then
      return nil
    end
  end
end

ScaleIndex = List{
  tonic = 0,
  second = 1,
  third = 2,
  fourth = 3,
  fifth = 4,
  sixth = 5,
  seventh = 6,
  octave = 7,
}
