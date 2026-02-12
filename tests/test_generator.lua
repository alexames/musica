-- Integration tests for Generator
-- Usage: lua tests/test_generator.lua

-- Require z3 before llx to avoid strict mode conflicts with z3's global registration
local z3 = require 'z3'

local unit = require 'llx.unit'
local llx = require 'llx'

-- Load individual modules
local Figure = require('musica.figure').Figure
local Direction = require('musica.direction').Direction
local Mode = require('musica.mode').Mode
local Pitch = require('musica.pitch').Pitch
local Scale = require('musica.scale').Scale

local generation = require 'musica.generation'

_ENV = unit.create_test_env(_ENV)

local tointeger = llx.tointeger

local Generator = generation.Generator
local GenerationContext = generation.GenerationContext
local InScaleRule = generation.InScaleRule
local MonotonicPitchRule = generation.MonotonicPitchRule
local AscendingPitchRule = generation.AscendingPitchRule
local StartOnPitchRule = generation.StartOnPitchRule
local EndOnPitchRule = generation.EndOnPitchRule
local MaxIntervalRule = generation.MaxIntervalRule
local PitchRangeRule = generation.PitchRangeRule
local DurationRangeRule = generation.DurationRangeRule
local VolumeRangeRule = generation.VolumeRangeRule
local FixedDurationRule = generation.FixedDurationRule
local FixedVolumeRule = generation.FixedVolumeRule
local TotalDurationRule = generation.TotalDurationRule

