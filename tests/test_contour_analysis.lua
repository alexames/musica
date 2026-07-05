-- Tests for contour analysis edge cases: empty and single-note melodies,
-- raw MIDI-integer pitches, chromatic (out-of-scale) notes, and negative
-- scale indices. Happy paths over Pitch-object melodies are already covered
-- by test_contour.lua.

local unit = require 'llx.unit'
local llx = require 'llx'
local analysis = require 'musica.contour.analysis'
local direction_module = require 'musica.direction'
local mode_module = require 'musica.mode'
require 'musica.modes'
local note_module = require 'musica.note'
local pitch_class_module = require 'musica.pitch_class'
local pitch_module = require 'musica.pitch'
local scale_module = require 'musica.scale'

local Direction = direction_module.Direction
local up = Direction.up
local down = Direction.down
local same = Direction.same
local Mode = mode_module.Mode
local Note = note_module.Note
local Pitch = pitch_module.Pitch
local PitchClass = pitch_class_module.PitchClass
local C = PitchClass.C
local F = PitchClass.F
local B = PitchClass.B
local Scale = scale_module.Scale
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

local scale = Scale{tonic = Pitch.c4, mode = Mode.major}

-- Build a melody from raw MIDI integers (the coerced-pitch code path).
local function midi_melody(...)
  local notes = {}
  for i, p in ipairs({...}) do notes[i] = {pitch = p} end
  return notes
end

describe('analysis.directional_contour', function()
  it('should mark a single note as same', function()
    local contour = analysis.directional_contour(
      {Note{pitch = Pitch.c4, duration = 1}})
    expect(contour).to.be_equal_to({same})
  end)

  it('should return an empty contour for an empty melody', function()
    expect(analysis.directional_contour({})).to.be_equal_to({})
  end)

  it('should accept raw MIDI integers as pitches', function()
    local contour = analysis.directional_contour(
      midi_melody(60, 64, 64, 60))
    expect(contour).to.be_equal_to({same, up, same, down})
  end)
end)

describe('analysis.relative_contour', function()
  it('should rank a single note as one', function()
    expect(analysis.relative_contour(midi_melody(72))).to.be_equal_to({1})
  end)

  it('should return an empty contour for an empty melody', function()
    expect(analysis.relative_contour({})).to.be_equal_to({})
  end)

  it('should reuse one rank for repeated pitches', function()
    expect(analysis.relative_contour(midi_melody(67, 60, 67)))
      .to.be_equal_to({2, 1, 2})
  end)

  it('should rank by order, ignoring interval size', function()
    -- An octave and a semitone both count as single rank steps.
    expect(analysis.relative_contour(midi_melody(60, 72, 61)))
      .to.be_equal_to({1, 3, 2})
  end)
end)

describe('analysis.pitch_index_contour', function()
  it('should pass raw MIDI integers through unchanged', function()
    expect(analysis.pitch_index_contour(midi_melody(60, 61, 62)))
      .to.be_equal_to({60, 61, 62})
  end)

  it('should return an empty contour for an empty melody', function()
    expect(analysis.pitch_index_contour({})).to.be_equal_to({})
  end)
end)

describe('analysis.scale_index_contour', function()
  it('should mark out-of-scale notes with nil', function()
    -- C4, C#4, D4 in C major: the C# has no scale index.
    local contour = analysis.scale_index_contour(
      midi_melody(60, 61, 62), scale)
    expect(contour[1]).to.be_equal_to(0)
    expect(contour[2]).to.be_nil()
    expect(contour[3]).to.be_equal_to(1)
  end)

  it('should index below the tonic and across octaves', function()
    -- B3 is one degree below the tonic; C5 is a full octave above it.
    expect(analysis.scale_index_contour(midi_melody(59, 72), scale))
      .to.be_equal_to({-1, 7})
  end)
end)

describe('analysis.pitch_class_contour', function()
  it('should spell integer black keys as the sharp of the lower natural',
     function()
    -- 61 = C#, 66 = F#: both report the lower natural letter class.
    expect(analysis.pitch_class_contour(midi_melody(60, 61, 66, 71)))
      .to.be_equal_to({C, C, F, B})
  end)

  it('should return an empty contour for an empty melody', function()
    expect(analysis.pitch_class_contour({})).to.be_equal_to({})
  end)
end)

if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
