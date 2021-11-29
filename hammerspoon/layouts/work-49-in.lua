return {
    name = "work-laptop",

    { -- Primary Screen
        screen = '5120x1440',

        { app = 'Messages', rect = { 1/6, 1/8, 1/6, 7/8 }, layouts = 'communications' },
        { window = 'Slack', rect = { 1/6,   0, 1/6, 7/8 }, layouts = 'communications' },

        { app = {'Code', 'DataGrip', 'IntelliJ IDEA'}, rect = {1/3, 0, 2/5, 1} },

        { app = {'Chrome'}, rect = {1/3 + 2/5, 0, 1 - (1/3 + 2/5), 1} },
        { app = {'Firefox'}, rect = {0, 0, 1/6, 1} },
    },

    is_work_computer = true,
}
