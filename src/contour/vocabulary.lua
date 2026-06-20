-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Contour vocabulary: named melodic shapes.
--
-- Each shape is a Contour subclass with a lowercase constructor. Shapes work in
-- scale-degree space (so the same shape transposes across keys) except
-- `chromatic_glide`, which moves by semitone. Names are kept disjoint from the
-- analysis functions in `musica.contour.analysis`.
--
-- Constructors (degree = scale index; all parameters optional unless noted):
--   monotonic{direction, from?, to?, length?, step?}
--   ascend_to{to, from?}            descend_to{to, from?}
--   stepwise_walk{from, to}         resolve{from, to}
--   arc{from, peak, to}
--   neighbor_turn{center, neighbor} double_neighbor{center, upper, lower}
--   turn{center, upper, lower}      zigzag{center, neighbor, length}
--   pedal{degree}                   hold{degree}
--   leap_then_hold{from, to, length?, min_leap?}
--   free_scale_indices{indices}
--   chromatic_glide{from, to, direction?}
-- @module musica.contour.vocabulary

local llx = require 'llx'
local analysis = require 'musica.contour.analysis'
local contour_module = require 'musica.contour.contour'
local direction = require 'musica.direction'
local melodic = require 'musica.melodic'
local stamper = require 'musica.stamper'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local List = llx.List
local tointeger = llx.tointeger
local Contour = contour_module.Contour
local uniform_directions = contour_module.uniform_directions
local Direction = direction.Direction
local directional_contour = analysis.directional_contour
local relative_contour = analysis.relative_contour
local scale_index_contour = analysis.scale_index_contour
local pitch_index_contour = analysis.pitch_index_contour
local scale_walk = melodic.scale_walk

local up, down, same = Direction.up, Direction.down, Direction.same

--- Resolve the starting scale index for a contour from itself then the frame.
local function start_index(self, frame)
  return self.from or (frame and frame.anchor) or 0
end

----------------------------------------------------------------------
-- Monotonic family: ascend_to, descend_to, stepwise_walk, resolve
----------------------------------------------------------------------

-- @type Monotonic
Monotonic = class 'Monotonic' : extends(Contour) {
  __init = function(self, args)
    args = args or {}
    Contour.__init(self, args)
    self.name = args.name or 'monotonic'
    if self.direction == nil and self.from ~= nil and self.to ~= nil then
      self.direction = (self.to >= self.from) and up or down
    end
  end,

  -- Resolve the intended direction from the contour, else from from/to (the
  -- contour's or the frame's).
  _direction = function(self, frame)
    if self.direction ~= nil then return self.direction end
    local from = self.from or (frame and frame.anchor)
    local to = self.to or (frame and frame.target)
    if from ~= nil and to ~= nil and from ~= to then
      return (to > from) and up or down
    end
    return nil
  end,

  directions = function(self, n, frame)
    local dir = self:_direction(frame)
    if dir == nil then return nil end  -- under-specified: let the base scorer error
    return uniform_directions(n, dir)
  end,

  indices = function(self, frame)
    local from = start_index(self, frame)
    local to = self.to or (frame and frame.target)
    local step = self.step or (frame and frame.step) or 1
    if to ~= nil then
      -- A declared direction must agree with the walk it would produce.
      if self.direction ~= nil and to ~= from then
        local walk = (to > from) and up or down
        if walk ~= self.direction then
          error('Contour:indices: ' .. self.name
            .. ' target contradicts its direction', 2)
        end
      end
      return scale_walk{from = from, to = to, step = step}
    end
    local length = self.length or (frame and frame.length)
    if not length then
      error('Contour:indices: monotonic needs a target or a length', 2)
    end
    local dir = self:_direction(frame)
    if dir == nil then
      error('Contour:indices: length-based monotonic needs a direction', 2)
    end
    local signed = (dir == down) and -math.abs(step) or math.abs(step)
    local indices = List{}
    for i = 0, length - 1 do indices:insert(from + i * signed) end
    return indices
  end,
}

function monotonic(args)
  return Monotonic(args)
end

function ascend_to(args)
  args = args or {}
  return Monotonic{name = 'ascend_to', from = args.from, to = args.to or args.target,
                   direction = up, length = args.length, step = args.step}
end

function descend_to(args)
  args = args or {}
  return Monotonic{name = 'descend_to', from = args.from, to = args.to or args.target,
                   direction = down, length = args.length, step = args.step}
