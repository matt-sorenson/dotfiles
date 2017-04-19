local sys    = require 'ms.sys'

local layout = {
    { -- Primary Screen
        { -- Workspace 1
            { app = 'Finder',   rect = {  0, 0,  1/6,   1}, layouts = {'default'} },
            { app = 'Sublime',  rect = {1/6, 0,  1/2,   1}, layouts = {'default'} },
            { app = 'Quiver',   rect = {1/6, 0,  1/2,   1}, layouts = {'default'} },
            { app = 'Chrome',   rect = {2/3, 0,  1/3,   1}, layouts = {'default'} },
            { app = 'Firefox',  rect = {2/3, 0,  1/3,   1}, layouts = {'default'} },
            { app = 'IntelliJ', rect = {1/6, 0,  1/2,   1}, layouts = {'default'} },
            { app = 'iTerm',    rect = {  0, 0, 9/10, 1/2}, layouts = {'default'} },
        },
        { -- Workspace 2
            { app = 'Mail',        rect = {    0, 0, 1/2, 1}, layouts = {'default'} },
            { app = 'Fantastical', rect = {  1/2, 0, 1/2, 1}, layouts = {'default'} },

            fullscreen = true
        }
    },
    { -- Secondary Screen
        { -- Workspace iTunes
            { app = 'iTunes',  rect = { 0, 0, 1, 1 }, layouts = {'default', 'media'} },

            fullscreen = true
        },
        { -- Workspace Spotify
            { app = 'Spotify', rect = { 0, 0, 1, 1 }, layouts = {'default', 'media'} },

            fullscreen = true
        },
        { -- Workspace 1
            { window = 'reddit',       rect = { 1/8, 8/14, 6/8, 11/28 }, layouts = {'default', 'media'} },
            { window = 'Hacker News',  rect = { 1/8, 8/14, 6/8, 11/28 }, layouts = {'default', 'media'} },
            { window = 'Youtube',      rect = { 1/8,  1/2, 6/8,   1/3 }, layouts = {'default', 'media'} },
            { window = 'Amazon Music', rect = { 1/8,  1/2, 6/8,   1/3 }, layouts = {'default', 'media'} },

            { app = 'Slack',                      rect = { 1/10,   0, 9/10, 1/2 }, layouts = {'default', 'communications'} },
            { app = 'Adium',                      rect = {    0, 1/2,  1/3, 1/2 }, layouts = {'default', 'communications'} },
            { app = 'Adium', window = 'Contacts', rect = {  2/3, 1/2,  1/3, 1/2 }, layouts = {'default', 'communications'} },
            { app = 'Messages',                   rect = {  1/5, 4/7,  3/5, 3/7 }, layouts = {'default', 'communications'} },
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
