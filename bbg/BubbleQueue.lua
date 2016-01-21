local Class = require( "Class" )

local Queue = require( "Queue" )
local Vector = require( "Vector" )
local Bubble = require( "Bubble" )

local BubbleQueue = Class()

--[[ Constructors ]]--

function BubbleQueue._init( self, pos, length, seed )
  local length = length or 1
  local seed = seed or os.time()

  self._queue = Queue()
  self._rng = love.math.newRandomGenerator( seed )
  self._pos = pos

  for queueidx = 1, length, 1 do self:_enqueue() end
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

function BubbleQueue.dequeue( self )
  self:_enqueue()
  return self._queue:dequeue()
end

--[[ Accessor Functions ]]--

--[[ Private Functions ]]--

function BubbleQueue._enqueue( self )
  -- TODO(JRC): Change this to an apply function for the sake of efficiency.
  for _, bubble in ipairs( self._queue:tolist() ) do
    bubble._pos = bubble._pos + Vector( 1.0, 0.0 )
  end

  local newpos = Vector( 0.5, 0.5 )
  local newbubble = Bubble( newpos, nil, self._rng:random(#Bubble.COLORS) )
  self._queue:enqueue( newbubble )
end

return BubbleQueue
