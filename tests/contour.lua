require 'unit'
require 'llx'
require 'musica.contour'
require 'musica.direction'
require 'musica.note'
require 'musica.mode'
require 'musica.modes'
require 'musica.chord'
require 'musica.quality'

_ENV = unit.create_test_env(_ENV)

--------------------------------------------------------------------------------
-- Test Data: "Mary Had a Little Lamb"
--------------------------------------------------------------------------------

local mary = {
  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.c4, duration=1},
  Note{pitch=Pitch.d4, duration=1},

  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.e4, duration=2},

  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.d4, duration=2},

  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.g4, duration=1},
  Note{pitch=Pitch.g4, duration=2},

  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.c4, duration=1},
  Note{pitch=Pitch.d4, duration=1},

  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.e4, duration=1},

  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.d4, duration=1},

  Note{pitch=Pitch.c4, duration=4},
}

--------------------------------------------------------------------------------
-- Analysis Functions Tests (existing tests, updated)
--------------------------------------------------------------------------------

describe('ContourAnalysis', function()
  it('should generate directional contour correctly', function()
    local result = directional_contour(mary)
    expect(result).to.be_equal_to(
      {same, down, down,   up,
         up, same, same,
       down, same, same,
         up,   up, same,
       down, down, down,   up,
         up, same, same, same,
       down, same,   up, down,
       down})
  end)

  it('should generate relative contour correctly', function()
    local result = relative_contour(mary)
    expect(result).to.be_equal_to(
      {2, 1, 0, 1,
       2, 2, 2,
       1, 1, 1,
       2, 3, 3,
       2, 1, 0, 1,
       2, 2, 2, 2,
       1, 1, 2, 1,
       0})
  end)

  it('should generate pitch index contour correctly', function()
    local result = pitch_index_contour(mary)
    expect(result).to.be_equal_to(
      {76, 74, 72, 74,
       76, 76, 76,
       74, 74, 74,
       76, 79, 79,
       76, 74, 72, 74,
       76, 76, 76, 76,
       74, 74, 76, 74,
       72})
  end)

  it('should generate scale index contour correctly', function()
    local result = scale_index_contour(mary,
                                  Scale{tonic=Pitch.c4, mode=Mode.major})
    expect(result).to.be_equal_to(
      {2, 1, 0, 1,
       2, 2, 2,
       1, 1, 1,
       2, 4, 4,
       2, 1, 0, 1,
       2, 2, 2, 2,
       1, 1, 2, 1,
       0})
  end)

  it('should generate pitch class contour correctly', function()
    local result = pitch_class_contour(mary)
    expect(result).to.be_equal_to(
      {E, D, C, D,
       E, E, E,
       D, D, D,
       E, G, G,
       E, D, C, D,
       E, E, E, E,
       D, D, E, D,
       C})
  end)
end)

--------------------------------------------------------------------------------
-- Shape Enum Tests
--------------------------------------------------------------------------------

describe('ShapeEnum', function()
  it('should have all expected shape values', function()
    expect(Shape.any).to_not.be_nil()
    expect(Shape.ascending).to_not.be_nil()
    expect(Shape.descending).to_not.be_nil()
    expect(Shape.strict_ascending).to_not.be_nil()
    expect(Shape.strict_descending).to_not.be_nil()
    expect(Shape.arch).to_not.be_nil()
    expect(Shape.trough).to_not.be_nil()
    expect(Shape.alternating).to_not.be_nil()
    expect(Shape.drone).to_not.be_nil()
    expect(Shape.returning).to_not.be_nil()
  end)

  it('should have correct name property', function()
    expect(Shape.ascending.name).to.be_equal_to('ascending')
    expect(Shape.descending.name).to.be_equal_to('descending')
    expect(Shape.arch.name).to.be_equal_to('arch')
  end)

  it('should be comparable by equality', function()
    expect(Shape.ascending == Shape.ascending).to.be_truthy()
    expect(Shape.ascending == Shape.descending).to.be_falsy()
  end)
end)

--------------------------------------------------------------------------------
-- Motion Enum Tests
--------------------------------------------------------------------------------

describe('MotionEnum', function()
  it('should have all expected motion values', function()
    expect(Motion.any).to_not.be_nil()
    expect(Motion.stepwise).to_not.be_nil()
    expect(Motion.leaps).to_not.be_nil()
    expect(Motion.mixed).to_not.be_nil()
  end)

  it('should have correct name property', function()
    expect(Motion.stepwise.name).to.be_equal_to('stepwise')
    expect(Motion.leaps.name).to.be_equal_to('leaps')
  end)
end)

