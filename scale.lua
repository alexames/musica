require 'llx'
require 'musictheory/chord'
require 'musictheory/mode'
require 'musictheory/pitch'
require 'musictheory/util'

Scale = class 'Scale' {
  __init = function(self, tonic, mode)
    check_arg_types{self=Scale, tonic=Pitch, mode=Mode}
    self.tonic = tonic
    self.mode = mode
  end,

--   get_pitches = function(self)
--     -- return [self.tonic + pitch_interval
--     --         for pitch_interval in self.mode.pitch_intervals.values]
--   end,

--   to_pitch = function(self, scale_index)
--     if scale_index == nil then
--       -- return nil
--     end
--     return self.tonic + self.mode[scale_index]
--   end,

--   to_pitches = function(self, scale_indices)
--     -- return [self.to_pitch(scale_index) for scale_index in scale_indices]
--   end,

--   to_scale_index = function(self, pitch)
--     if isinstance(pitch, Number) then
--       pitch_index = pitch
--     else
--       pitch_index = tointeger(pitch)
--     end

--     pitch_index_offset = pitch_index - tointeger(self.tonic)
--     offset_modulus = pitch_index_offset % tointeger(self.mode.octave_interval)
--     offsetOctave = math.floor(pitch_index_offset / tointeger(self.mode.octave_interval))
--     -- try:
--     --   scale_index_modulus = [tointeger(pitch - self.tonic)
--     --                        for pitch in self.get_pitches()].index(offset_modulus)
--     --   return scale_index_modulus + #self * offsetOctave
--     -- except:
--     --   return nil
--   end,

--   to_scale_indices = function(self, pitches)
--     -- return [self.to_scale_index(pitch) for pitch in pitches]
--   end,

--   relative = function(self, arg)
--     -- scale_index=nil, mode=nil, direction=up
--     if direction ~= up and direction ~= down then
--       -- raise ValueError("must specify up or down")
--     end

--     if mode then
--       scale_index = self.mode.relative(mode)
--       if not scale_index then
--         error("unrelated mode")
--       end
--       if direction == down then
--         scale_index = scale_index - #self
--       end
--     elseif scale_index ~= nil then
--       mode = self.mode:rotate(scale_index)
--     end

--     tonic_scale_index = self.to_scale_index(tointeger(self.tonic)) + scale_index
--     tonic = self:to_pitch(tonic_scale_index)

--     return Scale{tonic=tonic, mode=mode}
--   end,


  parallel = function(self, mode)
    return Scale(self.tonic, mode)
  end,

  __eq = function(self, other)
    return self.tonic == other.tonic and self.mode == other.mode
  end,

  __len = function(self)
    return #self.mode
  end,

  __index = function(self, index)
    if isinstance(index, Number) then
      return rawget(self, 'tonic') + rawget(self, 'mode')[index]
    elseif isinstance(index, Table) then
      local results = List{}
      for i, v in ipairs(index) do
        results[i] = self[v]
      end
      return results -- Make this a Chord
    else
      return Scale.__defaultindex(self, index)
    end
  end,

  contains = function(self, other)
    local other_pitch_indices
    if isinstance(other, Number) or isinstance(other, Pitch) then
      other_pitch_indices = List{other}
    elseif isinstance(other, Chord) or isinstance(other, Scale) then
      other_pitch_indices = other.get_pitches()
    elseif isinstance(other, Table) then
      other_pitch_indices = other
    end

    function canonicalize(pitch_indices, octave_interval)
      local result = {}
      for i=1, #pitch_indices do
        result[i] = tointeger(pitch_index[i]) % tointeger(octave_interval)
      end
      return result
    end

    local octave_interval = self.mode.octave_interval
    other_pitch_indices = canonicalize(other_pitch_indices, octave_interval)
    local my_pitch_indices = canonicalize(self.get_pitches(), octave_interval)
    for i=1, #other_pitch_indices do
      if not my_pitch_indices:contains(index) then
        return false
      end
    end
    return true
  end,

  __tostring = function(self)
    return string.format("Scale{tonic=%s, mode=%s}", self.tonic, self.mode)
  end,
}

-- -- function find_chord(scale, quality, nth=0, *, direction=up, scale_indices=[0,2,4])
-- function find_chord(args)
--   numberFound = 0
--   -- Search one octave at a time.
--   local start = 0
--   local finish = direction * #scale
--   while true do
--     for root_scale_index in range(start, finish, direction) do
--       -- testQuality = Quality{pitches=scale[(i + root_scale_index for i in scale_indices)]}

--       if testQuality == quality then
--         if numberFound == nth then
--           return Chord{root=scale:to_pitch(root_scale_index),
--                        quality=quality}
--         end
--         numberFound = numberFound + 1
--       end
--     end
--     start = start + direction * #scale
--     finish = finish + direction * #scale
--     -- If after one full octave there have not been any matches,
--     -- there won't be any matches going forward either. We should
--     -- return nil. If there was at least one match though, we should
--     -- keep searching until we find the nth match
--     if numberFound == 0 then
--       return nil
--     end
--   end
-- end


scale = Scale(Pitch.c4, Mode.minor)
print(scale)
print(scale[0])
print(scale[1])
print(scale[2])
print(scale[3])
print(scale[4])
print(scale[5])
print(scale[6])
print(scale[7])
print(scale[8])
print(scale[{0, 2, 4}])