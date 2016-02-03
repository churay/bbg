local Class = require( "Class" )

local Vector = require( "Vector" )
local Box = require( "Box" )
local Utility = require( "Utility" )

local Bubble = require( "Bubble" )
local BubbleGrid = Class()

--[[ Constructors ]]--

function BubbleGrid._init( self, gridseed )
  self:loadfromseed( gridseed )
end

--[[ Public Functions ]]--

function BubbleGrid.update( self, dt )
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

function BubbleGrid.draw( self, canvas )
  canvas.push()

  canvas.setColor( 200, 200, 200 )
  canvas.rectangle( "fill", 0.0, 0.0, self:getw(), self:geth() )

  for _, bubble in ipairs( self._bubblelist ) do bubble:draw( love.graphics ) end

  for _, cellrow, cellcol, bubble in self:_iteratecells() do
    if bubble ~= 0 then bubble:draw( canvas ) end

    -- TODO(JRC): Remove the following debugging functionality.
    local cellpos = self:_getcellpos( cellrow, cellcol )
    canvas.setColor( 255, 30, 0 )
    canvas.rectangle( "line", cellpos:getx(), cellpos:gety(), 1.0, 1.0 )
  end

  canvas.pop()
end

function BubbleGrid.addbubble( self, bubble )
  table.insert( self._bubblelist, bubble )
end

function BubbleGrid.addgridbubble( self, bubble, gridrow, gridcol )
  bubble._pos = self:_getcellpos( gridrow, gridcol ) + Vector( 0.5, 0.5 )
  self._bubblegrid[gridrow][gridcol] = bubble
end

function BubbleGrid.getgridbubble( self, gridrow, gridcol )
  return self._bubblegrid[gridrow] and self._bubblegrid[gridrow][gridcol]
end

-- TODO(JRC): Clean up this function so that it isn't so hacky.
function BubbleGrid.addgridrow( self, rowvals )
  self._rowoffset = self._rowoffset + 1

  for gridrow = self:geth() + 1, 2, -1 do
    self._bubblegrid[gridrow] = self._bubblegrid[gridrow - 1]
    for gridcol = 1, self:getw() - self:_isrowshort( gridrow ) do
      local gridbubble = self:getgridbubble( gridrow, gridcol )
      if gridbubble ~= 0 then
        gridbubble._pos = gridbubble._pos + Vector( 0.0, -1.0 )
      end
    end
  end

  local sentoffset = self:_isrowshort( 0 ) and 0.5 or -0.5
  for gridcol = 1, self:getw() - self:_isrowshort( 0 ) do
    local sentbubble = self:getgridbubble( 0, gridcol )
    sentbubble._pos = sentbubble._pos + Vector( sentoffset, 0.0 )
  end

  self._bubblegrid[1] = {}
  for gridcol = 1, self:getw() - self:_isrowshort( 1 ) do
    self:addgridbubble( Bubble(nil, nil, rowvals[gridcol]), 1, gridcol )
  end
end

function BubbleGrid.popgridbubble( self, gridrow, gridcol )
  local popbubble = self._bubblegrid[gridrow][gridcol]

  local function popnextfxn( r, c )
    local nextcells = {}
    for _, adjbubbleid in ipairs( self:_getadjbubbles(r, c) ) do
      local adjrow, adjcol = self:_getidcell( adjbubbleid )
      local adjbubble = self._bubblegrid[adjrow][adjcol]
      if popbubble:getcolor() == adjbubble:getcolor() then
        table.insert( nextcells, adjbubbleid )
      end
    end
    return nextcells
  end
  local function popqueryfxn( r, c )
    return popbubble:getcolor() == self._bubblegrid[r][c]:getcolor()
  end
  local bubblestopop = self:_querycells( { self:_getcellid(gridrow, gridcol) },
    popnextfxn, popqueryfxn )

  if Utility.len( bubblestopop ) >= 3 then
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

function BubbleGrid.savetoseed( self, gridseed )
  -- TODO(JRC): Implement this function.
end

