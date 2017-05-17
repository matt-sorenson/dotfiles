return {
    { -- Primary Screen
        screen = 'DELL P2715Q',

        { app = {'Sublime', 'Quiver', 'IntelliJ'}, rect = {   0, 0, 1/2, 1 } },
        { app = {'Chrome', 'Firefox'},             rect = { 1/2, 0, 1/2, 1 } },
    },
    { -- Secondary Screen
        screen = 'Color LCD',

        { app = 'iTerm', rect = { 0, 0, 1, 1/2 } },

        { app = 'Slack',    rect = {   0, 1/2, 1/2, 1/2 }, layouts = 'communications' },
        { app = 'Messages', rect = { 1/2, 1/2, 1/2, 1/2 }, layouts = 'communications' },
        { app = 'Adium',    rect = {   0, 1/2, 1/3, 1/2 }, layouts = 'communications' },
        { app = 'Chime',    rect = { 1/2, 1/2, 1/2, 1/2 }, layouts = 'communications' },

        { window = 'Youtube', rect = { 1/10, 0, 8/10, 1 }, layouts = 'media' },
    }
}
