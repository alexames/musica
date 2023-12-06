local midi = require 'midi'
require 'musictheory/chord'
require 'musictheory/figure'
require 'musictheory/meter'
require 'musictheory/note'

Part = class 'Part' : extends(Figure) {
}

-- Should we annotate which section you're in?
--   * Introduction https://en.wikipedia.org/wiki/Introduction_(music)
--   * Exposition https://en.wikipedia.org/wiki/Exposition_(music)
--   * Recapitulation https://en.wikipedia.org/wiki/Recapitulation_(music)
--   * Verse https://en.wikipedia.org/wiki/Verse%E2%80%93chorus_form
--   * Chorus https://en.wikipedia.org/wiki/Verse%E2%80%93chorus_form
--   * Refrain https://en.wikipedia.org/wiki/Refrain
--   * Conclusion https://en.wikipedia.org/wiki/Conclusion_(music)
--   * Coda https://en.wikipedia.org/wiki/Coda_(music)
--   * Bridge https://en.wikipedia.org/wiki/Bridge_(music)

FigureInstance = class 'FigureInstance' {
  __init = function(self, time, figure)
    check_arguments{self=FigureInstance, time=Number, figure=Figure}
    self.time = time
    self.figure = figure
  end,

  time_adjusted_notes = function(self)
    return function(instance, i)
      i = i + 1
      local note = instance.figure.notes[i]
      return note and i, note and Note{
        pitch = note.pitch,
        time = note.time + instance.time,
        duration = note.duration,
        volume = note.volume,
      }
    end, self, 0
  end,
}

Song = class 'Song' {
  __init = function(self)
    self.tracks = List{}
  end,

  make_part = function(self, instrument)
    local track = List{}
    track.instrument = instrument
    self.tracks:insert(track)
    return track
  end
}

function tomidifile(song)
  local midi_file = midi.MidiFile()
  for i, song_track in ipairs(song.tracks) do
    local events = List{}

    -- Gather events
    local channel = i - 1 -- not sure if this is correct?
    for j, figure_instance in ipairs(song_track) do
      for k, adjusted_note in figure_instance:time_adjusted_notes() do
        local note_number = tointeger(adjusted_note.pitch)
        local volume_int = tointeger(adjusted_note.volume * 255)
        local note_begin = midi.event.NoteBeginEvent(0, channel, note_number, volume_int)
        local note_end = midi.event.NoteEndEvent(0, channel, note_number, volume_int)
        note_begin.time = adjusted_note.time
        note_end.time = adjusted_note:finish()
        events:insert(note_begin)
        events:insert(note_end)
      end
    end

    events:sort(function(a, b) return a.time < b.time end)

    local midi_track = midi.Track()
    midi_file.tracks:insert(midi_track)
    local previous_time = 0
    midi_track.events:insert(
        midi.event.ProgramChangeEvent(0, channel, song_track.instrument))
    for j, event in ipairs(events) do
      event.time_delta = event.time - previous_time
      previous_time = event.time
      midi_track.events:insert(event)
    end
  end
  return midi_file
end

local song = Song{}

local figure = Figure{
  duration=4,
  melody=List{
    Note{pitch=Pitch.c4, duration=1.5, volume=1.0},
    Note{pitch=Pitch.e4, duration=.5, volume=1.0},
    Note{pitch=Pitch.g4, duration=1, volume=1.0},
    Note{pitch=Pitch.e4, duration=1, volume=1.0},

    Note{pitch=Pitch.c5, duration=1.5, volume=1.0},
    Note{pitch=Pitch.e5, duration=.5, volume=1.0},
    Note{pitch=Pitch.g5, duration=1, volume=1.0},
    Note{pitch=Pitch.e5, duration=1, volume=1.0},
  },
}
local part
part = song:make_part(midi.instrument.xylophone)
part:insert(FigureInstance(0, figure))

part = song:make_part(midi.instrument.music_box)
part:insert(FigureInstance(0, figure))

local midi_file = tomidifile(song)
local file <close> = io.open('test.mid', 'wb')
midi_file:write(file)
