require( "bustedext" )
local Graph = require( "bbg.Graph" )

describe( "Graph", function()
  --[[ Testing Variables ]]--

  local testgraph = nil
  local testvertices = nil
  local testedges = nil
  local testdiffgraph = nil

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
      local edge = testgraph:addedge( testvertices[ep[1]], testvertices[ep[2]],
        tostring(ep[1]) .. ">" .. tostring(ep[2])  )
      table.insert( testedges, edge )
    end

    -- Test AltGraph Diagram:
    --
    --   1---------->2
    --
    testaltgraph = Graph()
    testaltgraph:addedge( testaltgraph:addvertex("1"),
      testaltgraph:addvertex("2"), "1>2" )
  end )

  after_each( function()
    testgraph = nil
    testvertices = nil
    testedges = nil
    testaltgraph = nil
  end )

  --[[ Testing Functions ]]--

  it( "constructs instances that are initially empty", function()
    local emptygraph = Graph()

    assert.are.equivalentlists( {}, emptygraph:queryvertices() )
    assert.are.equivalentlists( {}, emptygraph:queryedges() )
  end )

  it( "properly adds vertices to the data structure", function()
    assert.are.equivalentlists( testvertices, testgraph:queryvertices() )

    for vertexidx, vertex in ipairs( testvertices ) do
      assert.is_true( vertex:isa(Graph.Vertex) )
      assert.are.equal( tostring(vertexidx), vertex:getlabel() )
    end
  end )

  it( "properly adds new edges to the data structure", function()
    assert.are.equivalentlists( testedges, testgraph:queryedges() )

    for edgeidx, edge in ipairs( testedges ) do
      assert.is_true( edge:isa(Graph.Edge) )
      assert.are.equal(
        edge:getsource():getlabel() .. ">" .. edge:getdestination():getlabel(),
        edge:getlabel()
      )
    end
  end )

  it( "doesn't allow adding edges with invalid start/end vertices", function()
    local remotevertices = testaltgraph:queryvertices()
    assert.falsy( testgraph:addedge(testvertices[1], remotevertices[2]) )
    assert.falsy( testgraph:addedge(remotevertices[1], testvertices[2]) )

    assert.are.equivalentlists( testedges, testgraph:queryedges() )
  end )

  it( "overwrites existing edges on edge readd", function()
    local overwriteedge = testgraph:queryedges()[1]
    local overwritesrc = overwriteedge:getsource()
    local overwritedst = overwriteedge:getdestination()

    local newelabel = "-" .. overwriteedge:getlabel() .. "-"
    local newedge = testgraph:addedge( overwritesrc, overwritedst, newelabel )

    assert.are.equal( newelabel, newedge:getlabel() )
    assert.are.equal( overwritesrc, newedge:getsource() )
    assert.are.equal( overwritedst, newedge:getdestination() )
  end )

  it( "properly removes vertices from the data structure", function()
    for testvertexidx = #testvertices, 1, -1 do 
      local testvertex = testvertices[testvertexidx]

      table.remove( testvertices, testvertexidx )
      testgraph:removevertex( testvertex )

      assert.are.equivalentlists( testvertices, testgraph:queryvertices() )
    end
  end )

  it( "removes all edges attached to a vertex upon its removal", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  it( "properly removes edges from the data structure", function()
    pending( "TODO(JRC): Implement this test case!" )
  end )

  it( "returns only existing vertices queried via 'findvertex'", function()
    for _, vertex in ipairs( testvertices ) do
      assert.are.equal( vertex, testgraph:findvertex(vertex) )
    end

    local remotevertex = testaltgraph:queryvertices()[1]
    assert.falsy( testgraph:findvertex(remotevertex) )
  end )

  it( "returns only existing edges queried via 'findedge'", function()
    for _, edge in ipairs( testedges ) do
      assert.are.equal( edge, testgraph:findedge(edge) )
    end

    local remoteedge = testaltgraph:queryedges()[1]
    assert.falsy( testgraph:findedge(remoteedge) )
  end )

  it( "supports 'findedge' edge queries using endpoint vertices", function()
    for _, edge in ipairs( testedges ) do
      local edgesrc = edge:getsource()
      local edgedst = edge:getdestination()
      assert.are.equal( edge, testgraph:findedge(edgesrc, edgedst) )
    end

    local remotevertices = testaltgraph:queryvertices()
    assert.falsy( testgraph:findedge(testvertices[1], testvertices[2]) )
    assert.falsy( testgraph:findedge(testvertices[1], remotevertices[2]) )
    assert.falsy( testgraph:findedge(remotevertices[1], remotevertices[2]) )
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
