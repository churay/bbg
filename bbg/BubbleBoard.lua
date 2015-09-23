local Class = require( "Class" )
local Box = require( "Box" )
local Bubble = require( "Bubble" )
local BubbleBoard = Class()

--[[ Constructors ]]--

function BubbleBoard._init( self, bbox, width, height )
  self._bbox = bbox
  self._width = width
  self._height = height

  self._bubbles = {}
  self._bubblegrid = {}

  for col = 1, self._width do
    self._bubblegrid[col] = {}
    for row = 1, self._height do
      self._bubblegrid[col][row] = 0
    end
  end
end

--[[ Public Functions ]]--

function BubbleBoard.add( self, bubble )
  table.insert( self._bubbles, bubble )
end

function BubbleBoard.update( self, dt )
  local boardbox = Box( 0.0, 0.0, 1.0, 1.0 )
  for bubbleidx = #self._bubbles, 1, -1 do
    local bubble = self._bubbles[bubbleidx]
    bubble:update( dt )

    -- TODO(JRC): Improve the code here so that the two if statements are
    -- combined with an or without sacrificing the aesthetics of the code.
    local bubblebox = bubble:getbbox()
    if bubblebox:getmin():getx() <= boardbox:getmin():getx() then bubble:bounce() end
    if bubblebox:getmax():getx() >= boardbox:getmax():getx() then bubble:bounce() end

    if not boardbox:intersects( bubble:getbbox() ) then
      table.remove( self._bubbles, bubbleidx )
    end
  end
end

function BubbleBoard.draw( self, canvas )
  canvas.push()
  canvas.translate( self._bbox:getmin():getxy() )
  canvas.scale( self._bbox:getdims() )

  canvas.setColor( 255, 255, 255 )
  canvas.rectangle( "fill", 0.0, 0.0, 1.0, 1.0 )

  for _, bubble in ipairs( self._bubbles ) do bubble:draw( love.graphics ) end
  canvas.pop()
end

return BubbleBoard
