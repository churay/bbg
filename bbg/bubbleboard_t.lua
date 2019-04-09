local struct = require( 'bbg.struct' )
local util = require( 'util' )
local color = require( 'bbg.color' )

local vector_t = require( 'bbg.vector_t' )
local shooter_t = require( 'bbg.shooter_t' )
local bubblequeue_t = require( 'bbg.bubblequeue_t' )
local bubblegrid_t = require( 'bbg.bubblegrid_t' )

local BGCOLOR = color.byname( 'white' )
local UICOLOR = color.byname( 'black' )

--[[ Constructors ]]--

local bubbleboard_t = struct( {},
  '_bubblegrid', false,
  '_shooter', false,
  '_boardqueue', false,
  '_shooterqueue', false,
  '_numshots', false,
  '_nextbubble', false
)

function bubbleboard_t._init( self, gridseed, queueseed )
  local gridseed = gridseed or 0
  local queueseed = queueseed or os.time()

  self._bubblegrid = bubblegrid_t( gridseed )
  self._shooter = shooter_t( vector_t(self:getw() / 2.0, 1.0), 1.8,  10.0, math.pi / 2.0 )

  self._boardqueue = bubblequeue_t( vector_t(0.0, 0.0), 8, queueseed * 7 )
  self._shooterqueue = bubblequeue_t( vector_t(0.5, 0.5), 2, queueseed )

  self._numshots = 0
  self._nextbubble = self:_getnextbubble()
end

--[[ Public Functions ]]--

function bubbleboard_t.update( self, dt )
  local hadmotion = self._bubblegrid:hasmotion()

  self._bubblegrid:update( dt )
  self._shooter:update( dt )
  self._shooterqueue:update( dt )

  local hasmotion = self._bubblegrid:hasmotion()
  if hadmotion and not hasmotion and ( self._numshots % 4 ) == 0 then
    self._bubblegrid:addgridrow( self._boardqueue:dequeueall(true) )
  end
end

function bubbleboard_t.draw( self, canvas )
  local gridheight = self._bubblegrid:geth()
  local queueheight = 2.0

  local totalwidth = self._bubblegrid:getw()
  local totalheight = gridheight + queueheight

  canvas.push()
  canvas.setColor( util.unpack(BGCOLOR) )
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
  canvas.setColor( util.unpack(UICOLOR) )
  canvas.setLineWidth( 3.0e-1 )
  for shotlineidx = 1, 4 - ( self._numshots % 4 ) do
    local shotlinex = ( 3.0 / 4.0 ) * totalwidth + 0.5 * ( shotlineidx - 1 )
    canvas.line( shotlinex, 0.5, shotlinex, 1.5 )
  end
  canvas.setLineWidth( 1.0e-1 )
  canvas.pop()

  canvas.pop()
end

function bubbleboard_t.shootbubble( self )
  -- TODO(JRC): Remove this so that multiple bubbles can be active at once.
  if self._bubblegrid:hasmotion() then return end

  local nextbubble = self._nextbubble
  self._nextbubble = self:_getnextbubble()

  nextbubble._pos = vector_t( nextbubble._pos.x, -nextbubble._pos.y )
  nextbubble._vel = self._shooter:tovector()

  self._bubblegrid:addbubble( nextbubble )
  self._numshots = self._numshots + 1
end

function bubbleboard_t.rotateshooter( self, rotdir )
  self._shooter:rotate( rotdir )
end

function bubbleboard_t.save( self, gridseed )
  self._bubblegrid:savetoseed( gridseed )
end

function bubbleboard_t.load( self, gridseed )
  if not self._bubblegrid:hasmotion() then
    self._bubblegrid:loadfromseed( gridseed )
  end
end

--[[ Accessor Functions ]]--

function bubbleboard_t.getw( self ) return self._bubblegrid:getw() end
function bubbleboard_t.geth( self ) return self._bubblegrid:geth() + 2 end
function bubbleboard_t.hasoverflow( self ) return self._bubblegrid:hasoverflow() end

--[[ Private Functions ]]--

function bubbleboard_t._getnextbubble( self )
  local nextbubble = self._shooterqueue:dequeue( true )
  nextbubble._pos = 1.0 * self._shooter._pos
  return nextbubble
end

return bubbleboard_t
