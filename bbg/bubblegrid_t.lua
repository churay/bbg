local struct = require( 'bbg.struct' )
local util = require( 'util' )
local config = require( 'bbg.config' )
local color = require( 'bbg.color' )

local vector_t = require( 'bbg.vector_t' )
local bbox_t = require( 'bbg.bbox_t' )
local bubble_t = require( 'bbg.bubble_t' )

local BGCOLOR = color.byname( 'lgray' )
local DEBUGCOLOR = { 1.0, 0.2, 0.0 } -- orange

--[[ Constructors ]]--

local bubblegrid_t = struct( {},
  '_bubblelist', {},
  '_bubblegrid', {},
  '_rowoffset', 0,
  '_gridbox', bbox_t(0.0, 0.0, 1.0, 1.0)
)

function bubblegrid_t._init( self, gridseed )
  self:loadfromseed( gridseed )
end

--[[ Public Functions ]]--

function bubblegrid_t.update( self, dt )
  for bubbleidx = #self._bubblelist, 1, -1 do
    local bubble = self._bubblelist[bubbleidx]

    local wallleftintx, wallrightintx = self:_getwallintx( bubble )
    if wallleftintx or wallrightintx then
      bubble:bounce()
    end

    local gridrowintx, gridcolintx = self:_getgridintx( bubble )
    if gridrowintx and gridcolintx then
      bubble:stop()

      self:addgridbubble( bubble, gridrowintx, gridcolintx )
      table.remove( self._bubblelist, bubbleidx )

      self:popgridbubble( gridrowintx, gridcolintx )
    end

    bubble:update( dt )
  end
end

function bubblegrid_t.draw( self, canvas )
  canvas.push()

  canvas.setColor( util.unpack(BGCOLOR) )
  canvas.rectangle( 'fill', 0.0, 0.0, self:getw(), self:geth() )

  for _, bubble in ipairs( self._bubblelist ) do bubble:draw( love.graphics ) end

  for _, cellrow, cellcol, bubble in self:_iteratecells() do
    if bubble ~= 0 then bubble:draw( canvas ) end

    if config.debug then
      local cellpos = self:_getcellpos( cellrow, cellcol )
      canvas.setColor( util.unpack(DEBUGCOLOR) )
      canvas.rectangle( 'line', cellpos.x, cellpos.y, 1.0, 1.0 )
    end
  end

  canvas.pop()
end

function bubblegrid_t.addbubble( self, bubble )
  table.insert( self._bubblelist, bubble )
end

function bubblegrid_t.addgridbubble( self, bubble, gridrow, gridcol )
  bubble._pos = self:_getcellpos( gridrow, gridcol ) + vector_t( 0.5, 0.5 )
  self._bubblegrid[gridrow][gridcol] = bubble
end

function bubblegrid_t.getgridbubble( self, gridrow, gridcol )
  return self._bubblegrid[gridrow] and self._bubblegrid[gridrow][gridcol]
end

function bubblegrid_t.addgridrow( self, rowbubbles )
  self._rowoffset = self._rowoffset + 1

  for gridrow = self:geth() + 1, 2, -1 do
    self._bubblegrid[gridrow] = self._bubblegrid[gridrow - 1]
    for gridcol = 1, self:getw() - self:_isrowshort( gridrow ) do
      local gridbubble = self:getgridbubble( gridrow, gridcol )
      if gridbubble ~= 0 then
        gridbubble._pos = gridbubble._pos + vector_t( 0.0, -1.0 )
      end
    end
  end

  local sentoffset = self:_isrowshort( 0 ) and 0.5 or -0.5
  for gridcol = 1, self:getw() - self:_isrowshort( 0 ) do
    local sentbubble = self:getgridbubble( 0, gridcol )
    sentbubble._pos = sentbubble._pos + vector_t( sentoffset, 0.0 )
  end

  self._bubblegrid[1] = {}
  for gridcol = 1, self:getw() - self:_isrowshort( 1 ) do
    self:addgridbubble( rowbubbles[gridcol], 1, gridcol )
  end
end

