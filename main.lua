local Hex = require 'hex'

function love.load()
  love.graphics.setBackgroundColor(25, 25, 25)
  grid = Hex(24, 37, 15)
end

function love.update(dt)
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
