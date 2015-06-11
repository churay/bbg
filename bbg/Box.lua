local Class = require( "Class" )
local Vector = require( "Vector" )
local Box = Class()

--[[ Constructors ]]--

function Box._init( self, minx, miny, width, height )
  self._min = Vector( minx, miny )
  self._width = width
  self._height = height
end

--[[ Operator Overloads ]]--

function Box.__eq( self, box )
  return self._min == box._min and self._width == box._width and self._height == box._height
end

function Box.__tostring( self )
  local posstring = tostring( self._min )
  local dimstring = "( " .. self._width .. ", " .. self._height .. " )"

  return "Box( " .. posstring .. ", " .. dimstring .. " )"
end

--[[ Public Functions ]]--

-- TODO(JRC): Implement more useful axis-aligned rectangle functions here.

function Box.intersects( self, box )
  local mpos = self:getmin(); local opos = box:getmin()

  -- TODO(JRC): Fix this.
  return 2.0 * math.abs( mpos:getx() - opos:getx() ) < self:getw() + box:getw() and
    2.0 * math.abs( mpos:gety() - opos:gety() ) < self:geth() + box:geth()
end

--[[ Accessor Functions ]]--

function Box.getmin( self ) return self._min end
function Box.getmax( self ) return self._min + Vector( self._width, self._height ) end
function Box.getw( self ) return self._width end
function Box.geth( self ) return self._height end

return Box
