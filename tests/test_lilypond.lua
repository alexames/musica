local unit = require 'llx.unit'
local llx = require 'llx'
local midi = require 'lua-midi'
local channel_module = require 'musica.channel'
local figure_module = require 'musica.figure'
local lilypond = require 'musica.lilypond'
local meter_module = require 'musica.meter'
local mode_module = require 'musica.mode'
local note_module = require 'musica.note'
local pitch_class_module = require 'musica.pitch_class'
local pitch_module = require 'musica.pitch'
local scale_module = require 'musica.scale'
local song_module = require 'musica.song'
local tempo_module = require 'musica.tempo'

local FigureInstance = channel_module.FigureInstance
local Figure = figure_module.Figure
local List = llx.List
local Meter = meter_module.Meter
local Mode = mode_module.Mode
local Note = note_module.Note
local Pitch = pitch_module.Pitch
local PitchClass = pitch_class_module.PitchClass
local Scale = scale_module.Scale
local Song = song_module.Song
local StressedPulse = meter_module.StressedPulse
local Tempo = tempo_module.Tempo
local UnstressedPulse = meter_module.UnstressedPulse
local main_file = llx.main_file

--- Build a Song with full metadata and one empty violin part.
-- Channels with notes cannot currently be engraved (see the documented
-- behavior test at the bottom), so golden tests use empty figures.
local function make_metadata_song()
  local song = Song{
    title='My Title',
    subtitle='My Subtitle',
    composer='My Composer',
    arranger='My Arranger',
    opus='Op. 1',
    dedication='My Dedication',
    copyright='2026',
    tempo=Tempo(120),
    meter=Meter{StressedPulse(), UnstressedPulse(), UnstressedPulse()},
    key=Scale{tonic=Pitch.c4, mode=Mode.major},
  }
  local channel = song:make_channel(midi.instrument.violin)
  channel.figure_instances:insert(FigureInstance(0, Figure{}))
  return song
end

_ENV = unit.create_test_env(_ENV)

describe('PitchToLilypondTest', function()
  it('should render middle C with a single apostrophe', function()
    expect(lilypond.pitch_to_lilypond(Pitch.c4)).to.be_equal_to("c'")
  end)

  it('should render the unmarked LilyPond octave without marks', function()
    expect(lilypond.pitch_to_lilypond(Pitch.c3)).to.be_equal_to('c')
  end)

  it('should render sharps with an is suffix', function()
    expect(lilypond.pitch_to_lilypond(Pitch.fsharp5)).to.be_equal_to("fis''")
  end)

  it('should render flats with an es suffix', function()
    expect(lilypond.pitch_to_lilypond(Pitch.bflat2)).to.be_equal_to('bes,')
  end)

  it('should render double accidentals', function()
    local double_sharp = Pitch{pitch_class=PitchClass.C, octave=4,
      accidentals=2}
    expect(lilypond.pitch_to_lilypond(double_sharp)).to.be_equal_to("cisis'")
    local double_flat = Pitch{pitch_class=PitchClass.B, octave=4,
      accidentals=-2}
    expect(lilypond.pitch_to_lilypond(double_flat)).to.be_equal_to("beses'")
  end)
end)

describe('DurationToLilypondTest', function()
  it('should map standard durations exactly', function()
    expect(lilypond.duration_to_lilypond(4)).to.be_equal_to('1')
    expect(lilypond.duration_to_lilypond(2)).to.be_equal_to('2')
    expect(lilypond.duration_to_lilypond(1)).to.be_equal_to('4')
    expect(lilypond.duration_to_lilypond(0.5)).to.be_equal_to('8')
    expect(lilypond.duration_to_lilypond(0.25)).to.be_equal_to('16')
    expect(lilypond.duration_to_lilypond(0.0625)).to.be_equal_to('64')
  end)

  it('should map dotted durations', function()
    expect(lilypond.duration_to_lilypond(3)).to.be_equal_to('2.')
    expect(lilypond.duration_to_lilypond(1.5)).to.be_equal_to('4.')
    expect(lilypond.duration_to_lilypond(0.75)).to.be_equal_to('8.')
  end)

  it('should map double-dotted durations', function()
    expect(lilypond.duration_to_lilypond(3.5)).to.be_equal_to('2..')
    expect(lilypond.duration_to_lilypond(1.75)).to.be_equal_to('4..')
  end)

  it('should return a remainder for non-standard durations', function()
    local lily, remainder = lilypond.duration_to_lilypond(5)
    expect(lily).to.be_equal_to('1')
    expect(remainder).to.be_near(1, 0.001)
  end)

  it('should report no remainder for exact durations', function()
    local lily, remainder = lilypond.duration_to_lilypond(2)
    expect(lily).to.be_equal_to('2')
    expect(remainder).to.be_equal_to(0)
  end)

  it('should fall back to a sixty-fourth for tiny durations', function()
    local lily, remainder = lilypond.duration_to_lilypond(0.01)
    expect(lily).to.be_equal_to('64')
    expect(remainder).to.be_equal_to(0)
  end)
end)

