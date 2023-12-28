require 'llx'

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

  __tostring = function(self)
    return String.format('FigureInstance(%s, %s)', self.time, self.figure)
  end,
}

Channel = class 'Channel' {
  __init = function(self, instrument)
    self.instrument = instrument
    self.figure_instances = List{}
  end,

  __tostring = function(self)
    return String.format('Channel{instrument=%s, figure_instances=%s}',
        self.instrument, self.figure_instances)
  end,
}