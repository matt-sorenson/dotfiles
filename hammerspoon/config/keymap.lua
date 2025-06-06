local print = require('ms.logger').new('config.keymap')

local audio     = require 'ms.audio'
local caffeine  = require 'ms.caffeine'
local fs        = require 'ms.fs'
local window    = require 'ms.window'
local sys       = require 'ms.sys'
local work      = require 'ms.work'
local workspace = require 'ms.workspace'

work.init()
local pr_hotkeys = {
    title = 'Team PR Targets',
    key = 'T',
}
for team, hotkey in pairs(work.get_pr_hotkey_map()) do
    table.insert(pr_hotkeys, {
        key = hotkey,
        msg = 'Random ' .. team .. ' member',
        fn = work.get_random_team_member_fn(team)
    })
end

-- If there are no PR hotkeys then remove the table so we don't have an empty sub-section
if #pr_hotkeys == 0 then
    pr_hotkeys = nil
end

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
        key = '[shift] ' .. key,
        msg = message,
        fn = function() caffeine.timed_on_m(hours * 60) end
    }
end

local function keybind_select_app(key, msg, app_name)
    return { key = key, msg = msg, fn = sys.select_app_fn(app_name) }
end

local function layout_has_sections_fn(section)
    return function()
        return not window.layout.current_layout_has_section(section)
    end
end

local config = {
    {
        title = 'global',
        key = '[ctrl,cmd] B',
        skip_help = true,

        {
            title = 'Window',
            key = 'W',

            { key = '1', msg = '1st section of screen', fn = window.layout.move_window_to_section_fn(1), skip_help = layout_has_sections_fn(1) },
            { key = '2', msg = '2nd section of screen', fn = window.layout.move_window_to_section_fn(2), skip_help = layout_has_sections_fn(2) },
            { key = '3', msg = '3rd section of screen', fn = window.layout.move_window_to_section_fn(3), skip_help = layout_has_sections_fn(3) },
            { key = '4', msg = '4rd section of screen', fn = window.layout.move_window_to_section_fn(4), skip_help = layout_has_sections_fn(4) },

            { key = '[shift] 1', msg = '1st 1/3 of screen', fn = window.layout.move_window_fn({ 0, 0, 1 / 3, 1 }) },
            { key = '[shift] 2', msg = '2nd 1/3 of screen', fn = window.layout.move_window_fn({ 1 / 3, 0, 1 / 3, 1 }) },
            { key = '[shift] 3', msg = '3rd 1/3 of screen', fn = window.layout.move_window_fn({ 2 / 3, 0, 1 / 3, 1 }) },

            { key = '[cmd,shift] 1', msg = '1st 1/2 of screen', fn = window.layout.move_window_fn({ 0, 0, 1 / 2, 1 }) },
            { key = '[cmd,shift] 2', msg = '2nd 1/2 of screen', fn = window.layout.move_window_fn({ 1 / 2, 0, 1 / 2, 1 }) },

            { key = '[shift] 5', msg = 'Resize to 1080p', fn = window.layout.resize_window_fn(1920, 1080) },
            { key = 'F',         msg = 'Maximize',        fn = window.layout.move_window_fn({ 0, 0, 1, 1 }) },
            { key = 'C',         msg = 'Center',          fn = window.layout.center_window_fn() },

            '-',

            { key = 'R', msg = 'Apply layout to window',      fn = window.layout.apply_to_window },
            { key = 'T', msg = 'Apply Default Layout',        fn = window.layout.apply },
            { key = 'E', msg = 'Apply Media Layout',          fn = window.layout.apply_fn('media') },
            { key = 'B', msg = 'Apply Communications Layout', fn = window.layout.apply_fn('communications') },

            '-',

            { key = 'G',         msg = 'Grid', fn = window.grid.show,             optional_mods = 'shift' },
            { key = '[shift] G', msg = 'Grid', fn = window.grid.show_fn('shift'), skip_help = true },

            '-',

            { key = 'S', msg = 'Get current window size', fn = sys.get_current_window_size },

            '-',

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
        },

        '-',

        -- defeat attempts to block paste
        { key = 'V', msg = "'key event' paste", fn = function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end },
        { key = 'B', msg = 'Find mouse', fn = require('ms.mouse-highlight') },

        '-',

        pr_hotkeys,
    }
}

table.compact(config)

return config
