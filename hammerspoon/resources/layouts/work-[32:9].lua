return {
    layout = {
        { -- Primary Screen
            screen = {'5120x1440', 'LS49AG95'},

            { app = 'Messages', rect = { 1/6, 1/8, 1/6, 7/8 }, categories = 'communications' },
            { app = 'Slack', rect = { 1/10,  0, 5/18, 7/8 }, categories = 'communications' },

            { app = {'Postman'}, rect = {0, 1/2-1/20, 1/3, 1/2 + 3/40} },

            { app = {'Code', 'VSCodium', 'DataGrip', 'IntelliJ IDEA'}, section = 3, categories = 'primary' },

            { app = {'Chrome'},  section = 4 },
            { app = {'Firefox', 'Music'}, section = 1, categories = 'media' },
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
