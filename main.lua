-- TODO(JRC): Eliminate this path inclusion somehow.
package.path = package.path .. ";bbg/?.lua"
local bbg = require( "bbg" )

-- package.path = package.path .. ";debug/?.lua"
-- ldb = require( "debug.debugger" )

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
      love.graphics.clear( 0, 0, 0 )
      love.draw()
      love.graphics.present()
    end

    if love.timer then love.timer.sleep( 1.0e-3 ) end
  end
end

function love.load()
  board = bbg.BubbleBoard( 0, os.time() )
end

function love.keypressed( key, scancode, isrepeat )
  if key == "q" then love.event.quit() end

  if key == "space" then board:shootbubble() end
  if key == "left" or key == "h" then board:rotateshooter( 1.0 ) end
  if key == "right" or key == "l" then board:rotateshooter( -1.0 ) end
end

function love.keyreleased( key, scancode )
  if key == "left" or key == "h" then board:rotateshooter( -1.0 ) end
  if key == "right" or key == "l" then board:rotateshooter( 1.0 ) end
end

function love.update( timedelta )
  board:update( timedelta )

  -- TODO(JRC): Figure out a better way to handle the board reset behavior here.
  if board:hasoverflow() then board = bbg.BubbleBoard( 0, os.time() ) end
end

function love.draw()
  -- NOTE(JRC): The board scale is adjusted by the inverted window scale to
  -- compensate for the difference this causes in window coordinates.
  local window = { width=love.graphics.getWidth(), height=love.graphics.getHeight() }
  local boardscale = (window.height / window.width) * (board:getw() / board:geth())

  love.graphics.push()
  love.graphics.scale( window.width, window.height )
  love.graphics.translate( 0.0, 1.0 )
  love.graphics.scale( 1.0, -1.0 )

  love.graphics.translate( (1.0 - boardscale) / 2.0, 0.0 )
  love.graphics.scale( boardscale, 1.0 )
  board:draw( love.graphics )

  love.graphics.pop()
end
