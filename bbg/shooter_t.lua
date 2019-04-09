local struct = require( 'bbg.struct' )
local util = require( 'util' )
local color = require( 'bbg.color' )

local vector_t = require( 'bbg.vector_t' )
local bubble_t = require( 'bbg.bubble_t' )

local UICOLOR = { 0.8, 0.6, 0.2 } -- brown

--[[ Constructors ]]--

local shooter_t = struct( {},
  '_pos', vector_t(),
  '_len', 0,
  '_shotspeed', 1.0,
  '_rotspeed', 2.0 * math.pi / 3.0,
  '_shotangle', math.pi / 2.0,
  '_rotdir', 0.0
)

--[[ Public Functions ]]--

function shooter_t.update( self, dt )
  local anglepad = math.pi / 16.0
  local rotdir = util.clamp( self._rotdir, -1.0, 1.0 )

  local newshotangle = self._shotangle + dt * rotdir * self._rotspeed
  self._shotangle = util.clamp( newshotangle, anglepad, math.pi - anglepad )
end

function shooter_t.draw( self, canvas )
  local gvector = ( self._len / (2.0 * self._shotspeed) ) * self:tovector()

  canvas.push()
  canvas.translate( self._pos:xy() )

  canvas.setLineWidth( 1.0e-1 )
  canvas.setColor( util.unpack(UICOLOR) )
  canvas.line( -gvector.x, -gvector.y, gvector.x, gvector.y )
  canvas.pop()
end

function shooter_t.rotate( self, rotdir )
  self._rotdir = self._rotdir + rotdir
end

function shooter_t.tovector( self )
  return self._shotspeed * vector_t( math.cos(self._shotangle), math.sin(self._shotangle) )
end

return shooter_t
