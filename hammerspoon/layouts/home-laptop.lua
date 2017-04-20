local sys    = require 'ms.sys'

local layout = {
    { -- Laptop Screen
        { -- Workspace 1
            { app = {'Sublime', 'Quiver'}, rect = {   0, 0, 4/5, 1 } },
            { app = {'Chrome', 'Firefox'}, rect = { 1/5, 0, 4/5, 1 } },

            { app = 'iTerm',   rect = {   0, 0,   1, 1/2 } },
        },
        { -- Workspace 2
            { app = 'Slack',    rect = {   0, 0, 1/2, 1 }, layouts = 'communications' },
            { app = 'Messages', rect = { 1/2, 0, 1/2, 1 }, layouts = 'communications' },
        },
    }
}

local function score(self)
    if hs.screen('Color LCD') then
        return 1
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
