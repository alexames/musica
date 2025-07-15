-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local channel = require 'musica.channel'
local chord = require 'musica.chord'
local figure = require 'musica.figure'
local llx = require 'llx'
local meter = require 'musica.meter'
local midi = require 'midi'
local note = require 'musica.note'
local pitch = require 'musica.pitch'

local _ENV, _M = llx.environment.create_module_environment()

local Channel = channel.Channel
local Chord = chord.Chord
local class = llx.class
local Figure = figure.Figure
local FigureInstance = channel.FigureInstance
local Meter = meter.Meter
local Note = note.Note
local Pitch = pitch.Pitch
local isinstance = llx.isinstance
local tointeger = llx.tointeger

local MIDI_VOLUME_MAX <const> = 127.0

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

Song = class 'Song' {
  __init = function(self, args)
    self.channels = args and args.channels or llx.List{}
    if args.midi_file then
      self:_song_from_midi_file(args.midi_file)
    end
  end,

  _song_from_midi_file = function(self, midi_file)
    local instrument_channel_map = {}
    local current_instrument = midi.instrument.acoustic_grand
    for i, track in ipairs(midi_file.tracks) do
      local unfinished_notes = {}
      local time_in_ticks = 0
      for j, event in ipairs(track.events) do
        time_in_ticks = time_in_ticks + event.time_delta
        if isinstance(event, midi.event.NoteEndEvent) then
          local note = assert(
            unfinished_notes[event.note_number],
            'encountered NoteEndEvent without corresponding NoteBeginEvent')
          -- Maybe we should have an option to quantize this.
          note.duration = (time_in_ticks / midi_file.ticks) - note.time
        elseif isinstance(event, midi.event.NoteBeginEvent) then
          local note = Note{
            pitch=Pitch{midi_index=event.note_number},
            time=time_in_ticks / midi_file.ticks,
            duration=nil, -- Unknown until NoteEndEvent
            volume=event.velocity / MIDI_VOLUME_MAX,
          }
          unfinished_notes[event.note_number] = note
          local channel = instrument_channel_map[current_instrument]
          if not channel then
            channel = self:make_channel(current_instrument)
            channel.figure_instances:insert(FigureInstance(0, Figure{}))
            instrument_channel_map[current_instrument] = channel
          end
          local figure = assert(channel.figure_instances[1].figure)
          figure.notes:insert(note)
        elseif isinstance(event, midi.event.VelocityChangeEvent) then
          -- Currently not supported
        elseif isinstance(event, midi.event.ControllerChangeEvent) then
          -- Currently not supported
        elseif isinstance(event, midi.event.ProgramChangeEvent) then
          current_instrument = event.new_program_number
        elseif isinstance(event, midi.event.ChannelPressureChangeEvent) then
          -- Currently not supported
        elseif isinstance(event, midi.event.PitchWheelChangeEvent) then
          -- Currently not supported
        elseif isinstance(event, midi.event.MetaEvent) then
          -- Currently not supported
        else
        end
      end
    end
  end,

  make_channel = function(self, instrument)
    local channel = Channel(instrument)
    self.channels:insert(channel)
    return channel
  end,

  __tomidifile = function(self)
    local midi_file = midi.MidiFile()
    for i, song_track in ipairs(self.channels) do
      local events = llx.List{}

      -- Gather events
      local channel = i - 1 -- not sure if this is correct?
      for j, figure_instance in ipairs(song_track.figure_instances) do
        for k, adjusted_note in figure_instance:time_adjusted_notes() do
          local note_number = tointeger(adjusted_note.pitch)
          local volume_int = tointeger(adjusted_note.volume * MIDI_VOLUME_MAX)
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
        local beats = event.time - previous_time
        event.time_delta = math.floor(beats * midi_file.ticks)
        previous_time = event.time
        midi_track.events:insert(event)
      end
      midi_track.events:insert(
          midi.event.EndOfTrackEvent(0, 0x0F, {}))
    end
    return midi_file
  end,

  __tostring = function(self)
    return string.format('Song{channels=%s}', self.channels)
  end,
}

return _M
