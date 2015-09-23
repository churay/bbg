-- TODO(JRC): Eliminate this path inclusion somehow.
package.path = package.path .. ";bbg/?.lua"
local bbg = require( "bbg" )

function love.run()
  math.randomseed( os.time() )

  if love.load then love.load( arg ) end
  if love.timer then love.timer.step() end

  local timedelta = 0
  local isrunning = true
  while isrunning do
    if love.event then
      love.event.pump()
      for levent, a, b, c, d in love.event.poll() do
        if levent == "quit" then
          isrunning = false
        end

        love.handlers[levent]( a, b, c, d )
      end
    end

    if love.timer then
      love.timer.step()
      timedelta = love.timer.getDelta()
    end

    if love.getinput then love.getinput() end
    if love.update then love.update( timedelta ) end
    if love.window and love.graphics and love.window.isCreated() then
      love.graphics.clear()
      love.draw()
      love.graphics.present()
    end

    if love.timer then love.timer.sleep( 1.0e-3 ) end
  end
end

function love.load()
  board = bbg.BubbleBoard( bbg.Box(0.10, 0.0, 0.80, 1.0), 20, 20 )
  shooter = bbg.Shooter( bbg.Vector(0.5, 0.0), 1.0, math.pi / 2.0  )
end

function love.keypressed( key, isrepeat )
  if key == "q" then love.event.quit() end

  if key == "right" or key == "l" then shooter:rotate( -1.0 ) end
  if key == "left" or key == "h" then shooter:rotate( 1.0 ) end
  if key == " " then board:add( shooter:shoot() ) end
end

function love.keyreleased( key )
  if key == "right" or key == "l" or key == "left" or key == "h" then shooter:rotate( 0.0 ) end
end

function love.update( timedelta )
  board:update( timedelta )
  shooter:update( timedelta )
end

function love.draw()
  -- TODO(JRC): Attempt to change this so that the coordinate system is changed
  -- only once at the beginning of the game and not each frame.
  love.graphics.push()
  love.graphics.scale( love.window.getWidth(), love.window.getHeight() )
  love.graphics.translate( 0.0, 1.0 )
  love.graphics.scale( 1.0, -1.0 )

  board:draw( love.graphics )
  shooter:draw( love.graphics )

  love.graphics.pop()
end
