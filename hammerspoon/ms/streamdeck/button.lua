local print = require('ms.logger').logger_fn('ms.streamdeck.button')

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
        on_press = function(self, deck) end,
        on_release = function(self, deck) end,

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

    if config.refresh_rate then
        local refresh_rate = config.refresh_rate
        out.get_refresh_rate = function(self) return refresh_rate end
    elseif config.get_refresh_rate then
        out.get_refresh_rate = config.get_refresh_rate
    end

    if config.icon then
        local icn

        if type(config.icon) == 'userdata' then
            -- 'userdata' here means it's an `hs.image`
            icn = config.icon
        else
            icn = icon.get_icon(config.icon)
        end

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