end

-- @type StepwiseWalk
StepwiseWalk = class 'StepwiseWalk' : extends(Monotonic) {
  __init = function(self, args)
    args = args or {}
    args.step = 1
    Monotonic.__init(self, args)
    self.name = args.name or 'stepwise_walk'
  end,

  -- Tighten scoring: in addition to the monotonic direction check, penalize any
  -- step larger than one scale degree (a "walk" is conjunct), when a scale is
  -- available to measure degree distance.
  score = function(self, melody, frame)
    local base = Monotonic.score(self, melody, frame)
    if frame and frame.scale then
      local degrees = scale_index_contour(melody, frame.scale)
      local big = 0
      for i = 2, #degrees do
        if degrees[i] == nil or degrees[i - 1] == nil then
          big = big + 1  -- out-of-scale (chromatic) note: not a scale step
        elseif math.abs(degrees[i] - degrees[i - 1]) > 1 then
          big = big + 1
        end
      end
      if #degrees > 1 then base = math.max(base, big / (#degrees - 1)) end
    end
    return base
  end,
}

function stepwise_walk(args)
  return StepwiseWalk(args)
end

-- A short stepwise descent into a target -- a melodic resolution.
function resolve(args)
  args = args or {}
  return StepwiseWalk{name = 'resolve', from = args.from, to = args.to or args.target}
end

----------------------------------------------------------------------
-- Arc: rise to a peak then fall
----------------------------------------------------------------------

