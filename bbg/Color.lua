local Color = {}

--[[ Color Values ]]--

Color.table = {}

Color.table.red     = { 1.0, 0.0, 0.0 }
Color.table.green   = { 0.0, 1.0, 0.0 }
Color.table.blue    = { 0.0, 0.0, 1.0 }
Color.table.yellow  = { 1.0, 1.0, 0.0 }
Color.table.magenta = { 1.0, 0.0, 1.0 }
Color.table.white   = { 1.0, 1.0, 1.0 }
Color.table.black   = { 0.0, 0.0, 0.0 }

Color.table.lgray   = { 0.7, 0.7, 0.7 }
Color.table.dgray   = { 0.3, 0.3, 0.3 }

--[[ Color Functions ]]--

function Color.byname( name, alpha )
  local c = Color.table[name]
  return { c[1], c[2], c[3], alpha }
end

function Color.from255( r, g, b, alpha )
  local a = alpha and alpha / 255.0
  return { r / 255.0, g / 255.0, b / 255.0, a }
end

return Color
