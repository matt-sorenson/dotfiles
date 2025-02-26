local print  = require('ms.logger').new('config:streamdeck')

local audio  = require 'ms.audio'
local ha     = require 'ms.home-assistant'
local colors = require 'ms.colors'

return {
  buttons = {
    [1] = {
      type = 'folder',
      icon = { path = 'home-assistant.png' },
      buttons = {
        [4] = {
          on_press = function(self, deck)
            ha.post('matt-office-sunlight:toggle')
          end,
    
          icon = {
            {
              text = '🔆',
            },
            {
              text = 'sunlamp',
              font_size = 20,
              text_alignment = 'center',
              frame = {
                x = 0,
                y = 96-30,
                w = 96,
                h = 22,
              },
              background_color = { red = 0, green = 0, blue = 0, alpha = .5 },
            },
          },
        },
        [8] = {
          on_press = function(self, deck)
            ha.post('matt-office-keylight:toggle')
          end,
    
          icon = {
            {
              text = '🔑',
            },
            {
              text = 'keylight',
              font_size = 20,
              text_alignment = 'center',
              frame = {
                x = 0,
                y = 96-30,
                w = 96,
                h = 22,
              },
              background_color = { red = 0, green = 0, blue = 0, alpha = .5 },
            },
          },
        },
      },
    },

    [4] = {
      on_press = function(self, deck)
        audio.toggle_input_mute()
        return true
      end,

      get_icon = function(self)
        if audio.is_input_muted() then
          return { path = 'mic-muted.png' }
        else
          return { path = 'mic-unmuted.png' }
        end
      end,
    },
    [8] = {
      on_press = function(self, deck)
        audio.toggle_mute()
        return true
      end,

      get_icon = function(self)
        if audio.is_muted() then
          return { path = 'speaker-muted.png' }
        else
          return { path = 'speaker-unmuted.png' }
        end
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

        return { text = string.format('%i', math.floor(volume)) }
      end,
    },
  },
}
