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

  local sentrow = 0
  self._bubblegrid[sentrow] = {}
  for sentcol = 1, self:getw() do
    local sentbbox = Box( sentcol + 0.5, self:geth(), 1, 1 )
    self._bubblegrid[sentrow][sentcol] = Bubble( sentbbox:getmid() )
  end
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

      -- Remove Bubble Chains Attached to the New Bubble --

      -- TODO(JRC): Fix the bug in this code that causes the incorrect set of
      -- bubbles to be popped.
      local bubblestopop = {}
      local bubblestotraverse = { self:_getcellid(gridrowintx, gridcolintx) }
      while next( bubblestotraverse ) ~= nil do
        local nextbubbleid = table.remove( bubblestotraverse )
        local nextbubblerow, nextbubblecol = self:_getidcell( nextbubbleid )

        bubblestopop[nextbubbleid] = { nextbubblerow, nextbubblecol }
        local adjcells = self:_getadjcells( nextbubblerow, nextbubblecol )
        for _, adjcell in ipairs( adjcells ) do
          local adjcellrow, adjcellcol = adjcell[1], adjcell[2]
          local adjcellid = self:_getcellid( adjcellrow, adjcellcol )
          local adjbubble = self._bubblegrid[adjcellrow][adjcellcol]

          if adjbubble ~= 0 and bubblestopop[adjcellid] == nil and
              bubble:getcolor() == adjbubble:getcolor() then
            table.insert( bubblestotraverse, self:_getcellid(adjcellrow, adjcellcol) )
          end
        end
      end

      if Utility.len( bubblestopop ) >= 3 then
        for _, bubbleloc in pairs( bubblestopop ) do
          local bubblerow, bubblecol = bubbleloc[1], bubbleloc[2]
          self._bubblegrid[bubblerow][bubblecol] = 0
        end

        -- TODO(JRC): Remove all bubbles that aren't attached to the top.
      end
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
        table.insert( adjcells, {adjrow, adjcol} )
      end
    end
  end

  return adjcells
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
