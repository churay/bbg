local Graph = require( "bbg.Graph" )

describe( "Graph", function()
  --[[ Testing Variables ]]--

  local testgraph = nil
  local testvertices = nil
  local testedges = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    -- Test Graph Diagram:
    --   +---->3-----+
    --   |     |     |
    --   |     |     v
    --   2     |     5    1
    --   |     |     ^
    --   |     v     |
    --   +---->4-----+
    testgraph = Graph()

    testvertices = {}
    for vertexidx = 1, 5, 1 do
      local vertex = testgraph:addvertex( tostring(vertexidx) )
      table.insert( testvertices, vertex )
    end

    testedges = {}
    local edgepairs = { {2, 3}, {2, 4}, {3, 5}, {4, 5}, {3, 4} }
    for _, ep in ipairs( edgepairs ) do
      -- TODO(JRC): Add labels to each of the edges that correspond to the
      -- vertices that they join.
      local edge = testgraph:addedge( testvertices[ep[1]], testvertices[ep[2]] )
      table.insert( testedges, edge )
    end
  end )

  after_each( function()
    testgraph = nil
    testvertices = nil
    testedges = nil
  end )

  --[[ Testing Functions ]]--

  it( "constructs instances that are initially empty", function()
    local emptygraph = Graph()

    assert.are.equal( 0, #emptygraph:queryvertices() )
    assert.are.equal( 0, #emptygraph:queryedges() )
  end )

  it( "returns only existing vertices queried via 'findvertex'", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  it( "returns only existing edges queried via 'findedge'", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  it( "properly adds vertices to the data structure", function()
    for vertexidx, vertex in ipairs( testvertices ) do
      assert.is_true( vertex:isa(Graph.Vertex) )
      assert.are.equal( tostring(vertexidx), vertex:getlabel() )
    end

    assert.are.equal( #testvertices, #testgraph:queryvertices() )
  end )

  it( "properly adds new edges to the data structure", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  it( "only allows adding edges with valid start/end vertices", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  it( "overwrites existing edges on edge readd", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  it( "properly removes vertices from the data structure", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  it( "removes all edges attached to a vertex upon its removal", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  it( "properly removes edges from the data structure", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  -- TODO(JRC): Consider renaming the following two tests to make
  -- it more clear that the tests are verifiying that the results
  -- make sense within the context of the graph being queried.

  it( "facilitates arbitrary vertex queries with 'queryvertices'", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  it( "facilitates arbitrary edge queries with 'queryedges'", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

end )
