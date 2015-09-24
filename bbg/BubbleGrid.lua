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
    bubble:update( dt )

    if bubble:getbbox():getmin():getx() <= self._gridbox:getmin():getx() or
        bubble:getbbox():getmax():getx() >= self._gridbox:getmax():getx() then
      bubble:bounce()
    end

    if bubble:getbbox():getmax():gety() >= self._gridbox:getmax():gety() then
      table.remove( self._bubblelist, bubbleidx )
    end
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

return BubbleGrid
