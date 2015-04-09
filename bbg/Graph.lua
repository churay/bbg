local Class = require( "Class" )
local Graph = Class()

-- TODO(JRC): It would probably be good to have an option to shallow or deep
-- copy the labels for vertices/edges in the graph.

--[[ Constructors ]]--

function Graph._init( self )
  self._vertices = {}
  self._edges = { labels = {}, outgoing = {}, incoming = {} }

  -- TODO(JRC): Remove this somehow (create utility generate id function?)!
  self._nextvid = 0
end

--[[ Operator Overloads ]]--

function Graph.__eq( self, graph )
  return false
end

function Graph.__tostring( self )
  return ""
end

--[[ Public Functions ]]--

function Graph.addvertex( self, vlabel )
  local vid = self:_getnextvid()

  self._vertices[vid] = vlabel
  self._edges.labels[vid] = {}
  self._edges.outgoing[vid] = {}
  self._edges.incoming[vid] = {}

  return GraphVertex( self, vid )
end

function Graph.addedge( self, srcvertex, dstvertex, elabel )
  if self:findvertex( srcvertex ) and self:findvertex( dstvertex ) then
    -- TODO(JRC): Remove the edge if it already exists.

    local srcvid = srcvertex._vid; local dstvid = dstvertex._vid
    self._edges.labels[srcvid][dstvid] = elabel
    self._edges.outgoing[srcvid][dstvid] = true
    self._edges.incoming[dstvid][srcvid] = true

    return GraphEdge( self, srcvid, dstvid )
  end

  return nil
end

function Graph.removevertex( self, vertex )
  
end

function Graph.removeedge( self, edge )
  -- TODO(JRC): Accept edge as GraphEdge or { src: Vert, dst: Vert }.
end

function Graph.findvertex( self, vertex )
  if self == vertex._graph and self._vertices[vertex._vid] ~= nil then
    return GraphVertex( self, vertex._vid )
  else
    return nil
  end
end

function Graph.findedge( self, srcvrepr, dstvrepr )
  return nil
end

--[[ Private Functions ]]--

function Graph._getnextvid( self )
  local nextvid = self._nextvid
  self._nextvid = self._nextvid + 1
  return nextvid
end

--[[ Private Classes ]]--

local GraphVertex = Class()

function GraphVertex._init( self, graph, vid )
  self._graph = graph
  self._vid = vid
end

function GraphVertex.getlabel( self )
  return self._graph.getvertexlabel( self )
end

function GraphVertex.getoutedges( self )
  return {}
end

function GraphVertex.getinedges( self )
  return {}
end

local GraphEdge = Class()

function GraphEdge._init( self, graph, srcvid, dstvid )
  self._graph = graph
  self._srcvid = srcvid
  self._dstvid = dstvid
end

function GraphEdge.getlabel( self )
  return self._graph.getedgelabel( self )
end

function GraphEdge.getsource( self )
  return self._graph.getvertex( self.srcvid )
end

function GraphEdge.getsource( self )
  return self._graph.getvertex( self.dstvid )
end

return Graph
