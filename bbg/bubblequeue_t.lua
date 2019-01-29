local struct = require( 'bbg.struct' )

local queue_t = require( 'bbg.queue_t' )
local vector_t = require( 'bbg.vector_t' )
local bubble_t = require( 'bbg.bubble_t' )

--[[ Constructors ]]--

local bubblequeue_t = struct( {},
  '_pos', vector_t(),
  '_rng', false,
  '_queue', queue_t()
)

function bubblequeue_t._init( self, pos, len, seed )
  local pos = pos or vector_t( 0.0, 0.0 )
  local len = len or 0
  local seed = seed or os.time()

  self._pos = pos
  self._rng = love.math.newRandomGenerator( seed )
  for queueidx = 1, len, 1 do self:enqueue() end
end

--[[ Public Functions ]]--

function bubblequeue_t.update( self, dt )
  
end

function bubblequeue_t.draw( self, canvas )
  canvas.push()
  canvas.translate( self._pos:getxy() )

  for _, bubble in ipairs( self._queue:tolist() ) do
    bubble:draw( canvas )
  end

  canvas.pop()
end

function bubblequeue_t.enqueue( self )
  for _, bubble in ipairs( self._queue:tolist() ) do
    bubble._pos:addip( vector_t(1.0, 0.0) )
  end

  local newpos = vector_t( 0.5, 0.5 )
  local newbubble = bubble_t( bubble_t.getnextcolorid(self._rng), newpos )
  self._queue:enqueue( newbubble )
end

function bubblequeue_t.dequeue( self, doreplace )
  if doreplace or false then self:enqueue() end
  return self._queue:dequeue()
end

function bubblequeue_t.dequeueall( self, doreplace )
  local bubblequeue = {}
  for i = 1, self:length() do table.insert( bubblequeue, self:dequeue(doreplace) ) end
  return bubblequeue
end

--[[ Accessor Functions ]]--

function bubblequeue_t.length( self ) return self._queue:length() end

--[[ Private Functions ]]--

return bubblequeue_t
