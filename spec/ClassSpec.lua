local Class = require( "bbg.Class" )

describe( "Class", function()
  --[[ Testing Variables ]]--

  local BaseClass = nil
  local OverrideClass = nil
  local DerivedClass = nil

  local baseobject = nil
  local overrideobject = nil
  local derviedobject = nil

  --[[ Testing Constants ]]--

  local BASE_VALUE = 1
  local OVERRIDE_VALUE = 2

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    BaseClass = Class()
    BaseClass.new = function( self ) self.testval = BASE_VALUE end
    BaseClass.getval = function( self ) return self.testval end

    OverrideClass = Class( BaseClass )
    OverrideClass.new = function( self ) self.testval = OVERRIDE_VALUE end

    DerivedClass = Class( BaseClass )

    baseobject = BaseClass()
    overrideobject = OverrideClass()
    derivedobject = DerivedClass()
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
    assert.is_true( true )
  end )

  it( "creates instances with a type's 'new' function", function()
    assert.is_true( true )
  end )

  it( "creates proper inheritance hierarchies", function()
    assert.is_true( true )
  end )

  it( "supports function inheritance", function()
    assert.is_true( true )
  end )

  it( "supports function overriding", function()
    assert.is_true( true )
  end )

  it( "uses the function override from the nearest type", function()
    assert.is_true( true )
  end )

end )
