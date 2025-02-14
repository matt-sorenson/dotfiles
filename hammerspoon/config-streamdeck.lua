local audio    = require 'ms.audio'
local colors = require 'ms.colors'
local icon = require 'ms.icon'
local ha = require 'ms.home-assistant'

local print = require('ms.logger').logger_fn('config:streamdeck')

return {
  buttons = {
    [1] = {
      type = 'folder',
      icon = icon.get_icon({ path = 'home-assistant.png' }),
      buttons = {
        [5] = {
          on_press = function(self, deck)
            print('Trying to trigger keylight')
            ha.post('matt-office-keylight.toggle')
            print('Tried triggering keylight')
          end,
  
          icon = { text = '🔆' },
        }
      },
    },
    [4] = {
      on_press = function(self, deck)
        audio.toggle_input_mute()
        return true
      end,

      get_icon = function(self)
        if audio.is_input_muted() then
          return icon.get_icon({ path = 'mic-muted.png', size = 'streamdeck_button' })
        else
          return icon.get_icon({ path = 'mic-unmuted.png', size = 'streamdeck_button' })
        end
      end,
    },
    [8] = {
      on_press = function(self, deck)
        audio.toggle_mute()
        return true
      end,

      get_icon = function(self)
        local icon_path = 'speaker-unmuted.png'
        
        if audio.is_muted() then
          icon_path = 'speaker-muted.png'
        end

        return icon.get_icon({
          path = icon_path,
          size = 'streamdeck_button'
        })
      end,
    },
  },

  encoders = {
    [4] = {
      on_turn = function(self, deck, direction)
        if direction == 'left' then
          audio.update_volume(-7)
        else
          audio.update_volume(7)
        end

        return true
      end,

      get_screen_image = function(self)
        local volume = audio.get_volume()

        return icon.get_icon({
          text = string.format('%i', math.floor(volume)),
          font_size = 50,
          size = 'streamdeck_encoder',
        })
      end,
    },
  },
}
