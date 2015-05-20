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
  bubbles = {}
  shooter = bbg.Shooter(
    bbg.Vector( love.window.getWidth() / 2.0, 5.0 ), 200.0, 0.025
  )
end

-- TODO(JRC): Move the input handling step to its own proper function.
function love.keypressed( keycode )
  if keycode == " " then table.insert( bubbles, shooter:shoot() ) end
end

function love.update( timedelta )
  -- TODO(JRC): Move the input handling step to its own proper function.
  if love.keyboard.isDown( "right" ) then shooter:adjust( -1.0 ) end
  if love.keyboard.isDown( "left" ) then shooter:adjust( 1.0 ) end

  shooter:update( timedelta )
  -- TODO(JRC): Remove bubbles that are outside the bounds of the screen.
  for _, bubble in ipairs( bubbles ) do
    bubble:update( timedelta )
  end
end

function love.draw()
  love.graphics.clear()

  shooter:draw( love.graphics )
  for _, bubble in ipairs( bubbles ) do
    bubble:draw( love.graphics )
  end
end
