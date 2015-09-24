-- TODO(JRC): Improve the initialization script to automatically pull all of the
-- class files from the "bbg" directory.

bbg = {
  Class = require( "Class" ),

  Vector = require( "Vector" ),
  Box = require( "Box" ),
  Queue = require( "Queue" ),
  Graph = require( "Graph" ),

  Bubble = require( "Bubble" ),
  Shooter = require( "Shooter" ),
  BubbleGrid = require( "BubbleGrid" ),
  BubbleBoard = require( "BubbleBoard" ),
}

return bbg
