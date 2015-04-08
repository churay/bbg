local assert = require( "luassert" )
local say = require( "say" )

local function nearlyequal( state, arguments )
  local expectednumber = arguments[1]
  local actualnumber = arguments[2]
  local epsilon = arguments[3] or 1e-7

  return math.abs( expectednumber - actualnumber ) < epsilon
end

say:set_namespace( "en" )

say:set( "assertion.are.nearlyequal",
  "Expected numbers to be nearly equal.\n" ..
  "Expected:\n%s\nPassed In:\n%s\nEpsilon:\n%s" )
say:set( "assertion.are_not.nearlyequal",
  "Expected numbers to be sufficiently different.\n" ..
  "Expected:\n%s\nPassed In:\n%s\nEpsilon:\n%s" )

assert:register( "assertion", "nearlyequal", nearlyequal,
  "assertion.are.nearlyequal", "assertion.are_not.nearlyequal" )
