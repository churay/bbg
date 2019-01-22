local Class = require( "Class" )

local Queue = require( "Queue" )
local Vector = require( "Vector" )
local Bubble = require( "Bubble" )

local BubbleQueue = Class()

--[[ Constructors ]]--

function BubbleQueue._init( self, pos, seed, startlength )
  local pos = pos or Vector( 0.0, 0.0 )
  local seed = seed or os.time()
  local startlength = startlength or 0

  self._pos = pos
  self._queue = Queue()
  self._rng = love.math.newRandomGenerator( seed )

  for queueidx = 1, startlength do self:enqueue() end
end

--[[ Public Functions ]]--

function BubbleQueue.update( self, dt )
  
end

function BubbleQueue.draw( self, canvas )
  canvas.push()
  canvas.translate( self._pos:getxy() )

  for _, bubble in ipairs( self._queue:tolist() ) do
    bubble:draw( canvas )
  end

  canvas.pop()
end

function BubbleQueue.enqueue( self )
  -- TODO(JRC): Change this to an apply function for the sake of efficiency.
  for _, bubble in ipairs( self._queue:tolist() ) do
    bubble._pos = bubble._pos + Vector( 1.0, 0.0 )
  end

  local newpos = Vector( 0.5, 0.5 )
  local newbubble = Bubble( newpos, nil, self._rng:random(#Bubble.COLORS) )
  self._queue:enqueue( newbubble )
end

function BubbleQueue.dequeue( self, doreplace )
  if doreplace or false then self:enqueue() end
  return self._queue:dequeue()
end

function BubbleQueue.dequeueall( self, doreplace )
  local bubblequeue = {}
  for i = 1, self:length() do table.insert( bubblequeue, self:dequeue(doreplace) ) end
  return bubblequeue
end

--[[ Accessor Functions ]]--

function BubbleQueue.length( self ) return self._queue:length() end

--[[ Private Functions ]]--

return BubbleQueue
