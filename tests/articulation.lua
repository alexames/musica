local unit = require 'llx.unit'
local llx = require 'llx'
local articulation_module = require 'musica.articulation'
local note_module = require 'musica.note'
local pitch_module = require 'musica.pitch'

local Articulation = articulation_module.Articulation
local apply_to_note = articulation_module.apply_to_note
local Note = note_module.Note
local Pitch = pitch_module.Pitch
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

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
    local result = apply_to_note(note, Articulation.staccato)
    expect(result.duration).to.be_equal_to(0.5)  -- 50%
  end)

  it('should not mutate original note when applying articulation', function()
    local note = Note{pitch = Pitch.c4, duration = 1.0, volume = 1.0}
    apply_to_note(note, Articulation.staccato)
    expect(note.duration).to.be_equal_to(1.0)
  end)

  it('should increase note volume when applying accent', function()
    local note = Note{pitch = Pitch.c4, duration = 1.0, volume = 0.5}
    local result = apply_to_note(note, Articulation.accent)
    expect(result.volume).to.be_equal_to(0.6)  -- 0.5 * 1.2
  end)

  it('should strongly increase note volume when applying marcato', function()
    local note = Note{pitch = Pitch.c4, duration = 1.0, volume = 0.5}
    local result = apply_to_note(note, Articulation.marcato)
    expect(result.volume).to.be_equal_to(0.7)  -- 0.5 * 1.4
  end)

  it('should very significantly shorten note duration when applying staccatissimo', function()
    local note = Note{pitch = Pitch.c4, duration = 1.0, volume = 1.0}
    local result = apply_to_note(note, Articulation.staccatissimo)
    expect(result.duration).to.be_equal_to(0.25)  -- 25%
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