function BubbleGrid.loadfromseed( self, gridseed )
  self._bubblelist, self._bubblegrid = {}, {}
  self._rowoffset = 0

  local seedfilename = self:_getseedfilename( gridseed )
  local seedfile = love.filesystem.newFile( seedfilename )

  if seedfile:open( "r" ) then
    for gridline in seedfile:lines() do
      local linebubbles = {}
      for _, linebubble in ipairs( Utility.split(gridline, " ") ) do
        table.insert( linebubbles, tonumber(linebubble) )
      end
      table.insert( self._bubblegrid, linebubbles )
    end
  else
    -- TODO(JRC): Improve the random generation here.
    for gridrow = 1, 11 do
      local bubblerow = {}
      for gridcol = 1, 8 - 1 * ( (gridrow + 1) % 2 ) do
        table.insert( bubblerow, gridrow <= 4 and math.random(#Bubble.COLORS) or 0 )
      end
      table.insert( self._bubblegrid, bubblerow )
    end
  end

  self._gridbox = Box( 0.0, 0.0, #self._bubblegrid[1], #self._bubblegrid )

  self._bubblegrid[0], self._bubblegrid[self:geth() + 1] = {}, {}
  for sentcol = 1, self:getw() do
    self:addgridbubble( Bubble(), 0, sentcol )
    table.insert( self._bubblegrid[self:geth() + 1], 0 )
  end

  for _, cellrow, cellcol, cellvalue in self:_iteratecells() do
    if cellvalue ~= 0 then
      self:addgridbubble( Bubble(nil, nil, cellvalue), cellrow, cellcol )
    end
  end
end

--[[ Accessor Functions ]]--

function BubbleGrid.getw( self ) return self._gridbox:getw() end
function BubbleGrid.geth( self ) return self._gridbox:geth() end
function BubbleGrid.hasmotion( self ) return #self._bubblelist > 0 end
function BubbleGrid.hasoverflow( self )
  for sentcol = 1, self:getw() do
    local sentbubble = self:getgridbubble( self:geth() + 1, sentcol )
    if sentbubble ~= 0 and sentbubble ~= nil then return true end
  end
  return false
end

--[[ Private Functions ]]--

function BubbleGrid._getwallintx( self, bubble )
  local bubblebox = bubble:getbbox()

  local isleftintx = bubblebox:getmin():getx() <= self._gridbox:getmin():getx()
  local isrightintx = bubblebox:getmax():getx() >= self._gridbox:getmax():getx()

  return isleftintx, isrightintx
end

function BubbleGrid._getgridintx( self, bubble )
  local bubblebbox = bubble:getbbox()
  local bubblecorners = {
    bubblebbox:getmin(),
    bubblebbox:getmax(),
    bubblebbox:getmin() + Vector(bubblebbox:getw(), 0.0),
    bubblebbox:getmin() + Vector(0.0, bubblebbox:geth()),
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

function BubbleGrid._querycells( self, startcells, nextfxn, queryfxn )
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

function BubbleGrid._iteratecells( self )
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

function BubbleGrid._getadjcells( self, cellrow, cellcol )
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

function BubbleGrid._getadjbubbles( self, cellrow, cellcol )
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

function BubbleGrid._getposcell( self, pos )
  local cellrow = self:geth() - math.ceil( pos:gety() ) + 1
  local cellcol = math.ceil( pos:getx() - 0.5 * self:_isrowshort(cellrow) )

  return cellrow, cellcol
end

function BubbleGrid._getcellpos( self, cellrow, cellcol )
  local cellminx = cellcol - 1 + 0.5 * self:_isrowshort( cellrow )
  local cellminy = self:geth() - cellrow

  return Vector( cellminx, cellminy )
end

function BubbleGrid._getcellid( self, cellrow, cellcol )
  return ( cellcol - 1 ) + ( cellrow - 1 ) * self:getw()
end

function BubbleGrid._getidcell( self, cellid )
  return math.floor( cellid / self:getw() ) + 1, ( cellid % self:getw() ) + 1
end

function BubbleGrid._iscellvalid( self, cellrow, cellcol )
  local maxcellrow = self:geth()
  local maxcellcol = self:getw() - self:_isrowshort( cellrow )

  return Utility.inrange( cellrow, 1, maxcellrow ) and
    Utility.inrange( cellcol, 1, maxcellcol )
end

function BubbleGrid._isrowshort( self, gridrow )
  return ( self._rowoffset + gridrow + 1 ) % 2
end

function BubbleGrid._getseedfilename( self, gridseed )
  return "boards/" .. gridseed .. ".txt"
end

return BubbleGrid
