local print  = require('ms.logger').new('config:streamdeck')

local audio  = require 'ms.audio'
local ha     = require 'ms.home-assistant'
local colors = require 'ms.colors'

local function button_label(message, valign)
    valign = valign or 'bottom'

    local frame
    if valign == 'bottom' then
        frame = { x = 0, y = 96 - 30, w = 96, h = 22 }
    elseif valign == 'top' then
        frame = { x = 0, y = 0, w = 96, h = 22 }
    end

    return {
        text = message,
        font_size = 20,
        text_alignment = 'center',
        frame = frame,
        background_color = { red = 0, green = 0, blue = 0, alpha = 1 },
    }
end

local function button_icon(path)
    local frame = { x = 7, y = 7, w = 82, h = 82 }
    return { path = path, frame = frame }
end

local function button_icon_label(path, message, valign)
    return {
        button_icon(path),
        button_label(message, valign),
    }
end

return {
    buttons = {
        [1] = {
            type = 'folder',
            icon = { path = 'home-assistant.png' },
            buttons = {
                [2] = {
                    type = 'folder',
                    icon = { path = 'mdi-roller-shade-open.png' },
                    buttons = {
                        [2] = {
                            on_press = function(self, deck)
                                ha.post('matt-office-blackout-shades:open')
                            end,

                            icon = button_icon_label('mdi-roller-shade-open.png', 'Blackout', 'top'),
                        },
                        [6] = {
                            on_press = function(self, deck)
                                ha.post('matt-office-blackout-shades:close')
                            end,

                            icon = button_icon_label('mdi-roller-shade-closed.png', 'Blackout', 'top'),
                        },

                        [3] = {
                            on_press = function(self, deck)
                                ha.post('matt-office-sheer-shades:home')
                            end,

                            icon = button_icon_label('mdi-roller-shade-home.png', 'Sheer', 'top'),
                        },
                        [4] = {
                            on_press = function(self, deck)
                                ha.post('matt-office-sheer-shades:open')
                            end,

                            icon = button_icon_label('mdi-roller-shade-open.png', 'Sheer', 'top'),
                        },
                        [8] = {
                            on_press = function(self, deck)
                                ha.post('matt-office-sheer-shades:close')
                            end,

                            icon = button_icon_label('mdi-roller-shade-closed.png', 'Sheer', 'top'),
                        },
                    }
                },

                [4] = {
                    on_press = function(self, deck)
                        ha.post('matt-office-sunlight:toggle')
                    end,

                    icon = {
                        { text = '🔆' },
                        button_label('sunlamp'),
                    },
                },
                [8] = {
                    on_press = function(self, deck)
                        ha.post('matt-office-keylight:toggle')
                    end,

                    icon = {
                        { text = '🔑' },
                        button_label('keylight'),
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
                    return button_icon('mic-muted.png')
                else
                    return button_icon('mic-unmuted.png')
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
                    return button_icon('speaker-muted.png')
                else
                    return button_icon('speaker-unmuted.png')
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
