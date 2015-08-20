local Class = require( "Class" )
local Bubble = require( "Bubble" )
local BubbleBoard = Class()

--[[ Constructors ]]--

function BubbleBoard._init( self, width, height )
  self._width = width
  self._height = height

  self._bubblegrid = {}
  self._bubbles = {}

  for col = 1, self._width do
    self._bubblegrid[col] = {}
    for row = 1, self._height do
      self._bubblegrid[col][row] = 0
    end
  end
end

--[[ Public Functions ]]--

function BubbleBoard.add( self, bubble )
  table.insert( self._bubbles, bubble )
end

function BubbleBoard.update( self, dt )
  
end

function BubbleBoard.draw( self, canvas )
  
end

return BubbleBoard
