local Class = require( "Class" )
local Vector = require( "Vector" )
local Bubble = Class()

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

function Bubble.update( self, dt )
  self._pos = self._pos + dt * self._vel
end

function Bubble.draw( self, canvas )
  canvas.setColor( unpack(self._color) )
  canvas.circle( "fill", self._pos:getx(), self._pos:gety(), 5, 5 )
end

return Bubble
