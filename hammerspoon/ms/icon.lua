local print = require('ms.logger').print_fn('ms.icon')

local sys = require 'ms.sys'
local colors = require "ms.colors"

-- Lots stolen from https://github.com/peterhajas/dotfiles/blob/a717d8fb0e89c787112f78529f97f1314ad70377/hammerspoon/.hammerspoon/

local builtin_resolutions = {
    default = { width = 96, height = 96 },
    streamdeck_button = { width = 96, height = 96 },
    streamdeck_encoder = { width = 200, height = 100 },
}

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

local function get_icon_from_canvas(elements, options)
    local resolution = builtin_resolutions[options.size or 'default']
    local width = options.width or resolution.width
    local height = options.height or resolution.height

    local canvas = get_canvas(width, height)

    canvas:replaceElements(elements)

    return canvas:imageFromCanvas()
end

local function try_load_image(path)
    return hs.image.imageFromPath(sys.get_resource_path('icons/' .. path))
end

local function get_icon_from_file(path, options)
    local image = try_load_image(path)

    if not image then
        image = try_load_image('error.png')
    end

    local elements = {}

    local resolution = builtin_resolutions[options.size or 'default']
    local width = options.width or resolution.width
    local height = options.height or resolution.height

    local canvas = get_canvas(width, height)

    if not options.skip_background_color then
        table.insert(elements, {
            action = "fill",
            frame = { x = 0, y = 0, w = width, h = height },
            fillColor = options.background_color or colors.black,
            type = "rectangle"
        })
    end

    table.insert(elements, {
        frame = { x = 0, y = 0, w = width, h = height },
        image = image,
        type = "image",
        transformation = options.transform,
    })

    return get_icon_from_canvas(elements, options)
end

local function get_icon_from_text(text, options)
    local options = options or {}
    local text_color = options.text_color or colors.off_white
    local font = options['font'] or ".AppleSystemUIFont"
    local font_size = options['font_size'] or 70
    local elements = {}

    local resolution = builtin_resolutions[options.size or 'default']
    local width = options.width or resolution.width
    local height = options.height or resolution.height

    if not options.skip_background_color then
        table.insert(elements, {
            action = "fill",
            frame = { x = 0, y = 0, w = width, h = height },
            fillColor = options.background_color or colors.black,
            type = "rectangle",
        })
    end

    table.insert(elements, {
        frame = { x = 0, y = 0, w = width, h = height },
        text = hs.styledtext.new(text, {
            font = { name = font, size = font_size },
            paragraphStyle = { alignment = "center" },
            color = text_color,
        }),
        type = "text",
        transformation = options.transform,
    })

    return get_icon_from_canvas(elements, options)
end

local function get_icon_for_color(color, options)
    local resolution = builtin_resolutions[options.size or 'default']
    local width = options.width or resolution.width
    local height = options.height or resolution.height

    local elements = {
        {
            action = "fill",
            frame = { x = 0, y = 0, w = width, h = height },
            fillColor = color or colors.black,
            type = "rectangle",
        }
    }

    return get_icon_from_canvas(elements, options)
end

--[[
# Icon Options

- `path` - path to the icon file
- `text` - text to render as an icon
- `color` - color to render as an icon
- `canvas` - a table of canvas elements to render as an icon

## All icon type options
- `background_color`
- `skip_background_color` -- Don't draw a background color

- `width`
- `height`

## Options specific to `text` icons
- `text_color`
- `font`
- `font_size`

## Options specific to `colors` icons
- `color` - the color to render

## Options specific to `canvas` icons
- `canvas` - the canvas elements to render (as an array)
]]
--[[ export ]]
local function get_icon(options)
    if type(options) == 'string' then
        options = { text = options }
    end

    if options.path then
        return get_icon_from_file(options.path, options)
    elseif options.text then
        return get_icon_from_text(options.text, options)
    elseif options.color then
        return get_icon_for_color(options.color, options)
    elseif options.canvas then
        return get_icon_from_canvas(options.canvas, options)
    else
        print:error('You must provide either a path, text, color or canvas to get_icon')
    end
end

return {
    get_icon = get_icon,

    clear_canvas_cache = clear_canvas_cache,
}
