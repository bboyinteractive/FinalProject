local lf, lg = love.filesystem, love.graphics
local abs, ceil, random, sqrt, max, min = math.abs, math.ceil, math.random, math.sqrt, math.max, math.min

return {
  dist = function(x, y)
    return sqrt(x * x + y * y)
  end,
  createEffect = function (filename)
    local t = lf.read(filename)
    return lg.newPixelEffect(t)
  end,
  lerp = function (a, b, k)
    return a + (b - a) * k
  end,
  sum = function (t)
    local s = 0
    for _,v in ipairs(t) do
      s = s + v
    end
    return s
  end,
  rescale = function (a0, a1, b0, b1, t)
    return b0 + (t - a0) * (b1 - b0) / (a1 - a0)
  end,
  HSLtoRGB = function (h, s, l)
    if s == 0 then return l, l, l end

    h, s, l = h / 256 * 6, s / 255, l / 255

    local c = (1 - abs(2 * l - 1)) * s
    local x = (1 - abs(h % 2 - 1)) * c

    local m, r, g, b = (l - 0.5 * c), 0, 0, 0

    if h < 1 then
      r, g, b = c, x, 0
    elseif h < 2 then
      r, g, b = x, c, 0
    elseif h < 3 then
      r, g, b = 0, c, x
    elseif h < 4 then
      r, g, b = 0, x, c
    elseif h < 5 then
      r, g, b = x, 0, c
    else
      r, g, b = c, 0, x
    end

    return ceil((r + m) * 256), ceil((g + m) * 256), ceil((b + m) * 256)
  end,
  bound = function (x, l, u)
    return max(min(x, u), l)
  end,
}
