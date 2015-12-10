local Class = require( "Class" )
local Vector = require( "Vector" )
local Box = require( "Box" )
local Bubble = Class()

Bubble.COLORS = { {245, 53, 74}, {14, 176, 0}, {0, 168, 255}, {253, 246, 78} }

--[[ Constructors ]]--

function Bubble._init( self, pos, vel, colval )
  local colval = colval or math.random( #Bubble.COLORS ) - 1.0
  local pos = pos or Vector( 0.0, 0.0 )
  local vel = vel or Vector( 0.0, 0.0 )

  self._pos = pos
  self._vel = vel
  self._color = Bubble.COLORS[(colval % #Bubble.COLORS) + 1.0]
end

--[[ Public Functions ]]--

function Bubble.update( self, dt )
  self._pos = self._pos + dt * self._vel
end

function Bubble.draw( self, canvas )
  canvas.push()
  canvas.translate( self._pos:getxy() )

  canvas.setColor( unpack(self._color) )
  canvas.circle( "fill", 0.0, 0.0, 0.5, 20.0 )

  -- TODO(JRC): Remove this functionality after debugging is complete.
  canvas.setColor( 234, 255, 0 )
  canvas.rectangle( "line", -0.5, -0.5, 1.0, 1.0 )
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
