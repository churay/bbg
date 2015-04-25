function love.conf( config )
  config.window.title = "bbg"
  config.window.width = 640
  config.window.height = 480
  config.window.vsync = true

  config.modules.audio = false
  config.modules.event = true
  config.modules.graphics = true
  config.modules.physics = false
  config.modules.system = true
  config.modules.timer = true
  config.modules.window = true
  config.modules.thread = true
end
