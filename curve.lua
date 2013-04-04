local Curve = {}
Curve.__index = Curve

function Curve:new(cp)
  local t = {}
  for _,v in ipairs(cp) do
    t[#t + 1] = v[1]
    t[#t + 1] = v[2]
  end
  return setmetatable({ _cp = t }, self)
end

local function split(t)
  local x, y = {}, {}
  for i,v in ipairs(t) do
    if i % 2 == 1 then x[#x + 1] = v else y[#y + 1] = v end
  end
  return x, y
end

local function deCasteljau(t, v, sz)
  if sz == 1 then return v[1] end

  local nv = {}
  for i = 1, sz - 1 do
    nv[i] = (1 - t) * v[i] + t * v[i + 1]
  end

  return deCasteljau(t, nv, sz - 1)
end

function Curve:build(step)
  step = step or 0.01

  local points = {}
  local x, y = split(self._cp)
  for i = 0, 1, step do
    local a, b = self:interpolate(i, x, y)
    points[#points + 1] = a
    points[#points + 1] = b
  end
  return points
end

function Curve:interpolate(t, x, y)
  if not (x and y) then
    x, y = split(self._cp)
  end

  return deCasteljau(t, x, #x), deCasteljau(t, y, #y)
end

return setmetatable(Curve, { __call = Curve.new })
