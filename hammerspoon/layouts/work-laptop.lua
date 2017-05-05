return {
    { -- Primary Screen
        screen = 'Color LCD',

        { app = {'Sublime', 'Quiver', 'IntelliJ', 'iTerm'},  rect = { 0,  0, 4/5, 1} },
        { app = {'Chrome', 'Firefox'},                       rect = {1/5, 0, 4/5, 1} },

        { app = 'Slack',    rect = {    0,   0, 9/10, 9/10 }, layouts = 'communications' },
        { app = 'Messages', rect = { 1/10,   0, 9/10, 9/10 }, layouts = 'communications' },

        { app = 'Adium',                      rect = {    0, 1/10, 1/3, 9/10 }, layouts = 'communications' },
        { app = 'Adium', window = 'Contacts', rect = {  2/3, 1/10, 1/3, 9/10 }, layouts = 'communications' },
    },

    is_work_computer = true,
}
