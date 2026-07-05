local unit = require 'llx.unit'
local llx = require 'llx'
local midi = require 'lua-midi'
local channel_module = require 'musica.channel'
local figure_module = require 'musica.figure'
local meter_module = require 'musica.meter'
local note_module = require 'musica.note'
local pitch_module = require 'musica.pitch'
local song_module = require 'musica.song'
local tempo_module = require 'musica.tempo'

local FigureInstance = channel_module.FigureInstance
local Figure = figure_module.Figure
local List = llx.List
local Meter = meter_module.Meter
local Note = note_module.Note
local Pitch = pitch_module.Pitch
local Song = song_module.Song
local StressedPulse = meter_module.StressedPulse
local Tempo = tempo_module.Tempo
local UnstressedPulse = meter_module.UnstressedPulse
local isinstance = llx.isinstance
local main_file = llx.main_file

local EPS = 0.001

--- Build a Song with a single acoustic grand channel containing the
-- given notes in one figure starting at time 0.
local function make_song_with_notes(notes)
  local song = Song{}
  local channel = song:make_channel(midi.instrument.acoustic_grand)
  channel.figure_instances:insert(
    FigureInstance(0, Figure{duration=4, notes=List(notes)}))
  return song
end

_ENV = unit.create_test_env(_ENV)

