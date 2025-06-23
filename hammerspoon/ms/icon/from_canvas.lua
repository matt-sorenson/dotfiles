local print = require('ms.logger').new('ms.icon.from_canvas')

local canvas_cache = {}

local function get_canvas(w, h)
    local key = string.format("%dx%d", w, h)
    local canvas = canvas_cache[key]

    if not canvas then
        print:infof("Creating new canvas for '%s'", key)
        canvas = hs.canvas.new({ x = 0, y = 0, w = w, h = h })
        canvas_cache[key] = canvas
    else
        print:debugf("Reusing canvas for '%s'", key)
    end

    return canvas
end

local function clear_canvas_cache()
    table.each(canvas_cache, function(canvas) canvas:delete() end)

    canvas_cache = {}
end

local function get_icon_from_canvas(elements, width, height)
    local canvas = get_canvas(width, height)

    canvas:replaceElements(elements)

    return canvas:imageFromCanvas()
end

local _from_canvas_mt = {
    __index = {
        clear_canvas_cache = clear_canvas_cache,
    },
    __call = function(_self, elements, width, height)
        return get_icon_from_canvas(elements, width, height)
    end,
}

local out = {}
setmetatable(out, _from_canvas_mt)

return out
