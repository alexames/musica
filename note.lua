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
  required={'pitch', 'time', 'duration'},
}

Note = class 'Note' {
  __init = function(self, arg)
    check_arguments{self=Note, arg=NoteArgs}
    self.pitch = arg.pitch
    self.time = arg.time
    self.duration = arg.duration
    self.volume = arg.volume or 1.0
  end,

  set_start = function(self, start)
    check_arguments{self=Note, start=Number}
    self.duration = finish() - start
    self.time = start
  end,

  start = function(self)
    return self.time
  end,

  set_finish = function(self, finish)
    self.duration = finish - self.time
  end,

  finish = function(self)
    return self.time + self.duration
  end,

  __tostring = function(self)
    return string.format("Note{pitch=%s, time=%s, duration=%s, volume=%s}",
                         self.pitch, self.time, self.duration, self.volume)
  end,
}
