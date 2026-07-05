-- Tests for the contour vocabulary -- the named melodic shapes.
--
-- Complements test_contour_match.lua / test_contour_realize.lua (which cover
-- scoring and realization happy paths through the flattened musica.contour
-- module) by exercising the vocabulary module directly: indices() resolution,
-- direction templates, constructor defaults/aliases, and error paths.

local unit = require 'llx.unit'
local llx = require 'llx'
local vocabulary = require 'musica.contour.vocabulary'
local frame_module = require 'musica.contour.frame'
local direction_module = require 'musica.direction'
local mode_module = require 'musica.mode'
require 'musica.modes'
local note_module = require 'musica.note'
local pitch_module = require 'musica.pitch'
local rhythm_module = require 'musica.rhythm'
local scale_module = require 'musica.scale'

local ContourFrame = frame_module.ContourFrame
local Direction = direction_module.Direction
local up = Direction.up
local down = Direction.down
local Mode = mode_module.Mode
local Note = note_module.Note
local Pitch = pitch_module.Pitch
local Rhythm = rhythm_module.Rhythm
local Scale = scale_module.Scale
local List = llx.List
local tointeger = llx.tointeger
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

local scale = Scale{tonic = Pitch.c4, mode = Mode.major}

-- Build a melody (array of Notes) from a list of Pitch constants.
local function melody(...)
  local notes = {}
  for i, p in ipairs({...}) do notes[i] = Note{pitch = p, duration = 1} end
  return notes
end

-- Build a melody from raw MIDI integers (analysis coerces via tointeger).
local function midi_melody(...)
  local notes = {}
  for i, p in ipairs({...}) do notes[i] = {pitch = p} end
  return notes
end

-- A rhythm of n quarter notes (one slot per expected note).
local function quarters(n)
  local durations = {}
  for i = 1, n do durations[i] = 1 end
  return Rhythm(durations)
end

-- Extract the MIDI pitch integers from a Figure, in order.
local function pitches(figure)
  local out = List{}
  for i = 1, #figure.notes do out[i] = tointeger(figure.notes[i].pitch) end
  return out
end

describe('vocabulary.monotonic', function()
  it('should infer an upward direction from from/to', function()
    expect(vocabulary.monotonic{from = 0, to = 4}.direction)
      .to.be_equal_to(up)
  end)

  it('should infer a downward direction from from/to', function()
    expect(vocabulary.monotonic{from = 4, to = 0}.direction)
      .to.be_equal_to(down)
  end)

  it('should walk stepwise from from to to', function()
    expect(vocabulary.monotonic{from = 0, to = 4}:indices())
      .to.be_equal_to({0, 1, 2, 3, 4})
  end)

  it('should walk downward when to is below from', function()
    expect(vocabulary.monotonic{from = 3, to = 0}:indices())
      .to.be_equal_to({3, 2, 1, 0})
  end)

  it('should honor a custom step size', function()
    expect(vocabulary.monotonic{from = 0, to = 4, step = 2}:indices())
      .to.be_equal_to({0, 2, 4})
  end)

  it('should produce a single index when from equals to', function()
    expect(vocabulary.monotonic{from = 4, to = 4}:indices())
      .to.be_equal_to({4})
  end)

  it('should count out length notes when no target is given', function()
    local shape = vocabulary.monotonic{from = 5, direction = up, length = 3}
    expect(shape:indices()).to.be_equal_to({5, 6, 7})
  end)

  it('should apply the step sign from the direction', function()
    local shape = vocabulary.monotonic{
      from = 5, direction = down, length = 3, step = 2,
    }
    expect(shape:indices()).to.be_equal_to({5, 3, 1})
  end)

  it('should take anchor and target from the frame', function()
    local frame = ContourFrame{anchor = 1, target = 3}
    expect(vocabulary.monotonic{}:indices(frame)).to.be_equal_to({1, 2, 3})
  end)

  it('should take the length from the frame', function()
    local frame = ContourFrame{anchor = 2, length = 3}
    local shape = vocabulary.monotonic{direction = down}
    expect(shape:indices(frame)).to.be_equal_to({2, 1, 0})
  end)

  it('should reject indices without a target or a length', function()
    expect(function() vocabulary.monotonic{}:indices() end).to.throw()
  end)

  it('should reject a length-based walk without a direction', function()
    expect(function() vocabulary.monotonic{length = 3}:indices() end)
      .to.throw()
  end)

  it('should reject a target that contradicts the direction', function()
    expect(function()
      vocabulary.descend_to{from = 0, to = 4}:indices()
    end).to.throw()
  end)

  it('should emit a uniform direction template with a wildcard head',
     function()
    local template = vocabulary.monotonic{direction = up}:directions(4)
    expect(template[1]).to.be_nil()
    expect(template[2]).to.be_equal_to(up)
    expect(template[3]).to.be_equal_to(up)
    expect(template[4]).to.be_equal_to(up)
  end)

  it('should resolve the scoring direction from the frame', function()
    local rising = melody(Pitch.c4, Pitch.d4, Pitch.e4)
    local frame = ContourFrame{anchor = 0, target = 4}
    expect(vocabulary.monotonic{}:score(rising, frame)).to.be_equal_to(0)
  end)

  it('should refuse to score when the direction is unresolvable', function()
    local rising = melody(Pitch.c4, Pitch.d4, Pitch.e4)
    expect(function() vocabulary.monotonic{}:score(rising) end).to.throw()
  end)
end)

