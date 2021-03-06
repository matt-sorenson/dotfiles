return {
    name = "work-ultrawide-vertical-laptop",

    { -- Primary Screen
        screen = '3440x1440',

        { app = 'Finder',              rect = {  0, 0, 1/6, 1} },
        { app = {'Code', 'Quiver'},    rect = {1/6, 0, 1/2, 1} },
        { app = {'Chrome', 'Firefox'}, rect = {2/3, 0, 1/3, 1} },
    }, { -- Secondary Screen
        screen = '1440x2560',
        { app = 'iTerm',    rect = { 0,      0, 9/10,   5/9 } },

        { window = 'Slack', rect = { 1/10,   0, 9/10,   5/9 }, layouts = 'communications' },
        { app = 'Messages', rect = {    0, 2/3,  1/2,   1/3 }, layouts = 'communications' },
    }, {
        screen = 'Color LCD',

        { window = {'reddit', 'Hacker News'}, rect = { 0, 0, 1, 1 }, layouts = 'media' },
        { window = 'Youtube',                 rect = { 0, 0, 1, 1 }, layouts = 'media' },
    },

    quiet_locations = {
        { screen = 3, rect = { 0, 0, 1, 1 } },
        { screen = 2, rect = { 1/4, 5/9, 3/4, 11/28 } },
    },

    is_work_computer = true,
}
