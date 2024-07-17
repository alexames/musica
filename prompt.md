We are going to discuss music theory.

I would like to procedurally generate music, and in order to do so I need a collection of chord progressions that match certain moods. I will provide you with a Lua API, that you can use to write code that will help generate music. Additionally, I will provide to you a description of a mood, theme, feeling, or idea, and I would like you to describe with prose what chord progressions can be used to evoke that idea.

Your response should contain two sections:
(1) The list of chord progressions and descriptions of how they can be used.
(2) Those same chords, represented as Lua code.

The second section containing the Lua code should be delimited by three backticks, like this:

```
-- This is some sample Lua code.
x = {}
```

Here is a snippet of Lua code that I wrote that you can use as a library. I would like you to use the tables here to aid in the representation of chords in code. You do not need to repeat this code in your response. It will be included by default. I would like you to use this API to represent the musical ideas you discuss.

```
-- A table with a list of modes:
mode = {
  ionian = Mode{...},
  dorian = Mode{...},
  phrygian = Mode{...},
  lydian = Mode{...},
  mixolydian = Mode{...},
  aeolian = Mode{...},
  locrian = Mode{...},

  major = ionian,
  minor = aeolian,
}

-- A table with a list of note classes
note_class = {
  a = NoteClass{...},
  b = NoteClass{...},
  c = NoteClass{...},
  d = NoteClass{...},
  e = NoteClass{...},
  f = NoteClass{...},
  g = NoteClass{...},
}

-- A table containing scale degrees using Roman Numeral notation
scale_degree = {
  i = ScaleDegree{degree=1, mode.minor},
  ii = ScaleDegree{degree=2, mode.minor},
  iii = ScaleDegree{degree=3, mode.minor},
  iv = ScaleDegree{degree=4, mode.minor},
  v = ScaleDegree{degree=5, mode.minor},
  vi = ScaleDegree{degree=6, mode.minor},
  vii = ScaleDegree{degree=7, mode.minor},

  I = ScaleDegree{degree=1, mode.major},
  II = ScaleDegree{degree=2, mode.major},
  III = ScaleDegree{degree=3, mode.major},
  IV = ScaleDegree{degree=4, mode.major},
  V = ScaleDegree{degree=5, mode.major},
  VI = ScaleDegree{degree=6, mode.major},
  VII = ScaleDegree{degree=7, mode.major},
}
```

Using that API you can generate chord progressions. When tell you the feeling I would like you to evoke, you can use it like so:

```
-- Common 4 chord progression
example_progression = ChordProgression{
  scale_degree.I,
  scale_degree.IV,
  scale_degree.V,
  scale_degree.vi,
}
```

Chord progressions often contain 4 chords, but are not required to. You may create 4, 8, or even chord progressions that have just 2 or 3 (or 5 or more) if the occasion calls for it.

I will now describe the mood, feeling, theme or idea I want a chord progression for:

