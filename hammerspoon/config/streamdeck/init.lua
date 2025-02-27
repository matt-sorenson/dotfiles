local print  = require('ms.logger').new('config.streamdeck.init')

local audio  = require 'ms.audio'

local helpers = require 'config.streamdeck.helpers'

return {
    buttons = {
        [1] = require('config.streamdeck.homeassistant'),

        [4] = {
            on_press = function(self, deck)
                audio.toggle_input_mute()
                return true
            end,

            get_icon = function(self)
                if audio.is_input_muted() then
                    return helpers.button_icon('mic-muted.png')
                else
                    return helpers.button_icon('mic-unmuted.png')
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
                    return helpers.button_icon('speaker-muted.png')
                else
                    return helpers.button_icon('speaker-unmuted.png')
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