-- @type Arc
Arc = class 'Arc' : extends(Contour) {
  __init = function(self, args)
    Contour.__init(self, args)
    self.name = 'arc'
  end,

  indices = function(self, frame)
    local from = start_index(self, frame)
    local peak = self.peak or (frame and frame.peak)
    local to = self.to or (frame and frame.target) or from
    if not peak then error('Contour:indices: arc needs a peak', 2) end
    local rise = scale_walk{from = from, to = peak}
    local fall = scale_walk{from = peak, to = to}
    local indices = List{}
    for _, value in ipairs(rise) do indices:insert(value) end
    for i = 2, #fall do indices:insert(fall[i]) end  -- drop the duplicated peak
    return indices
  end,

  -- An arc is unimodal: a run in one direction, then a run in the other. A hill
  -- (peak above the endpoints) rises then falls; a valley (peak below) falls
  -- then rises. Both the rise and the fall must occur, and once the contour
  -- turns it must not reverse again. Score is the fraction of moves that break
  -- this (plus a penalty if a required leg is missing).
  score = function(self, melody, frame)
    local from = self.from or (frame and frame.anchor) or 0
    local peak = self.peak or (frame and frame.peak)
    local finish = self.to or (frame and frame.target) or from
    local rising_first = true
    if peak ~= nil and peak <= math.min(from, finish) then rising_first = false end
    local first = rising_first and up or down
    local second = rising_first and down or up

    local dc = directional_contour(melody)
    local moves = {}
    for i = 2, #dc do
      if dc[i] ~= same then moves[#moves + 1] = dc[i] end
    end
    if #moves < 2 then return 1 end

    local bad, turned, saw_first, saw_second = 0, false, false, false
    for _, move in ipairs(moves) do
      if not turned then
        if move == first then
          saw_first = true
        elseif move == second then
          turned = true
          saw_second = true
        end
      else
        if move == second then
          saw_second = true
        else
          bad = bad + 1  -- reversed back after the turn
        end
      end
    end
    if not saw_first then bad = bad + 1 end
    if not saw_second then bad = bad + 1 end
    return bad / #moves
  end,
}

function arc(args)
  return Arc(args)
end

----------------------------------------------------------------------
-- Turns and neighbors
----------------------------------------------------------------------

-- @type NeighborTurn (center -> neighbor -> center)
NeighborTurn = class 'NeighborTurn' : extends(Contour) {
  __init = function(self, args)
    args = args or {}
    Contour.__init(self, args)
    self.name = 'neighbor_turn'
    self.center = args.center
    self.neighbor = args.neighbor
  end,

  _center = function(self, frame) return self.center or (frame and frame.anchor) or 0 end,
  _neighbor = function(self, frame)
    if self.neighbor ~= nil then return self.neighbor end
    return self:_center(frame) + 1
  end,

  indices = function(self, frame)
    local center = self:_center(frame)
    return List{center, self:_neighbor(frame), center}
  end,

  directions = function(self, n, frame)
    local rising = self:_neighbor(frame) >= self:_center(frame)
    return {nil, rising and up or down, rising and down or up}
  end,
}

function neighbor_turn(args)
  return NeighborTurn(args)
end

-- @type DoubleNeighbor (center -> upper -> lower -> center)
DoubleNeighbor = class 'DoubleNeighbor' : extends(Contour) {
  __init = function(self, args)
    args = args or {}
    Contour.__init(self, args)
    self.name = 'double_neighbor'
    self.center = args.center
    self.upper = args.upper
    self.lower = args.lower
  end,

  _parts = function(self, frame)
    local center = self.center or (frame and frame.anchor) or 0
    return center, self.upper or (center + 1), self.lower or (center - 1)
  end,

  indices = function(self, frame)
    local center, upper, lower = self:_parts(frame)
    return List{center, upper, lower, center}
  end,

  directions = function(self, n, frame)
    local center, upper, lower = self:_parts(frame)
    return {nil,
            (upper >= center) and up or down,
            (lower >= upper) and up or down,
            (center >= lower) and up or down}
  end,
}

function double_neighbor(args)
  return DoubleNeighbor(args)
end

-- @type Turn (gruppetto: upper -> center -> lower -> center)
Turn = class 'Turn' : extends(Contour) {
  __init = function(self, args)
    args = args or {}
    Contour.__init(self, args)
    self.name = 'turn'
    self.center = args.center
    self.upper = args.upper
    self.lower = args.lower
  end,

  _parts = function(self, frame)
    local center = self.center or (frame and frame.anchor) or 0
    return center, self.upper or (center + 1), self.lower or (center - 1)
  end,

  indices = function(self, frame)
    local center, upper, lower = self:_parts(frame)
    return List{upper, center, lower, center}
  end,

  directions = function(self, n, frame)
    local center, upper, lower = self:_parts(frame)
    return {nil,
            (center >= upper) and up or down,
            (lower >= center) and up or down,
            (center >= lower) and up or down}
  end,
}

function turn(args)
  return Turn(args)
end

-- @type Zigzag (oscillate center <-> neighbor)
Zigzag = class 'Zigzag' : extends(Contour) {
  __init = function(self, args)
    args = args or {}
    Contour.__init(self, args)
    self.name = 'zigzag'
    self.center = args.center
    self.neighbor = args.neighbor
  end,

  indices = function(self, frame)
    local center = self.center or (frame and frame.anchor) or 0
    local neighbor = self.neighbor or (center + 1)
    local length = self.length or (frame and frame.length) or 4
    local indices = List{}
    for i = 0, length - 1 do
      indices:insert((i % 2 == 0) and center or neighbor)
    end
    return indices
  end,

  directions = function(self, n)
    local rising = (self.neighbor or 1) >= (self.center or 0)
    local first = rising and up or down
    local second = rising and down or up
    local template = {}
    for i = 2, n do
      template[i] = (i % 2 == 0) and first or second
    end
    return template
  end,
}

function zigzag(args)
  return Zigzag(args)
end

----------------------------------------------------------------------
-- Pedal / hold / leap-then-hold
----------------------------------------------------------------------

-- @type Pedal (repeat a single degree; scale_stamper repeats it across slots)
Pedal = class 'Pedal' : extends(Contour) {
  __init = function(self, args)
    args = args or {}
    Contour.__init(self, args)
    self.name = args.name or 'pedal'
    self.degree = args.degree
  end,

  indices = function(self, frame)
    local degree = self.degree or (frame and frame.anchor) or 0
    return List{degree}
  end,

  directions = function(self, n)
    return uniform_directions(n, same)
  end,
}

function pedal(args)
  return Pedal(args)
end

function hold(args)
  args = args or {}
  return Pedal{name = 'hold', degree = args.degree or args[1]}
end

-- @type LeapThenHold (one leap, then sustain the target degree)
LeapThenHold = class 'LeapThenHold' : extends(Contour) {
  __init = function(self, args)
    args = args or {}
    Contour.__init(self, args)
    self.name = 'leap_then_hold'
    self.min_leap = args.min_leap or 2
  end,

  indices = function(self, frame)
    local from = start_index(self, frame)
    local to = self.to or (frame and frame.target)
    if to == nil then error('Contour:indices: leap_then_hold needs a target', 2) end
    local length = self.length or (frame and frame.length) or 2
    local indices = List{from}
    for i = 2, length do indices:insert(to) end
    return indices
  end,

  directions = function(self, n)
    local from = self.from or 0
    local to = self.to or (from + self.min_leap)
    local leap = (to >= from) and up or down
    local template = {[2] = leap}
    for i = 3, n do template[i] = same end
    return template
  end,
}

function leap_then_hold(args)
  return LeapThenHold(args)
end

----------------------------------------------------------------------
-- Free (scale-agnostic) indices: match by relative shape only
----------------------------------------------------------------------

-- @type FreeScaleIndices
FreeScaleIndices = class 'FreeScaleIndices' : extends(Contour) {
  __init = function(self, args)
    args = args or {}
    Contour.__init(self, args)
    self.name = 'free_scale_indices'
    self.spec_indices = args.indices
  end,

  indices = function(self, frame)
    local offset = (frame and frame.anchor) or 0
    local indices = List{}
    for i, value in ipairs(self.spec_indices) do
      indices[i] = value + offset
    end
    return indices
  end,

  -- Match by relative contour only (scale unspecified): does the melody rise and
  -- fall in the same relative order as the spec indices?
  score = function(self, melody, frame)
    local actual = relative_contour(melody)
    local template = {}
    for i, value in ipairs(self.spec_indices) do template[i] = {pitch = value} end
    local expected = relative_contour(template)
    local n = math.min(#actual, #expected)
    local mismatches = math.abs(#actual - #expected)
    for i = 1, n do
      if actual[i] ~= expected[i] then mismatches = mismatches + 1 end
    end
    local total = math.max(#actual, #expected)
    if total == 0 then return 0 end
    return mismatches / total
  end,
}

function free_scale_indices(args)
  return FreeScaleIndices(args)
end

----------------------------------------------------------------------
-- Chromatic glide: semitone motion (works outside the scale)
----------------------------------------------------------------------

-- @type ChromaticGlide
ChromaticGlide = class 'ChromaticGlide' : extends(Contour) {
  __init = function(self, args)
    args = args or {}
    Contour.__init(self, args)
    self.name = 'chromatic_glide'
    if self.direction == nil then
      if self.from ~= nil and self.to ~= nil then
        self.direction = (self.to >= self.from) and up or down
      else
        self.direction = down
      end
    end
  end,

  -- Chromatic motion is in semitone (pitch) space, so realize via stamper with
  -- explicit pitches rather than scale_stamper.
  realize = function(self, frame)
    local frame_module = require 'musica.contour.frame'
    frame = frame_module.as_frame(frame)
    local ok, err = self:is_realizable(frame)
    if not ok then error('Contour:realize: ' .. err, 2) end
    local scale = frame.scale
    local start_pitch = tointeger(scale[start_index(self, frame)])
    local end_pitch = tointeger(scale[self.to or frame.target])
    local step = (end_pitch >= start_pitch) and 1 or -1
    local pitches = List{}
    local pitch = start_pitch
    while (step > 0 and pitch <= end_pitch) or (step < 0 and pitch >= end_pitch) do
      pitches:insert(pitch)
      pitch = pitch + step
    end
    return stamper.stamper{
      pitches = pitches, rhythm = frame.rhythm,
      volume = frame.volume, duration = frame.duration,
    }
  end,

  -- All steps move by exactly one semitone in the chosen direction. Derive the
  -- direction the same way realize() does -- from the resolved from/to (which may
  -- come from the frame) -- so a frame-driven glide scores consistently with how
  -- it realizes, rather than from the construction-time default.
  score = function(self, melody, frame)
    local from = self.from or (frame and frame.anchor) or 0
    local to = self.to or (frame and frame.target)
    local want
    if to ~= nil then
      want = (to >= from) and 1 or -1
    else
      want = (self.direction == up) and 1 or -1
    end
    local pitches = pitch_index_contour(melody)
    if #pitches < 2 then return 1 end
    local bad = 0
    for i = 2, #pitches do
      if (pitches[i] - pitches[i - 1]) ~= want then bad = bad + 1 end
    end
    return bad / (#pitches - 1)
  end,
}

function chromatic_glide(args)
  return ChromaticGlide(args)
end

return _M
