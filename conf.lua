-- The configuration loading function for the application.  This function is
-- run before any other functions to bootstrap the application and initialize
-- important variables.
function love.conf( config )
  config.window.title = "bbg"     -- Window Title
  config.window.width = 640       -- Screen Width
  config.window.height = 480      -- Screen Height
  config.window.vsync = true      -- Vertical Sync

  config.modules.audio = false    -- Audio Module
  config.modules.event = true     -- Event Module
  config.modules.graphics = true  -- Graphics Module
  config.modules.physics = false  -- Physics Module
  config.modules.system = true    -- System Module
  config.modules.timer = true     -- Timer Module
  config.modules.window = true    -- Window Module
  config.modules.thread = true    -- Thread Module
end
