local struct = require( 'bbg.struct' )
local util = require( 'util' )
local config = require( 'bbg.config' )
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
  '_colorid', math.random(#BUBBLECOLORS),
  '_pos', vector_t(),
  '_vel', vector_t()
)

--[[ Public Functions ]]--

function bubble_t.update( self, dt )
  self._pos = self._pos + dt * self._vel
end

function bubble_t.draw( self, canvas )
  canvas.push()
  canvas.translate( self._pos:xy() )

  canvas.setColor( util.unpack(BUBBLECOLORS[self._colorid]) )
  canvas.circle( 'fill', 0.0, 0.0, 0.5, 20.0 )

  if config.debug then
    canvas.setColor( util.unpack(DEBUGCOLOR) )
    canvas.rectangle( 'line', -0.5, -0.5, 1.0, 1.0 )
  end

  canvas.pop()
end

function bubble_t.bounce( self )
  self._vel:addip( vector_t(-2.0 * self._vel.x, 0.0) )
end

function bubble_t.stop( self )
  self._vel = vector_t( 0.0, 0.0 )
end

function bubble_t.getbbox( self )
  local minx = self._pos.x - 0.5
  local miny = self._pos.y - 0.5

  return bbox_t( minx, miny, 1.0, 1.0 )
end

--[[ Accessor Functions ]]--

function bubble_t.getcenter( self ) return self._pos end
function bubble_t.getvelocity( self ) return self._vel end
function bubble_t.getcolorid( self ) return self._colorid end

--[[ Static Functions ]]--

function bubble_t.getnextcolorid( fxn )
  local fxn = fxn or math.random
  return fxn( #BUBBLECOLORS )
end

return bubble_t
