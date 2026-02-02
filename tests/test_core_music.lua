-- test_core_music.lua
-- Unit tests for core music modules (tempo, time_signature, rhythm, articulation)

local unit = require 'llx.unit'

local Tempo = require 'musica.tempo'.Tempo
local TimeSignature = require 'musica.time_signature'.TimeSignature
local Rhythm = require 'musica.rhythm'.Rhythm
local Articulation = require 'musica.articulation'.Articulation
local apply_to_note = require 'musica.articulation'.apply_to_note
local Note = require 'musica.note'.Note
local Pitch = require 'musica.pitch'.Pitch

_ENV = unit.create_test_env(_ENV)

describe('TempoTests', function()
  it('should create tempo with BPM', function()
    local tempo = Tempo(120)
    expect(tempo.bpm).to.be_equal_to(120)
  end)

  it('should create tempo with marking and set BPM in range', function()
    local tempo = Tempo{marking = 'Allegro'}
    expect(tempo.bpm >= 120 and tempo.bpm <= 156).to.be_truthy()
  end)

  it('should create tempo with marking and set marking to lowercase', function()
    local tempo = Tempo{marking = 'Allegro'}
    expect(tempo.marking).to.be_equal_to('allegro')
  end)

  it('should calculate microseconds per beat correctly', function()
    local tempo = Tempo(120)
    local microseconds = tempo:get_microseconds_per_beat()
    expect(microseconds).to.be_equal_to(500000)  -- 60,000,000 / 120
  end)

  it('should include marking in description', function()
    local tempo = Tempo{marking = 'Allegro'}
    local desc = tempo:describe()
    expect(desc:match('Allegro')).to.be_truthy()
  end)

  it('should include BPM in description', function()
    local tempo = Tempo{marking = 'Allegro'}
    local desc = tempo:describe()
    expect(desc:match('BPM')).to.be_truthy()
  end)

  it('should return true when tempo is in specified range', function()
    local tempo = Tempo(130)
    expect(tempo:is_in_range('allegro')).to.be_truthy()
  end)

  it('should return false when tempo is not in specified range', function()
    local tempo = Tempo(130)
    expect(tempo:is_in_range('adagio')).to.be_falsy()
  end)
end)

describe('TimeSignatureTests', function()
  it('should create 4/4 time signature with correct numerator', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts.numerator).to.be_equal_to(4)
  end)

  it('should create 4/4 time signature with correct denominator', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts.denominator).to.be_equal_to(4)
  end)

  it('should identify 4/4 as simple meter', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts:is_simple()).to.be_truthy()
  end)

  it('should identify 4/4 as not compound meter', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts:is_compound()).to.be_falsy()
  end)

  it('should identify 6/8 as not simple meter', function()
    local ts = TimeSignature{numerator = 6, denominator = 8}
    expect(ts:is_simple()).to.be_falsy()
  end)

  it('should identify 6/8 as compound meter', function()
    local ts = TimeSignature{numerator = 6, denominator = 8}
    expect(ts:is_compound()).to.be_truthy()
  end)

  it('should calculate 4 beats per measure for 4/4', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts:get_beats_per_measure()).to.be_equal_to(4)
  end)

  it('should calculate 2 beats per measure for 6/8', function()
    local ts = TimeSignature{numerator = 6, denominator = 8}
    expect(ts:get_beats_per_measure()).to.be_equal_to(2)  -- 6/3 = 2
  end)

  it('should classify 2/4 as duple meter', function()
    local ts_duple = TimeSignature{numerator = 2, denominator = 4}
    expect(ts_duple:get_meter_type()).to.be_equal_to('duple')
  end)

  it('should classify 3/4 as triple meter', function()
    local ts_triple = TimeSignature{numerator = 3, denominator = 4}
    expect(ts_triple:get_meter_type()).to.be_equal_to('triple')
  end)

  it('should classify 4/4 as quadruple meter', function()
    local ts_quadruple = TimeSignature{numerator = 4, denominator = 4}
    expect(ts_quadruple:get_meter_type()).to.be_equal_to('quadruple')
  end)

  it('should convert time signature to string', function()
    local ts = TimeSignature{numerator = 3, denominator = 4}
    expect(tostring(ts)).to.be_equal_to('3/4')
  end)
