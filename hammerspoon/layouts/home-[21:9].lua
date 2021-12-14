return {
    name = "home-ultrawide",

    layout = {
        { -- Primary Screen
            screen = '3440x1440',

            { app = 'Code',                rect = { 2/3, 0, 1/3,   1 } },
            { app = {'Chrome', 'Firefox'}, rect = { 0,   0, 1/3,   1 } },
        }
    },
}