describe('SongTest', function()
  it('should construct with empty channels by default', function()
    local song = Song{}
    expect(#song.channels).to.be_equal_to(0)
    expect(song.title).to.be_nil()
    expect(song.composer).to.be_nil()
    expect(song.tempo).to.be_nil()
    expect(song.meter).to.be_nil()
    expect(song.key).to.be_nil()
  end)

  it('should store metadata passed to the constructor', function()
    local tempo = Tempo(120)
    local meter = Meter{StressedPulse(), UnstressedPulse(),
      UnstressedPulse(), UnstressedPulse()}
    local song = Song{
      title='My Title',
      subtitle='My Subtitle',
      composer='My Composer',
      arranger='My Arranger',
      opus='Op. 1',
      dedication='My Dedication',
      copyright='2026',
      tempo=tempo,
      meter=meter,
    }
    expect(song.title).to.be_equal_to('My Title')
    expect(song.subtitle).to.be_equal_to('My Subtitle')
    expect(song.composer).to.be_equal_to('My Composer')
    expect(song.arranger).to.be_equal_to('My Arranger')
    expect(song.opus).to.be_equal_to('Op. 1')
    expect(song.dedication).to.be_equal_to('My Dedication')
    expect(song.copyright).to.be_equal_to('2026')
    expect(song.tempo).to.be_equal_to(tempo)
    expect(song.meter).to.be_equal_to(meter)
  end)

  it('should insert and return a channel from make_channel', function()
    local song = Song{}
    local channel = song:make_channel(midi.instrument.violin)
    expect(#song.channels).to.be_equal_to(1)
    expect(song.channels[1]).to.be_equal_to(channel)
    expect(channel.instrument).to.be_equal_to(midi.instrument.violin)
    expect(#channel.figure_instances).to.be_equal_to(0)
  end)

  it('should convert to a midi file with one track per channel', function()
    local song = make_song_with_notes{
      Note{pitch=Pitch.c4, time=0, duration=1, volume=1.0},
      Note{pitch=Pitch.e4, time=1, duration=1, volume=1.0},
      Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
    }
    song:make_channel(midi.instrument.violin)
    local midi_file = midi.tomidifile(song)
    expect(#midi_file.tracks).to.be_equal_to(2)
    -- Each track starts with a program change and ends with end of track
    for _, track in ipairs(midi_file.tracks) do
      expect(isinstance(track.events[1],
        midi.event.ProgramChangeEvent)).to.be_truthy()
      expect(isinstance(track.events[#track.events],
        midi.event.EndOfTrackEvent)).to.be_truthy()
    end
    -- Track 1: program change + 3 begin/end pairs + end of track
    expect(#midi_file.tracks[1].events).to.be_equal_to(8)
    local begins, ends = 0, 0
    for _, event in ipairs(midi_file.tracks[1].events) do
      if isinstance(event, midi.event.NoteEndEvent) then
        ends = ends + 1
      elseif isinstance(event, midi.event.NoteBeginEvent) then
        begins = begins + 1
      end
    end
    expect(begins).to.be_equal_to(3)
    expect(ends).to.be_equal_to(3)
    -- The empty violin channel still gets its own bookkeeping events
    expect(#midi_file.tracks[2].events).to.be_equal_to(2)
  end)

  it('should set program change to the channel instrument value', function()
    local song = Song{}
    song:make_channel(midi.instrument.violin)
    local midi_file = midi.tomidifile(song)
    local program_change = midi_file.tracks[1].events[1]
    expect(program_change.new_program_number)
      .to.be_equal_to(midi.instrument.violin.value)
  end)

  it('should round-trip notes through a midi file', function()
    local song = make_song_with_notes{
      Note{pitch=Pitch.c4, time=0, duration=1, volume=1.0},
      Note{pitch=Pitch.e4, time=1, duration=1, volume=1.0},
      Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
    }
    local midi_file = midi.tomidifile(song)
    local song2 = Song{midi_file=midi_file}
    expect(#song2.channels).to.be_equal_to(1)
    expect(song2.channels[1].instrument)
      .to.be_equal_to(midi.instrument.acoustic_grand)
    expect(#song2.channels[1].figure_instances).to.be_equal_to(1)
    local notes = song2.channels[1].figure_instances[1].figure.notes
    expect(#notes).to.be_equal_to(3)
    -- Note coerces pitches to MIDI integers, so compare integer values
    expect(notes[1].pitch).to.be_equal_to(60)
    expect(notes[2].pitch).to.be_equal_to(64)
    expect(notes[3].pitch).to.be_equal_to(67)
    expect(notes[1].time).to.be_near(0, EPS)
    expect(notes[2].time).to.be_near(1, EPS)
    expect(notes[3].time).to.be_near(2, EPS)
    expect(notes[1].duration).to.be_near(1, EPS)
    expect(notes[2].duration).to.be_near(1, EPS)
    expect(notes[3].duration).to.be_near(2, EPS)
    expect(notes[1].volume).to.be_near(1.0, EPS)
  end)

  it('should error on a NoteEndEvent with no NoteBeginEvent', function()
    local midi_file = midi.MidiFile{format=1, ticks=96}
    local track = midi.Track()
    track.events:insert(midi.event.NoteEndEvent(10, 0, 60, 0))
    midi_file.tracks:insert(track)
    local ok, err = pcall(function() return Song{midi_file=midi_file} end)
    expect(ok).to.be_falsy()
    expect(err).to.contain('malformed MIDI file:')
    expect(err).to.contain('note 60')
  end)

  it('should treat a zero-velocity NoteBeginEvent as a note end', function()
    local midi_file = midi.MidiFile{format=1, ticks=96}
    local track = midi.Track()
    track.events:insert(midi.event.NoteBeginEvent(0, 0, 60, 100))
    track.events:insert(midi.event.NoteBeginEvent(96, 0, 60, 0))
    midi_file.tracks:insert(track)
    local song = Song{midi_file=midi_file}
    expect(#song.channels).to.be_equal_to(1)
    local notes = song.channels[1].figure_instances[1].figure.notes
    expect(#notes).to.be_equal_to(1)
    expect(notes[1].pitch).to.be_equal_to(60)
    expect(notes[1].duration).to.be_near(1, EPS)
  end)

  it('should finish notes with no note off at the track end', function()
    local midi_file = midi.MidiFile{format=1, ticks=96}
    local track = midi.Track()
    track.events:insert(midi.event.NoteBeginEvent(0, 0, 60, 100))
    track.events:insert(midi.event.NoteBeginEvent(96, 0, 64, 100))
    midi_file.tracks:insert(track)
    local song = Song{midi_file=midi_file}
    local notes = song.channels[1].figure_instances[1].figure.notes
    expect(#notes).to.be_equal_to(2)
    local by_pitch = {}
    for _, note in ipairs(notes) do
      by_pitch[note.pitch] = note
    end
    -- The dangling C4 ends where the track ends (tick 96 = beat 1)
    expect(by_pitch[60].duration).to.be_near(1, EPS)
    -- The dangling E4 has zero length and is clamped to a 64th note
    expect(by_pitch[64].duration).to.be_near(0.0625, EPS)
  end)

  it('should clamp zero-length notes to a sixty-fourth note', function()
    local midi_file = midi.MidiFile{format=1, ticks=96}
    local track = midi.Track()
    track.events:insert(midi.event.NoteBeginEvent(0, 0, 60, 100))
    track.events:insert(midi.event.NoteEndEvent(0, 0, 60, 0))
    midi_file.tracks:insert(track)
    local song = Song{midi_file=midi_file}
    local notes = song.channels[1].figure_instances[1].figure.notes
    expect(#notes).to.be_equal_to(1)
    expect(notes[1].duration).to.be_near(0.0625, EPS)
  end)

  it('should assign the current instrument from program changes', function()
    local midi_file = midi.MidiFile{format=1, ticks=96}
    local track = midi.Track()
    track.events:insert(midi.event.ProgramChangeEvent(
      0, 0, midi.instrument.violin.value))
    track.events:insert(midi.event.NoteBeginEvent(0, 0, 60, 100))
    track.events:insert(midi.event.NoteEndEvent(96, 0, 60, 0))
    midi_file.tracks:insert(track)
    local song = Song{midi_file=midi_file}
    expect(#song.channels).to.be_equal_to(1)
    expect(song.channels[1].instrument)
      .to.be_equal_to(midi.instrument.violin)
  end)

  it('should return an engraving per part plus conductor', function()
    local song = Song{title='Engraved'}
    local channel = song:make_channel(midi.instrument.violin)
    channel.figure_instances:insert(FigureInstance(0, Figure{}))
    local engravings = song:tolilypond()
    expect(engravings['Conductor']).to.contain('\\version "2.24.0"')
    expect(engravings['Conductor']).to.contain('title = "Engraved"')
    expect(engravings['violin']).to.contain('instrumentName = "violin"')
  end)
end)

if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
