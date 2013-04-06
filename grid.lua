local Class = require 'lib.class'
local Hex   = require 'hex'
local Timer = require 'lib.timer'
local Utils = require 'utils'

local sqrt, floor = math.sqrt, math.floor

local Grid = Class{}
function Grid:init(rows, columns, side)
  self._count = rows * columns
  self._m = {}
  self._order = {}
  for i = 1, self._count - 1 do
    self._order[i] = i
  end
  self._order = Utils.shuffle(self._order)

  local apothem = sqrt(3) / 2 * side

  local r, c = 1, 1
  for r = 1, rows do
    self._m[r] = {}

    for c = 1, columns do
      local x, y
      if c % 2 == 1 then
        local c = floor(c / 2)
        x, y = 3 * side * c, 2 * apothem * (r - 1)
      else
        local hx, hy = self._m[r][c - 1]:getHomePosition()
        x, y = hx + (3 * side / 2), hy + apothem
      end

      self._m[r][c] = Hex(x, y, side, apothem)
    end
  end

  Timer.addPeriodic(0.001, function() self:launch() end, self._count - 1)
end

function Grid:launch()
  self._count = self._count - 1
  local n = self._order[self._count]
  local r, c = floor(n / #self._m[1]) + 1, n % #self._m[1] + 1
  self._m[r][c].start = true
end

function Grid:reset()
  self._order = Utils.shuffle(self._order)
  self._count = #self._m * #self._m[1]
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

return Grid
