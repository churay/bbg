function love.run()
  math.randomseed( os.time() )

  if love.load then love.load( arg ) end
  if love.timer then love.timer.step() end

  local timedelta = 0
  local isrunning = true
  while isrunning do
    if love.event then
      love.event.pump()
      for levent in love.event.poll() do
        if levent == "quit" then
          isrunning = false
        end
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
  color = { intensity = 0, alpha = 255 }
  intensityincreasing = true
end

function love.update( timedelta )
  local colordelta = (intensityincreasing and 1 or -1) * math.ceil( timedelta )

  color.intensity = color.intensity + colordelta

  if color.intensity >= 255 or color.intensity <= 0 then
    intensityincreasing = not intensityincreasing
  end
end

function love.draw()
  love.graphics.clear()

  love.graphics.setBackgroundColor( color.intensity, color.intensity, color.intensity, color.alpha )
end
