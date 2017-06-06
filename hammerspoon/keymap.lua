local audio    = require 'ms.audio'
local sys      = require 'ms.sys'
local layout   = require 'ms.layout'
local music    = require 'ms.music'
local caffeine = require 'ms.caffeine'

return {
    { mods = 'alt', key = 'space', fn = sys.select_app_fn('iTerm', { new_window = {'Shell', 'New Window'} })},

    -- defeat attempts to block paste
    { mods = {'cmd', 'alt'}, key = 'V', fn = function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end},

    {
        title = 'global',
        mods = { 'ctrl', 'cmd' },
        key = 'B',

        {
            title = 'Window',
            key = 'W',

            { mods = 'shift', key = 'W', msg = '↑', fn = layout.move_window_fn({   0,   0,   1, 1/3 }), optional_mods = 'shift' },
            { mods = 'shift', key = 'A', msg = '←', fn = layout.move_window_fn({   0,   0, 1/3,   1 }), optional_mods = 'shift' },
            { mods = 'shift', key = 'S', msg = '↓', fn = layout.move_window_fn({   0, 2/3,   1, 1/3 }), optional_mods = 'shift' },
            { mods = 'shift', key = 'D', msg = '→', fn = layout.move_window_fn({ 2/3,   0, 1/3,   1 }), optional_mods = 'shift' },
            { key = 'W', fn = layout.move_window_fn({ 0.0, 0.0, 1.0, 0.5 }) },
            { key = 'A', fn = layout.move_window_fn({ 0.0, 0.0, 0.5, 1.0 }) },
            { key = 'S', fn = layout.move_window_fn({ 0.0, 0.5, 1.0, 0.5 }) },
            { key = 'D', fn = layout.move_window_fn({ 0.5, 0.0, 0.5, 1.0 }) },

            '-',

            { key = 'Q', msg = 'Quiet current window',        fn = layout.move_window_fn({1/8, 8/14, 6/8, 5.5/14}, 2) },
            { key = 'F', msg = 'Maximize',                    fn = layout.move_window_fn({ 0, 0, 1, 1 })              },
            { key = 'G', msg = 'Grid' ,                       fn = hs.grid.show                                       },
            { key = 'R', msg = 'Apply layout to window',      fn = layout.apply_to_window                             },
            { key = 'T', msg = 'Apply Default Layout',        fn = layout.apply                                       },
            { key = 'E', msg = 'Apply Media Layout',          fn = layout.apply_fn('Media')                           },
            { key = 'C', msg = 'Apply Communications Layout', fn = layout.apply_fn('Communications')                  },
        },

        {
            title = 'Finder',
            key = 'F',

            { key = 'G', msg = 'Home',      fn = sys.select_app_fn('Finder', { window = sys.who_am_i(), new_window = sys.open_finder_fn('~/') })   },
            { key = 'W', msg = 'Workspace', fn = sys.select_app_fn('Finder', { window = 'ws',           new_window = sys.open_finder_fn('~/ws') }) },
        },

        {
            title = 'Music',
            key = 'S',

            { key = 'S', msg = 'Play/Pause',    fn = music.fn('playpause'),     repeat_on_mods = 'shift' },
            { key = 'A', msg = 'Previous',      fn = music.fn('previousTrack'), repeat_on_mods = 'shift' },
            { key = 'D', msg = 'Next',          fn = music.fn('nextTrack'),     repeat_on_mods = 'shift' },
            { key = 'R', msg = 'Shuffle',       fn = music.fn('shuffle'),       repeat_on_mods = 'shift' },
            { key = 'C', msg = 'Select player', fn = music.select_current_player },

            '-',

            { key = 'W', msg = 'Raise volume', fn = audio.update_volume_fn( 1), repeat_on_mods = 'shift' },
            { key = 'X', msg = 'Lower volume', fn = audio.update_volume_fn(-1), repeat_on_mods = 'shift' },
        },

        {
            title = 'Power',
            key = 'e',

            { key = 'S', msg = 'Screen Saver',           fn = hs.caffeinate.startScreensaver },
            { key = '1', msg = 'Caffeine on 10 Minutes', fn = function() caffeine.timed_on_m(10) end },
            { key = '2', msg = 'Caffeine on 20 Minutes', fn = function() caffeine.timed_on_m(20) end },
            { key = '3', msg = 'Caffeine on 30 Minutes', fn = function() caffeine.timed_on_m(30) end },
            { key = '4', msg = 'Caffeine on 40 Minutes', fn = function() caffeine.timed_on_m(40) end },
            { key = '5', msg = 'Caffeine on 50 Minutes', fn = function() caffeine.timed_on_m(50) end },
        }
    }
}
