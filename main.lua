local bbg = require( 'bbg' )
love.ext = require( 'opt.loveext' )

ldb = require( 'opt.debugger' )

function love.run()
  math.randomseed( os.time() )

  if love.load then love.load( arg ) end
  if love.timer then love.timer.step() end

  local isrunning = true
  local framestart, frameend, frameleft = 0, 0, 0
  while isrunning do
    if love.event then
      love.event.pump()
      for levent, a, b, c, d in love.event.poll() do
        if levent == 'quit' then isrunning = false end
        love.handlers[levent]( a, b, c, d )
      end
    end

    framestart = love.timer and love.timer.getTime() or 0
    if love.getinput then love.getinput() end
    if love.update then love.update( bbg.global.fdt + math.max(-frameleft, 0) ) end
    if love.window and love.graphics and love.window.isCreated() then
      love.graphics.clear( bbg.colors.byname('black') )
      love.draw()
      love.graphics.present()
    end
    frameend = love.timer and love.timer.getTime() or 0

    if love.timer then
      frameleft = bbg.global.fdt - ( frameend - framestart )
      if frameleft > 0 then love.timer.sleep( frameleft ) end
      love.timer.step()
    end
  end
end

function love.load()
  board = bbg.bubbleboard_t( 0, os.time() )
end

function love.keypressed( key, scancode, isrepeat )
  if key == 'q' then love.event.quit() end
  if string.match( key, '.alt' ) then isloading = true end

  if key == 'space' then board:shootbubble() end
  if key == 'left' or key == 'h' then board:rotateshooter( 1.0 ) end
  if key == 'right' or key == 'l' then board:rotateshooter( -1.0 ) end

  if string.match( key, '[0-9]' ) then
    if love.keyboard.isDown( 'lalt', 'ralt' ) then board:load( key )
    else board:save( key ) end
  end
end

function love.keyreleased( key, scancode )
  if key == 'left' or key == 'h' then board:rotateshooter( -1.0 ) end
  if key == 'right' or key == 'l' then board:rotateshooter( 1.0 ) end
end

function love.update( dt )
  bbg.global.fnum = bbg.global.fnum + 1
  bbg.global.avgfps = 1 / dt

  board:update( dt )
  -- TODO(JRC): Figure out a better way to handle the board reset behavior here.
  -- NOTE(JRC): This could be better handled by implementing an improved version
  -- of the 'BubbleBoard.save' function that saves its queue information in
  -- addition to the board.
  if board:hasoverflow() then board = bbg.bubbleboard_t( 0, os.time() ) end
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
