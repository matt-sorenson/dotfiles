local helpers = require 'ms.window.layout.helpers'

local function messages_slack_rect_fn()
    return helpers.combined_window_rect_fn(
        'com.tinyspeck.slackmacgap', { 0, 1/2, 7/8, 1/2 },
        'com.apple.MobileSMS', { 1/8, 1/2, 7/8, 1/2 },
        { 0, 1/2, 1, 1/2 }
    )
end

local main_apps = {
    'Code',
    'Cursor',
    'DataGrip',
    'IntelliJ IDEA',
    'TablePlus',
    'Bruno'
}

return {
    layout = {
        { -- Primary Horizontal Screen
            screen = {'3840x1600', '3440x1440'},

            { app = main_apps, section = 1 },
            -- TablePlus "New Workspace" window
            { app = 'TablePlus', window = '', resize_center = { 898, 556 } },

            { app = {'Chrome'},  section = 2 },

            { app = 'zoom.us', resize_center = { 1920, 1080 }, categories = 'communications' },
            { app = {'okta', 'AWS VPN Client'}, center = true },

            { window = 'Hammerspoon Console', rect = { 11 / 16, 1/10, 4/16, 4/5 } }
        },
        { -- Side Vertical Screen
            screen = { 'DELL G2725D', '1440x2560' },

            { app = {'Firefox', 'Music'}, section = 3, categories = 'media' },

            { app = 'Messages', fn = messages_slack_rect_fn(), categories = 'communications' },
            { app = 'Slack',    fn = messages_slack_rect_fn(), categories = 'communications' },
        }
    },

    sections = {
        { screen = 1, rect = {   0,   0, 5/8,   1 } },
        { screen = 1, rect = { 5/8,   0, 3/8,   1 } },

        { screen = 2, rect = {   0,   0,   1, 1/2 } },
        { screen = 2, rect = {   0, 1/2,   1, 1/2 } },
    },

    is_work_computer = true,
}
