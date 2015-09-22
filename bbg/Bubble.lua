local Class = require( "Class" )
local Vector = require( "Vector" )
local Box = require( "Box" )
local Bubble = Class()

Bubble.RADIUS = 1.0 / 40.0

function Bubble._init( self, pos, vel, color )
  self._pos = pos
  self._vel = vel
  -- TODO(JRC): Determine whether the random color should be the default value
  -- or whether this value should always be set by the constructor (probably the
  -- latter to make it possible for the game to generate the same set of bubbles
  -- for two competing players).
  self._color = color or {255, 255, 255}
end

function Bubble.bounce( self )
  self._vel = self._vel + Vector( -2.0 * self._vel:getx(), 0.0 )
end

function Bubble.stop( self )
  self._vel = Vector( 0.0, 0.0 )
end

function Bubble.update( self, dt )
  self._pos = self._pos + dt * self._vel
end

function Bubble.draw( self, canvas )
  canvas.push()
  canvas.translate( self._pos:getxy() )
  canvas.setColor( unpack(self._color) )
  canvas.circle( "fill", 0.0, 0.0, Bubble.RADIUS, 1.0 / Bubble.RADIUS )
  canvas.pop()
end

function Bubble.getbbox( self )
  local minx = self._pos:getx() - Bubble.RADIUS / 2.0
  local miny = self._pos:gety() - Bubble.RADIUS / 2.0

  return Box( minx, miny, Bubble.RADIUS, Bubble.RADIUS )
end

return Bubble
