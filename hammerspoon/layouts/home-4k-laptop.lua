local sys    = require 'ms.sys'

local layout = {
    { -- Primary Screen
        { -- Workspace 1
            { app = {'Sublime', 'Quiver'}, rect = {   0, 0, 1/2, 1 } },
            { app = {'Chrome', 'Firefox'}, rect = { 1/2, 0, 1/2, 1 } },
        },
    },
    { -- Secondary Screen
        { -- Workspace 1
            { app = 'iTerm', rect = { 0, 0, 1, 1/2 } },

            { app = 'Slack',    rect = {   0, 1/2, 1/2, 1/2 }, layouts = 'communications' },
            { app = 'Messages', rect = { 1/2, 1/2, 1/2, 1/2 }, layouts = 'communications' },

            { window = 'Youtube', rect = { 1/10, 0, 8/10, 1 }, layouts = 'media' },
        },
    }
}

local function score(self)
    if hs.screen('DELL P2715Q') and hs.screen('Color LCD') then
        return 2
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
