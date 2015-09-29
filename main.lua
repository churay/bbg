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
  board = bbg.BubbleBoard( os.time(), 8, 11 )
end

function love.keypressed( key, isrepeat )
  if key == "q" then love.event.quit() end

  -- TODO(JRC): Fix the exploit that allows players to rotate at double speed
  -- if they press both of the same direction key at the same time.
  if key == " " then board:shootbubble() end
  if key == "left" or key == "h" then board:rotateshooter( 1.0 ) end
  if key == "right" or key == "l" then board:rotateshooter( -1.0 ) end
end

function love.keyreleased( key )
  if key == "left" or key == "h" then board:rotateshooter( -1.0 ) end
  if key == "right" or key == "l" then board:rotateshooter( 1.0 ) end
end

function love.update( timedelta )
  board:update( timedelta )
end

function love.draw()
  -- TODO(JRC): Try to implement (or at least derive) this solution more elegantly.
  local boardratio = (board:getw() * love.window.getHeight()) / (board:geth() * love.window.getWidth())

  love.graphics.push()
  love.graphics.scale( love.window.getWidth(), love.window.getHeight() )
  love.graphics.translate( 0.0, 1.0 )
  love.graphics.scale( 1.0, -1.0 )

  love.graphics.translate( (1.0 - boardratio) / 2.0, 0.0 )
  love.graphics.scale( boardratio, 1.0 )
  board:draw( love.graphics )

  love.graphics.pop()
end