describe('NoteToLilypondTest', function()
  -- note_to_lilypond only reads .pitch and .duration, so a plain table
  -- with a Pitch object stands in for a Note. (A real Note cannot be
  -- used: it coerces its pitch to a MIDI integer; see the documented
  -- behavior test at the bottom.)
  it('should combine pitch and duration', function()
    local rendered = lilypond.note_to_lilypond{pitch=Pitch.c4, duration=1}
    expect(rendered).to.be_equal_to("c'4")
  end)

  it('should tie notes with complex durations', function()
    local rendered = lilypond.note_to_lilypond{pitch=Pitch.g4, duration=5}
    expect(rendered).to.be_equal_to("g'1~ g'4")
  end)
end)

describe('RestToLilypondTest', function()
  it('should render simple rests', function()
    expect(lilypond.rest_to_lilypond(1)).to.be_equal_to('r4')
    expect(lilypond.rest_to_lilypond(3)).to.be_equal_to('r2.')
  end)

  it('should split complex rests into multiple rests', function()
    expect(lilypond.rest_to_lilypond(2.5)).to.be_equal_to('r2 r8')
  end)
end)

describe('HeaderToLilypondTest', function()
  it('should include all metadata fields', function()
    local header = lilypond.header_to_lilypond(make_metadata_song())
    expect(header).to.contain('\\header {')
    expect(header).to.contain('title = "My Title"')
    expect(header).to.contain('subtitle = "My Subtitle"')
    expect(header).to.contain('composer = "My Composer"')
    expect(header).to.contain('arranger = "Arr. My Arranger"')
    expect(header).to.contain('opus = "Op. 1"')
    expect(header).to.contain('dedication = "My Dedication"')
    expect(header).to.contain('copyright = "2026"')
  end)

  it('should produce an empty header for a bare song', function()
    expect(lilypond.header_to_lilypond(Song{}))
      .to.be_equal_to('\\header {\n}')
  end)
end)

describe('MeterToLilypondTest', function()
  it('should default to common time', function()
    expect(lilypond.meter_to_lilypond(nil)).to.be_equal_to('\\time 4/4')
  end)

  it('should count pulses over a quarter-note denominator', function()
    local waltz = Meter{StressedPulse(), UnstressedPulse(),
      UnstressedPulse()}
    expect(lilypond.meter_to_lilypond(waltz)).to.be_equal_to('\\time 3/4')
  end)
end)

describe('TempoToLilypondTest', function()
  it('should render nothing without a tempo', function()
    expect(lilypond.tempo_to_lilypond(nil)).to.be_equal_to('')
  end)

  it('should render a plain BPM tempo', function()
    expect(lilypond.tempo_to_lilypond(Tempo(120)))
      .to.be_equal_to('\\tempo 4 = 120')
  end)

  it('should capitalize tempo markings', function()
    expect(lilypond.tempo_to_lilypond(Tempo{marking='allegro'}))
      .to.be_equal_to('\\tempo "Allegro" 4 = 138')
  end)
end)

