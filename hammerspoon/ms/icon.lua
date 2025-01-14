local sys = require 'ms.sys'
local colors = require "ms.colors"

local print = require('ms.logger').logger_fn('icon')

-- Lots stolen from https://github.com/peterhajas/dotfiles/blob/a717d8fb0e89c787112f78529f97f1314ad70377/hammerspoon/.hammerspoon/

local BUTTON_WIDTH = 96
local BUTTON_HEIGHT = 96

local shared_canvas = hs.canvas.new({ x = 0, y = 0, w = BUTTON_WIDTH, h = BUTTON_HEIGHT })

local function get_icon_from_canvas(elements, options)
  local width = options.width or BUTTON_WIDTH
  local height = options.height or BUTTON_HEIGHT

  local canvas = shared_canvas

  if width ~= BUTTON_WIDTH or height ~= BUTTON_HEIGHT then
    canvas = hs.canvas.new({ x = 0, y = 0, w = width, h = height })
  end

  canvas:replaceElements(elements)

  local image = canvas:imageFromCanvas()

  if canvas ~= shared_canvas then
    canvas:delete()
  end

  return image
end

local function try_load_image(path)
  return hs.image.imageFromPath(sys.get_resource_path('icons/' .. path))
end

local EXTENSIONS_TO_TRY = { '.png', '.svg' }

--[[
# Icon Options

- `path` - path to the icon file
- `text` - text to render as an icon

## All icon type options
- `background_color`
- `skip_background_color` -- Don't draw a background color

- `width`
- `height`

## Options specific to `text` icons
- `text_color`
- `font`
- `font_size`
]]

-- if this returns nil should probably `try_load_image('error.png')` to make
-- it visually clear that the icon is missing
local function load_icon_from_file(path)
  local image = try_load_image(path)
  if path then
    return image
  end

  for _, ext in pairs(EXTENSIONS_TO_TRY) do
    image = try_load_image(path .. ext)
    if image then
      return image
    end
  end

  print("failed to load icon: " .. path)
end

local function get_icon_from_file(path, options)
  local image = try_load_image(path)

  if not image then
    image = try_load_image('error.png')
  end

  local elements = {}

  local width = options.width or BUTTON_WIDTH
  local height = options.height or BUTTON_HEIGHT

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
  local options = options or { }
  local text_color = options.text_color or colors.off_white
  local font = options['font'] or ".AppleSystemUIFont"
  local font_size = options['font_size'] or 70
  local elements = {}

  local width = options.width or BUTTON_WIDTH
  local height = options.height or BUTTON_HEIGHT

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
  local width = options.width or BUTTON_WIDTH
  local height = options.height or BUTTON_HEIGHT

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

--[[ export ]] local function get_icon(options)
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
    print('You must provide either a path or text to get_icon')
  end
end

return {
  get_icon = get_icon
}
