-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- ContourSequence: a phrase built by composing contours end to end.
--
-- `arc .. neighbor_turn .. descend_to{...}` yields a ContourSequence, itself a
-- Contour. realize() concatenates each sub-contour's Figure (the second starts
-- where the first ends); score() splits the melody into consecutive segments
-- (by each frame's length) and reports the length-weighted average fit.
-- @module musica.contour.sequence

local llx = require 'llx'
local contour_module = require 'musica.contour.contour'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local isinstance = llx.isinstance
local List = llx.List
local Contour = contour_module.Contour

-- @type ContourSequence
ContourSequence = class 'ContourSequence' : extends(Contour) {
  __init = function(self, args)
    args = args or {}
    Contour.__init(self, {name = 'sequence'})
    self.contours = args.contours or args
  end,

  --- True when `frames` is an array of frames (one per contour) rather than a
  -- single frame applied to all.
  _is_frame_list = function(self, frames)
    local frame_module = require 'musica.contour.frame'
    if type(frames) ~= 'table' then return false end
    if isinstance(frames, frame_module.ContourFrame) then return false end
    return frames[1] ~= nil
  end,

  --- Realize the whole phrase. `frames` is either an array of frames (one per
  -- contour) or a single frame applied to every contour.
  -- @treturn Figure
  realize = function(self, frames)
    local list = self:_is_frame_list(frames)
    local result
    for i, contour in ipairs(self.contours) do
      local frame = list and frames[i] or frames
      local figure = contour:realize(frame)
      result = result and (result .. figure) or figure
    end
    return result
  end,

  is_realizable = function(self, frames)
    local list = self:_is_frame_list(frames)
    for i, contour in ipairs(self.contours) do
      local frame = list and frames[i] or frames
      local ok, err = contour:is_realizable(frame)
      if not ok then
        return false, string.format('segment %d: %s', i, err)
      end
    end
    return true
  end,

  --- Score by splitting the melody into consecutive segments. Requires a list
  -- of frames, each carrying a `length`, so the split is unambiguous.
  -- @treturn number
  score = function(self, melody, frames)
    if not self:_is_frame_list(frames) then
      error('ContourSequence:score needs an array of frames (one per contour)', 2)
    end
    -- Each segment's length must be declared, and they must account for exactly
    -- the whole melody -- otherwise the split is ambiguous and a short melody
    -- would silently leave trailing segments empty (scoring them as perfect).
    local expected = 0
    for i = 1, #self.contours do
      local frame = frames[i]
      if not (frame and frame.length) then
        error('ContourSequence:score needs frames[' .. i .. '].length', 2)
      end
      expected = expected + frame.length
    end
    if #melody ~= expected then
      error(string.format(
        'ContourSequence:score: melody has %d notes but segments declare %d',
        #melody, expected), 2)
    end
    local position = 1
    local total = 0
    for i, contour in ipairs(self.contours) do
      local frame = frames[i]
      local length = frame.length
      local segment = {}
      for j = 1, length do
        segment[j] = melody[position]
        position = position + 1
      end
      total = total + contour:score(segment, frame) * length
    end
    return total / expected
  end,

  __tostring = function(self)
    return string.format('ContourSequence<%d>', #self.contours)
  end,
}

--- Flatten-concatenate two contours (or sequences) into one ContourSequence.
-- @treturn ContourSequence
function concat(left, right)
  local function parts(contour)
    if isinstance(contour, ContourSequence) then return contour.contours end
    return {contour}
  end
  local merged = List{}
  for _, contour in ipairs(parts(left)) do merged:insert(contour) end
  for _, contour in ipairs(parts(right)) do merged:insert(contour) end
  return ContourSequence{contours = merged}
end

return _M
