require( "bustedext" )
local Queue = require( "bbg.Queue" )

describe( "Queue", function()
  --[[ Testing Constants ]]--

  local TEST_QUEUE_VALUES = { 1, 2, 3 }

  --[[ Testing Variables ]]--

  local testqueue = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testqueue = Queue()

    for validx = 1, #TEST_QUEUE_VALUES, 1 do
      testqueue:enqueue( TEST_QUEUE_VALUES[validx] )
    end
  end )

  after_each( function()
    testqueue = nil
  end )

  --[[ Testing Functions ]]--

  it( "inserts values at the front of its list on enqueue", function()
    assert.are.equivalentlists( TEST_QUEUE_VALUES, testqueue:tolist(), false )
  end )

  it( "removes values from the front of its list on dequeue", function()
    for frontvalidx = 1, #TEST_QUEUE_VALUES do
      assert.are.equal( TEST_QUEUE_VALUES[frontvalidx], testqueue:dequeue() )
      assert.are.equivalentlists(
        { select(frontvalidx + 1, unpack(TEST_QUEUE_VALUES)) },
        testqueue:tolist(), false
      )
    end
  end )

  it( "supports arbitrary sequences of enqueue/dequeue operations", function()
    for i = 1, 2 do testqueue:dequeue() end
    for i = TEST_QUEUE_VALUES[3] + 1, TEST_QUEUE_VALUES[3] + 5 do testqueue:enqueue( i ) end
    for i = 1, 4 do testqueue:dequeue() end

    local expectedsequence = { TEST_QUEUE_VALUES[3] + 4, TEST_QUEUE_VALUES[3] + 5 }
    assert.are.equivalentlists( expectedsequence, testqueue:tolist(), false )
  end )

  it( "allows its first value to be viewed and not removed with peek", function()
    for frontvalidx = 1, #TEST_QUEUE_VALUES - 1 do
      assert.are.equal( TEST_QUEUE_VALUES[frontvalidx], testqueue:peek() )
      assert.are.equivalentlists(
        { select(frontvalidx, unpack(TEST_QUEUE_VALUES)) },
        testqueue:tolist(), false
      )
      testqueue:dequeue()
    end
  end )

  it( "returns the correct value when queried for its length", function()
    for numdequeues = 0, #TEST_QUEUE_VALUES do
      assert.are.equal( #TEST_QUEUE_VALUES - numdequeues, testqueue:length() )
      testqueue:dequeue()
    end
  end )

  it( "can be purged through the use of the clear operation", function()
    testqueue:clear()
    assert.are.equivalentlists( {}, testqueue:tolist(), false )
  end )

  it( "properly indicates that queues with different values are unequal", function()
    local blankqueue = Queue()
    assert.are_not.equal( testqueue, blankqueue )

    local invertedqueue = Queue()
    for validx = #TEST_QUEUE_VALUES, 1, -1 do
      invertedqueue:enqueue( TEST_QUEUE_VALUES[validx] )
    end
    assert.are_not.equal( testqueue, invertedqueue )
  end )

  it( "indicates that queues with the same values and orderings are equal", function()
    assert.are.equal( testqueue, testqueue )

    local copyqueue = Queue()
    for i = 1, testqueue:length() do copyqueue:enqueue( i + 20 ) end
    for i = 1, copyqueue:length() do copyqueue:dequeue() end
    for _, queueval in ipairs( testqueue:tolist() ) do copyqueue:enqueue( queueval ) end
    assert.are.equal( testqueue, copyqueue )
  end )

end )
