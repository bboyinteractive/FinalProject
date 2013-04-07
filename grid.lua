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
        x = self._m[r][c - 1].x + (3 * side / 2)
        y = self._m[r][c - 1].y + apothem
      end

      self._m[r][c] = Hex(x, y, side, apothem)
    end
  end
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
