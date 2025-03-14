return {
    layout = {
        { -- Primary Screen
            screen = {'3840x1600', '3440x1440'},

            { app = {'Code', 'VSCodium', 'DataGrip', 'IntelliJ IDEA', 'TablePlus'}, section = 1 },

            { app = {'Chrome'},  section = 2 },

            { app = 'zoom.us', center = true, categories = 'communications' },
            { app = {'okta', 'AWS VPN Client'}, center = true },
        },
        {
            screen = { 'DELL G2725D', '1440x2560' },

            { app = {'Firefox', 'Music'}, section = 3, categories = 'media' },

            { app = 'Messages', rect = { 7/8, 1/2, 7/8, 1/2 }, categories = 'communications' },
            { app = 'Slack',    rect = {   0, 1/2, 7/8, 1/2 }, categories = 'communications' },
        }
    },

    sections = {
        { screen = 1, rect = {   0,   0, 5/8,   1 } },
        { screen = 1, rect = { 5/8,   0, 3/8,   1 } },

        { screen = 2, rect = {   0,   0,   1, 1/2 } },
        { screen = 2, rect = {   0, 1/2,   1, 1/2 } },
    },

    is_work_computer = true,
}
