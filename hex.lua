local sqrt, random, pi = math.sqrt, math.random, math.pi

local Hex = {}
Hex.__index = Hex

local MAX_DISPLACEMENT = 40

local function dist(x, y)
  return sqrt(x ^ 2 + y ^ 2)
end

function Hex:new(x, y, side, apothem, color)
  return setmetatable({
    x = x,
    y = y,
    side = side,
    apothem = apothem,
    color = color,
    angle = 0,
  }, self)
end

function Hex:update(dt)
  self.angle = self.angle + dt * pi / 2
  self.angle = self.angle % (pi * 2)
end

function Hex:contains(x, y)
  local a, b = x - self.x, y - self.y
  return a * a + b * b <= self.apothem * self.apothem
end

function Hex:draw()
  love.graphics.push()

  -- Rotate the hexagon about its center
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.angle)
  love.graphics.translate(-self.x, -self.y)

  love.graphics.setColor(self.color)
  love.graphics.circle(
    'fill',
    self.x,
    self.y,
    self.side,
    6)
  love.graphics.pop()
end

local Grid = {}
Grid.__index = Grid

function Grid:new(rows, columns, side)
  local m = {}
  -- The apothem of a hexagon is equal to the altitude of one
  -- of the six triangle's that make up the hexagon
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

      local color = { 0, 0, 0 }
      m[r][c] = Hex:new(x, y, side, apothem, color)
    end
  end

  return setmetatable({ _m = m }, self)
end

function Grid:get(row, column)
  return self._m[row][column]
end

function Grid:select(x, y)
  for r = 1, #self._m do
    for c = 1, #self._m[r] do
      if self._m[r][c]:contains(x, y) then
        return self:get(r, c)
      end
    end
  end

  return nil
end

function Grid:update(dt)
  for r = 1, #self._m do
    for c = 1, #self._m[r] do
      self._m[r][c]:update(dt)
    end
  end
end

function Grid:draw()
  for r = 1, #self._m do
    for c = 1, #self._m[r] do
      self._m[r][c]:draw()
    end
  end
end

return setmetatable(Grid, { __call = Grid.new })
