local midi = require 'midi'
require 'song'

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

local channel
channel = song:make_channel(midi.instrument.acoustic_guitar_nylon)
channel.figure_instances:insert(FigureInstance(0, figure))

channel = song:make_channel(midi.instrument.acoustic_guitar_steel)
channel.figure_instances:insert(FigureInstance(0, chords))

channel = song:make_channel(midi.instrument.acoustic_bass)
channel.figure_instances:insert(FigureInstance(0, bass))

channel = song:make_channel(midi.instrument.trumpet)
channel.figure_instances:insert(FigureInstance(0, trumpet))

local midi_file = tomidifile(song)
local file <close> = io.open('test.mid', 'wb')
midi_file:write(file)
