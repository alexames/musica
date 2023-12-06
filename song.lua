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

Part = class 'Part' {
  __init = function(self, instrument)
    self.instrument = instrument
    self.figure_instances = List{}
  end,
}

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
    self.parts = List{}
  end,

  make_part = function(self, instrument)
    local part = Part(instrument)
    self.parts:insert(part)
    return part
  end
}

function tomidifile(song)
  local midi_file = midi.MidiFile()
  for i, song_track in ipairs(song.parts) do
    local events = List{}

    -- Gather events
    local channel = i - 1 -- not sure if this is correct?
    for j, figure_instance in ipairs(song_track.figure_instances) do
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
  notes=List{
    Note{pitch=Pitch.b5, time=0, duration=0.5, volume=0.8},
    Note{pitch=Pitch.gsharp5, time=0.5, duration=0.25, volume=0.8},
    Note{pitch=Pitch.a5, time=0.75, duration=0.25, volume=0.8},
    Note{pitch=Pitch.e6, time=1, duration=0.5, volume=0.8},
    Note{pitch=Pitch.b5, time=1.5, duration=0.25, volume=0.8},
    Note{pitch=Pitch.gsharp5, time=1.75, duration=0.25, volume=0.8},
    Note{pitch=Pitch.a5, time=2, duration=0.5, volume=0.8},
    Note{pitch=Pitch.e6, time=2.5, duration=0.25, volume=0.8},
    Note{pitch=Pitch.b5, time=3, duration=0.5, volume=0.8},
    Note{pitch=Pitch.gsharp5, time=3.5, duration=0.25, volume=0.8},
    Note{pitch=Pitch.a5, time=3.75, duration=0.25, volume=0.8},
    Note{pitch=Pitch.e6, time=4, duration=0.5, volume=0.8},
    Note{pitch=Pitch.b5, time=4.5, duration=0.25, volume=0.8},
    Note{pitch=Pitch.gsharp5, time=4.75, duration=0.25, volume=0.8},
    Note{pitch=Pitch.a5, time=5, duration=0.5, volume=0.8},
    Note{pitch=Pitch.e6, time=5.5, duration=0.25, volume=0.8},
  },
}

local chords = Figure{
  notes=List{
    Note{pitch=Pitch.b4, time=0, duration=2, volume=0.6},
    Note{pitch=Pitch.d5, time=0, duration=2, volume=0.6},
    Note{pitch=Pitch.gsharp4, time=0, duration=2, volume=0.6},
    
    Note{pitch=Pitch.fsharp4, time=2, duration=2, volume=0.6},
    Note{pitch=Pitch.a4, time=2, duration=2, volume=0.6},
    Note{pitch=Pitch.d5, time=2, duration=2, volume=0.6},
    
    Note{pitch=Pitch.b3, time=4, duration=2, volume=0.6},
    Note{pitch=Pitch.e4, time=4, duration=2, volume=0.6},
    Note{pitch=Pitch.gsharp3, time=4, duration=2, volume=0.6},
    
    Note{pitch=Pitch.fsharp3, time=6, duration=2, volume=0.6},
    Note{pitch=Pitch.a3, time=6, duration=2, volume=0.6},
    Note{pitch=Pitch.d4, time=6, duration=2, volume=0.6},
  }
}

local bass = Figure{
  notes=List{
    Note{pitch=Pitch.g2, time=0, duration=0.5, volume=0.7},
    Note{pitch=Pitch.g2, time=0.5, duration=0.5, volume=0.7},
    Note{pitch=Pitch.gsharp2, time=1, duration=0.5, volume=0.7},
    Note{pitch=Pitch.gsharp2, time=1.5, duration=0.5, volume=0.7},
    
    Note{pitch=Pitch.a2, time=2, duration=0.25, volume=0.7},
    Note{pitch=Pitch.a2, time=2.25, duration=0.25, volume=0.7},
    Note{pitch=Pitch.a2, time=2.5, duration=0.25, volume=0.7},
    Note{pitch=Pitch.a2, time=2.75, duration=0.25, volume=0.7},
    
    Note{pitch=Pitch.g2, time=3, duration=0.5, volume=0.7},
    Note{pitch=Pitch.g2, time=3.5, duration=0.5, volume=0.7},
    
    Note{pitch=Pitch.fsharp2, time=4, duration=0.5, volume=0.7},
    Note{pitch=Pitch.fsharp2, time=4.5, duration=0.5, volume=0.7},
    
    Note{pitch=Pitch.g2, time=5, duration=0.25, volume=0.7},
    Note{pitch=Pitch.g2, time=5.25, duration=0.25, volume=0.7},
    Note{pitch=Pitch.g2, time=5.5, duration=0.25, volume=0.7},
    Note{pitch=Pitch.g2, time=5.75, duration=0.25, volume=0.7},
    
    Note{pitch=Pitch.gsharp2, time=6, duration=0.5, volume=0.7},
    Note{pitch=Pitch.gsharp2, time=6.5, duration=0.5, volume=0.7},
    
    Note{pitch=Pitch.a2, time=7, duration=0.25, volume=0.7},
    Note{pitch=Pitch.a2, time=7.25, duration=0.25, volume=0.7},
    Note{pitch=Pitch.a2, time=7.5, duration=0.25, volume=0.7},
    Note{pitch=Pitch.a2, time=7.75, duration=0.25, volume=0.7},
  }
}

local pickup_length = 1/8

local trumpet = Figure{
  notes=List{
    Note{pitch=Pitch.d4, time=0, duration=1, volume=0.9},
    Note{pitch=Pitch.g4, time=1, duration=1, volume=0.9},
    Note{pitch=Pitch.a4, time=2, duration=2, volume=0.9},
    Note{pitch=Pitch.f4, time=4-pickup_length, duration=pickup_length, volume=0.9}, -- Pickup note
    Note{pitch=Pitch.g4, time=4, duration=2, volume=0.9},
    Note{pitch=Pitch.a4, time=6-pickup_length, duration=pickup_length, volume=0.9}, -- Pickup note
    Note{pitch=Pitch.d5, time=6, duration=2, volume=0.9},
    Note{pitch=Pitch.a4, time=8-pickup_length, duration=pickup_length, volume=0.9}, -- Pickup note
  },
}

local part
part = song:make_part(midi.instrument.acoustic_guitar_nylon)
part.figure_instances:insert(FigureInstance(0, figure))

part = song:make_part(midi.instrument.acoustic_guitar_steel)
part.figure_instances:insert(FigureInstance(0, chords))

part = song:make_part(midi.instrument.acoustic_bass)
part.figure_instances:insert(FigureInstance(0, bass))

part = song:make_part(midi.instrument.trumpet)
part.figure_instances:insert(FigureInstance(0, trumpet))

local midi_file = tomidifile(song)
local file <close> = io.open('test.mid', 'wb')
midi_file:write(file)
