local struct = require( 'bbg.struct' )
local util = require( 'util' )
local color = require( 'bbg.color' )

local bbox_t = require( 'bbg.bbox_t' )
local vector_t = require( 'bbg.vector_t' )

local BUBBLECOLORS = { 'red', 'green', 'blue', 'yellow' }
for bubbleidx = 1, #BUBBLECOLORS, 1 do
  BUBBLECOLORS[bubbleidx] = color.byname(BUBBLECOLORS[bubbleidx])
end

local DEBUGCOLOR = { 0.9, 1.0, 0.0 }

--[[ Constructors ]]--

local bubble_t = struct( {},
  '_color', color.byname('black'),
  '_pos', vector_t(),
  '_vel', vector_t(),
)

function bubble_t._init( self, coloridx, pos, vel )
  self._color = BUBBLECOLORS[coloridx or math.random(#BUBBLECOLORS)]
  if pos then self._pos.x, self._pos.y = args[1].x, args[1].y end
  if vel then self._vel.x, self._vel.y = args[1].x, args[1].y end
end

--[[ Public Functions ]]--

function bubble_t.update( self, dt )
  self._pos = self._pos + dt * self._vel
end

function bubble_t.draw( self, canvas )
  canvas.push()
  canvas.translate( self._pos:getxy() )

  canvas.setColor( util.unpack(self._color) )
  canvas.circle( 'fill', 0.0, 0.0, 0.5, 20.0 )

  -- TODO(JRC): Only enable this functionality when the debug flag
  -- is enabled.
  canvas.setColor( util.unpack(DEBUGCOLOR) )
  canvas.rectangle( 'line', -0.5, -0.5, 1.0, 1.0 )
  canvas.pop()
end

function bubble_t.bounce( self )
  self._vel = self._vel + vector_t( -2.0 * self._vel:getx(), 0.0 )
end

function bubble_t.stop( self )
  self._vel = vector_t( 0.0, 0.0 )
end

function bubble_t.getbbox( self )
  local minx = self._pos:getx() - 0.5
  local miny = self._pos:gety() - 0.5

  return bbox_t( minx, miny, 1.0, 1.0 )
end

--[[ Accessor Functions ]]--

function bubble_t.getcenter( self ) return self._pos end
function bubble_t.getvelocity( self ) return self._vel end
function bubble_t.getcolor( self ) return self._color end

--[[ Static Functions ]]--

function bubble_t.getnumcolors() return #BUBBLECOLORS end

return bubble_t
