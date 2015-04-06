local Class = require( "Class" )
local Vector = Class()

--[[ Constructors ]]--

function Vector._init( self, xval, yval )
  self._x = xval
  self._y = yval
end

--[[ Operator Overloads ]]--

function Vector.__add( self, vector )
  return Vector( self._x + vector._x, self._y + vector._y )
end

function Vector.__sub( self, vector )
  return Vector( self._x - vector._x, self._y - vector._y )
end

function Vector.__mul( lvalue, rvalue )
  local self = nil; local scalar = nil

  if type( lvalue ) == "number" then 
    self = rvalue; scalar = lvalue 
  else
    self = lvalue; scalar = rvalue
  end

  return Vector( scalar * self._x, scalar * self._y )
end

function Vector.__unm( self )
  return Vector( -self._x, -self._y )
end

function Vector.__eq( self, vector )
  return self._x == vector._x and self._y == vector._y
end

function Vector.__tostring( self )
  return "Vector( " .. self._x .. ", " .. self._y .. " )"
end

--[[ Public Functions ]]--

function Vector.dot( self, vector )
  return self._x * vector._x + self._y * vector._y
end

function Vector.angleWith( self, vector )
  -- 0 == a.angleWith(b)
  -- a . b == |a||b|cos0
  -- 0 == acos( a . b / |a||b| )
  return 0.0
end

function Vector.magnitude( self )
  return math.sqrt( self:dot(self) )
end

function Vector.normalize( self )
  local magnitude = self:magnitude()

  self._x = self._x / magnitude
  self._y = self._y / magnitude
end

--[[ Private Functions ]]--



return Vector