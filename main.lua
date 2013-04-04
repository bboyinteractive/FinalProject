local Hex = require 'hex'

function love.load()
  grid = Hex(24, 37, 15)
end

function love.draw()
  grid:draw()
end

function love.keypressed(k, c)
  if k == 'escape' then
    love.event.quit()
  end
end
