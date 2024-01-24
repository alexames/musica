local util = require 'musictheory/util'

local UniqueSymbol = util.UniqueSymbol

IntervalQuality = {
  major = UniqueSymbol('IntervalQuality.major'),
  minor = UniqueSymbol('IntervalQuality.minor'),
  diminished = UniqueSymbol('IntervalQuality.diminished'),
  augmented = UniqueSymbol('IntervalQuality.augmented'),
  perfect = UniqueSymbol('IntervalQuality.perfect'),
}

return {
  IntervalQuality = IntervalQuality,
}