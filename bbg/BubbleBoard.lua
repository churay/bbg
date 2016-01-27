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

  --[[
  self._nextrowcounter = 4
  self._nextrowrng = love.math.newRandomGenerator( queueseed * 7 )
  ]]--
end

--[[ Public Functions ]]--

function BubbleBoard.update( self, dt )
  self._bubblegrid:update( dt )
  self._shooter:update( dt )
  self._bubblequeue:update( dt )
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
  canvas.pop()

  canvas.pop()
end

function BubbleBoard.shootbubble( self )
  --[[
  self._nextrowcounter = self._nextrowcounter - 1
  if self._nextrowcounter == 0 then
    local nextrowvals = {}
    for validx = 1, self:getw(), 1 do
      table.insert( nextrowvals, self._nextrowrng:random(#Bubble.COLORS)  )
    end

    self._bubblegrid:addgridrow( nextrowvals )

    self._nextrowcounter = 4
  end
  ]]--

  local nextbubble = self._nextbubble
  self._nextbubble = self:_getnextbubble()

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

--[[ Private Functions ]]--

function BubbleBoard._getnextbubble( self )
  local nextbubble = self._bubblequeue:dequeue()
  nextbubble._pos = Vector( self._shooter._pos:getxy() )

  return nextbubble
end

return BubbleBoard
