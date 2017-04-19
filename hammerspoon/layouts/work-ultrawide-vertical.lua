local sys    = require 'ms.sys'

local layout = {
    { -- Primary Screen
        { app = {'Mail', 'Fantastical'}, layouts = 'media' },

        { -- Workspace 1
            { app = 'Finder',                          rect = {  0, 0, 1/6, 1} },
            { app = {'Sublime', 'IntelliJ', 'Quiver'}, rect = {1/6, 0, 1/2, 1} },
            { app = {'Chrome', 'Firefox'},             rect = {2/3, 0, 1/3, 1} },
        },
    },
    { -- Secondary Screen
        { app = {'iTunes', 'Spotify' }, layouts = 'media' },

        { -- Workspace 1
            { app = 'iTerm', rect = { 0, 0, 9/10, 1/2} },

            { window = {'reddit', 'Hacker News'}, rect = { 1/8, 8/14, 6/8, 11/28 }, layouts = 'media' },
            { window = 'Youtube',                 rect = { 1/8,  1/2, 6/8,   1/3 }, layouts = 'media' },

            { app = 'Slack',                      rect = { 1/10,   0, 9/10, 1/2 }, layouts = 'communications' },
            { app = 'Adium',                      rect = {    0, 1/2,  1/3, 1/2 }, layouts = 'communications' },
            { app = 'Adium', window = 'Contacts', rect = {  2/3, 1/2,  1/3, 1/2 }, layouts = 'communications' },
            { app = 'Messages',                   rect = {  1/5, 4/7,  3/5, 3/7 }, layouts = 'communications' },
        }
    }
}

local function score(self)
    if sys.is_work_computer() and hs.screen('3440x1440') and hs.screen('1440x2560') then
        return 3
    end

    return -1
end

local function screens()
    return {
        hs.screen('3440x1440'),
        hs.screen('1440x2560')
    }
end

return {
    score = score,
    layout = layout,

    screens = screens
}
