local function Type( ParentType )
  local NewType = {}
  NewType.__index = NewType
  NewType.super = ParentType

  NewType.istype = function( self, SomeType )
    return SomeType == NewType
  end
  NewType.isa = function( self, SomeType )
    local CurrType = NewType
    while CurrType ~= nil do
      if CurrType == SomeType then return true end
      CurrType = CurrType.super
    end
    return false
  end

  local NewTypeMT = {}
  NewTypeMT.__index = ParentType
  NewTypeMT.__call = function( ObjType, ... )
    local object = setmetatable( {}, NewType )
    object:new( ... )
    return object
  end

  setmetatable( NewType, NewTypeMT )

  return NewType
end

ObjectType = Type()
ObjectType.new = function( self, ... ) end

function Class( ParentType )
  local ParentType = ParentType or ObjectType
  local ChildType = Type( ParentType )

  return ChildType
end

return Class
