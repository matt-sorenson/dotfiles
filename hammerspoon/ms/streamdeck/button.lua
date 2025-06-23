local sys_get_icon = require 'ms.icon'

--[[
  A button represents a single button on the stream deck
]]

local blank_button_image = sys_get_icon({size = 'streamdeck_button'})

local button_mt = {
    __index = {
        on_press = function(_self, _deck) end,
        on_release = function(_self, _deck) end,

        get_icon = function(_self) return blank_button_image end,

        -- return nil if the screen does not refresh by itself
        get_refresh_rate = function(_self, _deck) return nil end,

        -- This function that can be called to force the current
        -- deck stack frame to be redrawn, useful for updates triggered by
        -- a watcher or other external event
        redraw = function(_self) end,
    }
}

--[[ export ]]
local function button_new(config, frame, button_idx)
    local out = {}
    setmetatable(out, button_mt)

    if not config then
        config = {}
    end

    out.on_press = config.on_press
    out.on_release = config.on_release

    if config.refresh_rate then
        local refresh_rate = config.refresh_rate
        out.get_refresh_rate = function(_self) return refresh_rate end
    elseif config.get_refresh_rate then
        out.get_refresh_rate = config.get_refresh_rate
    end

    if config.icon then
        local icn

        icn = config.icon

        out.get_icon = function(_self) return icn end
    else
        out.get_icon = config.get_icon
    end

    -- The only time frame shouldn't be passed in is for 'automatic' buttons
    -- created by the ms.streamdeck library (like the button for popping the stack)
    if frame then
        out.redraw = function(_self, deck)
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
