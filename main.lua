local Curve = require 'curve'
local cp = {}

function love.load()
  love.graphics.setLineWidth(6)
  love.graphics.setPointSize(3)
end

function love.draw()
  love.graphics.setColor(0, 255, 0)
  for _,v in ipairs(cp) do
    love.graphics.point(v[1], v[2])
  end

  love.graphics.setColor(255, 0, 0)
  if #cp >= 2 then
    love.graphics.line(Curve(cp):build())
  end
end

function love.mousepressed(x, y, b)
  if b == 'l' then
    cp[#cp + 1] = { x, y }
  end
end
