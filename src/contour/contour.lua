-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Contour: the abstract type for a declarative melodic shape.
--
-- A Contour describes *movement* (rise to a peak then fall; step up to a target;
-- repeat one degree; turn around a center) without committing to absolute
-- pitches. Subclasses in `musica.contour.vocabulary` name the common shapes.
--
-- A Contour can:
--   * realize(frame)         -> Figure         (when fully specified)
--   * score(melody[, frame]) -> number (0=fit) (classify an existing melody)
--   * match(melody[, frame, tol]) -> bool, score
--   * to_rule(frame)         -> Rule           (DESIGNED, deferred; see below)
--   * a .. b                 -> ContourSequence (compose into a phrase)
--
-- Realization reuses the very same primitives the toolkit gestures use
-- (`melodic.scale_walk` + `stamper.scale_stamper`), so a realized contour is
-- byte-identical to the hand-written builder it replaces.
-- @module musica.contour.contour

local llx = require 'llx'
local analysis = require 'musica.contour.analysis'
local stamper = require 'musica.stamper'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local directional_contour = analysis.directional_contour
local scale_stamper = stamper.scale_stamper

--- Abstract base class. Subclasses MUST override `indices` (for realize) and
-- SHOULD provide either `directions` (a per-step Direction template for the
-- default scorer) or override `score` directly.
-- @type Contour
Contour = class 'Contour' {
  __init = function(self, args)
    args = args or {}
    self.name = args.name or 'contour'
    -- Shape parameters in degree space. Not every subclass uses every field;
    -- they are stored uniformly so frames and contours can fall back to one
    -- another (`self.from or frame.anchor`).
    self.from = args.from
    self.to = args.to or args.target
    self.peak = args.peak
    self.degree = args.degree
    self.direction = args.direction
    self.length = args.length
    self.step = args.step
    self.spec_indices = args.indices
    self.min_leap = args.min_leap
  end,

  --- Resolve this shape to a list of scale indices for the given frame.
  -- @tparam Contour self
  -- @tparam ContourFrame frame
  -- @treturn table List of scale indices
  indices = function(self, frame)
    error('Contour:indices must be overridden in subclass', 2)
  end,

  --- Optional per-step Direction template of length n used by the default
  -- scorer. Entry 1 corresponds to the first note (no incoming motion) and is
  -- usually a wildcard (nil). Any nil entry is a wildcard. Return nil to signal
  -- that the subclass overrides score() instead. The frame is passed so a
  -- subclass can resolve degrees it takes from the frame rather than itself.
  -- @treturn table|nil
  directions = function(self, n, frame)
    return nil
  end,

  --- True if `frame` carries enough to realize this contour into notes.
  -- @treturn boolean, string|nil
  is_realizable = function(self, frame)
    if not frame or not frame.scale then return false, 'frame.scale is required' end
    if not frame.rhythm then return false, 'frame.rhythm is required' end
    return true
  end,

  --- Realize into a Figure. Reuses scale_stamper so output matches the
  -- equivalent hand-written gesture exactly.
  -- @treturn Figure
  realize = function(self, frame)
    local frame_module = require 'musica.contour.frame'
    frame = frame_module.as_frame(frame)
    local ok, err = self:is_realizable(frame)
    if not ok then error('Contour:realize: ' .. err, 2) end
    return scale_stamper{
      scale = frame.scale,
      indices = self:indices(frame),
      rhythm = frame.rhythm,
      volume = frame.volume,
      duration = frame.duration,
    }
  end,

  --- Score how well `melody` fits this shape. 0 is a perfect fit; larger is
  -- worse (the fraction of comparable steps that disagree with the template).
  -- @tparam table melody array of notes (with .pitch)
  -- @treturn number
  score = function(self, melody, frame)
    local expected = self:directions(#melody, frame)
    if not expected then
      error('Contour:score: subclass provides neither directions() nor score()', 2)
    end
    local actual = directional_contour(melody)
    local comparable, mismatches = 0, 0
    for i = 1, #actual do
      local want = expected[i]
      if want ~= nil then
        comparable = comparable + 1
        if actual[i] ~= want then mismatches = mismatches + 1 end
      end
    end
    if comparable == 0 then return 0 end
    return mismatches / comparable
  end,

  --- True if the melody fits within tolerance (default exact). Also returns the
  -- score, so callers can rank.
  -- @treturn boolean, number
  match = function(self, melody, frame, tol)
    local s = self:score(melody, frame)
    return s <= (tol or 0), s
  end,

  --- DESIGNED, DEFERRED. Compile this contour to a generation Rule so a Z3
  -- solver can produce melodies of this shape. The intended mapping:
  --   * arc          -> OvershootRule (rise above target by N then descend)
  --   * ascend/walk  -> AllOf(StartOnPitch, EndOnPitch, InScale, Monotonic,
  --                           MaxInterval=1 for stepwise)
  --   * pedal        -> AllOf(InScale, every pitch == anchor)
  --   * neighbor     -> a fixed three-pitch boundary + interval rule
  -- A Contour is not itself a Rule; a future `ContourRule` will adapt it for the
  -- Generator. Implemented in the z3 follow-on (kept out of the core so contour
  -- loads without the native binding).
  to_rule = function(self, frame)
    error('Contour:to_rule is not yet implemented '
      .. '(z3 generation via contours is a designed follow-on)', 2)
  end,

  --- Compose two contours into a phrase. `arc .. turn .. fall`.
  __concat = function(left, right)
    local sequence = require 'musica.contour.sequence'
    return sequence.concat(left, right)
  end,

  __tostring = function(self)
    return string.format('Contour<%s>', self.name)
  end,
}

--- Shared helper for subclasses: a Direction template with a wildcard first
-- entry and `dir` for every following step.
-- @treturn table
function uniform_directions(n, dir)
  local template = {}
  for i = 2, n do template[i] = dir end
  return template
end

return _M
