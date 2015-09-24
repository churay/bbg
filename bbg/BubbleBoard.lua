local Class = require( "Class" )

local Vector = require( "Vector" )
local Queue = require( "Queue" )
local Box = require( "Box" )

local Bubble = require( "Bubble" )
local Shooter = require( "Shooter" )
local BubbleGrid = require( "BubbleGrid" )
local BubbleBoard = Class()

--[[ Constructors ]]--

function BubbleBoard._init( self, boardseed, gridwidth, gridheight )
  local boardseed = boardseed or os.time()
  local gridwidth = gridwidth or 8
  local gridheight = gridheight or 11

  self._bubblegrid = BubbleGrid( gridwidth, gridheight )
  self._shooter = Shooter( Vector(gridwidth / 2.0, 1.0), 1.8,  gridheight, math.pi / 2.0 )
  self._bubbleseed = boardseed

  -- TODO(JRC): Upgrade this to a Bubble queue.
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

return BubbleBoard
