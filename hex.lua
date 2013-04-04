local sqrt, random = math.sqrt, math.random

local Hex = {}
Hex.__index = Hex

function Hex:new(rows, columns, side)
  local m = {}
  local apothem = sqrt(3) / 2 * side

  local r, c = 1, 1
  for r = 1, rows do
    m[r] = {}

    for c = 1, columns do
      local x, y
      if c % 2 == 1 then
        local c = math.floor(c / 2)
        x = 3 * side * c
        y = 2 * apothem * (r - 1)
      else
        x = m[r][c - 1].x + (3 * side / 2)
        y = m[r][c - 1].y + apothem
      end

      m[r][c] = {
        x = x,
        y = y,
        side = side,
        apothem = apothem,
        color = {
          random(0, 255),
          random(0, 255),
          random(0, 255),
        },
      }
    end
  end

  return setmetatable({ _m = m }, self)
end

function Hex:draw()
  for r = 1, #self._m do
    for c = 1, #self._m[r] do
      local hex = self._m[r][c]
      love.graphics.setColor(hex.color)
      love.graphics.circle(
        'fill',
        hex.x,
        hex.y,
        hex.side - 1,
        6)
    end
  end
end

return setmetatable(Hex, { __call = Hex.new })
