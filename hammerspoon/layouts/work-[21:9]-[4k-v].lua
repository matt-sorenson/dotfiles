return {
    name = "work-ultrawide-vertical",

    layout = {
        { -- Primary Screen
            screen = '3440x1440',

            { app = 'Finder',                              rect = {  0, 0, 1/6, 1} },
            { app = {'Code', 'DataGrip', 'IntelliJ IDEA'}, rect = {  0, 0, 3/5, 1} },
            { app = {'Chrome', 'Firefox'},                 rect = {3/5, 0, 2/5, 1} },
            { window = 'zoom',                             rect = {3/5, 0, 2/5, 1 }, categories = 'communications' },
        }, { -- Secondary Screen
            screen = '1440x2560',

            { window = 'Youtube',                 rect = {   0, 1/2,    1,   1/2 }, categories = 'media' },
            { app = 'Music',                      rect = {   0, 1/2,    1,   1/2 }, categories = 'media' },

            { window = 'Slack',                   rect = {    0,   0, 9/10,   1/2 }, categories = 'communications' },
            { app = 'Messages',                   rect = { 1/10,   0, 9/10,   1/2 }, categories = 'communications' },
        },
    },

    is_work_computer = true,
}
