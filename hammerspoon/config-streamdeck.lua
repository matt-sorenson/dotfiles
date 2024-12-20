local audio    = require 'ms.audio'

local icon = require 'ms.icon'

return {
  buttons = {
      {
          type = 'folder',

          buttons = {
              'up',
              'blank',
              'blank',
              'blank',

              'blank',
              'blank',
              'blank',
              'blank',
          }
      },
      'blank',
      'blank',
      {
          on_press = function(self, deck)
              audio.toggle_mic_mute()
              return true
          end,

          get_icon = function(self)
              if audio.is_mic_muted() then
                  return icon.get_icon({
                      path = 'mic-muted.png',
                  })
              else
                  return icon.get_icon({
                      path = 'mic-unmuted.png',
                  })
              end
          end,
      },

      'blank',
      'blank',
      'blank',
      {
          on_press = function(self, deck)
              audio.toggle_mute()
              return true
          end,

          get_icon = function(self)
              if audio.is_muted() then
                  return icon.get_icon({
                      path = 'speaker-muted.png',
                  })
              else
                  return icon.get_icon({
                      path = 'speaker-unmuted.png',
                  })
              end
          end,
      },
  }
}