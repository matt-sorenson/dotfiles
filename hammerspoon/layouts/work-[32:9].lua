return {
    layout = {
        { -- Primary Screen
            screen = {'5120x1440', 'LS49AG95'},

            { app = 'Messages', rect = { 1/6, 1/8, 1/6, 7/8 }, categories = 'communications' },
            { window = 'Slack', rect = { 1/6,   0, 1/6, 7/8 }, categories = 'communications' },

            { app = {'Code', 'DataGrip', 'IntelliJ IDEA'}, rect = {1/3, 0, 2/5, 1} },
            { app = {'Postman'}, rect = {0, 1/2-1/20, 1/3, 1/2 + 2/20} },

            { app = {'Chrome'},  rect = {1/3 + 2/5, 0, 1 - (1/3 + 2/5), 1} },
            { app = {'Firefox'}, rect = {0, 0, 1/6, 1} },
        },
    },

    sections = {
        { screen = 1, rect = {         0, 0,             1/6, 1 } },
        { screen = 1, rect = {       1/6, 0,             1/6, 1 } },
        { screen = 1, rect = {       1/3, 0,             2/5, 1 } },
        { screen = 1, rect = { 1/3 + 2/5, 0, 1 - (1/3 + 2/5), 1 } },
    },

    is_work_computer = true,
}