function bubblegrid_t.popgridbubble( self, gridrow, gridcol )
  local popbubble = self._bubblegrid[gridrow][gridcol]

  local function popnextfxn( r, c )
    local nextcells = {}
    for _, adjbubbleid in ipairs( self:_getadjbubbles(r, c) ) do
      local adjrow, adjcol = self:_getidcell( adjbubbleid )
      local adjbubble = self._bubblegrid[adjrow][adjcol]
      if popbubble:getcolorid() == adjbubble:getcolorid() then
        table.insert( nextcells, adjbubbleid )
      end
    end
    return nextcells
  end
  local function popqueryfxn( r, c )
    return popbubble:getcolorid() == self._bubblegrid[r][c]:getcolorid()
  end
  local bubblestopop = self:_querycells( { self:_getcellid(gridrow, gridcol) },
    popnextfxn, popqueryfxn )

  if util.len( bubblestopop ) >= 3 then
    for bubbleid, _ in pairs( bubblestopop ) do
      local bubblerow, bubblecol = self:_getidcell( bubbleid )
      self._bubblegrid[bubblerow][bubblecol] = 0
    end

    local rootbubbles = {}
    for rootcol = 1, self:getw() do
      local rootid = self:_getcellid( 1, rootcol )
      if self._bubblegrid[1][rootcol] ~= 0 then table.insert( rootbubbles, rootid ) end
    end

    local rootedbubbles = self:_querycells( rootbubbles,
      function( r, c ) return self:_getadjbubbles( r, c ) end,
      function( r, c ) return true end )
    local unrootedbubbles = self:_querycells( { 0 },
      function( r, c ) return self:_getadjcells( r, c ) end,
      function( r, c ) return rootedbubbles[self:_getcellid(r, c)] == nil end )

    for unrootedid, _ in pairs( unrootedbubbles ) do
      local unrootedrow, unrootedcol = self:_getidcell( unrootedid )
      self._bubblegrid[unrootedrow][unrootedcol] = 0
    end
  end
end

function bubblegrid_t.savetoseed( self, gridseed )
  local seedfilename = self:_getseedfilename( gridseed )
  local seedfile = love.filesystem.newFile( seedfilename )

  if seedfile:open( 'w' ) then
    for cellid, cellrow, cellcol, cellbubble in self:_iteratecells() do
      local cellvalue = cellbubble ~= 0 and cellbubble:getcolorid() or 0
      if cellid ~= 0 and cellcol == 1 then seedfile:write( '\n' ) end
      seedfile:write( tostring(cellvalue) .. ' ' )
    end
  end

  if config.debug then
    print( 'Saved grid to seed file ' .. seedfilename )
  end
end

