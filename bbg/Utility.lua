local Utility = {}

function Utility.inrange( v, min, max, exclusive )
  if exclusive then return min < v and v < max
  else return min <= v and v <= max end
end

function Utility.clamp( v, min, max )
  return math.max( math.min(v, max), min )
end

-- The following two functions were taken from standard Lua 5.1 workarounds
-- listed at http://lua-users.org/wiki/VarargTheSecondClassCitizen.

function Utility.packvargs( ... )
  return { n = select("#", ...), ... }
end

function Utility.unpackvargs( vargs )
  return unpack( vargs, 1, vargs.n )
end

return Utility
