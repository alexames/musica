require 'llx'

require 'musictheory/pitch'

local NoteArgs = Schema{
  __name='NoteArgs',
  type=Table,
  properties={
    pitch={type=Union{Pitch,Integer}},
    time={type=Number},
    duration={type=Number},
    volume={type=Number},
  },
}

--- A note, with a pitch, time, duration and volume
Note = class 'Note' {
  --- Initializes a Note.
  __init = function(self, arg)
    check_arguments{self=Note, arg=NoteArgs}
    self.pitch = arg.pitch
    self.time = arg.time
    self.duration = arg.duration
    self.volume = arg.volume or 1.0
  end,

  --- Adjust the duration so that the note finishes at the given time.
  set_finish = function(self, finish)
    check_arguments{self=Note, finish=Number}
    self.duration = finish - self.time
  end,

  --- Returns the time at which the note terminates.
  finish = function(self)
    check_arguments{self=Note}
    return self.time + self.duration
  end,

  --- Check equality of two notes.
  __eq = function(self, other)
    check_arguments{self=Note, other=Note}
    return self.pitch == other.pitch
           and self.time == other.time
           and self.duration == other.duration
           and self.volume == other.volume
  end,

  --- Returns a string representation of the note.
  __tostring = function(self)
    return string.format("Note{pitch=%s, time=%s, duration=%s, volume=%s}",
                         self.pitch, self.time, self.duration, self.volume)
  end,
}
