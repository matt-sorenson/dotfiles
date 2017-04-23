local sys    = require 'ms.sys'

local layout = {
    { -- Primary Screen
        { app = {'Sublime', 'Quiver', 'IntelliJ', 'iTerm'},  rect = { 0,  0, 4/5, 1} },
        { app = {'Chrome', 'Firefox'},                       rect = {1/5, 0, 4/5, 1} },

        { app = 'Slack',    rect = {    0,   0, 9/10, 9/10 }, layouts = 'communications' },
        { app = 'Messages', rect = { 1/10,   0, 9/10, 9/10 }, layouts = 'communications' },

        { app = 'Adium',                      rect = {    0, 1/10, 1/3, 9/10 }, layouts = 'communications' },
        { app = 'Adium', window = 'Contacts', rect = {  2/3, 1/10, 1/3, 9/10 }, layouts = 'communications' },
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
