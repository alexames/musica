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
  __init = function(self, number_of_parts, meter_progression, chord_progression)
    duration = meter_progression.duration()
    -- self.parts = List{Part(duration) for unused in range(number_of_parts)}
    self.meter_progression = meter_progression
    self.duration = duration
    self.chord_progression = chord_progression
  end;

  add_parts = function(self, figure_tuple)
    for part, figure in zip(self.parts, figure_tuple) do
      if figure then
        part.add_figure(figure)
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

  make_section = function(self, meter_periods, chord_periods)
    if meter_periods == nil then
      meter_periods = List{}
    end
    if chord_periods == nil then
      chord_periods = List{}
    end
    return Section(self.tracks,
                   MeterProgression(meter_periods),
                   ChordProgression(chord_periods))
  end;

  append_section = function(self, section)
    self.sections.append(deepcopy(section))
  end;

  __repr = function(self)
    return string.format("Song(%s, %s)", self.tracks, repr(self.sections))
  end;
}

rest = nil
