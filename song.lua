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
Section = class 'Section' {
  __init = function(self, numberOfParts, meterProgression, chordProgression)
    duration = meterProgression.duration()
    -- self.parts = List{Part(duration) for unused in range(numberOfParts)}
    self.meterProgression = meterProgression
    self.duration = duration
    self.chordProgression = chordProgression
  end;

  addParts = function(self, figureTuple)
    for part, figure in zip(self.parts, figureTuple) do
      if figure then
        part.addFigure(figure)
      end
    end
  end;

  __repr = function(self)
    return string.format("Section(%s, %s, <%s>)", #self.parts, self.duration, self.parts)
  end;
}

Song = class 'Song' {
  __init = function(self, tracks)
    self.tracks = tracks
    self.sections = List{}
    self.instruments = List{Instrument.acoustic_grand} * tracks
  end;

  makeSection = function(self, meterPeriods, chordPeriods)
    if meterPeriods == nil then
      meterPeriods = List{}
    end
    if chordPeriods == nil then
      chordPeriods = List{}
    end
    return Section(self.tracks,
                   MeterProgression(meterPeriods),
                   ChordProgression(chordPeriods))
  end;

  appendSection = function(self, section)
    self.sections.append(deepcopy(section))
  end;

  __repr = function(self)
    return string.format("Song(%s, %s)", self.tracks, repr(self.sections))
  end;
}

rest = nil
