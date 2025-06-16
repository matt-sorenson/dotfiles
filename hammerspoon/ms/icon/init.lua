local print = require('ms.logger').new('ms.icon')

local streamdeck_colors = require('ms.colors').streamdeck

local get_canvas_from_color = require 'ms.icon.from_color'
local get_canvas_from_text = require 'ms.icon.from_text'
local get_canvas_from_file = require 'ms.icon.from_file'
local get_canvas_from_canvas = require 'ms.icon.from_canvas'

local builtin_resolutions = {
    default = { width = 96, height = 96 },
    streamdeck_button = { width = 96, height = 96 },
    streamdeck_encoder = { width = 200, height = 100 },
}

--[[
# Options can be passed in as an array of options or a single configuration.

## Configuration

### Must have one of
- `path` - path to the icon file, rooted from sys.get_resource_path('icons/' .. path)
- `text` - text to render as an icon
- `color` - color to render as an icon
- `canvas` - an array of canvas elements to render as an icon

### Options available to all icon types
- `background_color`
- `skip_background_color` -- Don't draw a background color

- `frame` - table with { x, y, w, h } fields
- `size` - if a frame was provided then this will be ignored
- `width` - if a frame or size was provided then this will be ignored
- `height` - if a frame or size was provided then this will be ignored

### Options available to `path` & `text`
- `transformation` - a `hs.canvas.matrix` to apply to the icon

### Options available to `text`
- `text_color`
- `font`
- `font_size`
- `text_alignment` - one of ['left', 'right', 'center', 'justified', 'natural']
]]
local function get_icon(options)
    if options.canvas or options.text or options.path or options.color then
        local size = options.size
        options = { options }
        options.size = size
    end

    -- Fill in the full size of the button as black
    if options.size == 'streamdeck_button' or options.size == 'streamdeck_encoder' then
        table.insert(options, 1, { color = streamdeck_colors.black, size = options.size })
    end

    local elements = {}
    for _, option in ipairs(options) do
        if not option.frame then
            local width
            local height
            local resolution = builtin_resolutions[option.size or options.size]
            if resolution then
                width = resolution.width
                height = resolution.height
            elseif option.width and option.height then
                width = option.width
                height = option.height
            end

            if not width or not height then
                print:warn('No width or height provided, using default', options)
                local resolution = builtin_resolutions['default']
                width = resolution.width
                height = resolution.height
            end

            option.frame = { x = 0, y = 0, w = width, h = height }
        end

        local res
        if option.path then
            res = get_canvas_from_file(option.path, option)
        elseif option.text then
            res = get_canvas_from_text(option.text, option)
        elseif option.color then
            res = get_canvas_from_color(option.color, option)
        elseif option.canvas then
            res = option.canvas
        else
            print:error('You must provide either a path, text, color, or canvas to get_icon', option)
        end

        table.append(elements, res)
    end

    local resolution = builtin_resolutions[options.size or 'default']
    local width = options.width or resolution.width
    local height = options.height or resolution.height

    return get_canvas_from_canvas(elements, width, height)
end

local _get_icon_mt = {
    __index = {
        clear_canvas_cache = get_canvas_from_canvas.clear_canvas_cache,
    },
    __call = function(self, elements)
        return get_icon(elements)
    end,
}

local out = {}
setmetatable(out, _get_icon_mt)

return out
