local unit = require 'unit'
require 'musica.chord'
require 'musica.pitch'
require 'musica.quality'

test_class 'ChordTest' {
  [test 'init'] = function(self)
    local chord = Chord{root=Pitch.c4, quality=Quality.major}
    EXPECT_EQ(chord.root, Pitch.c4)
    EXPECT_EQ(chord.quality, Quality.major)

    local chord = Chord{pitches=List{Pitch.c5, Pitch.eflat5, Pitch.g5}}
    EXPECT_EQ(chord.root, Pitch.c5)
    EXPECT_EQ(chord.quality, Quality.minor)
  end,

  [test 'get_quality'] = function(self)
    local chord = Chord{root=Pitch.c4, quality=Quality.major}
    EXPECT_EQ(chord.quality, Quality.major)
  end,

  [test 'to_pitch'] = function(self)
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    EXPECT_EQ(c_major:to_pitch(0), Pitch.c4)
    EXPECT_EQ(c_major:to_pitch(1), Pitch.e4)
    EXPECT_EQ(c_major:to_pitch(2), Pitch.g4)
    EXPECT_ERROR(c_major.to_pitch, c_major, 3)
  end,

  [test 'to_extended_pitch'] = function(self)
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    EXPECT_EQ(c_major:to_extended_pitch(0), Pitch.c4)
    EXPECT_EQ(c_major:to_extended_pitch(1), Pitch.e4)
    EXPECT_EQ(c_major:to_extended_pitch(2), Pitch.g4)
  end,

  [test 'inversion'] = function(self)
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}

    local c_major_inv0 = c_major:inversion(0)
    EXPECT_EQ(c_major_inv0:to_pitch(0), Pitch.c4)
    EXPECT_EQ(c_major_inv0:to_pitch(1), Pitch.e4)
    EXPECT_EQ(c_major_inv0:to_pitch(2), Pitch.g4)

    local c_major_inv1 = c_major:inversion(1)
    EXPECT_EQ(c_major_inv1:to_pitch(0), Pitch.e4)
    EXPECT_EQ(c_major_inv1:to_pitch(1), Pitch.g4)
    EXPECT_EQ(c_major_inv1:to_pitch(2), Pitch.c5)

    local c_major_inv2 = c_major:inversion(2)
    EXPECT_EQ(c_major_inv2:to_pitch(0), Pitch.g4)
    EXPECT_EQ(c_major_inv2:to_pitch(1), Pitch.c5)
    EXPECT_EQ(c_major_inv2:to_pitch(2), Pitch.e5)

    local c_major_inv3 = c_major:inversion(3)
    EXPECT_EQ(c_major_inv3:to_pitch(0), Pitch.c5)
    EXPECT_EQ(c_major_inv3:to_pitch(1), Pitch.e5)
    EXPECT_EQ(c_major_inv3:to_pitch(2), Pitch.g5)

    local c_major_inv4 = c_major:inversion(4)
    EXPECT_EQ(c_major_inv4:to_pitch(0), Pitch.e5)
    EXPECT_EQ(c_major_inv4:to_pitch(1), Pitch.g5)
    EXPECT_EQ(c_major_inv4:to_pitch(2), Pitch.c6)

    local c_major_inv0 = c_major:inversion(-1)
    EXPECT_EQ(c_major_inv0:to_pitch(0), Pitch.g3)
    EXPECT_EQ(c_major_inv0:to_pitch(1), Pitch.c4)
    EXPECT_EQ(c_major_inv0:to_pitch(2), Pitch.e4)
  end,

  [test 'over'] = function(self)
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}

    local c_maj7 = c_major / Pitch.b5
    EXPECT_EQ(c_maj7[{0, 1, 2, 3}],
              List{Pitch.c4, Pitch.e4, Pitch.g4, Pitch.b5})

    local c_maj_over_b = c_major / Pitch.b2
    EXPECT_EQ(c_maj_over_b[{0, 1, 2, 3}],
              List{Pitch.b2, Pitch.c4, Pitch.e4, Pitch.g4})
  end,

  [test 'len'] = function(self)
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    EXPECT_EQ(#c_major, 3)
  end,

  [test 'index'] = function(self)
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    EXPECT_EQ(c_major[0], Pitch.c4)
    EXPECT_EQ(c_major[1], Pitch.e4)
    EXPECT_EQ(c_major[2], Pitch.g4)
    EXPECT_EQ(c_major[{0, 1, 2}], {Pitch.c4, Pitch.e4, Pitch.g4})
  end,

  [test 'contains'] = function(self)
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    EXPECT_TRUE(c_major:contains(Pitch.c4))
    EXPECT_TRUE(c_major:contains(Pitch.e4))
    EXPECT_TRUE(c_major:contains(Pitch.g4))

    EXPECT_FALSE(c_major:contains(Pitch.d4))
    EXPECT_FALSE(c_major:contains(Pitch.f4))
    EXPECT_FALSE(c_major:contains(Pitch.c5))
  end,

  [test 'tostring'] = function(self)
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    EXPECT_EQ(tovalue(tostring(c_major)), c_major)
  end,
}

if main_file() then
  unit.run_unit_tests()
end
