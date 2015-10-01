local Class = require( "Class" )
local Box = require( "Box" )
local Bubble = require( "Bubble" )
local BubbleGrid = Class()

--[[ Constructors ]]--

-- TODO(JRC): Add a capability to specify a random seed for an initial configuration.
function BubbleGrid._init( self, width, height )
  self._gridbox = Box( 0.0, 0.0, width, height )

  self._bubblelist = {}
  self._bubblegrid = {}

  for col = 1, self:getw() do
    self._bubblegrid[col] = {}
    for row = 1, self:geth() do
      self._bubblegrid[col][row] = 0
    end
  end
end

--[[ Public Functions ]]--

function BubbleGrid.update( self, dt )
  for bubbleidx = #self._bubblelist, 1, -1 do
    local bubble = self._bubblelist[bubbleidx]

    if self:_getwallintx( bubble ) then bubble:bounce() end
    if self:_getgridintx( bubble ) then table.remove( self._bubblelist, bubbleidx ) end

    bubble:update( dt )
  end
end

function BubbleGrid.draw( self, canvas )
  canvas.push()

  canvas.setColor( 200, 200, 200 )
  canvas.rectangle( "fill", 0.0, 0.0, self:getw(), self:geth() )

  for _, bubble in ipairs( self._bubblelist ) do bubble:draw( love.graphics ) end
  canvas.pop()
end

function BubbleGrid.addbubble( self, bubble )
  table.insert( self._bubblelist, bubble )
end

--[[ Accessor Functions ]]--

function BubbleGrid.getw( self ) return self._gridbox:getw() end
function BubbleGrid.geth( self ) return self._gridbox:geth() end

--[[ Private Functions ]]--

function BubbleGrid._getwallintx( self, bubble )
  local bubblebox = bubble:getbbox()

  local isleftintx = bubblebox:getmin():getx() <= self._gridbox:getmin():getx()
  local isrightintx = bubblebox:getmax():getx() >= self._gridbox:getmax():getx()

  return isleftintx or isrightintx
end

function BubbleGrid._getgridintx( self, bubble )
  return false
end

return BubbleGrid
