local Class = require( "bbg.Class" )

describe( "Class", function()
  --[[ Testing Variables ]]--

  local BaseClass = nil
  local OverrideClass = nil
  local DerivedClass = nil
  local DerivedOverrideClass = nil

  local baseobject = nil
  local overrideobject = nil
  local derviedobject = nil
  local derivedoverrideobject = nil

  --[[ Testing Constants ]]--

  local BASE_VALUE = 1
  local OVERRIDE_VALUE = 2

  local BASE_NAME = "BaseClass"
  local OVERRIDE_NAME = "OverrideClass"
  local DERIVED_NAME = "DerivedClass"

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    BaseClass = Class()
    BaseClass.new = function( self ) self.testval = BASE_VALUE end
    BaseClass.getval = function( self ) return self.testval end
    BaseClass.tostr = function( self ) return BASE_NAME end

    OverrideClass = Class( BaseClass )
    OverrideClass.new = function( self ) self.testval = OVERRIDE_VALUE end
    OverrideClass.tostr = function( self ) return OVERRIDE_NAME end

    DerivedClass = Class( BaseClass )
    DerivedClass.tostr = function( self ) return DERIVED_NAME end

    DerivedOverrideClass = Class( OverrideClass )

    baseobject = BaseClass()
    overrideobject = OverrideClass()
    derivedobject = DerivedClass()
    derivedoverrideobject = DerivedOverrideClass()
  end )

  after_each( function()
    baseobject = nil
    overrideobject = nil
    derivedobject = nil

    BaseClass = nil
    OverrideClass = nil
    DerivedClass = nil
  end )

  --[[ Testing Functions ]]--

  it( "allows instances to use their type's functions", function()
    assert.are.equal( BASE_VALUE, baseobject:getval() )
    assert.are.equal( BASE_NAME, baseobject:tostr() )
  end )

  it( "throws errors when undefined type functions are invoked", function()
    pending( "TODO(JRC): Fix this test after researching error assertions." )
    assert.has_error( baseobject.undefinedfxn() )
  end )

  it( "creates proper inheritance hierarchies", function()
    assert.is.truthy( BaseClass.super )
    assert.are.equal( BaseClass, OverrideClass.super )
    assert.are.equal( BaseClass, DerivedClass.super )
    assert.are.equal( OverrideClass, DerivedOverrideClass.super )
  end )

  it( "supports function inheritance", function()
    pending( "TODO(JRC): Implement this test!" )
    assert.is_true( true )
  end )

  it( "supports function overriding", function()
    pending( "TODO(JRC): Implement this test!" )
    assert.is_true( true )
  end )

  it( "uses the function override from the nearest type", function()
    pending( "TODO(JRC): Implement this test!" )
    assert.is_true( true )
  end )

end )
