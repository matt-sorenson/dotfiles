local audio    = require 'ms.audio'
local caffeine = require 'ms.caffeine'
local grid     = require 'ms.grid'
local layout   = require 'ms.layout'
local sys      = require 'ms.sys'
local work     = require 'ms.work'

return {
    {
        title = 'global',
        mods = { 'ctrl', 'cmd' },
        key = 'B',
        skip_help_msg = true,

        -- defeat attempts to block paste
        { key = 'V', msg = 'key event paste', fn = function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end },

        {
            title = 'Window',
            key = 'W',

            { key = '1', msg = '1st 1/3rd of screen', fn = layout.move_window_fn({   0,   0,   1/3, 1 }) },
            { key = '2', msg = '2nd 1/3rd of screen', fn = layout.move_window_fn({ 1/3,   0,   1/3, 1 }) },
            { key = '3', msg = '3rd 1/3rd of screen', fn = layout.move_window_fn({ 2/3,   0,   1/3, 1 }) },

            { key = '1', mods = 'shift', msg = '1st section of screen', fn = layout.move_window_to_section_fn(1) },
            { key = '2', mods = 'shift', msg = '2nd section of screen', fn = layout.move_window_to_section_fn(2) },
            { key = '3', mods = 'shift', msg = '3rd section of screen', fn = layout.move_window_to_section_fn(3) },
            { key = '4', mods = 'shift', msg = '4rd section of screen', fn = layout.move_window_to_section_fn(4) },

            '-',

            { key = 'F', msg = 'Maximize',                    fn = layout.move_window_fn({ 0, 0, 1, 1}) },
            { key = 'R', msg = 'Apply layout to window',      fn = layout.apply_to_window               },
            { key = 'T', msg = 'Apply Default Layout',        fn = layout.apply                         },
            { key = 'E', msg = 'Apply Media Layout',          fn = layout.apply_fn('Media')             },
            { key = 'C', msg = 'Apply Communications Layout', fn = layout.apply_fn('Communications')    },

            '-',

            { key = 'S', msg = 'Get current window size', fn = sys.get_current_window_size },

            '-',

            { key = 'G', msg = 'Grid',                        fn = grid.show, optional_mods = 'shift'          },
            { key = 'G', mods = 'shift', msg = 'Grid',        fn = grid.show_fn('shift'), skip_help_msg = true },
        },

        {
            title = 'Finder',
            key = 'F',

            { key = 'G', msg = 'Home',      fn = sys.select_app_fn('Finder', sys.who_am_i(), sys.open_finder_fn('~/'))   },
            { key = 'W', msg = 'Workspace', fn = sys.select_app_fn('Finder', 'ws',           sys.open_finder_fn('~/ws')) },

            { key = 'S', msg = 'Mount Shares', fn = function() sys.mount_smb_shares(REMOTE_SHARES) end }
        },

        {
            title = 'Sound',
            key = 'S',

            { key = 'S', msg = 'Play/Pause', fn = sys.trigger_system_key_fn('PLAY'),     repeat_on_mods = 'shift' },
            { key = 'A', msg = 'Previous',   fn = sys.trigger_system_key_fn('PREVIOUS'), repeat_on_mods = 'shift' },
            { key = 'D', msg = 'Next',       fn = sys.trigger_system_key_fn('NEXT'),     repeat_on_mods = 'shift' },

            '-',

            { key = 'W', msg = 'Raise volume', fn = audio.update_volume_fn( 3), repeat_on_mods = 'shift' },
            { key = 'X', msg = 'Lower volume', fn = audio.update_volume_fn(-3), repeat_on_mods = 'shift' },
        },

        {
            title = 'Energy',
            key = 'E',

            { key = 'S', msg = 'Check Caffeine Status', fn = caffeine.alert_is_on },
            { key = 'T', msg = 'Toggle Caffeine',       fn = caffeine.toggle      },

            '-',

            { key = 'O', msg = 'Turn Caffeine On',  fn = caffeine.on  },
            { key = 'F', msg = 'Turn Caffeine Off', fn = caffeine.off },

            '-',

            { key = '1', msg = 'Caffeine on 10 Minutes', fn = function() caffeine.timed_on_m(10) end },
            { key = '2', msg = 'Caffeine on 20 Minutes', fn = function() caffeine.timed_on_m(20) end },
            { key = '3', msg = 'Caffeine on 30 Minutes', fn = function() caffeine.timed_on_m(30) end },
            { key = '4', msg = 'Caffeine on 40 Minutes', fn = function() caffeine.timed_on_m(40) end },
            { key = '5', msg = 'Caffeine on 50 Minutes', fn = function() caffeine.timed_on_m(50) end },
            { key = '6', msg = 'Caffeine on 60 Minutes', fn = function() caffeine.timed_on_m(60) end },

            '-',

            { key = '1', mods = 'shift', msg = 'Caffeine on 1 Hour',  fn = function() caffeine.timed_on_m(60) end },
            { key = '2', mods = 'shift', msg = 'Caffeine on 2 Hours', fn = function() caffeine.timed_on_m(120) end },
            { key = '3', mods = 'shift', msg = 'Caffeine on 3 Hours', fn = function() caffeine.timed_on_m(180) end },
        },

        { key = 'C', msg = 'Select Random PR Targets (Security)', fn = work.get_random_team_member_fn('team-security') },

    }
}
