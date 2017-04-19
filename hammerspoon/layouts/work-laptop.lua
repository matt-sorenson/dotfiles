local sys    = require 'ms.sys'

local layout = {
    { -- Primary Screen
        { -- Workspace iTunes
            { app = 'iTunes',  rect = { 0, 0, 1, 1 }, layouts = {'default', 'media'} },

            fullscreen = true
        },
        { -- Workspace Spotify
            { app = 'Spotify', rect = { 0, 0, 1, 1 }, layouts = {'default', 'media'} },

            fullscreen = true
        },
        { -- Workspace 1
            { app = 'Sublime',  rect = {  0, 0, 4/5, 1}, layouts = {'default'} },
            { app = 'Quiver',   rect = {  0, 0, 4/5, 1}, layouts = {'default'} },
            { app = 'IntelliJ', rect = {  0, 0, 4/5, 1}, layouts = {'default'} },
            { app = 'iTerm',    rect = {  0, 0, 4/5, 1}, layouts = {'default'} },

            { app = 'Chrome',   rect = {1/5, 0, 4/5,   1}, layouts = {'default'} },
            { app = 'Firefox',  rect = {1/5, 0, 4/5,   1}, layouts = {'default'} },
        },
        { -- Workspace 1
            { app = 'Slack',                      rect = {    0,   0, 9/10, 9/10 }, layouts = {'default', 'communications'} },
            { app = 'Messages',                   rect = { 1/10,   0, 9/10, 9/10 }, layouts = {'default', 'communications'} },

            { app = 'Adium',                      rect = {    0, 1/10, 1/3, 9/10 }, layouts = {'default', 'communications'} },
            { app = 'Adium', window = 'Contacts', rect = {  2/3, 1/10, 1/3, 9/10 }, layouts = {'default', 'communications'} },
        },
        { -- Workspace Mail
            { app = 'Mail',        rect = {    0, 0, 1/2, 1}, layouts = {'default'} },

            fullscreen = true
        },
        { -- Workspace Mail
            { app = 'Fantastical', rect = {  1/2, 0, 1/2, 1}, layouts = {'default'} },

            fullscreen = true
        },
    }
}

local function score(self)
    if sys.is_work_computer() and hs.screen('Color LCD') then
        return 2
    end

    return -1
end

local function screens()
    return { hs.screen('Color LCD') }
end

return {
    score = score,
    layout = layout,

    screens = screens
}
