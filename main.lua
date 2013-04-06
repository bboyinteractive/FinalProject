local pi = math.pi

local Grid = require 'grid'

function love.load()
  love.graphics.setBackgroundColor(25, 25, 25)
  --grid = Grid(1, 37, 15)
  grid = Grid(24, 37, 15)
end

function love.update(dt)
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
