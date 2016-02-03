local Class = require( "Class" )
local Vector = require( "Vector" )
local Bubble = require( "Bubble" )
local Utility = require( "Utility" )
local Shooter = Class()

--[[ Constructors ]]--

function Shooter._init( self, pos, length, shotspeed, rotspeed )
  self._pos = pos
  self._length = length

  self._rotdir = 0.0
  self._shotangle = math.pi / 2.0

  self._shotspeed = shotspeed or 1.0
  self._rotspeed = rotspeed or 2.0 * math.pi / 3.0
end

--[[ Public Functions ]]--

function Shooter.update( self, dt )
  local anglepad = math.pi / 16.0
  local rotdir = Utility.clamp( self._rotdir, -1.0, 1.0 )

  local newshotangle = self._shotangle + dt * rotdir * self._rotspeed
  self._shotangle = Utility.clamp( newshotangle, anglepad, math.pi - anglepad )
end

function Shooter.draw( self, canvas )
  local gvector = ( self._length / (2.0 * self._shotspeed) ) * self:tovector()

  canvas.push()
  canvas.translate( self._pos:getxy() )

  canvas.setLineWidth( 1.0e-1 )
  canvas.setColor( 212, 154, 44 )
  canvas.line( -gvector:getx(), -gvector:gety(), gvector:getx(), gvector:gety() )
  canvas.pop()
end

function Shooter.rotate( self, rotdir )
  self._rotdir = self._rotdir + rotdir
end

function Shooter.tovector( self )
  return self._shotspeed * Vector( math.cos(self._shotangle), math.sin(self._shotangle) )
end

return Shooter
