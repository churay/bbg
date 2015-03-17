function love.conf( config )
  config.title = "bbg"
  config.author = "Joe Ciurej"

  config.screen.width = 640
  config.screen.height = 480
  config.screen.vsync = true

  config.modules.audio = false
  config.modules.graphics = true
  config.modules.physics = false
  config.modules.thread = true
end
