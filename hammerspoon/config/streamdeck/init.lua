local audio  = require 'ms.audio'

local helpers = require 'config.streamdeck.helpers'

return {
    buttons = {
        [1] = require('config.streamdeck.homeassistant'),

        [4] = {
            on_press = function(_self, _deck)
                audio.toggle_input_mute()
                return true
            end,

            get_icon = function(_self)
                if audio.is_input_muted() then
                    return helpers.button_icon('mic-muted.png')
                else
                    return helpers.button_icon('mic-unmuted.png')
                end
            end,
        },
        [8] = {
            on_press = function(_self, _deck)
                audio.toggle_mute()
                return true
            end,

            get_icon = function(_self)
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
            on_turn = function(_self, _deck, direction)
                if direction == 'left' then
                    audio.decrease_volume()
                else
                    audio.increase_volume()
                end

                return true
            end,

            get_screen_image = function(_self)
                return { text = string.format('%i', math.floor(audio.get_volume())) }
            end,
        },
    },
}
