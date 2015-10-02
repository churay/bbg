local Class = require( "Class" )

local Vector = require( "Vector" )
local Box = require( "Box" )
local Utility = require( "Utility" )

local Bubble = require( "Bubble" )
local BubbleGrid = Class()

--[[ Constructors ]]--

-- TODO(JRC): Add a capability to specify a random seed for an initial configuration.
function BubbleGrid._init( self, width, height )
  self._gridbox = Box( 0.0, 0.0, width, height )

  self._bubblelist = {}
  self._bubblegrid = {}
  self:clear()

  local sentrow = 0
  self._bubblegrid[sentrow] = {}
  for sentcol = 1, self:getw() do
    local sentbbox = Box( sentcol + 0.5, self:geth(), 1, 1 )
    self._bubblegrid[sentrow][sentcol] = Bubble( sentbbox:getmid() )
  end
end

--[[ Public Functions ]]--

function BubbleGrid.update( self, dt )
  for bubbleidx = #self._bubblelist, 1, -1 do
    local bubble = self._bubblelist[bubbleidx]

    local wallleftintx, wallrightintx = self:_getwallintx( bubble )
    if wallleftintx or wallrightintx then
      bubble:bounce()
    end

    local gridrowintx, gridcolintx = self:_getgridintx( bubble )
    if gridrowintx and gridcolintx then
      bubble:stop()

      self:addgridbubble( bubble, gridrowintx, gridcolintx )
      table.remove( self._bubblelist, bubbleidx )

      -- TODO(JRC): Implement the behavior for destroying bubbles.
    end

    bubble:update( dt )
  end
end

function BubbleGrid.draw( self, canvas )
  canvas.push()

  canvas.setColor( 200, 200, 200 )
  canvas.rectangle( "fill", 0.0, 0.0, self:getw(), self:geth() )

  for _, bubble in ipairs( self._bubblelist ) do bubble:draw( love.graphics ) end

  for _, bubblerow in ipairs( self._bubblegrid ) do
    for _, bubble in ipairs( bubblerow ) do
      if bubble ~= 0 then bubble:draw( love.graphics ) end
    end
  end

  canvas.pop()
end

function BubbleGrid.addbubble( self, bubble )
  table.insert( self._bubblelist, bubble )
end

function BubbleGrid.addgridbubble( self, bubble, gridrow, gridcol )
  local cellminx = gridcol - 1 + 0.5 * ( (gridrow + 1) % 2 )
  local cellminy = self:geth() - gridrow
  bubble._pos = Vector( cellminx, cellminy ) + Vector( 0.5, 0.5 )

  self._bubblegrid[gridrow][gridcol] = bubble
end

function BubbleGrid.clear( self )
  self._bubbles = {}

  for row = 1, self:geth() do
    self._bubblegrid[row] = {}
    for col = 1, self:getw() do
      self._bubblegrid[row][col] = 0
    end
  end
end

--[[ Accessor Functions ]]--

function BubbleGrid.getw( self ) return self._gridbox:getw() end
function BubbleGrid.geth( self ) return self._gridbox:geth() end

--[[ Private Functions ]]--

function BubbleGrid._getwallintx( self, bubble )
  local bubblebox = bubble:getbbox()

  local isleftintx = bubblebox:getmin():getx() <= self._gridbox:getmin():getx()
  local isrightintx = bubblebox:getmax():getx() >= self._gridbox:getmax():getx()

  return isleftintx, isrightintx
end

function BubbleGrid._getgridintx( self, bubble )
  local bubblebbox = bubble:getbbox()
  local bubblecorners = {
    bubblebbox:getmin(),
    bubblebbox:getmax(),
    bubblebbox:getmin() + Vector(bubblebbox:getw(), 0.0),
    bubblebbox:getmin() + Vector(0.0, bubblebbox:geth()),
  }

  for _, bubblecorner in ipairs( bubblecorners ) do
    local intxrow = self:geth() - math.ceil( bubblecorner:gety() )
    local intxcol = math.ceil( bubblecorner:getx() ) + ( intxrow % 2 )

    local intxbubble = self._bubblegrid[intxrow] and self._bubblegrid[intxrow][intxcol]
    if intxbubble ~= nil and intxbubble ~= 0 then
      local intxbubblebbox = intxbubble:getbbox()
      local intxvector = bubblebbox:getmid() - intxbubblebbox:getmid()

      return self:_getgridpos( intxrow, intxcol, intxvector )
    end
  end
end

function BubbleGrid._getgridpos( self, row, col, dir )
  local dirangle = dir:angleto( Vector(1.0, 0.0) )

  local dirxright = ( col % 2 )
  local dirysign = dir:gety() > 0 and -1 or 1

  local dirxdelta = Utility.inrange( dirangle, 0.0, math.pi/2.0 ) and dirxright or dirxright-1
  local dirydelta = Utility.inrange( dirangle, math.pi/6.0, 5.0*math.pi/6.0 ) and 1 or 0

  return row + dirysign * dirydelta, col + dirxdelta
end

return BubbleGrid
