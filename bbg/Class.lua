local function Type( ParentType )
  local NewType = {}
  NewType.__index = NewType
  NewType._super = ParentType
  NewType._type = NewType

  NewType.istype = function( self, SomeType )
    return self._type == SomeType
  end
  NewType.isa = function( self, SomeType )
    local CurrType = self._type
    while CurrType ~= nil do
      if CurrType == SomeType then return true end
      CurrType = CurrType._super
    end
    return false
  end

  local NewTypeMT = {}
  NewTypeMT.__index = ParentType
  NewTypeMT.__call = function( ObjType, ... )
    local object = setmetatable( {}, NewType )
    object:_init( ... )
    return object
  end

  setmetatable( NewType, NewTypeMT )

  return NewType
end

local ObjectType = Type()
ObjectType._init = function( self, ... ) end

local function Class( ParentType )
  local ParentType = ParentType or ObjectType
  local ChildType = Type( ParentType )

  return ChildType
end

return Class
