-- Tests for Contour:realize -- turning a declared shape into concrete notes.

local unit = require 'llx.unit'
local llx = require 'llx'
local contour = require 'musica.contour'
local mode_module = require 'musica.mode'
require 'musica.modes'
local pitch_module = require 'musica.pitch'
local scale_module = require 'musica.scale'
local rhythm_module = require 'musica.rhythm'
local stamper_module = require 'musica.stamper'
local melodic = require 'musica.melodic'

local Scale = scale_module.Scale
local Mode = mode_module.Mode
local Pitch = pitch_module.Pitch
local Rhythm = rhythm_module.Rhythm
local scale_stamper = stamper_module.scale_stamper
local scale_walk = melodic.scale_walk
local tointeger = llx.tointeger
local List = llx.List
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

local scale = Scale{tonic = Pitch.c4, mode = Mode.major}

-- A rhythm of n quarter notes (one slot per expected note).
local function quarters(n)
  local durations = {}
  for i = 1, n do durations[i] = 1 end
  return Rhythm(durations)
end

-- Extract the MIDI pitch integers from a Figure, in order. Uses index access
-- (figure.notes is an llx.List, not a plain ipairs-iterable array).
local function pitches(figure)
  local out = List{}
  for i = 1, #figure.notes do out[i] = tointeger(figure.notes[i].pitch) end
  return out
end

