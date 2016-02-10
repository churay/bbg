local Utility = {}

function Utility.inrange( v, min, max, exclusive )
  if exclusive then return min < v and v < max
  else return min <= v and v <= max end
end

function Utility.clamp( v, min, max )
  return math.max( math.min(v, max), min )
end

-- The following function needs to be implemented to facilitate string splitting
-- (see http://lua-users.org/wiki/SplitJoin for details).

function Utility.split( str, sep )
  local sep = sep or "%s"
  local splitlist = {}
  for substr in string.gmatch( str, "([^" .. sep .. "]+)" ) do
    table.insert( splitlist, substr )
  end
  return splitlist
end

function Utility.keyof( v, t )
  local k = nil
  for tk, tv in pairs( t ) do
    if tv == v then k = tk end
  end
  return k
end

function Utility.any( t, truefxn )
  local numtrue = 0
  for k, v in pairs( t ) do
    if truefxn( k, v ) then numtrue = numtrue + 1 end
  end
  return numtrue > 0
end

-- The following function needs to be implemented to determine the number of
-- keys in an arbitrary table (see http://stackoverflow.com/a/2705804).

function Utility.len( t )
  local len = 0
  for _ in pairs( t ) do len = len + 1 end
  return len
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
