return {
        name = "home-laptop",

    { -- Laptop Screen
        screen = 'Color LCD',

        { app = {'Sublime', 'Quiver'}, rect = {   0, 0, 4/5, 1 } },
        { app = {'Chrome', 'Firefox'}, rect = { 1/5, 0, 4/5, 1 } },

        { app = 'iTerm',   rect = {   0, 0,   1, 1/2 } },

        { window = 'Slack', rect = {   0, 0, 1/2, 1 }, layouts = 'communications' },
        { app = 'Messages', rect = { 1/2, 0, 1/2, 1 }, layouts = 'communications' },
    }
}
