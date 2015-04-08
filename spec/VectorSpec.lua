require( "bustedext" )
local Vector = require( "bbg.Vector" )

describe( "Vector", function()
  --[[ Testing Constants ]]--

  local TEST_VECTOR_X = 1
  local TEST_VECTOR_Y = 2

  --[[ Testing Variables ]]--

  local testvector = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testvector = Vector( TEST_VECTOR_X, TEST_VECTOR_Y )
  end )

  after_each( function()
    testvector = nil
  end )

  --[[ Testing Functions ]]--

  it( "constructor initializes vector components", function()
    assert.are.equal( TEST_VECTOR_X, testvector:getx() )
    assert.are.equal( TEST_VECTOR_Y, testvector:gety() )
  end )

  it( "add operator properly adds vectors", function()
    local addvector = testvector + testvector

    assert.are.equal( 2*TEST_VECTOR_X, addvector:getx() )
    assert.are.equal( 2*TEST_VECTOR_Y, addvector:gety() )
  end )

  it( "subtraction operator properly subtracts vectors", function()
    local subvector = testvector - testvector

    assert.are.equal( 0, subvector:getx() )
    assert.are.equal( 0, subvector:gety() )
  end )

  it( "multiplication operator supports scalar multiplication", function()
    local mulscalar = 10.0

    local mulvector = mulscalar * testvector
    assert.are.equal( mulscalar*TEST_VECTOR_X, mulvector:getx() )
    assert.are.equal( mulscalar*TEST_VECTOR_Y, mulvector:gety() )

    local revmulvector = testvector * mulscalar
    assert.are.equal( mulscalar*TEST_VECTOR_X, revmulvector:getx() )
    assert.are.equal( mulscalar*TEST_VECTOR_Y, revmulvector:gety() )
  end )

  it( "unary subtraction operator properly inverts vectors", function()
    local negvector = -testvector

    assert.are.equal( -1*TEST_VECTOR_X, negvector:getx() )
    assert.are.equal( -1*TEST_VECTOR_Y, negvector:gety() )
  end )

  it( "equality operator only returns true for like vectors", function()
    local diffvector = Vector( TEST_VECTOR_Y, TEST_VECTOR_X )
    local equivvector = Vector( TEST_VECTOR_X, TEST_VECTOR_Y )

    assert.are.equal( testvector, testvector )
    assert.are.equal( equivvector, testvector )
    assert.are_not.equal( diffvector, testvector )
  end )

  it( "angle operator returns the proper angle between vectors", function()
    assert.are.nearlyequal( 0, testvector:angleto(testvector) )
    assert.are.nearlyequal( math.pi/2, Vector(1, 0):angleto(Vector(0, 1)) )
    assert.are.nearlyequal( math.pi, Vector(1, 0):angleto(Vector(-1, 0)) )
  end )

  it( "normalize properly turns vector to a unit equivalent", function()
    local hugevector = Vector( 10, 0 )
    hugevector:normalize()
    assert.are.equal( 1, hugevector:getx() )
    assert.are.equal( 0, hugevector:gety() )
    assert.are.equal( 1, hugevector:magnitude() )

    local enormousvector = Vector( 300, 300 )
    enormousvector:normalize()
    assert.are.nearlyequal( math.sqrt(2)/2, enormousvector:getx() )
    assert.are.nearlyequal( math.sqrt(2)/2, enormousvector:gety() )
    assert.are.nearlyequal( 1, enormousvector:magnitude() )
  end )

end )
