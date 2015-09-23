local Class = require( "Class" )
local Vector = require( "Vector" )
local Bubble = require( "Bubble" )
local Utility = require( "Utility" )
local Shooter = Class()

-- TODO(JRC): Improve the concept of the "Bubble Queue" so that it isn't so tightly
-- integrated with this class (or, at the very least, more elegantly integrated).

function Shooter._init( self, pos, shotspeed, rotspeed )
  self._pos = pos
  self._rotdir = 0.0

  self._shotspeed = shotspeed or 1.0
  self._rotspeed = rotspeed or math.pi / 2.0
  self._shotangle = math.pi / 2.0
end

function Shooter.shoot( self )
  local nextbubble = self:_getnextbubble()

  nextbubble._pos = Vector( self._pos:getx(), self._pos:gety() )
  nextbubble._vel = self._shotspeed * self:_getdirvector()

  return nextbubble
end

function Shooter.rotate( self, rotdir )
  self._rotdir = rotdir
end

function Shooter.update( self, dt )
  local newshotangle = self._shotangle + dt * self._rotdir * self._rotspeed
  self._shotangle = Utility.clamp( newshotangle, 0.0, math.pi )
end

function Shooter.draw( self, canvas )
  canvas.push()
  canvas.translate( self._pos:getxy() )

  canvas.setLineWidth( 5.0e-3 )
  canvas.setColor( 212, 154, 44 )
  canvas.line( 0.0, 0.0, ((1.0 / 20.0)*self:_getdirvector()):getxy() )
  canvas.pop()
end

function Shooter._getnextbubble( self )
  return Bubble( Vector(-1,0, -1.0), Vector(0, 0), {237, 67, 55} )
end

function Shooter._getdirvector( self )
  return Vector( math.cos(self._shotangle), math.sin(self._shotangle) )
end

return Shooter
