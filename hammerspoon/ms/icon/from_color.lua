local print = require('ms.logger').new('ms.icon.from_color')

local colors = require('ms.colors').streamdeck

local function get_canvas_from_color(color, options)
    if not color then
        print:warn('get_canvas_from_color called with no color, defaulting to colors.missing')
        color = colors.missing
    end

    return {
        {
            action = "fill",
            frame = options.frame,
            fillColor = color,
            type = "rectangle",
        }
    }
end

return get_canvas_from_color
