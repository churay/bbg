local Class = require( "Class" )
local Vector = require( "Vector" )
local Bubble = require( "Bubble" )
local Shooter = Class()

-- TODO(JRC): Improve the concept of the "Bubble Queue" so that it isn't so tightly
-- integrated with this class (or, at the very least, more elegantly integrated).

function Shooter._init( self, pos, shotspeed, rotspeed )
  self._pos = pos

  self._shotspeed = shotspeed or 1.0
  self._rotspeed = rotspeed or math.pi / 60.0
  self._shotangle = math.pi / 2.0
end

-- TODO(JRC): Make the time factor for the rotation speed the same as that for the
-- shot speed (i.e. per second instead of per frame).
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

-- TODO(JRC): Determine whether or not anything needs to be included in this function.
function Shooter.update( self, dt )
  
end

function Shooter.draw( self, canvas )
  local basepos = self._pos
  local tippos = (1.0 / 20.0) * self:_getdirvector()

  canvas.push()
  canvas.setColor( 212, 154, 44 )
  canvas.setLineWidth( 5.0e-3 )
  canvas.translate( basepos:getxy() )
  canvas.line( 0.0, 0.0, tippos:getxy() )
  canvas.pop()
end

function Shooter._getnextbubble( self )
  return Bubble( Vector(-1,0, -1.0), Vector(0, 0), {255, 255, 255} )
end

function Shooter._getdirvector( self )
  return Vector( math.cos(self._shotangle), math.sin(self._shotangle) )
end

return Shooter
