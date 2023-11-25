local unit = require 'unit'
require 'llx'
require 'musictheory/note'

test_class 'NoteTest' {
  [test 'init' - 'with volume'] = function(self)
    local note = Note{pitch=72, time=0, duration=2, volume=1}
    EXPECT_EQ(note.pitch, 72)
    EXPECT_EQ(note.time, 0)
    EXPECT_EQ(note.duration, 2)
    EXPECT_EQ(note.volume, 1)
  end,

  [test 'init' - 'without volume'] = function(self)
    local note = Note{pitch=72, time=0, duration=2}
    EXPECT_EQ(note.pitch, 72)
    EXPECT_EQ(note.time, 0)
    EXPECT_EQ(note.duration, 2)
    EXPECT_EQ(note.volume, 1)
  end,

  [test 'init' - 'error' - 'missing pitch'] = function(self)
    EXPECT_ERROR(Note, {time=0, duration=2})
  end,

  [test 'init' - 'error' - 'missing time'] = function(self)
    EXPECT_ERROR(Note, {pitch=72, duration=2})
  end,

  [test 'init' - 'error' - 'missing duration'] = function(self)
    EXPECT_ERROR(Note, {pitch=72, time=0})
  end,

  [test 'set_finish'] = function(self)
    local note = Note{pitch=72, time=10, duration=15}
    note:set_finish(12)
    EXPECT_EQ(note:finish(), 12)
    EXPECT_EQ(note.time, 10)
    EXPECT_EQ(note.duration, 2)
  end,

  [test 'finish'] = function(self)
    local note = Note{pitch=72, time=10, duration=2}
    EXPECT_EQ(note:finish(), 12)
  end,

  [test 'tostring'] = function(self)
    local note = Note{pitch=72, time=0, duration=2}
    EXPECT_EQ(tovalue(tostring(note)), note)
  end,
}

if main_file() then
  unit.run_unit_tests()
end
