local sys    = require 'ms.sys'

local layout = {
    { -- Primary Screen
        { -- Workspace 1
            { app = 'Sublime', rect = {   0, 0, 1/2, 1 }, layouts = {'default'} },
            { app = 'Quiver',  rect = {   0, 0, 1/2, 1 }, layouts = {'default'} },
            { app = 'Chrome',  rect = { 1/2, 0, 1/2, 1 }, layouts = {'default'} },
            { app = 'Firefox', rect = { 1/2, 0, 1/2, 1 }, layouts = {'default'} },
        },
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
            { app = 'iTerm',      rect = {    0, 0,    1, 1/2 }, layouts = {'default'} },

            { app = 'Slack',    rect = {   0, 1/2, 1/2, 1/2 }, layouts = {'default', 'communications'} },
            { app = 'Messages', rect = { 1/2, 1/2, 1/2, 1/2 }, layouts = {'default', 'communications'} },

            { window = 'Youtube', rect = { 1/10, 0, 8/10,   1 }, layouts = {'default', 'media'} },
        },
        { -- Workspace Mail
            { app = 'Mail', rect = { 0, 0, 1, 1 }, layouts = {'default', 'media'} },

            fullscreen = true
        },
        { -- Workspace Fantastical
            { app = 'Fantastical', rect = { 0, 0, 1, 1 }, layouts = {'default', 'media'} },

            fullscreen = true
        },
    }
}

local function score(self)
    if (not sys.is_work_computer()) and hs.screen('DELL P2715Q') and hs.screen('Color LCD') then
        return 3
    end

    return -1
end

local function screens()
    return {
        hs.screen('DELL P2715Q'),
        hs.screen('Color LCD')
    }
end

return {
    score = score,
    layout = layout,

    screens = screens,
}