describe('vocabulary.ascend_to and descend_to', function()
  it('should name themselves and fix their direction', function()
    local rise = vocabulary.ascend_to{to = 4}
    local fall = vocabulary.descend_to{to = 0}
    expect(rise.name).to.be_equal_to('ascend_to')
    expect(rise.direction).to.be_equal_to(up)
    expect(fall.name).to.be_equal_to('descend_to')
    expect(fall.direction).to.be_equal_to(down)
  end)

  it('should accept target as an alias for to', function()
    expect(vocabulary.ascend_to{target = 4}.to).to.be_equal_to(4)
  end)
end)

describe('vocabulary.stepwise_walk and resolve', function()
  it('should force a step of one scale degree', function()
    local walk = vocabulary.stepwise_walk{from = 0, to = 3, step = 5}
    expect(walk:indices()).to.be_equal_to({0, 1, 2, 3})
  end)

  it('should build resolve as a named stepwise descent', function()
    local shape = vocabulary.resolve{from = 2, to = 0}
    expect(shape.name).to.be_equal_to('resolve')
    expect(shape:indices()).to.be_equal_to({2, 1, 0})
  end)

  it('should penalize chromatic notes in a walk', function()
    -- C4, C#4, D4 -> scale indices {0, nil, 1} in C major. The C#4 is
    -- out of scale, so both consecutive steps involve a non-scale note and
    -- the walk scores as a total miss rather than a perfect stepwise line.
    local chromatic = midi_melody(60, 61, 62)
    local frame = ContourFrame{scale = scale}
    local walk = vocabulary.stepwise_walk{from = 0, to = 1}
    expect(walk:score(chromatic, frame)).to.be_equal_to(1)
  end)

  it('should score an in-scale stepwise line as a perfect fit', function()
    -- C4, D4, E4 -> scale indices {0, 1, 2}: every move is one scale
    -- degree, so the conjunct-walk penalty stays at zero.
    local stepwise = midi_melody(60, 62, 64)
    local frame = ContourFrame{scale = scale}
    local walk = vocabulary.stepwise_walk{from = 0, to = 2}
    expect(walk:score(stepwise, frame)).to.be_equal_to(0)
  end)
end)

