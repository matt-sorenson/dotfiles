local print = require('ms.logger').new('config.keymap')

local audio     = require 'ms.audio'
local caffeine  = require 'ms.caffeine'
local fs        = require 'ms.fs'
local window    = require 'ms.window'
local sys       = require 'ms.sys'
local workspace = require 'ms.workspace'


local function keybind_caffeine_in_minutes(key, minutes)
    return {
        key = key,
        msg = 'Caffeine on ' .. minutes .. ' Minutes',
        fn = function() caffeine.timed_on_m(minutes) end
    }
end

local function keybind_caffeine_in_hours(key, hours)
    local message = 'Caffeine on ' .. hours .. ' Hours'
    if hours == 1 then
        message = 'Caffeine on 1 Hour'
    end

    return {
        key = key,
        mods = 'shift',
        msg = message,
        fn = function() caffeine.timed_on_m(hours * 60) end
    }
end

local function keybind_select_app(key, msg, app_name)
    return { key = key, msg = msg, fn = sys.select_app_fn(app_name) }
end

return {
    {
        title = 'global',
        mods = { 'ctrl', 'cmd' },
        key = 'B',
        skip_help_msg = true,

        -- defeat attempts to block paste
        { key = 'V', msg = "'key event' paste", fn = function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end },

        { key = 'B', msg = 'Find mouse', fn = require('ms.mouse-highlight') },

        {
            title = 'Window',
            key = 'W',

            { key = '1', msg = '1st section of screen', fn = window.layout.move_window_to_section_fn(1) },
            { key = '2', msg = '2nd section of screen', fn = window.layout.move_window_to_section_fn(2) },
            { key = '3', msg = '3rd section of screen', fn = window.layout.move_window_to_section_fn(3) },
            { key = '4', msg = '4rd section of screen', fn = window.layout.move_window_to_section_fn(4) },

            { key = '1', mods = 'shift', msg = '1st 1/3rd of screen', fn = window.layout.move_window_fn({ 0, 0, 1 / 3, 1 }) },
            { key = '2', mods = 'shift', msg = '2nd 1/3rd of screen', fn = window.layout.move_window_fn({ 1 / 3, 0, 1 / 3, 1 }) },
            { key = '3', mods = 'shift', msg = '3rd 1/3rd of screen', fn = window.layout.move_window_fn({ 2 / 3, 0, 1 / 3, 1 }) },

            { key = '1', mods = {'cmd', 'shift'}, msg = '1st 1/2rd of screen', fn = window.layout.move_window_fn({ 0, 0, 1 / 2, 1 }) },
            { key = '2', mods = {'cmd', 'shift'}, msg = '2nd 1/2rd of screen', fn = window.layout.move_window_fn({ 1 / 2, 0, 1 / 2, 1 }) },

            { key = '5', mods = 'shift', msg = 'Resize to 1080p', fn = window.layout.resize_window_fn(1920, 1080) },

            '-',

            { key = 'F', msg = 'Maximize',                    fn = window.layout.move_window_fn({ 0, 0, 1, 1 }) },
            { key = 'R', msg = 'Apply layout to window',      fn = window.layout.apply_to_window },
            { key = 'T', msg = 'Apply Default Layout',        fn = window.layout.apply },
            { key = 'E', msg = 'Apply Media Layout',          fn = window.layout.apply_fn('Media') },
            { key = 'C', msg = 'Apply Communications Layout', fn = window.layout.apply_fn('Communications') },

            '-',

            { key = 'S', msg = 'Get current window size', fn = sys.get_current_window_size },

            '-',

            { key = 'G',                 msg = 'Grid', fn = window.grid.show,             optional_mods = 'shift' },
            { key = 'G', mods = 'shift', msg = 'Grid', fn = window.grid.show_fn('shift'), skip_help_msg = true },

            { key = 'Z', msg = 'Start focused Zoom meeting', fn = workspace.zoom_meeting },
        },

        {
            title = 'Finder',
            key = 'F',

            { key = 'G', msg = 'Home',         fn = sys.select_app_fn('Finder', sys.who_am_i(), sys.open_finder_fn('~/')) },
            { key = 'W', msg = 'Workspace',    fn = sys.select_app_fn('Finder', 'ws', sys.open_finder_fn('~/ws')) },

            { key = 'S', msg = 'Mount Shares', fn = function() fs.samba.mount_shares(REMOTE_SHARES) end }
        },

        {
            title = 'Sound',
            key = 'S',

            { key = 'S', msg = 'Play/Pause', fn = sys.trigger_system_key_fn('PLAY'),     repeat_on_mods = 'shift' },
            { key = 'A', msg = 'Previous',   fn = sys.trigger_system_key_fn('PREVIOUS'), repeat_on_mods = 'shift' },
            { key = 'D', msg = 'Next',       fn = sys.trigger_system_key_fn('NEXT'),     repeat_on_mods = 'shift' },

            '-',

            { key = 'W', msg = 'Raise volume', fn = audio.increase_volume, repeat_on_mods = 'shift' },
            { key = 'X', msg = 'Lower volume', fn = audio.decrease_volume, repeat_on_mods = 'shift' },
        },

        {
            title = 'Energy',
            key = 'E',

            { key = 'S', msg = 'Check Caffeine Status', fn = caffeine.alert_status },
            { key = 'T', msg = 'Toggle Caffeine',       fn = caffeine.toggle },

            '-',

            { key = 'O', msg = 'Turn Caffeine On',  fn = caffeine.on },
            { key = 'F', msg = 'Turn Caffeine Off', fn = caffeine.off },

            '-',

            keybind_caffeine_in_minutes('1', 10),
            keybind_caffeine_in_minutes('2', 20),
            keybind_caffeine_in_minutes('3', 30),
            keybind_caffeine_in_minutes('4', 40),
            keybind_caffeine_in_minutes('5', 50),
            keybind_caffeine_in_minutes('6', 60),
            keybind_caffeine_in_minutes('7', 70),
            keybind_caffeine_in_minutes('8', 80),
            keybind_caffeine_in_minutes('9', 90),
            keybind_caffeine_in_minutes('0', 100),

            '-',

            keybind_caffeine_in_hours('1', 1),
            keybind_caffeine_in_hours('2', 2),
            keybind_caffeine_in_hours('3', 3),
            keybind_caffeine_in_hours('4', 4),
            keybind_caffeine_in_hours('5', 5),
        },

        {
            title = 'Applications',
            key = 'A',

            keybind_select_app('S', 'Slack', 'Slack'),
            keybind_select_app('V', 'Visual Studio', 'Visual Studio Code'),
            keybind_select_app('F', 'Firefox', 'Firefox'),
            keybind_select_app('C', 'Chrome', 'Google Chrome'),
            keybind_select_app('Z', 'Zoom', 'zoom.us'),
        }
    }
}
