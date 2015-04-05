local function Type( ParentType )
  local NewType = {}

  -- TODO(JRC): Improve this so that it's less ugly.
  if ParentType == nil then NewType.new = function( self, ... ) end end
  NewType.super = ParentType

  -- TODO(JRC): Uncomment this section once this the functions is debugged.
  --[[
  NewType.istype = function( self, SomeType )
    return SomeType == NewType
  end
  NewType.isa = function( self, SomeType )
    if SomeType == NewType then
      return true
    elseif self.super then
      return self.super.isa( self, SomeType )
    else
      return false
    end
  end
  ]]--

  NewType.__index = NewType
  NewType.__call = function( self, ... )
    local object = {}
    setmetatable( object, NewType )
    object:new( unpack(arg) )
    return object
  end

  setmetatable( NewType, ParentType )

  return NewType
end

local ObjectType = Type()

function Class( ParentType )
  local ParentType = ParentType or ObjectType
  local ChildType = Type( ParentType )

  return ChildType
end

return Class
