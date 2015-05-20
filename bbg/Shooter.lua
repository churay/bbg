local Class = require( "Class" )
local Vector = require( "Vector" )
local Bubble = require( "Bubble" )
local Shooter = Class()

-- TODO(JRC): Improve the concept of the "Bubble Queue" so that it isn't so tightly
-- integrated with this class (or, at the very least, is more elegantly integrated).

function Shooter._init( self, pos, shotspeed, rotspeed )
  self._pos = pos

  self._shotspeed = shotspeed or 10.0
  self._rotspeed = rotspeed or 2.0
  self._shotangle = math.pi / 2.0
end

function Shooter.adjust( self, rotdir )
  -- NOTE(JRC): direction is a number that indicates an angular direction using
  -- positive/negative numbers and the right-hand rule.
  self._shotangle = self._shotangle + rotdir * self._rotspeed
end

function Shooter.shoot( self )
  local nextbubble = self:_getnextbubble()

  nextbubble._pos = Vector( self._pos:getx(), self._pos:gety() )
  nextbubble._vel = self._shotspeed * self:_getdirvector()

  return nextbubble
end

function Shooter._getnextbubble( self )
  return Bubble( Vector(-10, -10), Vector(0, 0), {255, 255, 255} )
end

-- TODO(JRC): Determine whether or not anything needs to be included in this function.
function Shooter.update( self, dt )
  
end

function Shooter.draw( self, canvas )
  canvas.setColor( 212, 154, 44 )

  local basepos = self._pos
  local tippos = self._pos + 10 * self:_getdirvector()
  canvas.line( basepos:getx(), basepos:gety(), tippos:getx(), tippos:gety() )
end

function Shooter._getdirvector( self )
  return Vector( math.cos(self._shotangle), math.sin(self._shotangle) )
end

return Shooter
