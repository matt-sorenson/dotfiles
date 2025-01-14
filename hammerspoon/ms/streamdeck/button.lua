local print = require('ms.logger').logger_fn('config:streamdeck:button')

local colors = require 'ms.colors'
local icon = require 'ms.icon'

--[[
  A button represents a single button on the stream deck
]]

local BUTTON_HEIGHT = 96
local BUTTON_WIDTH = 96
local DEFAULT_COLOR = colors.black

local blank_button_image = icon.get_icon({
  color = DEFAULT_COLOR,
  width = PER_ENCODER_SCREEN_WIDTH,
  height = PER_ENCODER_SCREEN_HEIGHT,
})

local button_mt = {
  __index = {
    --[[
      for `on_press`/`on_release` if a true is returned then the button
      will be redrawn after the callback is complete
    ]]
    on_press = function(self, deck) end,
    on_release = function(self, deck) end,

    --[[
      return
        - `hs.image` - the rendered image to display
        - { canvas = hs.canvas } } - a canvas to render
          - see see also ms.icon.get_icon_from_canvas for description
          - see also https://www.hammerspoon.org/docs/hs.canvas.html
    ]]
    get_icon = function(self) return blank_button_image end,

    -- return nil if the screen does not refresh by itself
    get_refresh_rate = function(self, deck) return nil end,

    -- This function that can be called to force the current
    -- deck stack frame to be redrawn, useful for updates triggered by
    -- a watcher or other external event
    redraw = function(self) end,
  }
}

--[[ export ]] local function button_new(config, frame, button_idx)
  local out = {}
  setmetatable(out, button_mt)

  if not config then
    config = {}
  end

  out.on_press = config.on_press
  out.on_release = config.on_release
  out.get_refresh_rate = config.get_refresh_rate

  if config.icon then
    icn = icon.get_icon(config.icon)
    out.get_icon = function(self) return icn end
  else
    out.get_icon = config.get_icon
  end

  -- The only time frame shouldn't be passed in is for 'automatic' buttons
  -- created by the ms.streamdeck library (like the button for popping the stack)
  if frame then
    out.redraw = function(self, deck)
      if button_idx then
        frame:redraw_button(deck, button_idx)
      else
        frame:redraw(deck)
      end
    end
  end

  return out
end

return {
  new = button_new,
}