describe('KeyToLilypondTest', function()
  it('should default to C major', function()
    expect(lilypond.key_to_lilypond(nil)).to.be_equal_to('\\key c \\major')
  end)

  it('should use the scale tonic without octave marks', function()
    local scale = Scale{tonic=Pitch.d5, mode=Mode.major}
    expect(lilypond.key_to_lilypond(scale)).to.be_equal_to('\\key d \\major')
  end)

  it('should render minor keys with the minor mode', function()
    local scale = Scale{tonic=Pitch.a4, mode=Mode.minor}
    expect(lilypond.key_to_lilypond(scale)).to.be_equal_to('\\key a \\minor')
  end)

  it('should render major keys with the major mode', function()
    local scale = Scale{tonic=Pitch.d4, mode=Mode.major}
    expect(lilypond.key_to_lilypond(scale)).to.be_equal_to('\\key d \\major')
  end)
end)

describe('ClefToLilypondTest', function()
  it('should default to treble', function()
    expect(lilypond.clef_to_lilypond(nil)).to.be_equal_to('\\clef treble')
  end)

  it('should accept valid clef names', function()
    expect(lilypond.clef_to_lilypond('bass')).to.be_equal_to('\\clef bass')
    expect(lilypond.clef_to_lilypond('alto')).to.be_equal_to('\\clef alto')
  end)

  it('should fall back to treble for unknown clefs', function()
    expect(lilypond.clef_to_lilypond('kazoo')).to.be_equal_to('\\clef treble')
  end)
end)

describe('TolilypondTest', function()
  it('should produce a conductor score and one score per part', function()
    local song = make_metadata_song()
    local channel = song:make_channel(midi.instrument.flute)
    channel.part_name = 'Flute I'
    channel.figure_instances:insert(FigureInstance(0, Figure{}))
    local engravings = song:tolilypond()
    expect(engravings['Conductor']).to.be_truthy()
    expect(engravings['violin']).to.be_truthy()
    expect(engravings['Flute I']).to.be_truthy()
  end)

  it('should engrave the conductor score with all staves', function()
    local song = make_metadata_song()
    local channel = song:make_channel(midi.instrument.flute)
    channel.part_name = 'Flute I'
    channel.figure_instances:insert(FigureInstance(0, Figure{}))
    local conductor = song:tolilypond()['Conductor']
    expect(conductor).to.contain('\\version "2.24.0"')
    expect(conductor).to.contain('title = "My Title"')
    expect(conductor).to.contain('partAMusic = {')
    expect(conductor).to.contain('partBMusic = {')
    expect(conductor).to.contain('\\new StaffGroup <<')
    expect(conductor).to.contain('\\partAStaff')
    expect(conductor).to.contain('\\partBStaff')
    expect(conductor).to.contain('instrumentName = "violin"')
    expect(conductor).to.contain('instrumentName = "Flute I"')
    expect(conductor).to.contain('\\layout { }')
    expect(conductor).to.contain('\\midi { }')
  end)

  it('should engrave key, meter, tempo and clef in each part', function()
    local part = make_metadata_song():tolilypond()['violin']
    expect(part).to.contain('\\clef treble')
    expect(part).to.contain('\\key c \\major')
    expect(part).to.contain('\\time 3/4')
    expect(part).to.contain('\\tempo 4 = 120')
  end)

  it('should engrave a standalone part with a single staff', function()
    local part = make_metadata_song():tolilypond()['violin']
    expect(part).to.contain('\\version "2.24.0"')
    expect(part).to.contain('\\score {')
    expect(part).to.contain('  \\partAStaff')
    expect(part).to_not.contain('StaffGroup')
  end)

  it('should derive short names from the part name', function()
    local part = make_metadata_song():tolilypond()['violin']
    expect(part).to.contain('shortInstrumentName = "vio."')
  end)

  it('should engrave the notes of a song', function()
    -- Note stores its pitch as a MIDI integer; pitch_to_lilypond spells
    -- integers with the default (sharp) enharmonic. C4 is middle C, which
    -- LilyPond writes as c'.
    local song = Song{}
    local channel = song:make_channel(midi.instrument.acoustic_grand)
    channel.figure_instances:insert(FigureInstance(0, Figure{
      duration=4,
      notes=List{Note{pitch=Pitch.c4, time=0, duration=1, volume=1.0}},
    }))
    local engravings = song:tolilypond()
    local conductor = engravings['Conductor']
    expect(conductor).to_not.be_nil()
    expect(conductor).to.contain("c'")
  end)
end)

if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
