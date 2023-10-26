return {
    layout = {
        { -- Primary Screen
            screen = {'Retina', '64CAA675-3C76-B4FA-343A-76AEF8A35229'},

            { app = {'Code', 'VSCodium', 'DataGrip', 'IntelliJ IDEA'}, rect = { 0,  0, 4/5, 1} },
            { app = {'Chrome', 'Firefox'}, rect = {1/5, 0, 4/5, 1} },

            { window = 'Slack', rect = { 1/10,   0, 9/10, 9/10 }, categories = 'communications' },
            { app = 'Messages', rect = { 1/10,   0, 9/10, 9/10 }, categories = 'communications' },
        },
    },

    is_work_computer = true,

    -- fallback means this layout is just the laptop screen
    -- if multiple matching layouts are available then this layout
    -- will not be used.
    fallback = true,
}
