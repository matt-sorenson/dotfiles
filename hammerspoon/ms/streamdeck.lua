local audio = require 'ms.audio'

local colors = require'ms.colors'

local get_icon = require('ms.icon').get_icon

local print = require('ms.logger').logger_fn('streamdeck')

local current_deck = nil
local asleep = false

local current_button_state = {}
local current_update_timers = {}

local button_state_stack = {}

local function streamdeck_discovery(connected, deck)
  print("Start streamdeck_discovery")

  if connected then
    print("Deck connected")

    local icon = get_icon({
      text = '🔊',
      background_color = colors.black,
    })

    deck:setButtonImage(1, icon)
    deck:buttonCallback(function(deck, button, pressed)
      if button == 1 and pressed then
        audio:toggle_mute()
      elseif button == 2 and pressed then
        audio:toggle_mic_mute()
      end

      print(button .. ' ' .. tostring(pressed))

      local text = '🔊'
      if audio:is_muted() then
        text = '🔇'
      end

      local icon = get_icon({
        text = text,
        background_color = colors.black,
      })
      deck:setButtonImage(1, icon)

      local text = '🎤'
      local background_color = colors.black
      if audio:is_muted() then
        text = '🎤'
        background_color = colors.red
      end

      local icon = get_icon({
        text = text,
        background_color = background_color,
      })
      deck:setButtonImage(2, icon)
    end)
  else
    print("Deck not connected")
  end

  print("End streamdeck_discovery")
end

hs.streamdeck.init(streamdeck_discovery)