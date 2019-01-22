function love.conf( config )
  config.identity = 'bbg'
  config.version = '11.2' -- v0.11.2
  config.console = false

  config.window.title = 'bbg'
  config.window.icon = nil
  config.window.borderless = false
  config.window.resizable = false
  config.window.width = 640
  config.window.height = 480
  config.window.vsync = true

  config.modules.audio = false
  config.modules.event = true
  config.modules.graphics = true
  config.modules.math = true
  config.modules.physics = false
  config.modules.sound = false
  config.modules.system = true
  config.modules.timer = true
  config.modules.window = true
  config.modules.thread = false
end
