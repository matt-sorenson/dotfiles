local colors = require 'ms.colors'
local icon = require 'ms.icon'

--[[
  Represents a single encoder on the stream deck
]]

local encoder_mt = {
  __index = {
    on_encoder_press = function(self, deck) end,
    on_encoder_release = function(self, deck) end,

    -- direction will be either 'left' or 'right'
    on_encoder_turn = function(self, deck, direction) end,
  }
}

--[[ export -- encoder ]] local function encoder_new(config)
  local out = {}
  setmetatable(out, button_mt)

  out.on_encoder_press = config.on_encoder_press
  out.on_encoder_release = config.on_encoder_release
  out.on_encoder_turn = config.on_encoder_turn

  return out
end

--[[
  The screen represents the screen above the encoders
]]

local screen_mt = {
  __index = {
    on_short_press = function(self, deck, x, y) end,
    on_long_press = function(self, deck, x, y) end,

    -- Direction will be either 'left' or 'right' for simple swipe interactions
    on_swipe = function(self, deck, x_begin, y_begin, direction, x_end, x_end) end,

    render_screen = function(self, deck) end,

    -- return nil if the screen does not refresh by itself
    get_refresh_rate = function(self, deck) return nil end,
  }
}

--[[ export -- screen ]] local function screen_new(config)
  local out = {}
  setmetatable(out, screen_mt)

  out.on_short_press = config.on_short_press
  out.on_long_press = config.on_long_press
  out.on_swipe = config.on_swipe
  out.render_screen = config.render_screen
  out.get_refresh_rate = config.get_refresh_rate


  return out
end

--[[
  A button represents a single button on the stream deck
]]

local button_mt = {
  __index = {
    on_press = function(self, deck) end,
    on_release = function(self, deck) end,

    get_icon = function(self) end,

    --[[
      return `nil` for no text or a table with the following keys:
        - text: the text to display, default is nil (no text)
        - text_color: the color of the text, default: colors.off_white
        - text_size: the size of the text, default: 14
        - background_color: the background color of the text, default: colors.black
        - v_align: vertical alignment of the text, enum: ['top', 'center', 'bottom'], default: 'bottom'
        - h_align: horizontal alignment of the text, enum: ['left', 'center', 'right'], default: 'center'
    ]]
    get_text = function(self)
      return nil

      --[[ example
        return {
          text = 'text',
        }
      ]]
    end,
  }
}


--[[ export -- button ]] local function button_new(config)
local out = {}
  setmetatable(out, button_mt)

  out.on_press = config.on_press
  out.on_release = config.on_release
  out.get_icon = config.get_icon
  out.get_text = config.get_text

  return out
end


--[[
  Stack Frame represents a single view on the stream deck

  Outside of the base stack frame the upper left button will always be a back/'pop stack' button
]]

--[[stack_frame]] local function stack_frame_redraw(self, deck)
  for i, button in ipairs(self.buttons) do
    local icon = button:get_icon()

    if icon then
      deck:setButtonImage(i, icon)
    end
  end
end

--[[stack_frame]] local function stack_frame_enter(self, deck)
  self:on_enter(deck)

  deck:buttonCallback(function(deck, button, pressed)
    stack_frame_button_callback(self, deck, button, pressed)
  end)

  stack_frame_redraw(self, deck)
end

--[[stack_frame]] local function stack_frame_exit(self, deck)
  self:on_exit(deck)
end

--[[stack_frame]] local stack_frame_mt = {
  __index = {
    on_enter = function(self, deck) end,
    on_exit = function(self, deck) end,

    get_icon = function(self) end,
    get_text = function(self) end,

    enter = stack_frame_enter,
    exit = stack_frame_exit,
  }
}

--[[
  -- If a for in the buttons table is the string 'up' then the button will be the 'pop stack' button
  -- An empty table in any of the lists will be an blank/no-op button/encoder

  config = {
    buttons = {
      { -- Any of the button fields may be nil
        type = 'button', -- nil will be treated as 'button'

        on_press = function(self, deck) end,
        on_release = function(self, deck) end,

        get_icon = function(self) end,
        get_text = function(self) end,
      },

      {
        type = 'folder',

        stack = {
          buttons = {},
          encoders = {},
          screen = {},
        }
      }
    },

    encoders = {
      { -- Any of the encoder fields may be nil
        on_encoder_press = function(self, deck) end,
        on_encoder_release = function(self, deck) end,
        on_encoder_turn = function(self, deck, direction) end,
      },
    },

    screen = {
      on_screen_short_press = function(self, deck, x, y) end,
      on_screen_long_press = function(self, deck, x, y) end,
      on_screen_swipe = function(self, deck, x_begin, y_begin, direction, x_end, x_end) end,
      render_screen = function(self, deck) end,
      get_refresh_rate = function(self, deck) return nil end,
    }
  }
]]

-- We use this button when no config is provided for a button so it's handled
-- gracefully.
local noop_button = button_new({
  get_icon = function(self)
    return icon.get_icon({
      color = colors.black,
    })
  end
})

--[[ export -- stack_frame ]] local function stack_frame_new(config, parent)
  local out = {}
  setmetatable(out, stack_frame_mt)

  if config.screen then
    out.screen = screen_new(config.screen)
  end

  out.buttons = {}
  for i, btn in ipairs(config.buttons) do
    if btn == 'up' then
      out.buttons[i] = button_new({
        on_press = function(self, deck)
          if parent then
            out:exit(deck)
            parent:enter(deck)
          end
        end,
        get_icon = function(self)
          return icon.get_icon('⏎')
        end,
      })
    elseif btn == 'blank' then
      out.buttons[i] = noop_button
    elseif btn.type == 'folder' then
      local child_frame = stack_frame_new(btn, out)

      out.buttons[i] = button_new({
        on_press = function(self, deck)
          out:exit(deck)
          child_frame:enter(deck)
        end,
        get_icon = function(self)
          return icon.get_icon({
            color = colors.red,
          })
        end,
        get_text = function(self)
          return child_frame:get_text()
        end,
      })
    else
      out.buttons[i] = button_new(btn)
    end
  end

  for i=1, 8 do
    if not out.buttons[i] then
      out.buttons[i] = noop_button
    end
  end

  return out
end

--[[stack_frame]] function stack_frame_button_callback(self, deck, button, pressed)
  local result

  if pressed then
    result = self.buttons[button]:on_press(deck)
  else
    result = self.buttons[button]:on_release(deck)
  end

  if result then
    stack_frame_redraw(self, deck)
  end
end

function init(config)
  local out = stack_frame_new(config)

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
