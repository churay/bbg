local Graph = require( "bbg.Graph" )

describe( "Graph", function()
  --[[ Testing Variables ]]--

  local testgraph = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testgraph = Graph()

    testvertices = {}
    for vertexidx = 1, 5, 1 do
      local vertex = testgraph:addvertex( tostring(vlabel) )
      table.insert( testvertices, vertex )
    end

    testgraph:addedge( testvertices["2"], testvertices["3"] )
    testgraph:addedge( testvertices["2"], testvertices["4"] )
    testgraph:addedge( testvertices["3"], testvertices["5"] )
    testgraph:addedge( testvertices["4"], testvertices["5"] )
    testgraph:addedge( testvertices["3"], testvertices["4"] )
  end )

  after_each( function()
    testgraph = nil
  end )

  --[[ Testing Functions ]]--

  it( "works properly", function()
    assert.are.equal( true, true )
  end )

  --[[
  it( "add operator properly adds vectors", function()
    local addvector = testvector + testvector

    assert.are.equal( 2*TEST_VECTOR_X, addvector:getx() )
    assert.are.equal( 2*TEST_VECTOR_Y, addvector:gety() )
  end )
  ]]--

end )
