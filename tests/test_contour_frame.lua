-- Tests for ContourFrame: field storage, derive() copies, and as_frame()
-- coercion (including the plain-table frame path through Contour:realize).

local unit = require 'llx.unit'
local llx = require 'llx'
local frame_module = require 'musica.contour.frame'
local vocabulary = require 'musica.contour.vocabulary'
local mode_module = require 'musica.mode'
require 'musica.modes'
local pitch_module = require 'musica.pitch'
local rhythm_module = require 'musica.rhythm'
local scale_module = require 'musica.scale'

local ContourFrame = frame_module.ContourFrame
local as_frame = frame_module.as_frame
local Mode = mode_module.Mode
local Pitch = pitch_module.Pitch
local Rhythm = rhythm_module.Rhythm
local Scale = scale_module.Scale
local List = llx.List
local tointeger = llx.tointeger
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

local scale = Scale{tonic = Pitch.c4, mode = Mode.major}

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

describe('ContourFrame', function()
  it('should store every provided field', function()
    local rhythm = quarters(4)
    local frame = ContourFrame{
      scale = scale, anchor = 1, target = 5, peak = 3, length = 4,
      step = 2, rhythm = rhythm, volume = 0.5, duration = 2,
    }
    expect(frame.scale).to.be_equal_to(scale)
    expect(frame.anchor).to.be_equal_to(1)
    expect(frame.target).to.be_equal_to(5)
    expect(frame.peak).to.be_equal_to(3)
    expect(frame.length).to.be_equal_to(4)
    expect(frame.step).to.be_equal_to(2)
    expect(frame.rhythm).to.be_equal_to(rhythm)
    expect(frame.volume).to.be_equal_to(0.5)
    expect(frame.duration).to.be_equal_to(2)
  end)

  it('should leave unbound fields nil in a vague frame', function()
    local frame = ContourFrame{}
    expect(frame.scale).to.be_nil()
    expect(frame.anchor).to.be_nil()
    expect(frame.rhythm).to.be_nil()
  end)

  it('should construct with no arguments at all', function()
    expect(ContourFrame().target).to.be_nil()
  end)

  it('should print as ContourFrame', function()
    expect(tostring(ContourFrame{})).to.be_equal_to('ContourFrame')
  end)
end)

describe('ContourFrame.derive', function()
  it('should override only the given fields', function()
    local frame = ContourFrame{scale = scale, anchor = 1, target = 5}
    local derived = frame:derive{anchor = 9}
    expect(derived.anchor).to.be_equal_to(9)
    expect(derived.target).to.be_equal_to(5)
    expect(derived.scale).to.be_equal_to(scale)
  end)

  it('should not modify the original frame', function()
    local frame = ContourFrame{anchor = 1}
    local derived = frame:derive{anchor = 9}
    expect(frame.anchor).to.be_equal_to(1)
    expect(rawequal(derived, frame)).to.be_falsy()
  end)

  it('should return a ContourFrame instance', function()
    local derived = ContourFrame{anchor = 1}:derive{target = 2}
    expect(llx.isinstance(derived, ContourFrame)).to.be_truthy()
  end)

  it('should copy every field when no overrides are given', function()
    local frame = ContourFrame{
      scale = scale, anchor = 1, target = 5, peak = 3, length = 4,
      step = 2, volume = 0.5, duration = 2,
    }
    local copy = frame:derive()
    expect(copy.scale).to.be_equal_to(scale)
    expect(copy.anchor).to.be_equal_to(1)
    expect(copy.target).to.be_equal_to(5)
    expect(copy.peak).to.be_equal_to(3)
    expect(copy.length).to.be_equal_to(4)
    expect(copy.step).to.be_equal_to(2)
    expect(copy.volume).to.be_equal_to(0.5)
    expect(copy.duration).to.be_equal_to(2)
  end)

  it('should not clear a field with an explicit nil override', function()
    -- NOTE: documents current behavior. A nil value in the overrides table
    -- is invisible to pairs(), so derive{anchor = nil} keeps the original
    -- anchor rather than unbinding it.
    local frame = ContourFrame{anchor = 1}
    expect(frame:derive{anchor = nil}.anchor).to.be_equal_to(1)
  end)
end)

describe('frame.as_frame', function()
  it('should coerce nil into an empty frame', function()
    local frame = as_frame(nil)
    expect(llx.isinstance(frame, ContourFrame)).to.be_truthy()
    expect(frame.scale).to.be_nil()
  end)

  it('should coerce a plain table into a frame', function()
    local frame = as_frame{scale = scale, anchor = 2}
    expect(llx.isinstance(frame, ContourFrame)).to.be_truthy()
    expect(frame.scale).to.be_equal_to(scale)
    expect(frame.anchor).to.be_equal_to(2)
  end)

  it('should return an existing frame unchanged', function()
    local frame = ContourFrame{anchor = 2}
    expect(rawequal(as_frame(frame), frame)).to.be_truthy()
  end)

  it('should let realize accept a plain table as its frame', function()
    local figure = vocabulary.ascend_to{to = 2}:realize{
      scale = scale, anchor = 0, rhythm = quarters(3),
    }
    expect(pitches(figure)).to.be_equal_to({60, 62, 64})
  end)
end)

if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
