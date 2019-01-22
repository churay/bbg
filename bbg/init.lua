local util = require( 'util' )
local bbg = util.libload( 'bbg' )

-- NOTE(JRC): If any of the reserved variable tables are overloaded with
-- a module name, then this module should fail to load.
if bbg.global ~= nil or bbg.model ~= nil or bbg.view ~= nil or bbg.input ~= nil then
  return nil
end

--[[ Global Values ]]--

bbg.global = {}
bbg.global.debug = true
bbg.global.fnum = 1
bbg.global.fps = 60.0
bbg.global.avgfps = 0.0
bbg.global.fdt = 1 / bbg.global.fps

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
