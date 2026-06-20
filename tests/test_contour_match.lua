-- Tests for Contour:score / Contour:match -- classifying an existing melody.

local unit = require 'llx.unit'
local llx = require 'llx'
local contour = require 'musica.contour'
local mode_module = require 'musica.mode'
require 'musica.modes'
local note_module = require 'musica.note'
local pitch_module = require 'musica.pitch'
local scale_module = require 'musica.scale'

local Scale = scale_module.Scale
local Mode = mode_module.Mode
local Note = note_module.Note
local Pitch = pitch_module.Pitch
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

local scale = Scale{tonic = Pitch.c4, mode = Mode.major}

-- Build a melody (array of Notes) from a list of pitches.
local function melody(...)
  local notes = {}
  for i, p in ipairs({...}) do notes[i] = Note{pitch = p, duration = 1} end
  return notes
end

local rising = melody(Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4, Pitch.g4)
local falling = melody(Pitch.g4, Pitch.f4, Pitch.e4, Pitch.d4, Pitch.c4)
local arc_melody = melody(Pitch.c4, Pitch.e4, Pitch.g4, Pitch.e4, Pitch.c4)
local pedal_melody = melody(Pitch.c4, Pitch.c4, Pitch.c4, Pitch.c4)
local zigzag_melody = melody(Pitch.c4, Pitch.d4, Pitch.c4, Pitch.d4, Pitch.c4)

describe('Contour.score', function()
  it('ascend_to fits a rising line and rejects a falling one', function()
    expect(contour.ascend_to{to = 4}:score(rising)).to.be_equal_to(0)
    expect(contour.ascend_to{to = 4}:score(falling)).to.be_greater_than(0.9)
  end)

  it('descend_to fits a falling line', function()
    expect(contour.descend_to{to = 0}:score(falling)).to.be_equal_to(0)
    expect(contour.descend_to{to = 0}:score(rising)).to.be_greater_than(0.9)
  end)

  it('arc fits a rise-then-fall and penalizes a zigzag', function()
    expect(contour.arc{from = 0, peak = 2, to = 0}:score(arc_melody)).to.be_equal_to(0)
    expect(contour.arc{from = 0, peak = 1, to = 0}:score(zigzag_melody)).to.be_greater_than(0)
  end)

  it('pedal fits a repeated note and rejects movement', function()
    expect(contour.pedal{degree = 0}:score(pedal_melody)).to.be_equal_to(0)
    expect(contour.pedal{degree = 0}:score(rising)).to.be_greater_than(0.9)
  end)

  it('neighbor_turn fits center, neighbor, center', function()
    local turn_melody = melody(Pitch.c4, Pitch.d4, Pitch.c4)
    expect(contour.neighbor_turn{center = 0, neighbor = 1}:score(turn_melody))
      .to.be_equal_to(0)
  end)

  it('stepwise_walk penalizes leaps when a scale is supplied', function()
    local frame = contour.ContourFrame{scale = scale}
    local leaps = melody(Pitch.c4, Pitch.e4, Pitch.g4)   -- thirds, not steps
    local steps = melody(Pitch.c4, Pitch.d4, Pitch.e4)   -- conjunct
    expect(contour.stepwise_walk{from = 0, to = 2}:score(leaps, frame)).to.be_greater_than(0)
    expect(contour.stepwise_walk{from = 0, to = 2}:score(steps, frame)).to.be_equal_to(0)
  end)

  it('free_scale_indices matches relative shape, ignoring the scale', function()
    local fsi = contour.free_scale_indices{indices = {0, 2, 1}}  -- low, high, mid
    expect(fsi:score(melody(Pitch.c4, Pitch.g4, Pitch.e4))).to.be_equal_to(0)
    expect(fsi:score(melody(Pitch.c4, Pitch.d4, Pitch.e4))).to.be_greater_than(0)
  end)
end)

describe('Contour.match', function()
  it('returns a boolean and the score, honoring tolerance', function()
    local ok, score = contour.ascend_to{to = 4}:match(rising)
    expect(ok).to.be_equal_to(true)
    expect(score).to.be_equal_to(0)
    local loose = contour.ascend_to{to = 4}:match(falling, nil, 0.5)
    expect(loose).to.be_equal_to(false)
  end)
end)

describe('ContourSequence.score', function()
  it('scores each segment of a composed phrase', function()
    local phrase = contour.ascend_to{to = 2} .. contour.descend_to{to = 0}
    local melody_up_down = melody(Pitch.c4, Pitch.d4, Pitch.e4,
                                  Pitch.e4, Pitch.d4, Pitch.c4)
    local frames = {
      contour.ContourFrame{scale = scale, length = 3},
      contour.ContourFrame{scale = scale, length = 3},
    }
    expect(phrase:score(melody_up_down, frames)).to.be_equal_to(0)
  end)

  it('rejects a melody whose length does not match the declared segments', function()
    local phrase = contour.ascend_to{to = 2} .. contour.descend_to{to = 0}
    local frames = {
      contour.ContourFrame{scale = scale, length = 3},
      contour.ContourFrame{scale = scale, length = 3},
    }
    local too_short = melody(Pitch.c4, Pitch.d4, Pitch.e4)  -- 3 notes, need 6
    local ok = pcall(function() return phrase:score(too_short, frames) end)
    expect(ok).to.be_equal_to(false)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