describe('GenerationContext', function()
  it('should create Z3 variables for each note position', function()
    local ctx = GenerationContext{num_notes = 4}

    expect(ctx:get_num_notes()).to.be_equal_to(4)
    expect(#ctx:get_pitch_vars()).to.be_equal_to(4)
    expect(#ctx:get_duration_vars()).to.be_equal_to(4)
    expect(#ctx:get_volume_vars()).to.be_equal_to(4)
  end)

  it('should convert pitches to Z3 values', function()
    local ctx = GenerationContext{num_notes = 2}
    local z3_val = ctx:pitch_to_z3(Pitch.c4)

    expect(z3_val).to_not.be_nil()
  end)

  it('should convert durations to Z3 values', function()
    local ctx = GenerationContext{num_notes = 2}
    local z3_val = ctx:duration_to_z3(0.5)
    local back = ctx:z3_to_duration(500)

    expect(z3_val).to_not.be_nil()
    expect(back).to.be_equal_to(0.5)
  end)

  it('should convert volumes to Z3 values', function()
    local ctx = GenerationContext{num_notes = 2}
    local z3_val = ctx:volume_to_z3(0.75)
    local back = ctx:z3_to_volume(750)

    expect(z3_val).to_not.be_nil()
    expect(back).to.be_equal_to(0.75)
  end)
end)

describe('Generator', function()
  it('should generate a simple ascending scale passage', function()
    local c_major = Scale{tonic = Pitch.c4, mode = Mode.major}

    local generator = Generator{
      rules = {
        InScaleRule{scale = c_major},
        AscendingPitchRule{strict = true},
        StartOnPitchRule{pitch = Pitch.c4},
        EndOnPitchRule{pitch = Pitch.g4},
        PitchRangeRule{min_pitch = Pitch.c4, max_pitch = Pitch.c5},
        DurationRangeRule{min_duration = 0.5, max_duration = 1.0},
        VolumeRangeRule{min_volume = 0.5, max_volume = 1.0},
      },
      context = {
        num_notes = 5,
      },
    }

    local figure = generator:generate_one()
    expect(figure).to_not.be_nil()
    expect(#figure.notes).to.be_equal_to(5)

    -- Verify first and last notes
    expect(tointeger(figure.notes[1].pitch)).to.be_equal_to(tointeger(Pitch.c4))
    expect(tointeger(figure.notes[5].pitch)).to.be_equal_to(tointeger(Pitch.g4))

    -- Verify ascending order
    for i = 2, #figure.notes do
      local prev = tointeger(figure.notes[i-1].pitch)
      local curr = tointeger(figure.notes[i].pitch)
      expect(curr).to.be_greater_than(prev)
    end

    -- Validate the generated figure passes all rules
    local ok, failures = generator:validate(figure)
    expect(ok).to.be_truthy()
  end)

  it('should return nil for unsatisfiable constraints', function()
    local c_major = Scale{tonic = Pitch.c4, mode = Mode.major}

    local generator = Generator{
      rules = {
        InScaleRule{scale = c_major},
        AscendingPitchRule{strict = true},
        StartOnPitchRule{pitch = Pitch.c4},
        EndOnPitchRule{pitch = Pitch.b3},  -- B3 < C4, can't ascend to it
        PitchRangeRule{min_pitch = Pitch.c3, max_pitch = Pitch.c5},
        DurationRangeRule{min_duration = 0.5, max_duration = 1.0},
      },
      context = {
        num_notes = 4,
      },
    }

    local figure = generator:generate_one()
    expect(figure).to.be_nil()
  end)

  it('should enumerate multiple distinct solutions', function()
    local c_major = Scale{tonic = Pitch.c4, mode = Mode.major}

    local generator = Generator{
      rules = {
        InScaleRule{scale = c_major},
        StartOnPitchRule{pitch = Pitch.c4},
        EndOnPitchRule{pitch = Pitch.e4},
        PitchRangeRule{min_pitch = Pitch.c4, max_pitch = Pitch.g4},
        -- Fix duration and volume to reduce solution space
        DurationRangeRule{min_duration = 1.0, max_duration = 1.0},
        VolumeRangeRule{min_volume = 1.0, max_volume = 1.0},
      },
      context = {
        num_notes = 3,
      },
      max_solutions = 20,
    }

    local solutions = llx.List{}
    for i, figure in generator:generate_all() do
      solutions:insert(figure)
    end

    expect(#solutions).to.be_greater_than(1)

    -- All solutions should be valid
    for i, figure in ipairs(solutions) do
      local ok, _ = generator:validate(figure)
      expect(ok).to.be_truthy()
    end

    -- All solutions should start on C4 and end on E4
    for i, figure in ipairs(solutions) do
      expect(tointeger(figure.notes[1].pitch)).to.be_equal_to(tointeger(Pitch.c4))
      expect(tointeger(figure.notes[3].pitch)).to.be_equal_to(tointeger(Pitch.e4))
    end
  end)

  it('should validate figures correctly', function()
    local c_major = Scale{tonic = Pitch.c4, mode = Mode.major}

    local generator = Generator{
      rules = {
        InScaleRule{scale = c_major},
        StartOnPitchRule{pitch = Pitch.c4},
      },
    }

    -- Create a valid figure manually
    local valid_figure = Figure{
      duration = 3,
      melody = {
        {pitch = Pitch.c4, duration = 1, volume = 1},
        {pitch = Pitch.e4, duration = 1, volume = 1},
        {pitch = Pitch.g4, duration = 1, volume = 1},
      }
    }

    local ok, failures = generator:validate(valid_figure)
    expect(ok).to.be_truthy()
    expect(#failures).to.be_equal_to(0)
  end)

  it('should report validation failures', function()
    local c_major = Scale{tonic = Pitch.c4, mode = Mode.major}

    local generator = Generator{
      rules = {
        InScaleRule{scale = c_major},
        StartOnPitchRule{pitch = Pitch.c4},
      },
    }

    -- Create an invalid figure (starts on D, has C#)
    local invalid_figure = Figure{
      duration = 3,
      melody = {
        {pitch = Pitch.d4, duration = 1, volume = 1},  -- Wrong start
        {pitch = Pitch.csharp4, duration = 1, volume = 1},  -- Not in scale
        {pitch = Pitch.g4, duration = 1, volume = 1},
      }
    }

    local ok, failures = generator:validate(invalid_figure)
    expect(ok).to.be_falsy()
    expect(#failures).to.be_equal_to(2)  -- Both rules should fail
  end)

  it('should respect max_solutions limit', function()
    local generator = Generator{
      rules = {
        PitchRangeRule{min_pitch = Pitch.c4, max_pitch = Pitch.e4},
        -- Fix duration and volume to limit solution space
        DurationRangeRule{min_duration = 1.0, max_duration = 1.0},
        VolumeRangeRule{min_volume = 1.0, max_volume = 1.0},
      },
      context = {
        num_notes = 2,
      },
      max_solutions = 3,
    }

    local count = 0
    for i, figure in generator:generate_all() do
      count = count + 1
    end

    expect(count).to.be_less_than_or_equal(3)
  end)

  it('should use fixed duration and volume rules', function()
    local generator = Generator{
      rules = {
        StartOnPitchRule{pitch = Pitch.c4},
        PitchRangeRule{min_pitch = Pitch.c4, max_pitch = Pitch.g4},
        FixedDurationRule{index = 1, duration = 0.5},
        FixedDurationRule{index = 2, duration = 0.25},
        FixedDurationRule{index = 3, duration = 1.0},
        FixedVolumeRule{index = 1, volume = 0.8},
        FixedVolumeRule{index = 2, volume = 0.6},
        FixedVolumeRule{index = 3, volume = 1.0},
      },
      context = {
        num_notes = 3,
      },
    }

    local figure = generator:generate_one()
    expect(figure).to_not.be_nil()

    expect(figure.notes[1].duration).to.be_equal_to(0.5)
    expect(figure.notes[2].duration).to.be_equal_to(0.25)
    expect(figure.notes[3].duration).to.be_equal_to(1.0)

    expect(figure.notes[1].volume).to.be_equal_to(0.8)
    expect(figure.notes[2].volume).to.be_equal_to(0.6)
    expect(figure.notes[3].volume).to.be_equal_to(1.0)
  end)

  it('should combine multiple rule types', function()
    local c_major = Scale{tonic = Pitch.c4, mode = Mode.major}

    local generator = Generator{
      rules = {
        InScaleRule{scale = c_major},
        AscendingPitchRule{strict = true},
        StartOnPitchRule{pitch = Pitch.c4},
        EndOnPitchRule{pitch = Pitch.c5},
        MaxIntervalRule{max_semitones = 4},  -- No leaps larger than major third
        PitchRangeRule{min_pitch = Pitch.c4, max_pitch = Pitch.c5},
        DurationRangeRule{min_duration = 0.5, max_duration = 1.0},
        VolumeRangeRule{min_volume = 0.5, max_volume = 1.0},
      },
      context = {
        num_notes = 8,
      },
    }

    local figure = generator:generate_one()
    expect(figure).to_not.be_nil()

    -- Verify all constraints
    local ok, _ = generator:validate(figure)
    expect(ok).to.be_truthy()

    -- Verify no large leaps
    for i = 2, #figure.notes do
      local prev = tointeger(figure.notes[i-1].pitch)
      local curr = tointeger(figure.notes[i].pitch)
      expect(math.abs(curr - prev)).to.be_less_than_or_equal(4)
    end
  end)

  it('should constrain total duration', function()
    local generator = Generator{
      rules = {
        PitchRangeRule{min_pitch = Pitch.c4, max_pitch = Pitch.g4},
        TotalDurationRule{exact_total = 4.0},
        DurationRangeRule{min_duration = 0.5, max_duration = 2.0},
        VolumeRangeRule{min_volume = 0.5, max_volume = 1.0},
      },
      context = {
        num_notes = 4,
      },
    }

    local figure = generator:generate_one()
    expect(figure).to_not.be_nil()

    local total = 0
    for i, note in ipairs(figure.notes) do
      total = total + note.duration
    end

    -- Allow small floating point tolerance
    expect(math.abs(total - 4.0)).to.be_less_than(0.01)
  end)
end)

if llx.main_file() then
  unit.run_unit_tests()
end
