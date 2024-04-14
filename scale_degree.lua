local llx = require 'llx'

ScaleDegree = llx.List{
  tonic = 0,
  supertonic = 1,
  mediant = 2,
  subdominant = 3,
  dominant = 4,
  submediant = 5,
  leading_tone = 6,
}

return {
  ScaleDegree = ScaleDegree,
}