describe('vocabulary.arc', function()
  it('should rise to the peak then fall to the target', function()
    expect(vocabulary.arc{from = 0, peak = 2, to = 0}:indices())
      .to.be_equal_to({0, 1, 2, 1, 0})
  end)

  it('should support a valley whose peak is below the endpoints', function()
    expect(vocabulary.arc{from = 2, peak = 0, to = 2}:indices())
      .to.be_equal_to({2, 1, 0, 1, 2})
  end)

  it('should default the target back to the starting index', function()
    expect(vocabulary.arc{from = 1, peak = 3}:indices())
      .to.be_equal_to({1, 2, 3, 2, 1})
  end)

  it('should take anchor, peak, and target from the frame', function()
    local frame = ContourFrame{anchor = 0, peak = 2, target = 1}
    expect(vocabulary.arc{}:indices(frame)).to.be_equal_to({0, 1, 2, 1})
  end)

  it('should reject indices without a peak', function()
    expect(function() vocabulary.arc{from = 0}:indices() end).to.throw()
  end)

  it('should score a melody with fewer than two moves as a total miss',
     function()
    local shape = vocabulary.arc{from = 0, peak = 2, to = 0}
    expect(shape:score(melody(Pitch.c4, Pitch.e4))).to.be_equal_to(1)
    expect(shape:score(melody(Pitch.c4, Pitch.c4, Pitch.c4)))
      .to.be_equal_to(1)
  end)

  it('should penalize a missing falling leg', function()
    local rising = melody(Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4, Pitch.g4)
    local shape = vocabulary.arc{from = 0, peak = 4, to = 0}
    expect(shape:score(rising)).to.be_near(0.25, 1e-9)
  end)

  it('should penalize reversing again after the turn', function()
    local wobble = melody(Pitch.c4, Pitch.e4, Pitch.d4, Pitch.e4)
    local shape = vocabulary.arc{from = 0, peak = 2, to = 0}
    expect(shape:score(wobble)).to.be_near(1 / 3, 1e-9)
  end)
end)

describe('vocabulary neighbor shapes', function()
  it('should default the neighbor to one degree above the center', function()
    expect(vocabulary.neighbor_turn{center = 3}:indices())
      .to.be_equal_to({3, 4, 3})
  end)

  it('should center a neighbor turn on the frame anchor', function()
    local frame = ContourFrame{anchor = 5}
    expect(vocabulary.neighbor_turn{}:indices(frame))
      .to.be_equal_to({5, 6, 5})
  end)

  it('should invert the direction template for a lower neighbor', function()
    local shape = vocabulary.neighbor_turn{center = 0, neighbor = -1}
    local template = shape:directions(3)
    expect(template[1]).to.be_nil()
    expect(template[2]).to.be_equal_to(down)
    expect(template[3]).to.be_equal_to(up)
  end)

  it('should match a lower neighbor figure', function()
    local shape = vocabulary.neighbor_turn{center = 0, neighbor = -1}
    expect(shape:score(melody(Pitch.c4, Pitch.b3, Pitch.c4)))
      .to.be_equal_to(0)
  end)

  it('should surround the center with both neighbors', function()
    expect(vocabulary.double_neighbor{center = 0}:indices())
      .to.be_equal_to({0, 1, -1, 0})
    expect(vocabulary.double_neighbor{center = 2, upper = 4, lower = 1}
      :indices()).to.be_equal_to({2, 4, 1, 2})
  end)

  it('should match a double neighbor figure', function()
    local figure = melody(Pitch.c4, Pitch.d4, Pitch.b3, Pitch.c4)
    expect(vocabulary.double_neighbor{center = 0}:score(figure))
      .to.be_equal_to(0)
  end)

  it('should order a turn as upper, center, lower, center', function()
    expect(vocabulary.turn{center = 0, upper = 2, lower = -2}:indices())
      .to.be_equal_to({2, 0, -2, 0})
  end)

  it('should center a turn on the frame anchor', function()
    local frame = ContourFrame{anchor = 3}
    expect(vocabulary.turn{}:indices(frame)).to.be_equal_to({4, 3, 2, 3})
  end)

  it('should match a gruppetto figure', function()
    local figure = melody(Pitch.e4, Pitch.d4, Pitch.c4, Pitch.d4)
    expect(vocabulary.turn{center = 1}:score(figure)).to.be_equal_to(0)
  end)
end)

