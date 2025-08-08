local print = require('ms.logger').new('ms.streamdeck.deck_frame')

local sys_get_icon = require 'ms.icon'

local button = require 'ms.streamdeck.button'
local encoder = require 'ms.streamdeck.encoder'

--[[
  A Deck frame represents a single view on the stream deck, it acts as a stack
  where pushing a new frame takes over the deck and popping it returns to the
  parent frame.

  Outside of the base stack frame all frames should have a 'pop stack' button.
]]

--[[
  config = {
    buttons = {
      { -- Any of the button fields may be nil
        type = 'button', -- nil will be treated as 'button'

        -- Most implementations will just need `on_press` to be defined but
        -- `on_release` is available if it is needed.
        -- If either method returns `true` then the button will be redrawn.
        on_press = function(self, deck) end,
        on_release = function(self, deck) end,

        -- If `icon` is provided it will be used, otherwise falls back to `get_icon()`
        -- get_icon should return either an `hs.image` or a table for `ms.sys_get_icon()`
        icon = `hs.image` or input table for `ms.sys_get_icon()`
        get_icon = function(self) end,

        -- If refresh_rate is provided then it is used, otherwise falls back to
        -- `get_refresh_rate()`. If neither is provided a default
        -- `get_refresh_rate()` is provided that returns nil. `get_refresh_rate()`
        -- is called any time the the deck frame is entered.
        refresh_rate = number, -- seconds,
        get_refresh_rate = function(self) return <time_in_seconds> or nil end,
      },

      {
        type = 'folder',

        buttons = {},
        encoders = {},
      }
    },

    encoders = {
      { -- Any of the encoder fields may be nil
        on_press = function(self, deck) end,
        on_release = function(self, deck) end,
        on_turn = function(self, deck, direction) end,
        get_screen_image = function(self) end,
        get_screen_refresh_rate() = function(self) end,
      },
    },
  }
]]

local function redraw(self, deck)
    local button_columns, button_rows = deck:buttonLayout()
    local button_count = button_columns * button_rows

    for i = 1, button_count do
        self:redraw_button(deck, i)
    end

    local encoder_count = 4
    for i = 1, encoder_count do
        self:redraw_encoder(deck, i)
    end
end

local noop_button = button.new()
local function redraw_button(self, deck, button_idx)
    local icn

    if self.buttons[button_idx] then
        icn = self.buttons[button_idx]:get_icon()

        if type(icn) == 'table' then
            if (not icn.width or not icn.height) and not icn.size then
                icn.size = 'streamdeck_button'
            end

            icn = sys_get_icon(icn)
        end
    else
        icn = noop_button:get_icon()
    end

    deck:setButtonImage(button_idx, icn)
end

local noop_encoder = encoder.new()
local function redraw_encoder(self, deck, encoder_idx)
    local icn

    if self.encoders[encoder_idx] then
        icn = self.encoders[encoder_idx]:get_screen_image()

        if type(icn) == 'table' and (not icn.width or not icn.height ) and not icn.size then
            icn.size = 'streamdeck_encoder'
        end

        icn = sys_get_icon(icn)
    else
        icn = noop_encoder:get_screen_image()
    end

    deck:setScreenImage(encoder_idx, icn)
end

local function button_callback(self, deck, btn, pressed)
    local result
    if self.buttons[btn] then
        if pressed then
            result = self.buttons[btn]:on_press(deck)
        else
            result = self.buttons[btn]:on_release(deck)
        end
    end

    if result == nil then
        return false
    end

    if result then
        self:redraw_button(deck, btn)
    end

    return result
end

local function encoder_callback(self, deck, enc, direction)
    local result
    if self.encoders[enc] then
        result = self.encoders[enc]:on_turn(deck, direction)
    end

    if result == nil then
        return false
    end

    if result then
        self:redraw_encoder(deck, enc)
    end

    return result
end

local function refresh_button(deck_frame, button_idx, deck)
    deck_frame:redraw_button(deck, button_idx)
end

local function refresh_encoder(deck_frame, encoder_idx, deck)
    deck_frame:redraw_encoder(deck, encoder_idx)
end

