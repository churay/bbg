local Queue = require( "bbg.Queue" )

describe( "Queue", function()
  --[[ Testing Constants ]]--

  local TEST_QUEUE_VALUES = { 1, 2, 3 }

  --[[ Testing Variables ]]--

  local testqueue = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testqueue = Queue()

    for _, queuevalue in ipairs( TEST_QUEUE_VALUES ) do
      testqueue:enqueue( queuevalue )
    end
  end )

  after_each( function()
    testqueue = nil
  end )

  --[[ Testing Functions ]]--

  it( "inserts values at the front of its list on enqueue", function()
    pending( "TODO(JRC): Implement this test case!" )
    assert.are.equal( 0, testvar )
  end )

  it( "removes values from the front of its list on dequeue", function()
    pending( "TODO(JRC): Implement this test case!" )
    assert.are.equal( 0, testvar )
  end )

  it( "supports arbitrary sequences of enqueue/dequeue operations", function()
    pending( "TODO(JRC): Implement this test case!" )
    assert.are.equal( 0, testvar )
  end )

  it( "allows its first value to be viewed and not removed with peek", function()
    pending( "TODO(JRC): Implement this test case!" )
    assert.are.equal( 0, testvar )
  end )

  it( "returns the correct value when queried for its length", function()
    pending( "TODO(JRC): Implement this test case!" )
    assert.are.equal( 0, testvar )
  end )

  it( "can be purged through the use of the clear operation", function()
    pending( "TODO(JRC): Implement this test case!" )
    assert.are.equal( 0, testvar )
  end )

  it( "properly indicates that queues with different values are unequal", function()
    pending( "TODO(JRC): Implement this test case!" )
    assert.are.equal( 0, testvar )
  end )

  it( "indicates that queues with the same values and orderings are equal", function()
    pending( "TODO(JRC): Implement this test case!" )
    assert.are.equal( 0, testvar )
  end )

end )