end)

describe('RhythmTests', function()
  it('should create rhythm with specified durations', function()
    local rhythm = Rhythm{durations = {1, 0.5, 0.5, 1}}
    expect(#rhythm.durations).to.be_equal_to(4)
  end)

  it('should calculate total duration correctly', function()
    local rhythm = Rhythm{1, 0.5, 0.5, 1}
    expect(rhythm:total_duration()).to.be_equal_to(3.0)
  end)

  it('should augment first duration by factor', function()
    local rhythm = Rhythm{1, 0.5}
    local augmented = rhythm:augment(2)
    expect(augmented.durations[1]).to.be_equal_to(2.0)
  end)

  it('should augment second duration by factor', function()
    local rhythm = Rhythm{1, 0.5}
    local augmented = rhythm:augment(2)
    expect(augmented.durations[2]).to.be_equal_to(1.0)
  end)

  it('should diminish first duration by factor', function()
    local rhythm = Rhythm{1, 0.5}
    local diminished = rhythm:diminish(2)
    expect(diminished.durations[1]).to.be_equal_to(0.5)
  end)

  it('should diminish second duration by factor', function()
    local rhythm = Rhythm{1, 0.5}
    local diminished = rhythm:diminish(2)
    expect(diminished.durations[2]).to.be_equal_to(0.25)
  end)

  it('should repeat pattern specified number of times', function()
    local rhythm = Rhythm{1, 0.5}
    local repeated = rhythm:repeat_pattern(3)
    expect(#repeated.durations).to.be_equal_to(6)
  end)

  it('should reverse first duration in retrograde', function()
    local rhythm = Rhythm{1, 0.5, 0.25}
    local retro = rhythm:retrograde()
    expect(retro.durations[1]).to.be_equal_to(0.25)
  end)

  it('should reverse second duration in retrograde', function()
    local rhythm = Rhythm{1, 0.5, 0.25}
    local retro = rhythm:retrograde()
    expect(retro.durations[2]).to.be_equal_to(0.5)
  end)

  it('should reverse third duration in retrograde', function()
    local rhythm = Rhythm{1, 0.5, 0.25}
    local retro = rhythm:retrograde()
    expect(retro.durations[3]).to.be_equal_to(1)
  end)
end)

describe('ArticulationTests', function()
  it('should have staccato articulation defined', function()
    expect(Articulation.staccato ~= nil).to.be_truthy()
  end)

  it('should have legato articulation defined', function()
    expect(Articulation.legato ~= nil).to.be_truthy()
  end)

  it('should have accent articulation defined', function()
    expect(Articulation.accent ~= nil).to.be_truthy()
  end)

  it('should shorten note duration when applying staccato', function()
    local note = Note{pitch = Pitch.c4, duration = 1.0, volume = 1.0}
    apply_to_note(note, Articulation.staccato)
    expect(note.duration).to.be_equal_to(0.5)  -- 50%
  end)

  it('should increase note volume when applying accent', function()
    local note = Note{pitch = Pitch.c4, duration = 1.0, volume = 0.5}
    apply_to_note(note, Articulation.accent)
    expect(note.volume).to.be_equal_to(0.6)  -- 0.5 * 1.2
  end)

  it('should strongly increase note volume when applying marcato', function()
    local note = Note{pitch = Pitch.c4, duration = 1.0, volume = 0.5}
    apply_to_note(note, Articulation.marcato)
    expect(note.volume).to.be_equal_to(0.7)  -- 0.5 * 1.4
  end)

  it('should very significantly shorten note duration when applying staccatissimo', function()
    local note = Note{pitch = Pitch.c4, duration = 1.0, volume = 1.0}
    apply_to_note(note, Articulation.staccatissimo)
    expect(note.duration).to.be_equal_to(0.25)  -- 25%
  end)
end)

run_unit_tests()
