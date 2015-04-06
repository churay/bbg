local Class = require( "bbg.Class" )

describe( "Class", function()
  --[[ Testing Constants ]]--

  -- The names of all the functions defined in the test classes.
  local CLASS_FUNCTIONS = { "new", "getval", "tostr" }

  -- The values initialized to instances of the different test class types.
  local BASE_VALUE = 1
  local OVERRIDE_VALUE = 2

  -- The names associated with the different test class types.
  local BASE_NAME = "BaseClass"
  local OVERRIDE_NAME = "OverrideClass"
  local DESCENDENT_NAME = "DescendentClass"

  --[[ Testing Variables ]]--

  local BaseClass = nil
  local OverrideClass = nil
  local InheritClass = nil
  local DescendentClass = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    BaseClass = Class()
    BaseClass.new = function( self ) self.testval = BASE_VALUE end
    BaseClass.getval = function( self ) return self.testval end
    BaseClass.tostr = function( self ) return BASE_NAME end

    OverrideClass = Class( BaseClass )
    OverrideClass.new = function( self ) self.testval = OVERRIDE_VALUE end
    OverrideClass.getval = function( self ) return self.testval + 1 end
    OverrideClass.tostr = function( self ) return OVERRIDE_NAME end

    InheritClass = Class( BaseClass )

    DescendentClass = Class( InheritClass )
    DescendentClass.tostr = function( self ) return DESCENDENT_NAME end
  end )

  after_each( function()
    BaseClass = nil
    OverrideClass = nil
    InheritClass = nil
    DescendentClass = nil
  end )

  --[[ Testing Functions ]]--

  it( "distributes all functions to type instances", function()
    baseobject = BaseClass()

    for field, _ in pairs( BaseClass ) do
      assert.is.truthy( baseobject[field] )
    end
  end )

  it( "distributes the same functions to all type instances", function()
    baseobject = BaseClass()
    baseobject2 = BaseClass()

    for field, _ in pairs( BaseClass ) do
      assert.are.equal( BaseClass[field], baseobject[field] )
      assert.are.equal( BaseClass[field], baseobject2[field] )
    end
  end )

  it( "allows instances to use their type's functions", function()
    baseobject = BaseClass()

    assert.are.equal( BASE_VALUE, baseobject:getval() )
    assert.are.equal( BASE_NAME, baseobject:tostr() )
  end )

  it( "throws errors when undefined type functions are invoked", function()
    -- TODO(JRC): This test should be changed to use `assert.has_error`.
    baseobject = BaseClass()
    assert.is.equal( nil, baseobject["undefinedfxn"] )
  end )

  it( "properly sets the 'super' field to the type's parent type", function()
    assert.is.truthy( BaseClass.super )
    assert.are.equal( BaseClass, OverrideClass.super )
    assert.are.equal( BaseClass, InheritClass.super )
    assert.are.equal( InheritClass, DescendentClass.super )
  end )

  it( "distributes all nonoverridden functions to child types", function()
    for _, fxn in pairs( CLASS_FUNCTIONS ) do
      assert.are.equal( BaseClass[fxn], InheritClass[fxn] )
    end

    assert.are.equal( InheritClass.new, DescendentClass.new )
    assert.are.equal( InheritClass.getval, DescendentClass.getval )
  end )

  it( "supports function overriding in child classes", function()
    for _, fxn in pairs( CLASS_FUNCTIONS ) do
      assert.are_not.equal( BaseClass[fxn], OverrideClass[fxn] )
    end

    assert.are_not.equal( InheritClass.tostr, DescendentClass.tostr )
  end )

  it( "distributes the function override from the nearest type", function()
    overrideobject = OverrideClass()
    assert.are.equal( OVERRIDE_VALUE, overrideobject:getval() - 1 )
    assert.are.equal( OVERRIDE_NAME, overrideobject:tostr() )

    inheritobject = InheritClass()
    assert.are.equal( BASE_VALUE, inheritobject:getval() )
    assert.are.equal( BASE_NAME, inheritobject:tostr() )

    descendentobject = DescendentClass()
    assert.are.equal( BASE_VALUE, descendentobject:getval() )
    assert.are.equal( DESCENDENT_NAME, descendentobject:tostr() )
  end )

end )
