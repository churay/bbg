local Class = require( "Class" )
local Vector = require( "Vector" )
local Box = require( "Box" )
local Bubble = Class()

Bubble.RADIUS = 2.5e-1

-- TODO(JRC): Determine whether the logic for stopping bubbles should be included
-- in this file or elsewhere.

function Bubble._init( self, pos, vel, color )
  self._pos = pos
  self._vel = vel
  -- TODO(JRC): Remember that the type of this thing should be a list containing
  -- the red, green, and blue components of the bubble color.
  -- TODO(JRC): Determine whether the random color should be the default value
  -- or whether this value should always be set by the constructor (probably the
  -- latter to make it possible for the game to generate the same set of bubbles
  -- for two competing players).
  self._color = color
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
  canvas.setColor( unpack(self._color) )
  canvas.circle( "fill", self._pos:getx(), self._pos:gety(), Bubble.RADIUS, 40 )
end

function Bubble.getbbox( self )
  local minx = self._pos:getx() - Bubble.RADIUS / 2.0
  local miny = self._pos:gety() - Bubble.RADIUS / 2.0

  return Box( minx, miny, Bubble.RADIUS, Bubble.RADIUS )
end

return Bubble
