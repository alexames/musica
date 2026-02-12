-- Unit tests for generation rules
-- Usage: lua tests/test_rules.lua

-- Require z3 before llx to avoid strict mode conflicts
-- with z3's global registration
local z3 = require 'z3'

local unit = require 'llx.unit'
local llx = require 'llx'

-- Load individual modules to avoid full musica import overhead
local Direction = require('musica.direction').Direction
local Figure = require('musica.figure').Figure
local Mode = require('musica.mode').Mode
local Pitch = require('musica.pitch').Pitch
local Scale = require('musica.scale').Scale

local generation = require 'musica.generation'

_ENV = unit.create_test_env(_ENV)

local InScaleRule = generation.InScaleRule
local MonotonicPitchRule = generation.MonotonicPitchRule
local AscendingPitchRule = generation.AscendingPitchRule
local DescendingPitchRule = generation.DescendingPitchRule
local StartOnPitchRule = generation.StartOnPitchRule
local EndOnPitchRule = generation.EndOnPitchRule
local OvershootRule = generation.OvershootRule
local PitchRangeRule = generation.PitchRangeRule
local MaxIntervalRule = generation.MaxIntervalRule
local ConjunctMotionRule = generation.ConjunctMotionRule
local AllOfRule = generation.AllOfRule
local AnyOfRule = generation.AnyOfRule
local NotRule = generation.NotRule

