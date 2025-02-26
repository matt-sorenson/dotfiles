
local ha = require 'ms.home-assistant'

local helpers = require 'config.streamdeck.helpers'

return {
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

                    icon = helpers.button_icon_label('mdi-roller-shade-open.png', 'Blackout', 'top'),
                },
                [6] = {
                    on_press = function(self, deck)
                        ha.post('matt-office-blackout-shades:close')
                    end,

                    icon = helpers.button_icon_label('mdi-roller-shade-closed.png', 'Blackout', 'top'),
                },

                [3] = {
                    on_press = function(self, deck)
                        ha.post('matt-office-sheer-shades:home')
                    end,

                    icon = helpers.button_icon_label('mdi-roller-shade-home.png', 'Sheer', 'top'),
                },
                [4] = {
                    on_press = function(self, deck)
                        ha.post('matt-office-sheer-shades:open')
                    end,

                    icon = helpers.button_icon_label('mdi-roller-shade-open.png', 'Sheer', 'top'),
                },
                [8] = {
                    on_press = function(self, deck)
                        ha.post('matt-office-sheer-shades:close')
                    end,

                    icon = helpers.button_icon_label('mdi-roller-shade-closed.png', 'Sheer', 'top'),
                },
            }
        },

        [4] = {
            on_press = function(self, deck)
                ha.post('matt-office-sunlight:toggle')
            end,

            icon = {
                { text = '🔆' },
                helpers.button_label('sunlamp'),
            },
        },
        [8] = {
            on_press = function(self, deck)
                ha.post('matt-office-keylight:toggle')
            end,

            icon = {
                { text = '🔑' },
                helpers.button_label('keylight'),
            },
        },
    },
}