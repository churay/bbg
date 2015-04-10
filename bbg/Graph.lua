local Class = require( "Class" )
local Graph = Class()

-- TODO(JRC): It would probably be good to have an option to shallow or deep
-- copy the labels for vertices/edges in the graph.

--[[ Constructors ]]--

function Graph._init( self )
  self._vertices = {}
  self._edges = { labels = {}, outgoing = {}, incoming = {} }

  -- TODO(JRC): Remove this somehow (create utility generate id function?)!
  self._nextvid = 1
end

--[[ Public Functions ]]--

function Graph.addvertex( self, vlabel )
  local vid = self:_getnextvid()

  self._vertices[vid] = vlabel
  self._edges.labels[vid] = {}
  self._edges.outgoing[vid] = {}
  self._edges.incoming[vid] = {}

  return Graph.Vertex( self, vid )
end

function Graph.addedge( self, srcvertex, dstvertex, elabel )
  if self:findvertex( srcvertex ) and self:findvertex( dstvertex ) then
    if self:findedge( srcvertex, dstvertex ) then
      self:removeedge( srcvertex, dstvertex )
    end

    local srcvid = srcvertex._vid; local dstvid = dstvertex._vid
    self._edges.labels[srcvid][dstvid] = elabel
    self._edges.outgoing[srcvid][dstvid] = true
    self._edges.incoming[dstvid][srcvid] = true

    return Graph.Edge( self, srcvid, dstvid )
  end
end

function Graph.removevertex( self, vertex )
  local vertex = self:findvertex( vertex )
  if vertex then
    for vinedge in vertex:getinedges() do self:removeedge( vinedge ) end
    for voutedge in vertex:getoutedges() do self:removeedge( voutedge ) end

    local vid = vertex._vid
    self._vertices[vid] = nil
    self._edges.labels[vid] = nil
    self._edges.outgoing[vid] = nil
    self._edges.incoming[vid] = nil
  end
end

function Graph.removeedge( self, ... )
  local edge = self:findedge( ... )
  if edge then
    self._edges.labels[edge._srcvid][edge._dstvid] = nil
    self._edges.outgoing[edge._srcvid][edge._dstvid] = nil
    self._edges.incoming[edge._dstvid][edge._srcvid] = nil
  end
end

function Graph.findvertex( self, vertex )
  if self == vertex._graph and self._vertices[vertex._vid] ~= nil then
    return vertex
  end
end

function Graph.findedge( self, ... )
  local edge = nil
  if arg.n == 1 then edge = arg[1]
  elseif arg.n == 2 then edge = Graph.Edge( self, arg[1]._vid, arg[2]._vid )
  else edge = nil end

  if edge and self == edge._graph and
    self._edges.outgoing[edge._srcvid] ~= nil and 
    self._edges.outgoing[edge._srcvid][edge._dstvid] ~= nil then
    return edge
  end
end

--[[ Private Functions ]]--

function Graph._getnextvid( self )
  local nextvid = self._nextvid
  self._nextvid = self._nextvid + 1
  return nextvid
end

--[[ Private Classes ]]--

Graph.Vertex = Class()

function Graph.Vertex._init( self, graph, vid )
  self._graph = graph
  self._vid = vid
end

function Graph.Vertex.__eq( self, vertex )
  return self._graph == vertex._graph and self._vid == vertex._vid
end

function Graph.Vertex.getlabel( self )
  return self._graph._vertices[self._vid] 
end

function Graph.Vertex.getoutedges( self )
  local outedges = {}

  for dstvid in self._graph.outgoing[self._vid] do
    local dstvertex = Graph.Vertex( self._graph, dstvid )
    table.insert( outedges, self._graph:findedge(self, dstvertex) )
  end

  return outedges
end

function Graph.Vertex.getinedges( self )
  local inedges = {}

  for dstvid in self._graph.incoming[self._vid] do
    local dstvertex = Graph.Vertex( self._graph, dstvid )
    table.insert( inedges, self._graph:findedge(dstvertex, self) )
  end

  return inedges
end

Graph.Edge = Class()

function Graph.Edge._init( self, graph, srcvid, dstvid )
  self._graph = graph
  self._srcvid = srcvid
  self._dstvid = dstvid
end

function Graph.Edge.__eq( self, edge )
  return self._graph == edge._graph and self._srcvid == edge._srcvid and 
    self._dstvid == edge._dstvid
end

function Graph.Edge.getlabel( self )
  return self._graph._edges.labels[self._srcvid][self._dstvid]
end

function Graph.Edge.getsource( self )
  return self._graph:findvertex( Graph.Vertex(self._graph, self._srcvid) )
end

function Graph.Edge.getdestination( self )
  return self._graph:findvertex( Graph.Vertex(self._graph, self._dstvid) )
end

return Graph