describe('Contour.realize', function()
  it('ascend_to walks the scale up to the target', function()
    local frame = contour.ContourFrame{scale = scale, anchor = 0, rhythm = quarters(5)}
    local figure = contour.ascend_to{to = 4}:realize(frame)
    expect(pitches(figure)).to.be_equal_to({60, 62, 64, 65, 67})  -- C D E F G
  end)

  it('descend_to walks the scale down to the target', function()
    local frame = contour.ContourFrame{scale = scale, anchor = 4, rhythm = quarters(5)}
    local figure = contour.descend_to{to = 0}:realize(frame)
    expect(pitches(figure)).to.be_equal_to({67, 65, 64, 62, 60})  -- G F E D C
  end)

  it('is byte-identical to the equivalent hand-written scale_stamper', function()
    local rhythm = quarters(5)
    local frame = contour.ContourFrame{scale = scale, anchor = 0, rhythm = rhythm}
    local got = contour.ascend_to{to = 4}:realize(frame)
    local want = scale_stamper{scale = scale,
                               indices = scale_walk{from = 0, to = 4},
                               rhythm = rhythm}
    expect(#got.notes).to.be_equal_to(#want.notes)
    for i = 1, #want.notes do
      expect(tointeger(got.notes[i].pitch)).to.be_equal_to(tointeger(want.notes[i].pitch))
      expect(got.notes[i].time).to.be_equal_to(want.notes[i].time)
      expect(got.notes[i].duration).to.be_equal_to(want.notes[i].duration)
    end
  end)

  it('arc rises to the peak then falls back', function()
    local frame = contour.ContourFrame{scale = scale, rhythm = quarters(9)}
    local figure = contour.arc{from = 0, peak = 4, to = 0}:realize(frame)
    -- indices {0,1,2,3,4,3,2,1,0} -> C D E F G F E D C
    expect(pitches(figure)).to.be_equal_to({60, 62, 64, 65, 67, 65, 64, 62, 60})
  end)

  it('pedal repeats a single degree across every rhythm slot', function()
    local frame = contour.ContourFrame{scale = scale, anchor = 0, rhythm = quarters(4)}
    local figure = contour.pedal{degree = 0}:realize(frame)
    expect(pitches(figure)).to.be_equal_to({60, 60, 60, 60})
  end)

  it('neighbor_turn goes center, neighbor, center', function()
    local frame = contour.ContourFrame{scale = scale, rhythm = quarters(3)}
    local figure = contour.neighbor_turn{center = 0, neighbor = 1}:realize(frame)
    expect(pitches(figure)).to.be_equal_to({60, 62, 60})  -- C D C
  end)

  it('turn realizes a gruppetto: upper, center, lower, center', function()
    local frame = contour.ContourFrame{scale = scale, rhythm = quarters(4)}
    local figure = contour.turn{center = 1}:realize(frame)
    -- upper=2, center=1, lower=0 -> E D C D
    expect(pitches(figure)).to.be_equal_to({64, 62, 60, 62})
  end)

  it('chromatic_glide descends by semitone, leaving the scale', function()
    local frame = contour.ContourFrame{scale = scale, rhythm = quarters(5)}
    -- from scale index 2 (E4=64) down to index 0 (C4=60)
    local figure = contour.chromatic_glide{from = 2, to = 0}:realize(frame)
    expect(pitches(figure)).to.be_equal_to({64, 63, 62, 61, 60})
  end)

  it('free_scale_indices realizes literal indices offset by the anchor', function()
    local frame = contour.ContourFrame{scale = scale, anchor = 7, rhythm = quarters(3)}
    local figure = contour.free_scale_indices{indices = {0, 2, 4}}:realize(frame)
    -- offset by 7 -> indices {7,9,11} -> C5 E5 G5
    expect(pitches(figure)).to.be_equal_to({72, 76, 79})
  end)

  it('a contour sequence realizes its segments end to end', function()
    local seq = contour.ascend_to{to = 2} .. contour.descend_to{to = 0}
    local frames = {
      contour.ContourFrame{scale = scale, anchor = 0, rhythm = quarters(3)},
      contour.ContourFrame{scale = scale, anchor = 2, rhythm = quarters(3)},
    }
    local figure = seq:realize(frames)
    -- ascend 0->2 = C D E ; descend 2->0 = E D C
    expect(pitches(figure)).to.be_equal_to({60, 62, 64, 64, 62, 60})
  end)
end)

-- A realized shape must score as a perfect fit for the contour that produced it.
-- This guards the realize/score agreement for tricky cases the review surfaced:
-- valley arcs, lower neighbors, inverted double-neighbors, and frame-driven
-- (rather than construction-time) chromatic glides.
describe('Contour realize/score self-consistency', function()
  local cases = {
    {label = 'ascend_to',
     contour = contour.ascend_to{to = 4},
     frame = contour.ContourFrame{scale = scale, anchor = 0, rhythm = quarters(5)}},
    {label = 'descend_to',
     contour = contour.descend_to{to = 0},
     frame = contour.ContourFrame{scale = scale, anchor = 4, rhythm = quarters(5)}},
    {label = 'arc (hill)',
     contour = contour.arc{from = 0, peak = 4, to = 0},
     frame = contour.ContourFrame{scale = scale, rhythm = quarters(9)}},
    {label = 'arc (valley)',
     contour = contour.arc{from = 4, peak = 0, to = 4},
     frame = contour.ContourFrame{scale = scale, rhythm = quarters(9)}},
    {label = 'neighbor_turn (upper)',
     contour = contour.neighbor_turn{center = 0, neighbor = 1},
     frame = contour.ContourFrame{scale = scale, rhythm = quarters(3)}},
    {label = 'neighbor_turn (lower)',
     contour = contour.neighbor_turn{center = 0, neighbor = -1},
     frame = contour.ContourFrame{scale = scale, rhythm = quarters(3)}},
    {label = 'turn',
     contour = contour.turn{center = 1},
     frame = contour.ContourFrame{scale = scale, rhythm = quarters(4)}},
    {label = 'double_neighbor (inverted)',
     contour = contour.double_neighbor{center = 0, upper = -1, lower = 1},
     frame = contour.ContourFrame{scale = scale, rhythm = quarters(4)}},
    {label = 'pedal',
     contour = contour.pedal{degree = 0},
     frame = contour.ContourFrame{scale = scale, rhythm = quarters(4)}},
    {label = 'chromatic_glide (frame-driven, ascending)',
     contour = contour.chromatic_glide{},
     frame = contour.ContourFrame{scale = scale, anchor = 0, target = 2,
                                  rhythm = quarters(5)}},
  }
  for _, case in ipairs(cases) do
    it('realized ' .. case.label .. ' scores 0 against its own contour', function()
      local notes = case.contour:realize(case.frame).notes
      expect(case.contour:score(notes, case.frame)).to.be_equal_to(0)
    end)
  end
end)

if main_file() then
  unit.run_unit_tests()
end
