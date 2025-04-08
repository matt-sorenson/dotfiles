local print = require('ms.logger').new('ms.icon')

local colors = require('ms.colors').streamdeck
local ls = require 'ms.sys'

local function try_load_image(path)
    return hs.image.imageFromPath(ls.get_resource_path('icons/' .. path))
end

local function get_canvas_from_file(path, options)
    local image = try_load_image(path)

    if not image then
        print:warnf("Failed to load image from path '%s'", path)
        image = try_load_image('error.png')
    end

    local elements = {}

    if not options.skip_background_color then
        table.insert(elements, {
            action = 'fill',
            frame = options.frame,
            fillColor = options.background_color or colors.black,
            type = 'rectangle'
        })
    end

    table.insert(elements, {
        frame = options.frame,
        image = image,
        type = 'image',
        transformation = options.transform,
    })

    return elements
end

return get_canvas_from_file