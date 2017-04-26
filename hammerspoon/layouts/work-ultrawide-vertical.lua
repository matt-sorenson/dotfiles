return {
    { -- Primary Screen
        screen = '3440x1440',

        { app = 'Finder',              rect = {  0, 0, 1/6, 1} },
        { app = {'Sublime', 'Quiver'}, rect = {1/6, 0, 1/2, 1} },
        { app = {'Chrome', 'Firefox'}, rect = {2/3, 0, 1/3, 1} },
        { app = 'IntelliJ',            rect = {  0, 0, 2/3, 1} }
    },
    { -- Secondary Screen
        screen = '1440x2560',

        { app = 'iTerm', rect = { 0, 0, 9/10, 1/2} },

        { window = {'reddit', 'Hacker News'}, rect = { 1/8, 8/14, 6/8, 11/28 }, layouts = 'media' },
        { window = 'Youtube',                 rect = { 1/8,  1/2, 6/8,   1/3 }, layouts = 'media' },

        { app = 'Slack',                      rect = { 1/10,   0, 9/10, 1/2 }, layouts = 'communications' },
        { app = 'Adium',                      rect = {    0, 1/2,  1/3, 1/2 }, layouts = 'communications' },
        { app = 'Adium', window = 'Contacts', rect = {  2/3, 1/2,  1/3, 1/2 }, layouts = 'communications' },
        { app = 'Messages',                   rect = {  1/5, 4/7,  3/5, 3/7 }, layouts = 'communications' },
    }
}
