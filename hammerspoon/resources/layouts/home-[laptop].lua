return {
    layout = {
        { -- Laptop Screen
            screen = 'Built-in Retina Display',

            { app = 'Code',                rect = {   0, 0, 4/5, 1 } },
            { app = {'Chrome', 'Firefox'}, rect = { 1/5, 0, 4/5, 1 } },

            { window = 'Slack', rect = {   0, 0, 1/2, 1 }, layouts = 'communications' },
            { app = 'Messages', rect = { 1/2, 0, 1/2, 1 }, layouts = 'communications' },
        },
    },

    -- fallback means this layout is just the laptop screen
    -- if multiple matching layouts are available then this layout
    -- will not be used.
    fallback = true,
}
