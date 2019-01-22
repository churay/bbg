local struct = require( 'bbg.struct' )

--[[ Constructors ]]--

local queue_t = struct( {}, '_entries', {}, '_startidx', 1, '_endidx', 0 )

--[[ Operator Overloads ]]--

function queue_t.__eq( self, other )
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

function queue_t.enqueue( self, entry )
  self._endidx = self._endidx + 1
  self._entries[self._endidx] = entry
end

function queue_t.dequeue( self )
  local dequeuedvalue = self._entries[self._startidx]
  self._entries[self._startidx] = nil
  self._startidx = self._startidx + 1
  return dequeuedvalue
end

function queue_t.peek( self )
  return self._entries[self._startidx]
end

function queue_t.length( self )
  return self._endidx - self._startidx + 1
end

function queue_t.clear( self )
  for key, _ in pairs( self._entries ) do
    self._entries[key] = nil
  end

  self._startidx = 1
  self._endidx = 0
end

function queue_t.tolist( self )
  local queuelist = {}

  for entryidx = self._startidx, self._endidx, 1 do
    table.insert( queuelist, self._entries[entryidx] )
  end

  return queuelist
end

return queue_t
