local Class = require( 'Class' )

local Vector = require( 'Vector' )
local Color = require( 'Color' )
local Box = require( 'Box' )
local Bubble = require( 'Bubble' )

local Shooter = require( 'Shooter' )
local BubbleQueue = require( 'BubbleQueue' )
local BubbleGrid = require( 'BubbleGrid' )
local BubbleBoard = Class()

BubbleBoard.BGCOLOR = Color.byname( 'white' )
BubbleBoard.UICOLOR = Color.byname( 'black' )

--[[ Constructors ]]--

function BubbleBoard._init( self, gridseed, queueseed )
  local gridseed = gridseed or 0
  local queueseed = queueseed or os.time()

  self._bubblegrid = BubbleGrid( gridseed )
  self._shooter = Shooter( Vector(self:getw() / 2.0, 1.0), 1.8,  10.0, math.pi / 2.0 )

  self._boardqueue = BubbleQueue( Vector(0.0, 0.0), queueseed * 7, 8 )
  self._shooterqueue = BubbleQueue( Vector(0.5, 0.5), queueseed, 2 )

  self._numshots = 0
  self._nextbubble = self:_getnextbubble()
end

--[[ Public Functions ]]--

function BubbleBoard.update( self, dt )
  local hadmotion = self._bubblegrid:hasmotion()

  self._bubblegrid:update( dt )
  self._shooter:update( dt )
  self._shooterqueue:update( dt )

  local hasmotion = self._bubblegrid:hasmotion()
  if hadmotion and not hasmotion and ( self._numshots % 4 ) == 0 then
    self._bubblegrid:addgridrow( self._boardqueue:dequeueall(true) )
  end
end

function BubbleBoard.draw( self, canvas )
  local gridheight = self._bubblegrid:geth()
  local queueheight = 2.0

  local totalwidth = self._bubblegrid:getw()
  local totalheight = gridheight + queueheight

  canvas.push()
  canvas.setColor( unpack(BubbleBoard.BGCOLOR) )
  canvas.rectangle( 'fill', 0.0, 0.0, 1.0, 1.0 )

  canvas.push()
  canvas.translate( 0, queueheight / totalheight )
  canvas.scale( 1.0, gridheight / totalheight )
  canvas.scale( 1.0 / totalwidth, 1.0 / gridheight )
  self._bubblegrid:draw( canvas )
  canvas.pop()

  canvas.push()
  canvas.scale( 1.0, queueheight / totalheight )
  canvas.scale( 1.0 / totalwidth, 1.0 / queueheight )
  self._shooter:draw( canvas )
  self._shooterqueue:draw( canvas )
  self._nextbubble:draw( canvas )

  -- TODO(JRC): Move this logic to its own class if this ends up being the
  -- final representation for the number of shots remaining until adjustment.
  canvas.setColor( unpack(BubbleBoard.UICOLOR) )
  canvas.setLineWidth( 3.0e-1 )
  for shotlineidx = 1, 4 - ( self._numshots % 4 ) do
    local shotlinex = ( 3.0 / 4.0 ) * totalwidth + 0.5 * ( shotlineidx - 1 )
    canvas.line( shotlinex, 0.5, shotlinex, 1.5 )
  end
  canvas.setLineWidth( 1.0e-1 )
  canvas.pop()

  canvas.pop()
end

function BubbleBoard.shootbubble( self )
  -- TODO(JRC): Remove this so that multiple bubbles can be active at once.
  if self._bubblegrid:hasmotion() then return end

  local nextbubble = self._nextbubble
  self._nextbubble = self:_getnextbubble()

  nextbubble._pos = Vector( nextbubble._pos:getx(), -nextbubble._pos:gety() )
  nextbubble._vel = self._shooter:tovector()

  self._bubblegrid:addbubble( nextbubble )
  self._numshots = self._numshots + 1
end

function BubbleBoard.rotateshooter( self, rotdir )
  self._shooter:rotate( rotdir )
end

function BubbleBoard.save( self, gridseed )
  self._bubblegrid:savetoseed( gridseed )
end

function BubbleBoard.load( self, gridseed )
  if not self._bubblegrid:hasmotion() then
    self._bubblegrid:loadfromseed( gridseed )
  end
end

--[[ Accessor Functions ]]--

function BubbleBoard.getw( self ) return self._bubblegrid:getw() end
function BubbleBoard.geth( self ) return self._bubblegrid:geth() + 2 end
function BubbleBoard.hasoverflow( self ) return self._bubblegrid:hasoverflow() end

--[[ Private Functions ]]--

function BubbleBoard._getnextbubble( self )
  local nextbubble = self._shooterqueue:dequeue( true )
  nextbubble._pos = Vector( self._shooter._pos:getxy() )
  return nextbubble
end

return BubbleBoard
