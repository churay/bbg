local color = {}

--[[ Color Values ]]--

color.table = {}

color.table.red     = { 1.0, 0.0, 0.0 }
color.table.green   = { 0.0, 1.0, 0.0 }
color.table.blue    = { 0.0, 0.0, 1.0 }
color.table.yellow  = { 1.0, 1.0, 0.0 }
color.table.magenta = { 1.0, 0.0, 1.0 }
color.table.white   = { 1.0, 1.0, 1.0 }
color.table.black   = { 0.0, 0.0, 0.0 }

color.table.lgray   = { 0.7, 0.7, 0.7 }
color.table.dgray   = { 0.3, 0.3, 0.3 }

--[[ Color Functions ]]--

function color.byname( name, alpha )
  local c = color.table[name]
  return { c[1], c[2], c[3], alpha }
end

return color
