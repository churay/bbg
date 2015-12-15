local Class = require( "Class" )

local Vector = require( "Vector" )
local Queue = require( "Queue" )
local Box = require( "Box" )

local Bubble = require( "Bubble" )
local Shooter = require( "Shooter" )
local BubbleGrid = require( "BubbleGrid" )
local BubbleBoard = Class()

--[[ Constructors ]]--

function BubbleBoard._init( self, gridseed, queueseed )
  local gridseed = gridseed or 0
  local queueseed = queueseed or os.time()

  self._bubblegrid = BubbleGrid( gridseed )
  -- self._bubblequeue = BubbleQueue( queueseed )
  self._shooter = Shooter( Vector(self:getw() / 2.0, 1.0), 1.8,  10.0, math.pi / 2.0 )

  -- TODO(JRC): Upgrade this to a Bubble queue; pass the queue seed.
  self._nextbubble = Bubble( Vector(self._shooter._pos:getxy()), Vector(0.0, 0.0) )
end

--[[ Public Functions ]]--

function BubbleBoard.update( self, dt )
  self._bubblegrid:update( dt )
  self._shooter:update( dt )
end

function BubbleBoard.draw( self, canvas )
  local gridheight = self._bubblegrid:geth()
  local queueheight = 2.0

  local totalwidth = self._bubblegrid:getw()
  local totalheight = gridheight + queueheight

  canvas.push()
  canvas.setColor( 255, 255, 255 )
  canvas.rectangle( "fill", 0.0, 0.0, 1.0, 1.0 )

  canvas.push()
  canvas.translate( 0, queueheight / totalheight )
  canvas.scale( 1.0, gridheight / totalheight )
  canvas.scale( 1.0 / totalwidth, 1.0 / gridheight )
  self._bubblegrid:draw( canvas )
  canvas.pop()

  -- TODO(JRC): Draw the next bubble, the bubble queue, and the outlines for
  -- the board.
  canvas.push()
  canvas.scale( 1.0, queueheight / totalheight )
  canvas.scale( 1.0 / totalwidth, 1.0 / queueheight )
  self._shooter:draw( canvas )
  canvas.pop()

  canvas.pop()
end

function BubbleBoard.shootbubble( self )
  local nextbubble = self._nextbubble
  self._nextbubble = Bubble( Vector(self._shooter._pos:getxy()), Vector(0.0, 0.0) )

  nextbubble._pos = Vector( nextbubble._pos:getx(), -nextbubble._pos:gety() )
  nextbubble._vel = self._shooter:tovector()

  self._bubblegrid:addbubble( nextbubble )
end

function BubbleBoard.rotateshooter( self, rotdir )
  self._shooter:rotate( rotdir )
end

--[[ Accessor Functions ]]--

function BubbleBoard.getw( self ) return self._bubblegrid:getw() end
function BubbleBoard.geth( self ) return self._bubblegrid:geth() + 2 end

return BubbleBoard
