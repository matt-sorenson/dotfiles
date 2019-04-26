return {
    name = "work-ultrawide-laptop",

    { -- Primary Screen
        screen = '3440x1440',

        { app = 'Finder',                rect = {  0, 0, 1/6, 1} },
        { app = {'Sublime', 'Quiver'},   rect = {1/6, 0, 1/2, 1} },
        { app = {'Chrome', 'Firefox'},   rect = {2/3, 0, 1/3, 1} },
    }, { -- Secondary Screen
        screen = 'Color LCD',

        { app = 'iTerm',                      rect = { 0,      0, 9/10,   5/9 } },

        { window = {'reddit', 'Hacker News'}, rect = {  1/4, 5/9,  3/4, 11/28 }, layouts = 'media' },
        { window = 'Youtube',                 rect = {    0, .48,   .7,   1/3 }, layouts = 'media' },
        { window = 'Slack', rect = { 1/10,   0, 9/10, 9/10 }, layouts = 'communications' },
        { app = 'Messages', rect = { 1/10,   0, 9/10, 9/10 }, layouts = 'communications' },
    },

    is_work_computer = true,
}
