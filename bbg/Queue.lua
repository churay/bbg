local Class = require( "Class" )
local Queue = Class()

-- TODO(JRC): Optimize this class so that dequeue operations occur in constant time.

--[[ Constructors ]]--

function Queue._init( self )
  self._entries = {}
end

--[[ Operator Overloads ]]--

function Queue.__eq( self, queue )
  return false
end

function Queue.__tostring( self )
  local queuestring = ""

  queuestring = queuestring .. "< "
  for _, entry in ipairs( self:tolist() ) do
    queuestring = queuestring .. tostring( entry ) .. ", "
  end
  queuestring = queuestring .. ">"

  return queuestring
end

--[[ Public Functions ]]--

function Queue.enqueue( self, entry )
  table.insert( self._entries, entry )
end

function Queue.dequeue( self )
  return table.remove( self._entries, 1 )
end

function Queue.peek( self )
  return self._entries[1]
end

function Queue.clear( self )
  for key, _ in pairs( self._entries ) do
    self._entries[key] = nil
  end
end

function Queue.tolist( self )
  local queuelist = {}

  for _, entry in ipairs( self._entries ) do
    table.insert( queuelist, entry )
  end

  return queuelist
end

return Queue
