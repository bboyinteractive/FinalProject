local sqrt, random = math.sqrt, math.random

local Hex = {}
Hex.__index = Hex

function Hex:new(x, y, side, apothem, color)
  return setmetatable({
    x = x,
    y = y,
    side = side,
    apothem = apothem,
    color = color,
  }, self)
end

function Hex:draw()
  love.graphics.setColor(self.color)
  love.graphics.circle(
    'fill',
    self.x,
    self.y,
    self.side - 1,
    6)
end

local Grid = {}
Grid.__index = Grid

function Grid:new(rows, columns, side)
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

      m[r][c] = Hex:new(x, y, side, apothem, { 0, 0, 0 })
    end
  end

  return setmetatable({ _m = m }, self)
end

function Grid:get(row, column)
  return self._m[row][column]
end

function Grid:draw()
  for r = 1, #self._m do
    for c = 1, #self._m[r] do
      self._m[r][c]:draw()
    end
  end
end

return setmetatable(Grid, { __call = Grid.new })
