local Grid  = require 'grid'
local Timer = require 'lib.timer'
local pi = math.pi

function love.load()
  love.graphics.setBackgroundColor(25, 25, 25)
  time = 0

  grid = Grid(24, 37, 15)
end

function love.update(dt)
  Timer.update(dt)
  time = time + dt

  --noise:send('time', time)

  if love.mouse.isDown('l') then
    local v = grid:select(love.mouse.getPosition())
    if v then
      v.color = { 255, 0, 0 }
      v.speed = pi * 2
    end
  elseif love.mouse.isDown('r') then
    local v = grid:select(love.mouse.getPosition())
    if v then
      v.color = { 0, 0, 0 }
      v.speed = 0
    end
  end

  grid:update(dt)
end

function love.draw()
  grid:draw()
end

function love.keypressed(k, c)
  if k == 'escape' then
    love.event.quit()
  end
end
