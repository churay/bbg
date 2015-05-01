local Class = require( "Class" )
local Utility = require( "Utility" )
local Graph = Class()

-- TODO(JRC): It would probably be good to have an option to shallow or deep
-- copy the labels for vertices/edges in the graph.

--[[ Constructors ]]--

function Graph._init( self )
  self._vertices = {}
  self._edges = { labels = {}, outgoing = {}, incoming = {} }

  self._nextvid = 1
end

--[[ Public Functions ]]--

function Graph.addvertex( self, vlabel )
  local vid = self:_getnextvid()
  local vlabel = vlabel == nil and true or vlabel

  self._vertices[vid] = vlabel
  self._edges.labels[vid] = {}
  self._edges.outgoing[vid] = {}
  self._edges.incoming[vid] = {}

  return Graph.Vertex( self, vid )
end

-- TODO(JRC): Add an option for adding bidirectional edges.
function Graph.addedge( self, srcvertex, dstvertex, elabel )
  if self:findvertex( srcvertex ) and self:findvertex( dstvertex ) then
    if self:findedge( srcvertex, dstvertex ) then
      self:removeedge( srcvertex, dstvertex )
    end

    local srcvid = srcvertex._vid; local dstvid = dstvertex._vid
    local elabel = elabel == nil and true or elabel
    self._edges.labels[srcvid][dstvid] = elabel
    self._edges.outgoing[srcvid][dstvid] = true
    self._edges.incoming[dstvid][srcvid] = true

    return Graph.Edge( self, srcvid, dstvid )
  end
end

function Graph.removevertex( self, vertex )
  local vertex = self:findvertex( vertex )
  if vertex then
    for _, ie in ipairs( vertex:getinedges() ) do self:removeedge( ie ) end
    for _, oe in ipairs( vertex:getoutedges() ) do self:removeedge( oe ) end

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

  local arg = Utility.packvargs( ... )
  if arg.n == 1 then edge = arg[1]
  elseif arg.n == 2 then edge = Graph.Edge( self, arg[1]._vid, arg[2]._vid )
  else edge = nil end

  if edge and self == edge._graph and
    self._edges.outgoing[edge._srcvid] ~= nil and 
    self._edges.outgoing[edge._srcvid][edge._dstvid] ~= nil then
    return edge
  end
end

function Graph.queryvertices( self, queryfxn )
  local queriedvertices = {}
  local queryfxn = queryfxn or function( v ) return true end

  for vid, vlabel in pairs( self._vertices ) do
    local vertex = Graph.Vertex( self, vid )
    if queryfxn( vertex ) then table.insert( queriedvertices, vertex ) end
  end

  return queriedvertices
end

function Graph.queryedges( self, queryfxn )
  local queriededges = {}
  local queryfxn = queryfxn or function( e ) return true end

  for srcvid, srcverttoedges in pairs( self._edges.labels ) do
    for dstvid, elabel in pairs( srcverttoedges ) do
      local edge = Graph.Edge( self, srcvid, dstvid )
      if queryfxn( edge ) then table.insert( queriededges, edge ) end
    end
  end

  return queriededges
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

  for dstvid in pairs( self._graph._edges.outgoing[self._vid] ) do
    local dstvertex = Graph.Vertex( self._graph, dstvid )
    table.insert( outedges, self._graph:findedge(self, dstvertex) )
  end

  return outedges
end

function Graph.Vertex.getinedges( self )
  local inedges = {}

  for srcvid in pairs( self._graph._edges.incoming[self._vid] ) do
    local srcvertex = Graph.Vertex( self._graph, srcvid )
    table.insert( inedges, self._graph:findedge(srcvertex, self) )
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
