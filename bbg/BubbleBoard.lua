local Class = require( "Class" )

local Vector = require( "Vector" )
local Box = require( "Box" )
local Bubble = require( "Bubble" )

local Shooter = require( "Shooter" )
local BubbleQueue = require( "BubbleQueue" )
local BubbleGrid = require( "BubbleGrid" )
local BubbleBoard = Class()

--[[ Constructors ]]--

function BubbleBoard._init( self, gridseed, queueseed )
  local gridseed = gridseed or 0
  local queueseed = queueseed or os.time()

  self._bubblegrid = BubbleGrid( gridseed )
  self._shooter = Shooter( Vector(self:getw() / 2.0, 1.0), 1.8,  10.0, math.pi / 2.0 )
  self._bubblequeue = BubbleQueue( Vector(0.5, 0.5), 2, queueseed )
  self._nextbubble = self:_getnextbubble()

  -- TODO(JRC): This should be refactored so that it's a bit less ugly.
  self._numshotbubbles = 0
  self._rng = love.math.newRandomGenerator( queueseed * 7 )
end

--[[ Public Functions ]]--

function BubbleBoard.update( self, dt )
  local hadmotion = self._bubblegrid:hasmotion()

  self._bubblegrid:update( dt )
  self._shooter:update( dt )
  self._bubblequeue:update( dt )

  -- TODO(JRC): This should be refactored so that it's a bit less ugly.
  local hasmotion = self._bubblegrid:hasmotion()
  if hadmotion and not hasmotion and ( self._numshotbubbles % 4 ) == 0 then
    local nextrowvals = {}
    for validx = 1, self:getw(), 1 do
      table.insert( nextrowvals, self._rng:random(#Bubble.COLORS) )
    end
    self._bubblegrid:addgridrow( nextrowvals )
  end
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

  canvas.push()
  canvas.scale( 1.0, queueheight / totalheight )
  canvas.scale( 1.0 / totalwidth, 1.0 / queueheight )
  self._shooter:draw( canvas )
  self._bubblequeue:draw( canvas )
  self._nextbubble:draw( canvas )

  -- TODO(JRC): Move this logic to its own class if this ends up being the
  -- final representation for the number of shots remaining until adjustment.
  canvas.setColor( 0, 0, 0 )
  canvas.setLineWidth( 3.0e-1 )
  for shotlineidx = 1, 4 - (self._numshotbubbles % 4), 1 do
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
  self._numshotbubbles = self._numshotbubbles + 1
end

function BubbleBoard.rotateshooter( self, rotdir )
  self._shooter:rotate( rotdir )
end

--[[ Accessor Functions ]]--

function BubbleBoard.getw( self ) return self._bubblegrid:getw() end
function BubbleBoard.geth( self ) return self._bubblegrid:geth() + 2 end

--[[ Private Functions ]]--

function BubbleBoard._getnextbubble( self )
  local nextbubble = self._bubblequeue:dequeue()
  nextbubble._pos = Vector( self._shooter._pos:getxy() )

  return nextbubble
end

return BubbleBoard