local function setup_timer(deck_frame, method, index, deck, interval)
    return hs.timer.new(interval, function()
        method(deck_frame, index, deck)
    end)
end

local function enter(self, deck)
    self:on_enter(deck)

    deck:buttonCallback(function(deck, btn, pressed) -- luacheck: ignore deck
        button_callback(self, deck, btn, pressed)
    end)

    deck:encoderCallback(function(deck, enc, pressed, left, right) -- luacheck: ignore deck
        if left then
            encoder_callback(self, deck, enc, 'left')
        elseif right then
            encoder_callback(self, deck, enc, 'right')
        elseif pressed then
            self.encoders[enc]:on_press(deck)
        else
            self.encoders[enc]:on_release(deck)
        end
    end)

    redraw(self, deck)

    self.timers = {}
    for i, btn in pairs(self.buttons) do
        local refresh_rate = btn.get_refresh_rate()
        if refresh_rate then
            local timer = setup_timer(self, refresh_button, i, deck, refresh_rate)
            timer:start()

            table.insert(self.timers, timer)
        end
    end

    for i, enc in pairs(self.encoders) do
        local refresh_rate = enc.get_screen_refresh_rate()
        if refresh_rate then
            local timer = setup_timer(self, refresh_encoder, i, deck, refresh_rate)
            timer:start()

            table.insert(self.timers, timer)
        end
    end
end

local function exit(self, deck)
    -- Stop and delete all timers
    table.ieach(self.timers, function(timer) timer:stop() end)
    self.timers = {}

    self:on_exit(deck)
end

local deck_frame_mt = {
    __index = {
        on_enter = function(_self, _deck) end,
        on_exit = function(_self, _deck) end,

        get_icon = function(_self) end,
        get_text = function(_self) end,

        enter = enter,
        exit = exit,

        redraw = redraw,
        redraw_button = redraw_button,
        redraw_encoder = redraw_encoder,
    }
}

local up_icon = sys_get_icon({
    text = '⏎',

    -- Have the return icon point up to be similar to browser/file explorer 'up' icon
    -- Last translate is off a bit to make it look more visually centered
    transform = hs.canvas.matrix.translate(48, 48):scale(-1, 1):rotate(90):translate(-48, -43),

    size = 'streamdeck_button',
})

local function deck_frame_new(config, parent)
    local out = {}
    setmetatable(out, deck_frame_mt)

    out.timers = {}

    out.buttons = {}
    if config.buttons then
        for i, btn in pairs(config.buttons) do
            if btn.type == 'folder' then
                local child_frame = deck_frame_new(btn, out)

                local get_icon
                if btn.icon then
                    get_icon = function(_self) return btn.icon end
                elseif btn.get_icon then
                    get_icon = btn.get_icon
                else
                    get_icon = function(_self) return sys_get_icon({ text = '📁' }) end
                end

                out.buttons[i] = button.new({
                  on_press = function(_self, deck)
                      out:exit(deck)
                      child_frame:enter(deck)
                  end,
                  get_text = function(_self)
                      return child_frame:get_text()
                  end,
                  get_icon = get_icon,
                })
            else
                out.buttons[i] = button.new(btn, out, i)
            end
        end
    end

    -- Overwrite any provided button 1 with a 'pop' button
    if parent then
        if config.buttons[1] and config.buttons[1] ~= 'pop' then
            print:warn(
                "Provided a button '1' when parent frame exists, " ..
                "this will be overwritten by the 'pop' button"
            )
        end

        out.buttons[1] = button.new({
            on_press = function(_self, deck)
                out:exit(deck)
                parent:enter(deck)
            end,
            get_icon = function(_self) return up_icon end,
        })
    end

    out.encoders = {}
    if config.encoders then
        for i, encoder_config in pairs(config.encoders) do
            out.encoders[i] = encoder.new(encoder_config, out, i)
        end
    end

    return out
end

local function init(config)
    local out = deck_frame_new(config)

    hs.streamdeck.init(function(connected, deck)
        if connected then
            print("streamdeck connected")
            out:enter(deck)
        else
            print("streamdeck disconnected")
        end
    end)
end

return {
    new = init,
}
