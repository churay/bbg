-- TODO(JRC): Improve the initialization script to automatically pull all of the
-- class files from the "bbg" directory.

bbg = {
  Class = require( "Class" ),

  Vector = require( "Vector" ),
  Queue = require( "Queue" ),
  Graph = require( "Graph" ),

  Bubble = require( "Bubble" ),
  Shooter = require( "Shooter" ),
}

return bbg