describe('vocabulary.zigzag', function()
  it('should oscillate center and neighbor for a default length of four',
     function()
    expect(vocabulary.zigzag{center = 0, neighbor = 2}:indices())
      .to.be_equal_to({0, 2, 0, 2})
  end)

  it('should take an odd length from the frame', function()
    local frame = ContourFrame{length = 5}
    expect(vocabulary.zigzag{center = 0}:indices(frame))
      .to.be_equal_to({0, 1, 0, 1, 0})
  end)

  it('should alternate the direction template', function()
    local template = vocabulary.zigzag{center = 0, neighbor = 1}:directions(4)
    expect(template[1]).to.be_nil()
    expect(template[2]).to.be_equal_to(up)
    expect(template[3]).to.be_equal_to(down)
    expect(template[4]).to.be_equal_to(up)
  end)

  it('should match oscillation in either orientation', function()
    local upper = vocabulary.zigzag{center = 0, neighbor = 1}
    local lower = vocabulary.zigzag{center = 0, neighbor = -1}
    expect(upper:score(
      melody(Pitch.c4, Pitch.d4, Pitch.c4, Pitch.d4, Pitch.c4)))
      .to.be_equal_to(0)
    expect(lower:score(melody(Pitch.c4, Pitch.b3, Pitch.c4, Pitch.b3)))
      .to.be_equal_to(0)
  end)
end)

describe('vocabulary.pedal and hold', function()
  it('should resolve the pedal degree from itself then the frame', function()
    expect(vocabulary.pedal{degree = 2}:indices()).to.be_equal_to({2})
    expect(vocabulary.pedal{}:indices(ContourFrame{anchor = 3}))
      .to.be_equal_to({3})
  end)

  it('should accept the hold degree positionally or by name', function()
    expect(vocabulary.hold{3}.degree).to.be_equal_to(3)
    expect(vocabulary.hold{degree = 5}.degree).to.be_equal_to(5)
    expect(vocabulary.hold{3}.name).to.be_equal_to('hold')
  end)
end)

describe('vocabulary.leap_then_hold', function()
  it('should leap once then sustain the target', function()
    expect(vocabulary.leap_then_hold{from = 0, to = 4, length = 4}:indices())
      .to.be_equal_to({0, 4, 4, 4})
  end)

  it('should default to a length of two', function()
    expect(vocabulary.leap_then_hold{from = 0, to = 4}:indices())
      .to.be_equal_to({0, 4})
  end)

  it('should take anchor, target, and length from the frame', function()
    local frame = ContourFrame{anchor = 1, target = 5, length = 3}
    expect(vocabulary.leap_then_hold{}:indices(frame))
      .to.be_equal_to({1, 5, 5})
  end)

  it('should reject indices without a target', function()
    expect(function() vocabulary.leap_then_hold{from = 0}:indices() end)
      .to.throw()
  end)

  it('should default min_leap to two degrees', function()
    expect(vocabulary.leap_then_hold{}.min_leap).to.be_equal_to(2)
    expect(vocabulary.leap_then_hold{min_leap = 5}.min_leap)
      .to.be_equal_to(5)
  end)

  it('should match a leap followed by repeated notes', function()
    local shape = vocabulary.leap_then_hold{from = 0, to = 4}
    expect(shape:score(melody(Pitch.c4, Pitch.g4, Pitch.g4, Pitch.g4)))
      .to.be_equal_to(0)
  end)

  it('should match a downward leap', function()
    local shape = vocabulary.leap_then_hold{from = 4, to = 0}
    expect(shape:score(melody(Pitch.g4, Pitch.c4, Pitch.c4)))
      .to.be_equal_to(0)
  end)

  it('should penalize continued motion after the leap', function()
    local shape = vocabulary.leap_then_hold{from = 0, to = 4}
    expect(shape:score(melody(Pitch.c4, Pitch.d4, Pitch.e4)))
      .to.be_near(0.5, 1e-9)
  end)
end)

