local ha = require 'ms.home-assistant'

local helpers = require 'config.streamdeck.helpers'

return {
    type = 'folder',
    icon = helpers.button_icon('home-assistant.png'),
    buttons = {
        [2] = {
            type = 'folder',
            icon = helpers.button_icon('mdi-roller-shade-open.png'),
            buttons = {
                [2] = {
                    on_press = function(_self, _deck)
                        ha.post('matt-office-blackout-shades:open')
                    end,

                    icon = helpers.button_icon_label(
                        'mdi-roller-shade-open.png',
                        'Blackout',
                        'top'),
                },
                [6] = {
                    on_press = function(_self, _deck)
                        ha.post('matt-office-blackout-shades:close')
                    end,

                    icon = helpers.button_icon_label(
                        'mdi-roller-shade-closed.png',
                        'Blackout',
                        'top'),
                },

                [3] = {
                    on_press = function(_self, _deck)
                        ha.post('matt-office-sheer-shades:home')
                    end,

                    icon = {
                        helpers.button_icon('mdi-roller-shade-home.png'),
                        helpers.button_label('Sheer', 'top'),
                        {
                            color = { red = 0, green = 0, blue = 0, alpha = 0.5 },
                            frame = { x = 0, y = 96-30, w = 96, h = 30 },
                        },
                        helpers.button_label('Home', 'bottom'),
                    }
                },
                [4] = {
                    on_press = function(_self, _deck)
                        ha.post('matt-office-sheer-shades:open')
                    end,

                    icon = helpers.button_icon_label(
                        'mdi-roller-shade-open.png',
                        'Sheer',
                        'top'),
                },
                [8] = {
                    on_press = function(_self, _deck)
                        ha.post('matt-office-sheer-shades:close')
                    end,

                    icon = helpers.button_icon_label(
                        'mdi-roller-shade-closed.png',
                        'Sheer',
                        'top'),
                },
            }
        },

        [3] = {
            on_press = function(_self, _deck)
                ha.post('matt-office:start-day')
            end,

            icon = {
                { text = '📅' },
                helpers.button_label('start day'),
            },
        },
        [7] = {
            on_press = function(_self, _deck)
                ha.post('matt-office:end-day')
            end,

            icon = {
                { text = '📅' },
                helpers.button_label('end day'),
            },
        },

        [4] = {
            on_press = function(_self, _deck)
                ha.post('matt-office-sunlight:toggle')
            end,

            icon = {
                { text = '🔆' },
                helpers.button_label('sunlamp'),
            },
        },
        [8] = {
            on_press = function(_self, _deck)
                ha.post('matt-office-keylight:toggle')
            end,

            icon = {
                { text = '🔑' },
                helpers.button_label('keylight'),
            },
        },
    },
}