function bubblegrid_t.loadfromseed( self, gridseed )
  local seedfilename = self:_getseedfilename( gridseed )
  local seedfile = love.filesystem.newFile( seedfilename )

  if seedfile:open( 'r' ) then
    for gridline in seedfile:lines() do
      local bubblerow = {}
      for _, linebubble in util.iterstring( gridline, ' ' ) do
        table.insert( bubblerow , tonumber(linebubble) )
      end
      table.insert( self._bubblegrid, bubblerow )
    end
  else
    -- TODO(JRC): Improve the random generation here.
    for gridrow = 1, 11 do
      local bubblerow = {}
      for gridcol = 1, 8 - 1 * ( (gridrow + 1) % 2 ) do
        table.insert( bubblerow, gridrow <= 4 and bubble_t.getnextcolorid() or 0 )
      end
      table.insert( self._bubblegrid, bubblerow )
    end
  end

  self._rowoffset = #self._bubblegrid[1] < #self._bubblegrid[2] and 1 or 0
  self._gridbox:scale( #self._bubblegrid[1 + self._rowoffset], #self._bubblegrid )

  self._bubblegrid[0], self._bubblegrid[self:geth() + 1] = {}, {}
  for sentcol = 1, self:getw() do
    self:addgridbubble( bubble_t(), 0, sentcol )
    table.insert( self._bubblegrid[self:geth() + 1], 0 )
  end

  for _, cellrow, cellcol, cellvalue in self:_iteratecells() do
    if cellvalue ~= 0 then
      self:addgridbubble( bubble_t(cellvalue), cellrow, cellcol )
    end
  end

  if config.debug then
    print( 'Loaded grid from seed file ' .. seedfilename )
  end
end

--[[ Accessor Functions ]]--

function bubblegrid_t.getw( self ) return self._gridbox.dim.x end
function bubblegrid_t.geth( self ) return self._gridbox.dim.y end
function bubblegrid_t.hasmotion( self ) return #self._bubblelist > 0 end
function bubblegrid_t.hasoverflow( self )
  return util.any( self._bubblegrid[self:geth() + 1], function(k, v) return v ~= 0 end )
end

--[[ Private Functions ]]--

function bubblegrid_t._getwallintx( self, bubble )
  local bubblebox = bubble:getbbox()

  local isleftintx = bubblebox.min.x <= self._gridbox.min.x
  local isrightintx = bubblebox.max.x >= self._gridbox.max.x

  return isleftintx, isrightintx
end

function bubblegrid_t._getgridintx( self, bubble )
  local bubblebbox = bubble:getbbox()
  local bubblecorners = {
    bubblebbox.min,
    bubblebbox.max,
    bubblebbox.min + vector_t(bubblebbox.dim.x, 0.0),
    bubblebbox.min + vector_t(0.0, bubblebbox.dim.y),
  }

  for _, bubblecorner in ipairs( bubblecorners ) do
    local intxrow, intxcol = self:_getposcell( bubblecorner )
    local intxbubble = self:getgridbubble( intxrow, intxcol )

    if intxbubble ~= nil and intxbubble ~= 0 then
      if ( bubble:getcenter() - intxbubble:getcenter() ):magnitude() < 2.0 then
        return self:_getposcell( bubble:getcenter() )
      end
    end
  end
end

function bubblegrid_t._querycells( self, startcells, nextfxn, queryfxn )
  local queriedcells = {}

  local visitedcells, cellstotraverse = {}, startcells
  while next( cellstotraverse ) ~= nil do
    local currcellid = table.remove( cellstotraverse )
    local currcellrow, currcellcol = self:_getidcell( currcellid )

    if visitedcells[currcellid] == nil then
      visitedcells[currcellid] = true

      if queryfxn( currcellrow, currcellcol ) then
        queriedcells[currcellid] = true
      end

      for _, nextcellid in ipairs( nextfxn(currcellrow, currcellcol) ) do
        table.insert( cellstotraverse, nextcellid )
      end
    end
  end

  return queriedcells
end

function bubblegrid_t._iteratecells( self )
  local function itercells( bubblegrid, currcellid )
    local isnextvalid = self:_iscellvalid( self:_getidcell(currcellid + 1) )

    local nextcellid = currcellid + ( isnextvalid and 1 or 2 )
    local nextcellrow, nextcellcol = bubblegrid:_getidcell( nextcellid )

    local nextcell = self:getgridbubble( nextcellrow, nextcellcol )
    if self:_iscellvalid( nextcellrow, nextcellcol ) and nextcell then
      return nextcellid, nextcellrow, nextcellcol, nextcell
    end
  end

  return itercells, self, -1
end

function bubblegrid_t._getadjcells( self, cellrow, cellcol )
  local adjcells = {}
  local cellrightdelta = self:_isrowshort( cellrow )

  for cellrowdelta = -1, 1 do
    local cellcoldeltas = cellrowdelta == 0 and { -1, 1 } or
      { cellrightdelta - 1, cellrightdelta }

    for _, cellcoldelta in ipairs( cellcoldeltas ) do
      local adjrow, adjcol = cellrow + cellrowdelta, cellcol + cellcoldelta
      if self:_iscellvalid( adjrow, adjcol ) then
        table.insert( adjcells, self:_getcellid(adjrow, adjcol) )
      end
    end
  end

  return adjcells
end

function bubblegrid_t._getadjbubbles( self, cellrow, cellcol )
  local adjbubbles = {}

  for _, adjcellid in ipairs( self:_getadjcells(cellrow, cellcol) ) do
    local adjcellrow, adjcellcol = self:_getidcell( adjcellid )

    local adjbubble = self._bubblegrid[adjcellrow][adjcellcol]
    if adjbubble ~= 0 then
      table.insert( adjbubbles, self:_getcellid(adjcellrow, adjcellcol) )
    end
  end

  return adjbubbles
end

function bubblegrid_t._getposcell( self, pos )
  local cellrow = self:geth() - math.ceil( pos.y ) + 1
  local cellcol = math.ceil( pos.x - 0.5 * self:_isrowshort(cellrow) )

  return cellrow, cellcol
end

function bubblegrid_t._getcellpos( self, cellrow, cellcol )
  local cellminx = cellcol - 1 + 0.5 * self:_isrowshort( cellrow )
  local cellminy = self:geth() - cellrow

  return vector_t( cellminx, cellminy )
end

function bubblegrid_t._getcellid( self, cellrow, cellcol )
  return ( cellcol - 1 ) + ( cellrow - 1 ) * self:getw()
end

function bubblegrid_t._getidcell( self, cellid )
  return math.floor( cellid / self:getw() ) + 1, ( cellid % self:getw() ) + 1
end

function bubblegrid_t._iscellvalid( self, cellrow, cellcol )
  local maxcellrow = self:geth()
  local maxcellcol = self:getw() - self:_isrowshort( cellrow )

  return util.inrange( cellrow, 1, maxcellrow ) and
    util.inrange( cellcol, 1, maxcellcol )
end

function bubblegrid_t._isrowshort( self, gridrow )
  return ( self._rowoffset + gridrow + 1 ) % 2
end

function bubblegrid_t._getseedfilename( self, gridseed )
  return 'data/boards/' .. gridseed .. '.txt'
end

return bubblegrid_t
