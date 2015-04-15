local assert = require( "luassert" )
local say = require( "say" )

local function nearlyequal( state, arguments )
  local expectednumber = arguments[1]
  local actualnumber = arguments[2]
  local epsilon = arguments[3] or 1e-7

  return math.abs( expectednumber - actualnumber ) < epsilon
end

local function equivalentlists( state, arguments )
  local expectedlist = arguments[1]
  local actuallist = arguments[2]

  for _, expectedvalue in ipairs( expectedlist ) do
    local expectedexists = false
    for _, actualvalue in ipairs( actuallist ) do
      expectedexists = expectedexists or expectedvalue == actualvalue
    end
    if not expectedexists then return false end
  end

  return #expectedlist == #actuallist
end

say:set_namespace( "en" )

say:set( "assertion.are.nearlyequal",
  "Expected numbers to be nearly equal.\n" ..
  "Expected:\n%s\nPassed In:\n%s\nEpsilon:\n%s" )
say:set( "assertion.are_not.nearlyequal",
  "Expected numbers to be sufficiently different.\n" ..
  "Expected:\n%s\nPassed In:\n%s\nEpsilon:\n%s" )

say:set( "assertion.are.equivalentlists",
  "Expected lists to be contain the same elements.\n" ..
  "Expected:\n%s\nPassed In:\n%s" )
say:set( "assertion.are_not.equivalentlists",
  "Expected lists to contain at least one differing element.\n" ..
  "Expected:\n%s\nPassed In:\n%s" )

assert:register( "assertion", "nearlyequal", nearlyequal,
  "assertion.are.nearlyequal", "assertion.are_not.nearlyequal" )
assert:register( "assertion", "equivalentlists", equivalentlists,
  "assertion.are.equivalentlists", "assertion.are_not.equivalentlists" )
