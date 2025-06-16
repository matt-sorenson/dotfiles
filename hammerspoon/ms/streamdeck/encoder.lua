local print = require('ms.logger').new('ms.streamdeck.encoder')

local colors = require('ms.colors').streamdeck
local sys_get_icon = require 'ms.icon'

--[[
  Represents a single encoder on the stream deck
]]

local SCREEN_WIDTH = 800
local SCREEN_HEIGHT = 100

local TOTAL_ENCODERS = 4
local PER_ENCODER_SCREEN_WIDTH = SCREEN_WIDTH / TOTAL_ENCODERS
local PER_ENCODER_SCREEN_HEIGHT = SCREEN_HEIGHT

local DEFAULT_COLOR = colors.black

local blank_encoder_screen_image = sys_get_icon({
    size = 'streamdeck_encoder',
})

local encoder_mt = {
    __index = {
        on_press = function(self, deck) end,
        on_release = function(self, deck) end,

        -- direction will be either 'left' or 'right'
        on_turn = function(self, deck, direction) end,

        --[[
          returns
            - `hs.image` - a rendered image to draw
            - table, see `ms.icon` for more information
              - width/height should be included
        ]]
        get_screen_image = function(self) return blank_encoder_screen_image end,

        get_screen_width = function(self) return PER_ENCODER_SCREEN_WIDTH end,
        get_screen_height = function(self) return PER_ENCODER_SCREEN_HEIGHT end,

        --[[
          returns
            - nil if the screen does not refresh by itself
            - number - how often to refresh the screen in seconds
        ]]
        get_screen_refresh_rate = function(self) return nil end,

        -- This function forces a redraw, useful for updates triggered by a callback
        redraw = function(self, deck) end,
    }
}

--[[ export ]]
local function encoder_new(config, deck_frame, encoder_idx)
    local out = {}
    setmetatable(out, encoder_mt)

    if not config then
        config = {}
    end

    if config.refresh_rate then
        out.get_screen_refresh_rate = function(self) return config.refresh_rate end
    elseif config.get_screen_refresh_rate then
        out.get_screen_refresh_rate = config.get_screen_refresh_rate
    end

    out.on_press = config.on_press
    out.on_release = config.on_release
    out.on_turn = config.on_turn
    out.get_screen_image = config.get_screen_image

    if deck_frame then
        out.redraw = function(self, deck)
            if encoder_idx then
                deck_frame:redraw_encoder(deck, encoder_idx)
            else
                deck_frame:redraw(deck)
            end
        end
    end

    return out
end

return {
    new = encoder_new,
}
