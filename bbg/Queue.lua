local Class = require( "Class" )
local Queue = Class()

--[[ Constructors ]]--

function Queue._init( self )
  self._entries = {}

  self._startidx = 1
  self._endidx = 0
end

--[[ Operator Overloads ]]--

function Queue.__eq( self, other )
  local selflist = self:tolist(); local otherlist = other:tolist()

  if self:length() ~= other:length() then
    return false
  else
    local listsequal = true
    for entryidx = 1, self:length(), 1 do
      listsequal = listsequal and selflist[entryidx] == otherlist[entryidx]
    end
    return listsequal
  end
end

--[[ Public Functions ]]--

function Queue.enqueue( self, entry )
  self._endidx = self._endidx + 1
  table.insert( self._entries, self._endidx, entry )
end

function Queue.dequeue( self )
  self._startidx = self._startidx + 1
  return table.remove( self._entries, self._startidx - 1 )
end

function Queue.peek( self )
  return self._entries[self._startidx]
end

function Queue.length( self )
  return self._endidx - self._startidx + 1
end

function Queue.clear( self )
  for key, _ in pairs( self._entries ) do
    self._entries[key] = nil
  end

  self._startidx = 1
  self._endidx = 0
end

function Queue.tolist( self )
  local queuelist = {}

  for entryidx = self._startidx, self._endidx, 1 do
    table.insert( queuelist, self._entries[entryidx] )
  end

  return queuelist
end

return Queue