describe('vocabulary.free_scale_indices', function()
  it('should return the literal indices when no anchor offsets them',
     function()
    expect(vocabulary.free_scale_indices{indices = {0, 2, 1}}:indices())
      .to.be_equal_to({0, 2, 1})
  end)

  it('should offset every index by the frame anchor', function()
    local shape = vocabulary.free_scale_indices{indices = {0, 2, 1}}
    expect(shape:indices(ContourFrame{anchor = 3}))
      .to.be_equal_to({3, 5, 4})
  end)

  it('should count a length mismatch against the score', function()
    local shape = vocabulary.free_scale_indices{indices = {0, 1}}
    local three_notes = melody(Pitch.c4, Pitch.d4, Pitch.e4)
    expect(shape:score(three_notes)).to.be_near(1 / 3, 1e-9)
  end)

  it('should score an empty spec against an empty melody as a fit',
     function()
    expect(vocabulary.free_scale_indices{indices = {}}:score({}))
      .to.be_equal_to(0)
  end)
end)

describe('vocabulary.chromatic_glide', function()
  it('should default to a downward glide when unspecified', function()
    expect(vocabulary.chromatic_glide{}.direction).to.be_equal_to(down)
  end)

  it('should infer its direction from the endpoints', function()
    expect(vocabulary.chromatic_glide{from = 0, to = 2}.direction)
      .to.be_equal_to(up)
  end)

  it('should realize an ascending glide in semitones', function()
    local frame = ContourFrame{scale = scale, rhythm = quarters(5)}
    local figure = vocabulary.chromatic_glide{from = 0, to = 2}
      :realize(frame)
    expect(pitches(figure)).to.be_equal_to({60, 61, 62, 63, 64})
  end)

  it('should realize a single note when from equals to', function()
    local frame = ContourFrame{scale = scale, rhythm = quarters(1)}
    local figure = vocabulary.chromatic_glide{from = 0, to = 0}
      :realize(frame)
    expect(pitches(figure)).to.be_equal_to({60})
  end)

  it('should refuse to realize without a scale', function()
    local frame = ContourFrame{rhythm = quarters(3)}
    expect(function()
      vocabulary.chromatic_glide{from = 0, to = 2}:realize(frame)
    end).to.throw()
  end)

  it('should score a semitone line as a perfect fit', function()
    local glide = vocabulary.chromatic_glide{from = 0, to = 2}
    expect(glide:score(midi_melody(60, 61, 62, 63, 64))).to.be_equal_to(0)
  end)

  it('should reject whole-tone motion', function()
    local glide = vocabulary.chromatic_glide{from = 0, to = 2}
    expect(glide:score(midi_melody(60, 62, 64))).to.be_equal_to(1)
  end)

  it('should score a single-note melody as a total miss', function()
    expect(vocabulary.chromatic_glide{}:score(midi_melody(60)))
      .to.be_equal_to(1)
  end)

  it('should derive the scoring direction from the frame', function()
    local frame = ContourFrame{anchor = 2, target = 0}
    expect(vocabulary.chromatic_glide{}:score(midi_melody(64, 63, 62), frame))
      .to.be_equal_to(0)
  end)

  it('should fall back to the default downward direction', function()
    expect(vocabulary.chromatic_glide{}:score(midi_melody(62, 61, 60)))
      .to.be_equal_to(0)
  end)
end)

describe('vocabulary realize preconditions', function()
  it('should refuse to realize without a rhythm', function()
    local frame = ContourFrame{scale = scale, anchor = 0}
    expect(function() vocabulary.ascend_to{to = 4}:realize(frame) end)
      .to.throw()
  end)
end)

if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
