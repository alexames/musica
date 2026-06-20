-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- ContourFrame: the realization context for a Contour.
--
-- A Contour describes a *shape* in the abstract (degree space, direction).
-- A ContourFrame supplies everything needed to turn that shape into concrete
-- notes: the scale, the rhythm, dynamics, and -- when the contour does not carry
-- them itself -- the anchor/target/peak scale degrees and a note count.
--
-- Every field is optional. A "vague" frame (few fields bound) can still drive
-- matching/scoring; only realize() requires enough to produce notes (at least a
-- scale and a rhythm). Contours read their own shape parameters first and fall
-- back to the frame, so the same contour can be fully self-contained
-- (`arc{from=0, peak=4, to=0}`) or take its anchor from the frame
-- (`ascend_to{to=7}` realized in a frame with `anchor=0`).
-- @module musica.contour.frame

local llx = require 'llx'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class

-- @type ContourFrame
ContourFrame = class 'ContourFrame' {
  __init = function(self, args)
    args = args or {}
    self.scale = args.scale       -- Scale used to resolve degree indices
    self.anchor = args.anchor     -- starting scale index (default 0 in contours)
    self.target = args.target     -- ending scale index
    self.peak = args.peak         -- apex scale index (arcs)
    self.length = args.length     -- note count for count-based shapes
    self.step = args.step         -- walk step size in scale degrees (default 1)
    self.rhythm = args.rhythm     -- Rhythm or list of {time, duration}
    self.volume = args.volume     -- number or list of numbers
    self.duration = args.duration -- figure duration override
  end,

  --- Returns a copy of this frame with the given fields overridden.
  -- @tparam ContourFrame self
  -- @tparam table overrides fields to replace
  -- @treturn ContourFrame
  derive = function(self, overrides)
    local merged = {
      scale = self.scale, anchor = self.anchor, target = self.target,
      peak = self.peak, length = self.length, step = self.step,
      rhythm = self.rhythm, volume = self.volume, duration = self.duration,
    }
    for key, value in pairs(overrides or {}) do
      merged[key] = value
    end
    return ContourFrame(merged)
  end,

  __tostring = function(self)
    return 'ContourFrame'
  end,
}

--- Coerce a plain table (or nil) into a ContourFrame.
-- @tparam table|ContourFrame|nil frame
-- @treturn ContourFrame
function as_frame(frame)
  if frame == nil then return ContourFrame{} end
  if llx.isinstance(frame, ContourFrame) then return frame end
  return ContourFrame(frame)
end

return _M