-- Helper to create a simple figure from pitches
local function make_figure(pitches)
  local melody = llx.List{}
  for i, pitch in ipairs(pitches) do
    melody:insert({pitch = pitch, duration = 1, volume = 1})
  end
  return Figure{duration = #pitches, melody = melody}
end

describe('InScaleRule', function()
  local c_major = Scale{tonic = Pitch.c4, mode = Mode.major}

  it('should validate figure in C major', function()
    local rule = InScaleRule{scale = c_major}
    local figure = make_figure({Pitch.c4, Pitch.e4, Pitch.g4, Pitch.c5})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject figure with note outside scale', function()
    local rule = InScaleRule{scale = c_major}
    local figure = make_figure({Pitch.c4, Pitch.csharp4, Pitch.g4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('not in scale')
  end)

  it('should accept notes in different octaves', function()
    local rule = InScaleRule{scale = c_major}
    local figure = make_figure({Pitch.c3, Pitch.e5, Pitch.g6})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)
end)

describe('MonotonicPitchRule', function()
  it('should validate strictly ascending melody', function()
    local rule = MonotonicPitchRule{direction = Direction.up, strict = true}
    local figure = make_figure({Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject non-ascending melody in strict mode', function()
    local rule = MonotonicPitchRule{direction = Direction.up, strict = true}
    local figure = make_figure({Pitch.c4, Pitch.e4, Pitch.d4, Pitch.f4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
  end)

  it('should reject repeated notes in strict mode', function()
    local rule = MonotonicPitchRule{direction = Direction.up, strict = true}
    local figure = make_figure({Pitch.c4, Pitch.d4, Pitch.d4, Pitch.e4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
  end)

  it('should allow repeated notes in non-strict mode', function()
    local rule = MonotonicPitchRule{direction = Direction.up, strict = false}
    local figure = make_figure({Pitch.c4, Pitch.d4, Pitch.d4, Pitch.e4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should validate strictly descending melody', function()
    local rule = MonotonicPitchRule{direction = Direction.down, strict = true}
    local figure = make_figure({Pitch.g4, Pitch.f4, Pitch.e4, Pitch.d4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)
end)

describe('AscendingPitchRule', function()
  it('should create an ascending rule', function()
    local rule = AscendingPitchRule()
    local figure = make_figure({Pitch.c4, Pitch.d4, Pitch.e4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)
end)

describe('DescendingPitchRule', function()
  it('should create a descending rule', function()
    local rule = DescendingPitchRule()
    local figure = make_figure({Pitch.e4, Pitch.d4, Pitch.c4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)
end)

describe('StartOnPitchRule', function()
  it('should validate correct starting pitch', function()
    local rule = StartOnPitchRule{pitch = Pitch.c4}
    local figure = make_figure({Pitch.c4, Pitch.d4, Pitch.e4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject incorrect starting pitch', function()
    local rule = StartOnPitchRule{pitch = Pitch.c4}
    local figure = make_figure({Pitch.d4, Pitch.e4, Pitch.f4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('First note')
  end)

  it('should reject empty figure', function()
    local rule = StartOnPitchRule{pitch = Pitch.c4}
    local figure = Figure{duration = 0, notes = llx.List{}}

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('no notes')
  end)
end)

describe('EndOnPitchRule', function()
  it('should validate correct ending pitch', function()
    local rule = EndOnPitchRule{pitch = Pitch.g4}
    local figure = make_figure({Pitch.c4, Pitch.d4, Pitch.g4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject incorrect ending pitch', function()
    local rule = EndOnPitchRule{pitch = Pitch.g4}
    local figure = make_figure({Pitch.c4, Pitch.d4, Pitch.e4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('Last note')
  end)
end)

describe('OvershootRule', function()
  it('should validate correct overshoot pattern', function()
    local rule = OvershootRule{
      source_pitch = Pitch.c4,
      target_pitch = Pitch.g4,
      overshoot_amount = 2,
    }
    -- C4 (72) -> E4 (76) -> C5 (84, overshoot >= G4 79 + 2) -> G4 (79)
    local figure = make_figure({Pitch.c4, Pitch.e4, Pitch.c5, Pitch.g4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject pattern without sufficient overshoot', function()
    local rule = OvershootRule{
      source_pitch = Pitch.c4,
      target_pitch = Pitch.g4,
      overshoot_amount = 10,
    }
    -- C5 (84) is only 5 semitones above G4 (79), need 10
    local figure = make_figure({Pitch.c4, Pitch.e4, Pitch.c5, Pitch.g4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('overshoot')
  end)

  it('should reject wrong starting pitch', function()
    local rule = OvershootRule{
      source_pitch = Pitch.c4,
      target_pitch = Pitch.g4,
      overshoot_amount = 2,
    }
    local figure = make_figure({Pitch.d4, Pitch.e4, Pitch.a4, Pitch.g4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
  end)

  it('should reject wrong ending pitch', function()
    local rule = OvershootRule{
      source_pitch = Pitch.c4,
      target_pitch = Pitch.g4,
      overshoot_amount = 2,
    }
    local figure = make_figure({Pitch.c4, Pitch.e4, Pitch.a4, Pitch.a4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
  end)
end)

describe('PitchRangeRule', function()
  it('should validate pitches within range', function()
    local rule = PitchRangeRule{
      min_pitch = Pitch.c4,
      max_pitch = Pitch.c5,
    }
    local figure = make_figure({Pitch.c4, Pitch.e4, Pitch.g4, Pitch.c5})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject pitch below minimum', function()
    local rule = PitchRangeRule{
      min_pitch = Pitch.c4,
      max_pitch = Pitch.c5,
    }
    local figure = make_figure({Pitch.b3, Pitch.c4, Pitch.e4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('below minimum')
  end)

  it('should reject pitch above maximum', function()
    local rule = PitchRangeRule{
      min_pitch = Pitch.c4,
      max_pitch = Pitch.c5,
    }
    local figure = make_figure({Pitch.c4, Pitch.e4, Pitch.d5})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('above maximum')
  end)
end)

describe('MaxIntervalRule', function()
  it('should validate small intervals', function()
    local rule = MaxIntervalRule{max_semitones = 4}
    local figure = make_figure({Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject large leaps', function()
    local rule = MaxIntervalRule{max_semitones = 4}
    -- C4 to G4 is 7 semitones
    local figure = make_figure({Pitch.c4, Pitch.g4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('exceeds maximum')
  end)

  it('should handle descending intervals', function()
    local rule = MaxIntervalRule{max_semitones = 4}
    -- G4 to C4 is -7 semitones (still exceeds max)
    local figure = make_figure({Pitch.g4, Pitch.c4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
  end)
end)

describe('ConjunctMotionRule', function()
  it('should validate stepwise motion', function()
    local rule = ConjunctMotionRule{}
    local figure = make_figure({Pitch.c4, Pitch.d4, Pitch.e4, Pitch.d4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject leaps', function()
    local rule = ConjunctMotionRule{}
    -- Major third = 4 semitones
    local figure = make_figure({Pitch.c4, Pitch.e4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('Leap')
  end)
end)

describe('AllOfRule', function()
  it('should pass when all rules pass', function()
    local rule = AllOfRule{
      rules = {
        StartOnPitchRule{pitch = Pitch.c4},
        EndOnPitchRule{pitch = Pitch.g4},
      }
    }
    local figure = make_figure({Pitch.c4, Pitch.e4, Pitch.g4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should fail when any rule fails', function()
    local rule = AllOfRule{
      rules = {
        StartOnPitchRule{pitch = Pitch.c4},
        EndOnPitchRule{pitch = Pitch.g4},
      }
    }
    local figure = make_figure({Pitch.c4, Pitch.e4, Pitch.f4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
  end)
end)

describe('AnyOfRule', function()
  it('should pass when any rule passes', function()
    local rule = AnyOfRule{
      rules = {
        StartOnPitchRule{pitch = Pitch.c4},
        StartOnPitchRule{pitch = Pitch.d4},
      }
    }
    local figure = make_figure({Pitch.d4, Pitch.e4, Pitch.f4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should fail when all rules fail', function()
    local rule = AnyOfRule{
      rules = {
        StartOnPitchRule{pitch = Pitch.c4},
        StartOnPitchRule{pitch = Pitch.d4},
      }
    }
    local figure = make_figure({Pitch.e4, Pitch.f4, Pitch.g4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
  end)
end)

describe('NotRule', function()
  it('should pass when child rule fails', function()
    local rule = NotRule{
      rule = StartOnPitchRule{pitch = Pitch.c4}
    }
    local figure = make_figure({Pitch.d4, Pitch.e4, Pitch.f4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should fail when child rule passes', function()
    local rule = NotRule{
      rule = StartOnPitchRule{pitch = Pitch.c4}
    }
    local figure = make_figure({Pitch.c4, Pitch.e4, Pitch.f4})

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
  end)
end)

-- Import duration and volume rules
local DurationRangeRule = generation.DurationRangeRule
local TotalDurationRule = generation.TotalDurationRule
local FixedDurationRule = generation.FixedDurationRule
local VolumeRangeRule = generation.VolumeRangeRule
local FixedVolumeRule = generation.FixedVolumeRule
local MonotonicVolumeRule = generation.MonotonicVolumeRule

-- Helper to create a figure with custom durations and volumes
local function make_figure_full(notes)
  local melody = llx.List{}
  for _, note in ipairs(notes) do
    melody:insert({
      pitch = note.pitch,
      duration = note.duration or 1,
      volume = note.volume or 1,
    })
  end
  local total = 0
  for _, note in ipairs(notes) do
    total = total + (note.duration or 1)
  end
  return Figure{duration = total, melody = melody}
end

describe('DurationRangeRule', function()
  it('should validate durations within range', function()
    local rule = DurationRangeRule{min_duration = 0.25, max_duration = 2.0}
    local figure = make_figure_full({
      {pitch = Pitch.c4, duration = 0.5},
      {pitch = Pitch.d4, duration = 1.0},
      {pitch = Pitch.e4, duration = 1.5},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject duration below minimum', function()
    local rule = DurationRangeRule{min_duration = 0.5, max_duration = 2.0}
    local figure = make_figure_full({
      {pitch = Pitch.c4, duration = 0.25},
      {pitch = Pitch.d4, duration = 1.0},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('below minimum')
  end)

  it('should reject duration above maximum', function()
    local rule = DurationRangeRule{min_duration = 0.25, max_duration = 1.0}
    local figure = make_figure_full({
      {pitch = Pitch.c4, duration = 0.5},
      {pitch = Pitch.d4, duration = 2.0},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('above maximum')
  end)
end)

describe('TotalDurationRule', function()
  it('should validate exact total duration', function()
    local rule = TotalDurationRule{exact_total = 3.0}
    local figure = make_figure_full({
      {pitch = Pitch.c4, duration = 1.0},
      {pitch = Pitch.d4, duration = 1.0},
      {pitch = Pitch.e4, duration = 1.0},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject wrong total duration', function()
    local rule = TotalDurationRule{exact_total = 4.0}
    local figure = make_figure_full({
      {pitch = Pitch.c4, duration = 1.0},
      {pitch = Pitch.d4, duration = 1.0},
      {pitch = Pitch.e4, duration = 1.0},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('exact')
  end)

  it('should validate total duration in range', function()
    local rule = TotalDurationRule{min_total = 2.0, max_total = 4.0}
    local figure = make_figure_full({
      {pitch = Pitch.c4, duration = 1.0},
      {pitch = Pitch.d4, duration = 1.5},
      {pitch = Pitch.e4, duration = 0.5},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)
end)

describe('FixedDurationRule', function()
  it('should validate correct fixed duration', function()
    local rule = FixedDurationRule{index = 2, duration = 0.5}
    local figure = make_figure_full({
      {pitch = Pitch.c4, duration = 1.0},
      {pitch = Pitch.d4, duration = 0.5},
      {pitch = Pitch.e4, duration = 1.0},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject wrong fixed duration', function()
    local rule = FixedDurationRule{index = 2, duration = 0.5}
    local figure = make_figure_full({
      {pitch = Pitch.c4, duration = 1.0},
      {pitch = Pitch.d4, duration = 1.0},
      {pitch = Pitch.e4, duration = 1.0},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('required')
  end)
end)

describe('VolumeRangeRule', function()
  it('should validate volumes within range', function()
    local rule = VolumeRangeRule{min_volume = 0.3, max_volume = 0.9}
    local figure = make_figure_full({
      {pitch = Pitch.c4, volume = 0.5},
      {pitch = Pitch.d4, volume = 0.7},
      {pitch = Pitch.e4, volume = 0.8},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject volume below minimum', function()
    local rule = VolumeRangeRule{min_volume = 0.5, max_volume = 1.0}
    local figure = make_figure_full({
      {pitch = Pitch.c4, volume = 0.3},
      {pitch = Pitch.d4, volume = 0.7},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('below minimum')
  end)

  it('should reject volume above maximum', function()
    local rule = VolumeRangeRule{min_volume = 0.0, max_volume = 0.8}
    local figure = make_figure_full({
      {pitch = Pitch.c4, volume = 0.5},
      {pitch = Pitch.d4, volume = 0.95},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('above maximum')
  end)
end)

describe('FixedVolumeRule', function()
  it('should validate correct fixed volume', function()
    local rule = FixedVolumeRule{index = 1, volume = 0.8}
    local figure = make_figure_full({
      {pitch = Pitch.c4, volume = 0.8},
      {pitch = Pitch.d4, volume = 0.5},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject wrong fixed volume', function()
    local rule = FixedVolumeRule{index = 1, volume = 0.8}
    local figure = make_figure_full({
      {pitch = Pitch.c4, volume = 0.5},
      {pitch = Pitch.d4, volume = 0.5},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('required')
  end)
end)

describe('MonotonicVolumeRule', function()
  it('should validate increasing volume (crescendo)', function()
    local rule = MonotonicVolumeRule{increasing = true}
    local figure = make_figure_full({
      {pitch = Pitch.c4, volume = 0.3},
      {pitch = Pitch.d4, volume = 0.5},
      {pitch = Pitch.e4, volume = 0.8},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should validate decreasing volume (decrescendo)', function()
    local rule = MonotonicVolumeRule{increasing = false}
    local figure = make_figure_full({
      {pitch = Pitch.c4, volume = 0.9},
      {pitch = Pitch.d4, volume = 0.6},
      {pitch = Pitch.e4, volume = 0.3},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject non-monotonic volume for crescendo', function()
    local rule = MonotonicVolumeRule{increasing = true}
    local figure = make_figure_full({
      {pitch = Pitch.c4, volume = 0.5},
      {pitch = Pitch.d4, volume = 0.8},
      {pitch = Pitch.e4, volume = 0.4},  -- decreases
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('less than')
  end)

  it('should allow equal volumes in non-strict mode', function()
    local rule = MonotonicVolumeRule{increasing = true, strict = false}
    local figure = make_figure_full({
      {pitch = Pitch.c4, volume = 0.5},
      {pitch = Pitch.d4, volume = 0.5},
      {pitch = Pitch.e4, volume = 0.8},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should reject equal volumes in strict mode', function()
    local rule = MonotonicVolumeRule{increasing = true, strict = true}
    local figure = make_figure_full({
      {pitch = Pitch.c4, volume = 0.5},
      {pitch = Pitch.d4, volume = 0.5},
      {pitch = Pitch.e4, volume = 0.8},
    })

    local ok, err = rule:validate(figure)
    expect(ok).to.be_falsy()
    expect(err).to.contain('not strictly greater')
  end)
end)

if llx.main_file() then
  unit.run_unit_tests()
end