--------------------------------------------------------------------------------
-- Contour Matching Tests
--------------------------------------------------------------------------------

describe('ContourMatching', function()
  describe('ascending shape', function()
    it('should match ascending melody', function()
      local c = Contour{shape = Shape.ascending}
      local ascending_melody = {Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4, Pitch.g4}
      local matches, errors = c:matches(ascending_melody)
      expect(matches).to.be_truthy()
    end)

    it('should match ascending melody with repeated notes', function()
      local c = Contour{shape = Shape.ascending}
      local melody = {Pitch.c4, Pitch.c4, Pitch.d4, Pitch.e4, Pitch.e4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject descending motion in ascending contour', function()
      local c = Contour{shape = Shape.ascending}
      local melody = {Pitch.c4, Pitch.d4, Pitch.c4, Pitch.e4}  -- Has a dip
      local matches, errors = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)

  describe('strict ascending shape', function()
    it('should match strictly ascending melody', function()
      local c = Contour{shape = Shape.strict_ascending}
      local melody = {Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject repeated notes in strict ascending', function()
      local c = Contour{shape = Shape.strict_ascending}
      local melody = {Pitch.c4, Pitch.d4, Pitch.d4, Pitch.e4}  -- Has repeat
      local matches = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)

  describe('descending shape', function()
    it('should match descending melody', function()
      local c = Contour{shape = Shape.descending}
      local melody = {Pitch.g4, Pitch.f4, Pitch.e4, Pitch.d4, Pitch.c4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject ascending motion in descending contour', function()
      local c = Contour{shape = Shape.descending}
      local melody = {Pitch.g4, Pitch.f4, Pitch.g4, Pitch.e4}  -- Has a rise
      local matches = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)

  describe('arch shape', function()
    it('should match arch-shaped melody', function()
      local c = Contour{shape = Shape.arch}
      local melody = {Pitch.c4, Pitch.d4, Pitch.e4, Pitch.d4, Pitch.c4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject trough in arch contour', function()
      local c = Contour{shape = Shape.arch}
      local melody = {Pitch.e4, Pitch.d4, Pitch.c4, Pitch.d4, Pitch.e4}
      local matches = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)

  describe('trough shape', function()
    it('should match trough-shaped melody', function()
      local c = Contour{shape = Shape.trough}
      local melody = {Pitch.e4, Pitch.d4, Pitch.c4, Pitch.d4, Pitch.e4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)
  end)

  describe('drone shape', function()
    it('should match drone melody (all same pitch)', function()
      local c = Contour{shape = Shape.drone}
      local melody = {Pitch.c4, Pitch.c4, Pitch.c4, Pitch.c4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject melody with pitch changes in drone contour', function()
      local c = Contour{shape = Shape.drone}
      local melody = {Pitch.c4, Pitch.c4, Pitch.d4, Pitch.c4}
      local matches = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)

  describe('alternating shape', function()
    it('should match alternating melody', function()
      local c = Contour{shape = Shape.alternating}
      local melody = {Pitch.c4, Pitch.e4, Pitch.d4, Pitch.f4, Pitch.e4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject consecutive same direction', function()
      local c = Contour{shape = Shape.alternating}
      local melody = {Pitch.c4, Pitch.d4, Pitch.e4, Pitch.d4}  -- Two ups in a row
      local matches = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)

  describe('returning shape', function()
    it('should match melody that returns to start', function()
      local c = Contour{shape = Shape.returning}
      local melody = {Pitch.c4, Pitch.e4, Pitch.g4, Pitch.e4, Pitch.c4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject melody that does not return', function()
      local c = Contour{shape = Shape.returning}
      local melody = {Pitch.c4, Pitch.e4, Pitch.g4}
      local matches = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)
end)

--------------------------------------------------------------------------------
-- Motion Matching Tests
--------------------------------------------------------------------------------

describe('MotionMatching', function()
  describe('stepwise motion', function()
    it('should match stepwise melody', function()
      local c = Contour{motion = Motion.stepwise}
      -- C4 to D4 is 2 semitones (whole step), D4 to E4 is 2 semitones
      local melody = {Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject leaps in stepwise contour', function()
      local c = Contour{motion = Motion.stepwise}
      -- C4 to E4 is 4 semitones (major third) - a leap
      local melody = {Pitch.c4, Pitch.e4, Pitch.g4}
      local matches = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)

  describe('leaps motion', function()
    it('should match melody with only leaps', function()
      local c = Contour{motion = Motion.leaps}
      -- C4 to E4 is 4 semitones, E4 to G4 is 3 semitones
      local melody = {Pitch.c4, Pitch.e4, Pitch.g4, Pitch.c5}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject stepwise motion in leaps contour', function()
      local c = Contour{motion = Motion.leaps}
      local melody = {Pitch.c4, Pitch.d4, Pitch.g4}  -- C to D is a step
      local matches = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)
end)

--------------------------------------------------------------------------------
-- Boundary Constraint Tests
--------------------------------------------------------------------------------

describe('BoundaryConstraints', function()
  describe('start pitch', function()
    it('should match melody starting on specified pitch', function()
      local c = Contour{start_pitch = Pitch.c4}
      local melody = {Pitch.c4, Pitch.d4, Pitch.e4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject melody not starting on specified pitch', function()
      local c = Contour{start_pitch = Pitch.c4}
      local melody = {Pitch.d4, Pitch.e4, Pitch.f4}
      local matches = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)

  describe('end pitch', function()
    it('should match melody ending on specified pitch', function()
      local c = Contour{end_pitch = Pitch.g4}
      local melody = {Pitch.c4, Pitch.e4, Pitch.g4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should reject melody not ending on specified pitch', function()
      local c = Contour{end_pitch = Pitch.g4}
      local melody = {Pitch.c4, Pitch.e4, Pitch.f4}
      local matches = c:matches(melody)
      expect(matches).to.be_falsy()
    end)
  end)

  describe('scale degree constraints', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}

    it('should match melody starting on tonic', function()
      local c = Contour{
        start_scale_degree = 0,  -- Tonic (C)
        scale = c_major
      }
      local melody = {Pitch.c4, Pitch.d4, Pitch.e4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)

    it('should match melody ending on dominant', function()
      local c = Contour{
        end_scale_degree = 4,  -- Dominant (G)
        scale = c_major
      }
      local melody = {Pitch.c4, Pitch.e4, Pitch.g4}
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end)
  end)
end)

--------------------------------------------------------------------------------
-- Interval Constraint Tests
--------------------------------------------------------------------------------

describe('IntervalConstraints', function()
  it('should enforce maximum interval', function()
    local c = Contour{max_interval = 4}  -- Max of major third
    local melody = {Pitch.c4, Pitch.e4, Pitch.g4}  -- C-E is 4, E-G is 3
    local matches = c:matches(melody)
    expect(matches).to.be_truthy()
  end)

  it('should reject intervals exceeding maximum', function()
    local c = Contour{max_interval = 3}  -- Max of minor third
    local melody = {Pitch.c4, Pitch.g4}  -- C-G is 7 semitones
    local matches = c:matches(melody)
    expect(matches).to.be_falsy()
  end)

  it('should enforce minimum interval', function()
    local c = Contour{min_interval = 3}  -- At least minor third
    local melody = {Pitch.c4, Pitch.e4, Pitch.g4}  -- All intervals >= 3
    local matches = c:matches(melody)
    expect(matches).to.be_truthy()
  end)

  it('should reject intervals below minimum', function()
    local c = Contour{min_interval = 3}
    local melody = {Pitch.c4, Pitch.d4, Pitch.g4}  -- C-D is only 2
    local matches = c:matches(melody)
    expect(matches).to.be_falsy()
  end)
end)

--------------------------------------------------------------------------------
-- Scale Constraint Tests
--------------------------------------------------------------------------------

describe('ScaleConstraints', function()
  local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}

  it('should match melody entirely in scale', function()
    local c = Contour{scale = c_major}
    local melody = {Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4, Pitch.g4}
    local matches = c:matches(melody)
    expect(matches).to.be_truthy()
  end)

  it('should reject melody with out-of-scale notes', function()
    local c = Contour{scale = c_major}
    local melody = {Pitch.c4, Pitch.d4, Pitch.fsharp4, Pitch.g4}  -- F# not in C major
    local matches = c:matches(melody)
    expect(matches).to.be_falsy()
  end)
end)

--------------------------------------------------------------------------------
-- Chord Constraint Tests
--------------------------------------------------------------------------------

describe('ChordConstraints', function()
  local c_major_chord = Chord{root=Pitch.c4, quality=Quality.major}

  it('should match melody using only chord tones', function()
    local c = Contour{chord = c_major_chord, require_in_chord = true}
    local melody = {Pitch.c4, Pitch.e4, Pitch.g4, Pitch.c5}  -- All chord tones
    local matches = c:matches(melody)
    expect(matches).to.be_truthy()
  end)

  it('should reject melody with non-chord tones', function()
    local c = Contour{chord = c_major_chord, require_in_chord = true}
    local melody = {Pitch.c4, Pitch.d4, Pitch.e4}  -- D is not a chord tone
    local matches = c:matches(melody)
    expect(matches).to.be_falsy()
  end)
end)

--------------------------------------------------------------------------------
-- Range Constraint Tests
--------------------------------------------------------------------------------

describe('RangeConstraints', function()
  it('should match melody within pitch range', function()
    local c = Contour{min_pitch = Pitch.c4, max_pitch = Pitch.g4}
    local melody = {Pitch.c4, Pitch.e4, Pitch.g4}
    local matches = c:matches(melody)
    expect(matches).to.be_truthy()
  end)

  it('should reject melody outside pitch range', function()
    local c = Contour{min_pitch = Pitch.c4, max_pitch = Pitch.g4}
    local melody = {Pitch.c4, Pitch.e4, Pitch.a4}  -- A4 exceeds max
    local matches = c:matches(melody)
    expect(matches).to.be_falsy()
  end)

  it('should enforce melodic span constraints', function()
    local c = Contour{min_span = 4, max_span = 12}
    local melody = {Pitch.c4, Pitch.e4, Pitch.g4}  -- Span is 7 semitones
    local matches = c:matches(melody)
    expect(matches).to.be_truthy()
  end)
end)

--------------------------------------------------------------------------------
-- Combined Constraint Tests
--------------------------------------------------------------------------------

describe('CombinedConstraints', function()
  it('should match melody satisfying multiple constraints', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour{
      shape = Shape.ascending,
      motion = Motion.stepwise,
      start_scale_degree = 0,  -- Start on tonic
      end_scale_degree = 4,    -- End on dominant
      scale = c_major,
    }
    -- C D E F G - ascending stepwise from C to G
    local melody = {Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4, Pitch.g4}
    local matches = c:matches(melody)
    expect(matches).to.be_truthy()
  end)

  it('should reject if any constraint fails', function()
    local c = Contour{
      shape = Shape.ascending,
      start_pitch = Pitch.c4,
      end_pitch = Pitch.g4,
    }
    -- Starts correctly, ends correctly, but has a dip
    local melody = {Pitch.c4, Pitch.e4, Pitch.d4, Pitch.g4}
    local matches = c:matches(melody)
    expect(matches).to.be_falsy()
  end)
end)

--------------------------------------------------------------------------------
-- Generation Tests
--------------------------------------------------------------------------------

describe('ContourGeneration', function()
  it('should generate melodies matching ascending shape', function()
    local c = Contour{shape = Shape.ascending}
    local figures = c:generate{length = 5, count = 3}

    expect(#figures).to.be_equal_to(3)

    for _, figure in ipairs(figures) do
      expect(#figure.notes).to.be_equal_to(5)
      -- Verify each generated melody matches the contour
      local matches = c:matches(figure.notes)
      expect(matches).to.be_truthy()
    end
  end)

  it('should generate scale-based melodies', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour{
      shape = Shape.ascending,
      scale = c_major,
    }
    local figures = c:generate{length = 5, count = 2}

    for _, figure in ipairs(figures) do
      local matches = c:matches(figure.notes)
      expect(matches).to.be_truthy()
    end
  end)

  it('should generate melodies with start and end constraints', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour{
      start_scale_degree = 0,  -- Start on C
      end_scale_degree = 4,    -- End on G
      scale = c_major,
    }
    local figures = c:generate{length = 5, count = 3}

    for _, figure in ipairs(figures) do
      local matches = c:matches(figure.notes)
      expect(matches).to.be_truthy()
    end
  end)

  it('should respect rhythm parameter', function()
    local c = Contour{shape = Shape.ascending}
    local rhythm = {1.0, 0.5, 0.5, 1.0}  -- Quarter, eighth, eighth, quarter
    local figures = c:generate{length = 4, count = 1, rhythm = rhythm}

    expect(#figures).to.be_equal_to(1)
    local notes = figures[1].notes
    expect(notes[1].duration).to.be_equal_to(1.0)
    expect(notes[2].duration).to.be_equal_to(0.5)
    expect(notes[3].duration).to.be_equal_to(0.5)
    expect(notes[4].duration).to.be_equal_to(1.0)
  end)

  it('should use default duration when rhythm not provided', function()
    local c = Contour{shape = Shape.ascending}
    local figures = c:generate{length = 3, count = 1, duration = 0.25}

    local notes = figures[1].notes
    for _, note in ipairs(notes) do
      expect(note.duration).to.be_equal_to(0.25)
    end
  end)
end)

--------------------------------------------------------------------------------
-- Pre-defined Contour Factory Tests
--------------------------------------------------------------------------------

describe('PredefinedContours', function()
  it('should create ascending contour', function()
    local c = Contour.ascending()
    local melody = {Pitch.c4, Pitch.d4, Pitch.e4}
    expect(c:matches(melody)).to.be_truthy()
  end)

  it('should create descending contour', function()
    local c = Contour.descending()
    local melody = {Pitch.g4, Pitch.f4, Pitch.e4}
    expect(c:matches(melody)).to.be_truthy()
  end)

  it('should create arch contour', function()
    local c = Contour.arch()
    local melody = {Pitch.c4, Pitch.e4, Pitch.g4, Pitch.e4, Pitch.c4}
    expect(c:matches(melody)).to.be_truthy()
  end)

  it('should create trough contour', function()
    local c = Contour.trough()
    local melody = {Pitch.g4, Pitch.e4, Pitch.c4, Pitch.e4, Pitch.g4}
    expect(c:matches(melody)).to.be_truthy()
  end)

  it('should create scale run up contour', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour.scale_run_up{scale = c_major}
    local melody = {Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4, Pitch.g4}
    expect(c:matches(melody)).to.be_truthy()
  end)

  it('should create scale run down contour', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour.scale_run_down{scale = c_major}
    local melody = {Pitch.g4, Pitch.f4, Pitch.e4, Pitch.d4, Pitch.c4}
    expect(c:matches(melody)).to.be_truthy()
  end)

  it('should create drone contour', function()
    local c = Contour.drone()
    local melody = {Pitch.c4, Pitch.c4, Pitch.c4}
    expect(c:matches(melody)).to.be_truthy()
  end)

  it('should create returning contour', function()
    local c = Contour.returning()
    local melody = {Pitch.c4, Pitch.e4, Pitch.g4, Pitch.e4, Pitch.c4}
    expect(c:matches(melody)).to.be_truthy()
  end)

  it('should pass through additional args to factory', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour.ascending{
      scale = c_major,
      start_scale_degree = 0,
    }
    -- Should be ascending AND start on tonic AND in scale
    local melody = {Pitch.c4, Pitch.d4, Pitch.e4}
    expect(c:matches(melody)).to.be_truthy()

    -- Wrong start
    local bad_start = {Pitch.d4, Pitch.e4, Pitch.f4}
    expect(c:matches(bad_start)).to.be_falsy()
  end)
end)

--------------------------------------------------------------------------------
-- Custom Rule Tests
--------------------------------------------------------------------------------

describe('CustomRules', function()
  it('should support custom rules via function', function()
    -- Custom rule: no repeated notes allowed
    local no_repeats = custom_rule('no_repeats', function(melody, context)
      local pitches = {}
      for i, note in ipairs(melody) do
        local p = note.pitch or note
        if i > 1 then
          local prev = pitches[#pitches]
          if tointeger(p) == tointeger(prev) then
            return false, "Found repeated note"
          end
        end
        table.insert(pitches, p)
      end
      return true
    end)

    local c = Contour{rules = {no_repeats}}

    local good = {Pitch.c4, Pitch.d4, Pitch.e4}
    expect(c:matches(good)).to.be_truthy()

    local bad = {Pitch.c4, Pitch.c4, Pitch.d4}
    expect(c:matches(bad)).to.be_falsy()
  end)

  it('should allow adding rules after construction', function()
    local c = Contour{shape = Shape.ascending}

    -- Add a max interval rule
    c:add_rule(max_interval_rule(4))

    local good = {Pitch.c4, Pitch.e4, Pitch.g4}  -- Intervals: 4, 3
    expect(c:matches(good)).to.be_truthy()

    local bad = {Pitch.c4, Pitch.g4}  -- Interval: 7 (exceeds 4)
    expect(c:matches(bad)).to.be_falsy()
  end)
end)

--------------------------------------------------------------------------------
-- Enumeration Tests
--------------------------------------------------------------------------------

describe('ContourEnumeration', function()
  it('should enumerate all ascending stepwise melodies from C4 to G4', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour{
      shape = Shape.strict_ascending,
      motion = Motion.stepwise,
      start_pitch = Pitch.c4,
      end_pitch = Pitch.g4,
      scale = c_major,
    }

    local melodies = c:enumerate{length = 4, as_pitches = true}

    -- With strict ascending stepwise from C4 to G4 in 4 notes,
    -- we need to go up 7 semitones (C to G) in 3 steps
    -- Possible paths in C major: C-D-E-G, C-D-F-G, C-E-F-G
    -- That's 3 valid melodies
    expect(#melodies).to.be_greater_than(0)

    -- Verify all results match the contour
    for _, melody in ipairs(melodies) do
      local matches = c:matches(melody)
      expect(matches).to.be_truthy()
    end
  end)

  it('should enumerate with max_results limit', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour{
      shape = Shape.ascending,
      scale = c_major,
    }

    local melodies = c:enumerate{length = 4, max_results = 5}
    expect(#melodies).to.be_equal_to(5)
  end)

  it('should return Figures by default', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour{
      shape = Shape.strict_ascending,
      motion = Motion.stepwise,
      start_pitch = Pitch.c4,
      scale = c_major,
    }

    local figures = c:enumerate{length = 3, max_results = 1}
    expect(#figures).to.be_equal_to(1)
    -- Should be a Figure with notes
    expect(figures[1].notes).to_not.be_nil()
    expect(#figures[1].notes).to.be_equal_to(3)
  end)

  it('should respect rhythm in enumerated Figures', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour{
      shape = Shape.strict_ascending,
      start_pitch = Pitch.c4,
      scale = c_major,
    }

    local rhythm = {1.0, 0.5, 0.5}
    local figures = c:enumerate{length = 3, max_results = 1, rhythm = rhythm}

    local notes = figures[1].notes
    expect(notes[1].duration).to.be_equal_to(1.0)
    expect(notes[2].duration).to.be_equal_to(0.5)
    expect(notes[3].duration).to.be_equal_to(0.5)
  end)

  it('should support iterator-based lazy enumeration', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour{
      shape = Shape.strict_ascending,
      motion = Motion.stepwise,
      start_pitch = Pitch.c4,
      scale = c_major,
    }

    local count = 0
    local first_melody = nil
    for melody in c:iter_melodies{length = 3, as_pitches = true} do
      count = count + 1
      if not first_melody then
        first_melody = melody
      end
      -- Stop after getting a few to test lazy evaluation
      if count >= 3 then
        break
      end
    end

    expect(count).to.be_greater_than(0)
    expect(first_melody).to_not.be_nil()
  end)

  it('should allow ranking enumerated melodies', function()
    local c_major = Scale{tonic=Pitch.c4, mode=Mode.major}
    local c = Contour{
      shape = Shape.strict_ascending,
      motion = Motion.stepwise,
      start_pitch = Pitch.c4,
      end_pitch = Pitch.g4,
      scale = c_major,
    }

    -- Example ranking function: prefer melodies with smaller total interval span
    local function rank_melody(pitches)
      local total_movement = 0
      for i = 2, #pitches do
        total_movement = total_movement + math.abs(
          tointeger(pitches[i]) - tointeger(pitches[i-1]))
      end
      -- Lower movement = higher rank (more stepwise)
      return 100 - total_movement
    end

    local best_melody = nil
    local best_rank = -math.huge

    for melody in c:iter_melodies{length = 4, as_pitches = true} do
      local rank = rank_melody(melody)
      if rank > best_rank then
        best_melody = melody
        best_rank = rank
      end
    end

    expect(best_melody).to_not.be_nil()
    -- The best melody should still match the contour
    expect(c:matches(best_melody)).to.be_truthy()
  end)
end)

--------------------------------------------------------------------------------
-- Error Message Tests
--------------------------------------------------------------------------------

describe('ErrorMessages', function()
  it('should return descriptive error messages on mismatch', function()
    local c = Contour{shape = Shape.ascending}
    local melody = {Pitch.c4, Pitch.e4, Pitch.d4}  -- Not ascending
    local matches, errors = c:matches(melody)

    expect(matches).to.be_falsy()
    expect(errors).to_not.be_nil()
    expect(#errors).to.be_greater_than(0)
    -- Error should mention descending motion
    local found_desc = false
    for _, err in ipairs(errors) do
      if err:match('descending') then
        found_desc = true
        break
      end
    end
    expect(found_desc).to.be_truthy()
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
