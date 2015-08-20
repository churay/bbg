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

    if love.timer then love.timer.sleep( 0.001 ) end
  end
end

function love.load()
  screenbox = bbg.Box( 0.0, 0.0, love.window.getMode() )

  bubbles = {}
  shooter = bbg.Shooter(
    bbg.Vector( love.window.getWidth() / 2.0, 5.0 ), 200.0, 0.025
  )
end

function love.getinput()
  if love.keyboard.isDown( "right" ) or love.keyboard.isDown( "l" ) then
    shooter:adjust( -1.0 )
  end
  if love.keyboard.isDown( "left" ) or love.keyboard.isDown( "h" ) then
    shooter:adjust( 1.0 )
  end
  if love.keyboard.isDown( " " ) then
    table.insert( bubbles, shooter:shoot() )
  end
  if love.keyboard.isDown( "q" ) then
    love.event.push( "quit" )
  end
end

function love.update( timedelta )
  shooter:update( timedelta )

  for bubbleidx = #bubbles, 1, -1 do
    bubbles[bubbleidx]:update( timedelta )

    if not screenbox:intersects( bubbles[bubbleidx]:getbbox() ) then
      table.remove( bubbles, bubbleidx )
    end
  end
end

function love.draw()
  -- TODO(JRC): Attempt to change this so that the coordinate system is changed
  -- only once at the beginning of the game and not each frame.
  love.graphics.push()
  love.graphics.translate( 0.0, love.window.getHeight() )
  love.graphics.scale( 1.0, -1.0 )

  shooter:draw( love.graphics )
  for _, bubble in ipairs( bubbles ) do bubble:draw( love.graphics ) end

  love.graphics.pop()
end
