require 'llx'
require 'musictheory/chord'
require 'musictheory/direction'
require 'musictheory/mode'
require 'musictheory/modes'
require 'musictheory/pitch'
require 'musictheory/util'

ScaleArgs = Schema{
  type=Table,
  properties={
    tonic={type=Pitch},
    mode={type=Mode},
  },
  required={'tonic', 'mode'},
}

Scale = class 'Scale' {
  __init = function(self, arg)
    check_arguments{self=Scale, arg=ScaleArgs}
    self.tonic = arg.tonic
    self.mode = arg.mode
  end,

  get_pitches = function(self)
    check_arguments{self=Scale}
    local result = List{}
    for i=1, #self.mode do
      result[i] = self.tonic + self.mode[i-1]
    end
    return result
  end,

  to_pitch = function(self, scale_index)
    check_arguments{self=Scale, scale_index=Integer}
    return self.tonic + self.mode[scale_index]
  end,

  to_pitches = function(self, scale_indices)
    check_arguments{self=Scale, scale_indices=Table}
    return transform(scale_indices, function(i, scale_index)
      return self:to_pitch(scale_index)
    end)
  end,

  to_scale_index = function(self, pitch)
    check_arguments{self=Scale, pitch=Union{Pitch,Integer}}
    local pitch_index = tointeger(pitch)
    local pitch_index_offset = pitch_index - tointeger(self.tonic)
    local offset_modulus = pitch_index_offset % tointeger(self.mode:octave_interval())
    local offset_octave = pitch_index_offset // tointeger(self.mode:octave_interval())
    local normalized_indices = transform(self:get_pitches(), function(i, pitch)
      return tointeger(pitch - self.tonic)
    end)
    local scale_index_index = normalized_indices:ifind(offset_modulus)
    if scale_index_index then
      local scale_index_modulus = scale_index_index - 1
      return scale_index_modulus + #self * offset_octave
    end
    return nil
  end,

  to_scale_indices = function(self, pitches)
    local result = List{}
    for i, pitch in ipairs(pitches) do
      result[i] = self.to_scale_index(pitch)
    end
    return result
  end,

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

    local tonic_scale_index = self:to_scale_index(tointeger(self.tonic)) + scale_index
    local tonic = self:to_pitch(tonic_scale_index)

    return Scale{tonic=tonic, mode=mode}
  end,

  parallel = function(self, mode)
    check_arguments{self=Scale, mode=Mode}
    return Scale{tonic=self.tonic, mode=mode}
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
      return transform(pitch_indices, function(i, pitch_index)
        return tointeger(pitch_index) % tointeger(octave_interval)
      end)
    end

    local octave_interval = self.mode:octave_interval()
    other_pitch_indices = canonicalize(other_pitch_indices, octave_interval)
    local my_pitch_indices = canonicalize(self:get_pitches(), octave_interval)
    for i=1, #other_pitch_indices do
      local index = other_pitch_indices[i]
      if not my_pitch_indices:contains(index) then
        return false
      end
    end
    return true
  end,

  __eq = function(self, other)
    return self.tonic == other.tonic and self.mode == other.mode
  end,

  __len = function(self)
    return #self.mode
  end,

  __index = multi_index(function(self, index)
    return self.tonic + self.mode[index]
  end),

  __tostring = function(self)
    return string.format("Scale{tonic=%s, mode=%s}", self.tonic, self.mode)
  end,
}

function find_chord(args)
  local scale = args.scale
  local quality = args.quality
  local nth = args.nth or 0
  local direction = args.direction or up
  local relative_scale_indices = args.scale_indices or List{0, 2, 4}
  local number_found = 0
  -- Search one octave at a time.
  local start = 0
  local finish = direction * #scale
  while true do
    for root_scale_index in range(start, finish, direction) do
      local absolute_scale_indices = 
        transform(relative_scale_indices, function(i, scale_index)
          return scale_index + root_scale_index
        end)
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
    -- If after one full octave there have not been any matches,
    -- there won't be any matches going forward either. We should
    -- return nil. If there was at least one match though, we should
    -- keep searching until we find the nth match
    if number_found == 0 then
      return nil
    end
  end
end
