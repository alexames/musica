local unit = require 'llx.unit'
local llx = require 'llx'
local channel_module = require 'musica.channel'
local figure_module = require 'musica.figure'

local Channel = channel_module.Channel
local Figure = figure_module.Figure
local FigureInstance = channel_module.FigureInstance
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

local function make_figure()
  return Figure{duration=4, notes={
    {pitch=60, time=0, duration=1, volume=0.5},
    {pitch=62, time=1, duration=2},
  }}
end

describe('FigureInstanceTest', function()
  it('should set time on initialization', function()
    local instance = FigureInstance(3, make_figure())
    expect(instance.time).to.be_equal_to(3)
  end)

  it('should set figure on initialization', function()
    local figure = make_figure()
    local instance = FigureInstance(3, figure)
    expect(instance.figure).to.be_equal_to(figure)
  end)

  it('should offset note times by instance time in'
    .. ' time_adjusted_notes', function()
    local instance = FigureInstance(10, make_figure())
    local times = llx.List{}
    for _, note in instance:time_adjusted_notes() do
      times:insert(note.time)
    end
    expect(times).to.be_equal_to(llx.List{10, 11})
  end)

  it('should preserve pitch duration and volume in'
    .. ' time_adjusted_notes', function()
    local instance = FigureInstance(10, make_figure())
    local notes = llx.List{}
    for _, note in instance:time_adjusted_notes() do
      notes:insert(note)
    end
    expect(notes[1].pitch).to.be_equal_to(60)
    expect(notes[1].duration).to.be_equal_to(1)
    expect(notes[1].volume).to.be_equal_to(0.5)
    expect(notes[2].pitch).to.be_equal_to(62)
    expect(notes[2].duration).to.be_equal_to(2)
    expect(notes[2].volume).to.be_equal_to(1)
  end)

  it('should yield sequential indices in time_adjusted_notes', function()
    local instance = FigureInstance(10, make_figure())
    local indices = llx.List{}
    for i in instance:time_adjusted_notes() do
      indices:insert(i)
    end
    expect(indices).to.be_equal_to(llx.List{1, 2})
  end)

  it('should yield nothing for a figure with no notes', function()
    local instance = FigureInstance(0, Figure{duration=4})
    local count = 0
    for _ in instance:time_adjusted_notes() do
      count = count + 1
    end
    expect(count).to.be_equal_to(0)
  end)

  it('should be equal to an instance with same time and figure', function()
    local a = FigureInstance(2, make_figure())
    local b = FigureInstance(2, make_figure())
    expect(a == b).to.be_truthy()
  end)

  it('should not be equal to an instance with different time', function()
    local a = FigureInstance(2, make_figure())
    local b = FigureInstance(3, make_figure())
    expect(a == b).to.be_falsy()
  end)

  it('should not be equal to an instance with different figure', function()
    local a = FigureInstance(2, make_figure())
    local b = FigureInstance(2, Figure{duration=4, notes={
      {pitch=64, time=0, duration=1},
    }})
    expect(a == b).to.be_falsy()
  end)

  it('should include class name and time in tostring', function()
    local instance = FigureInstance(7, make_figure())
    expect(tostring(instance)).to.contain('FigureInstance(7')
  end)
end)

describe('ChannelTest', function()
  it('should set instrument on initialization', function()
    local channel = Channel(42)
    expect(channel.instrument).to.be_equal_to(42)
  end)

  it('should start with empty figure_instances', function()
    local channel = Channel(42)
    expect(#channel.figure_instances).to.be_equal_to(0)
  end)

  it('should default part_name to nil', function()
    expect(Channel(42).part_name).to.be_nil()
  end)

  it('should default short_name to nil', function()
    expect(Channel(42).short_name).to.be_nil()
  end)

  it('should default clef to nil', function()
    expect(Channel(42).clef).to.be_nil()
  end)

  it('should default transposition to nil', function()
    expect(Channel(42).transposition).to.be_nil()
  end)

  it('should set sheet music metadata from args', function()
    local channel = Channel(42, {part_name='Violin I', short_name='Vln. I',
                                 clef='treble', transposition=-2})
    expect(channel.part_name).to.be_equal_to('Violin I')
    expect(channel.short_name).to.be_equal_to('Vln. I')
    expect(channel.clef).to.be_equal_to('treble')
    expect(channel.transposition).to.be_equal_to(-2)
  end)

  it('should be equal to a channel with same instrument and'
    .. ' instances', function()
    local a = Channel(42)
    local b = Channel(42)
    a.figure_instances:insert(FigureInstance(0, make_figure()))
    b.figure_instances:insert(FigureInstance(0, make_figure()))
    expect(a == b).to.be_truthy()
  end)

  it('should not be equal to a channel with different'
    .. ' instrument', function()
    expect(Channel(42) == Channel(43)).to.be_falsy()
  end)

  it('should not be equal to a channel with different'
    .. ' figure_instances', function()
    local a = Channel(42)
    local b = Channel(42)
    b.figure_instances:insert(FigureInstance(0, make_figure()))
    expect(a == b).to.be_falsy()
  end)

  it('should not be equal to a channel with different clef', function()
    local a = Channel(42, {clef='treble'})
    local b = Channel(42, {clef='bass'})
    expect(a == b).to.be_falsy()
  end)

  it('should not be equal to a channel with different'
    .. ' part_name', function()
    local a = Channel(42, {part_name='Violin I'})
    local b = Channel(42, {part_name='Violin II'})
    expect(a == b).to.be_falsy()
  end)

  it('should include class name in tostring', function()
    expect(tostring(Channel(42))).to.contain('Channel')
  end)
end)

if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
