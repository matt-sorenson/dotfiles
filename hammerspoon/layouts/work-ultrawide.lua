return {
    name = "work-laptop",

    { -- Primary Screen
        screen = '3440x1440',

        { window = 'Slack',                            rect = {  0, 0, 1/6, 1 }, layouts = 'communications' },
        { app = {'Code', 'DataGrip', 'IntelliJ IDEA'}, rect = {1/6, 0, 1/2, 1} },
        { app = {'Chrome', 'Firefox'},                 rect = {2/3, 0, 1/3, 1} },

        { app = {'Code', 'IntelliJ'}, rect = { 0,  0, 4/5, 1} },
        { app = {'Chrome', 'Firefox'},         rect = {1/5, 0, 4/5, 1} },

        { app = 'Messages', rect = { 1/10,   0, 9/10, 9/10 }, layouts = 'communications' },
    },

    is_work_computer = true,
}
