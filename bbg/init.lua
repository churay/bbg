local util = require( 'util' )
local bbg = util.libload( 'bbg' )

-- NOTE(JRC): If any of the reserved variable tables are overloaded with
-- a module name, then this module should fail to load.
if bbg.meta ~= nil or bbg.model ~= nil or bbg.view ~= nil or bbg.input ~= nil then
  return nil
end

--[[ Meta Values ]]--

bbg.meta = {}
bbg.meta.fcount = 0.0
bbg.meta.avgfps = 0.0

--[[ Model Values ]]--

bbg.model = {}
bbg.model.board = 0
bbg.model.func = 0

--[[ View Values ]]--

bbg.view = {}
bbg.view.viewport = 0

--[[ Input Values ]]--

bbg.input = {}
bbg.input.mouse = 0

return bbg
