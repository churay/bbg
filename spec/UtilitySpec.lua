local Utility = require( "bbg.Utility" )

describe( "Utility", function()
  --[[ Testing Functions ]]--

  it( "clamps values outside of the given range to the closest value", function()
    local minimum = 0.0
    local maximum = 1.0

    assert.are.equal( minimum, Utility.clamp(minimum - 1.0, minimum, maximum) )
    assert.are.equal( maximum, Utility.clamp(maximum + 1.0, minimum, maximum) )
  end )

  it( "doesn't change a clamped value that lies in the given range", function()
    local minimum = 0.0
    local maximum = 1.0
    local rangevalue = ( minimum + maximum ) / 2.0

    assert.are.equal( rangevalue, Utility.clamp(rangevalue, minimum, maximum) )
  end )

  it( "supports variable arguments packing", function()
    local nonilsvargs = Utility.packvargs( 1, 2, 3 )

    assert.are.equal( 3, nonilsvargs.n )
    for i = 1, 3 do assert.are.equal( i, nonilsvargs[i] ) end
  end )

  it( "supports variable arguments packing with nil values", function()
    local nilsvargs = Utility.packvargs( nil, 2, nil, 4 )

    assert.are.equal( 4, nilsvargs.n )
    for i = 1, 4 do
      local expectedargval = i % 2 == 0 and i or nil
      assert.are.equal( expectedargval, nilsvargs[i] )
    end
  end )

  it( "supports unpacking a variable argument pack", function()
    local packandunpack = function( ... )
      return Utility.unpackvargs( Utility.packvargs(...) )
    end

    local p1, p2, p3, p4 = packandunpack( 1, nil, 3 )

    assert.are.equal( 1, p1 )
    assert.are.equal( nil, p2 )
    assert.are.equal( 3, p3 )
    assert.are.equal( nil, p4 )
  end )

end )
