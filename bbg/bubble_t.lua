local Class = require( 'Class' )
local Vector = require( 'Vector' )
local Box = require( 'Box' )
local Color = require( 'Color' )
local Bubble = Class()

Bubble.COLORS = { Color.byname('red'), Color.byname('green'), Color.byname('blue'), Color.byname('yellow') }

--[[ Constructors ]]--

function Bubble._init( self, pos, vel, colval )
  local pos = pos or Vector( 0.0, 0.0 )
  local vel = vel or Vector( 0.0, 0.0 )
  local colval = colval or math.random( #Bubble.COLORS )

  self._pos = pos
  self._vel = vel
  self._color = Bubble.COLORS[colval]
end

--[[ Public Functions ]]--

function Bubble.update( self, dt )
  self._pos = self._pos + dt * self._vel
end

function Bubble.draw( self, canvas )
  canvas.push()
  canvas.translate( self._pos:getxy() )

  canvas.setColor( unpack(self._color) )
  canvas.circle( 'fill', 0.0, 0.0, 0.5, 20.0 )

  -- TODO(JRC): Remove this functionality after debugging is complete.
  canvas.setColor( Color.from255(234, 255, 0) )
  canvas.rectangle( 'line', -0.5, -0.5, 1.0, 1.0 )
  canvas.pop()
end

function Bubble.bounce( self )
  self._vel = self._vel + Vector( -2.0 * self._vel:getx(), 0.0 )
end

function Bubble.stop( self )
  self._vel = Vector( 0.0, 0.0 )
end

function Bubble.getbbox( self )
  local minx = self._pos:getx() - 0.5
  local miny = self._pos:gety() - 0.5

  return Box( minx, miny, 1.0, 1.0 )
end

--[[ Accessor Functions ]]--

function Bubble.getcenter( self ) return self._pos end
function Bubble.getvelocity( self ) return self._vel end
function Bubble.getcolor( self ) return self._color end

return Bubble
