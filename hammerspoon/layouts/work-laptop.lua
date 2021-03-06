return {
    name = "work-laptop",

    { -- Primary Screen
        screen = 'Color LCD',

        { app = {'Code', 'IntelliJ', 'iTerm'}, rect = { 0,  0, 4/5, 1} },
        { app = {'Chrome', 'Firefox'},         rect = {1/5, 0, 4/5, 1} },

        { window = 'Slack', rect = { 1/10,   0, 9/10, 9/10 }, layouts = 'communications' },
        { app = 'Messages', rect = { 1/10,   0, 9/10, 9/10 }, layouts = 'communications' },
    },

    is_work_computer = true,
}
