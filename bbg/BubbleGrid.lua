local Class = require( "Class" )

local Vector = require( "Vector" )
local Box = require( "Box" )
local Utility = require( "Utility" )

local Bubble = require( "Bubble" )
local BubbleGrid = Class()

--[[ Constructors ]]--

-- TODO(JRC): Add a capability to specify a random seed for an initial configuration.
function BubbleGrid._init( self, width, height )
  self._gridbox = Box( 0.0, 0.0, width, height )

  self._bubblelist = {}
  self._bubblegrid = {}
  self:clear()

  self._bubblegrid[0] = {}
  for sentcol = 1, self:getw() do self:addgridbubble( Bubble(), 0, sentcol ) end
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

  for gridrow, bubblerow in ipairs( self._bubblegrid ) do
    for gridcol, bubble in ipairs( bubblerow ) do
      if bubble ~= 0 then bubble:draw( love.graphics ) end

      -- TODO(JRC): Remove the following debugging functionality.
      local cellpos = self:_getcellpos( gridrow, gridcol )
      canvas.setColor( 255, 30, 0 )
      canvas.rectangle( "line", cellpos:getx(), cellpos:gety(), 1.0, 1.0 )
    end
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

function BubbleGrid.popgridbubble( self, gridrow, gridcol )
  local popbubble = self._bubblegrid[gridrow][gridcol]

  local popnextfxn = function( r, c )
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
  local popqueryfxn = function( r, c )
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

function BubbleGrid.clear( self )
  self._bubbles = {}

  for row = 1, self:geth() do
    self._bubblegrid[row] = {}
    for col = 1, self:getw() do
      self._bubblegrid[row][col] = 0
    end
  end
end

--[[ Accessor Functions ]]--

function BubbleGrid.getw( self ) return self._gridbox:getw() end
function BubbleGrid.geth( self ) return self._gridbox:geth() end

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
    local intxbubble = self._bubblegrid[intxrow] and self._bubblegrid[intxrow][intxcol]

    if intxbubble ~= nil and intxbubble ~= 0 then
      if( bubble:getcenter() - intxbubble:getcenter() ):magnitude() < 2.0 then
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

function BubbleGrid._getadjcells( self, cellrow, cellcol )
  local adjcells = {}
  local cellrightdelta = ( cellrow + 1 ) % 2

  for cellrowdelta = -1, 1 do
    local cellcoldeltas = cellrowdelta == 0 and { -1, 1 } or
      { cellrightdelta - 1, cellrightdelta }
    for _, cellcoldelta in ipairs( cellcoldeltas ) do
      local adjrow, adjcol = cellrow + cellrowdelta, cellcol + cellcoldelta
      if Utility.inrange( adjrow, 1, self:geth() ) and
          Utility.inrange( adjcol, 1, self:getw() ) then
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
  local cellcol = math.ceil( pos:getx() - 0.5 * ((cellrow + 1) % 2) )

  return cellrow, cellcol
end

function BubbleGrid._getcellpos( self, cellrow, cellcol )
  local cellminx = cellcol - 1 + 0.5 * ( (cellrow + 1) % 2 )
  local cellminy = self:geth() - cellrow

  return Vector( cellminx, cellminy )
end

function BubbleGrid._getcellid( self, cellrow, cellcol )
  return ( cellcol - 1 ) + ( cellrow - 1 ) * self:getw()
end

function BubbleGrid._getidcell( self, cellid )
  return math.floor( cellid / self:getw() ) + 1, ( cellid % self:getw() ) + 1
end

return BubbleGrid
