return {
    name = "work-ultrawide-vertical",

    { -- Primary Screen
        screen = '3440x1440',

        { app = 'Finder',                              rect = {  0, 0, 1/6, 1} },
        { app = {'Code', 'DataGrip', 'IntelliJ IDEA'}, rect = {  0, 0, 3/5, 1} },
        { app = {'Chrome', 'Firefox'},                 rect = {3/5, 0, 2/5, 1} },
        { window = 'zoom',                             rect = {3/5, 0, 2/5, 1 }, layouts = 'communications' },
    }, { -- Secondary Screen
        screen = '1440x2560',

        { window = 'Youtube',                 rect = {   0, 1/2,    1,   1/2 }, layouts = 'media' },
        { app = 'Music',                      rect = {   0, 1/2,    1,   1/2 }, layouts = 'media' },

        { window = 'Slack',                   rect = {    0,   0, 9/10,   1/2 }, layouts = 'communications' },
        { app = 'Messages',                   rect = { 1/10,   0, 9/10,   1/2 }, layouts = 'communications' },
    },

    quiet_locations = {
        { screen = 2, rect = { 1/4, 5/9, 3/4, 11/28 } },
        { screen = 2, rect = { 1/4, 5/9, 3/4, 11/28 } },
    },

    is_work_computer = true,
}
