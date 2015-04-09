local Class = require( "Class" )
local Bubble = Class()

-- TODO(JRC): Implement this class!

function Bubble._init( self, pos, vel, color )
  self._pos = pos
  self._vel = vel
  self._color = color
end

function Bubble.update( self, dt )
  return 0.0
end
