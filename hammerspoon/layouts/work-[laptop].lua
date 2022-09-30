return {
    layout = {
        { -- Primary Screen
            screen = 'Built-in Retina Display',

            { app = {'Code', 'DataGrip', 'IntelliJ IDEA'}, rect = { 0,  0, 4/5, 1} },
            { app = {'Chrome', 'Firefox'},                 rect = {1/5, 0, 4/5, 1} },

            { window = 'Slack', rect = { 1/10,   0, 9/10, 9/10 }, categories = 'communications' },
            { app = 'Messages', rect = { 1/10,   0, 9/10, 9/10 }, categories = 'communications' },
        },
    },

    is_work_computer = true,
}
