local audio    = require 'ms.audio'
local bind     = require 'ms.bind'
local caffeine = require 'ms.caffeine'
local grid     = require 'ms.grid'
local layout   = require 'ms.layout'
local music    = require 'ms.music'
local sys      = require 'ms.sys'

if sys.is_work_computer() then
    REMOTE_SHARE_HOST = 'sorensm.aka.amazon.com'
    REMOTE_SHARE_FOLDER = 'desktop'
else
    REMOTE_SHARE_HOST = 'matt-srv'
    REMOTE_SHARE_FOLDER = 'matt'
end

hs.window.animationDuration = 0

hs.hotkey.bind('alt', 'space', sys.select_app_fn('iTerm', {toggle = true, new_window = {'Shell', 'New Window'} }))

-- Defeat attempts at blocking paste
hs.hotkey.bind({'cmd', 'alt'}, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

local global_modal = bind.modal_new(bind.default_modal(), {'ctrl', 'cmd'}, 'B')

local window_modal = bind.modal_new(global_modal, {}, 'W', 'Window')
local finder_modal = bind.modal_new(global_modal, {}, 'F', 'Finder')
local music_modal  = bind.modal_new(global_modal, {}, 'S', 'Music')
local power_modal  = bind.modal_new(global_modal, {}, 'E', 'Power')

window_modal:bind({'shift'}, 'W', '33% ↑', sys.set_window_rect_fn({   0,   0,   1, 1/3 }))
window_modal:bind({'shift'}, 'A', '33% ←', sys.set_window_rect_fn({   0,   0, 1/3,   1 }))
window_modal:bind({'shift'}, 'S', '33% ↓', sys.set_window_rect_fn({   0, 2/3,   1, 1/3 }))
window_modal:bind({'shift'}, 'D', '33% →', sys.set_window_rect_fn({ 2/3,   0, 1/3,   1 }))
window_modal:bind({},        'W', '50% ↑', sys.set_window_rect_fn({ 0.0, 0.0, 1.0, 0.5 }))
window_modal:bind({},        'A', '50% ←', sys.set_window_rect_fn({ 0.0, 0.0, 0.5, 1.0 }))
window_modal:bind({},        'S', '50% ↓', sys.set_window_rect_fn({ 0.0, 0.5, 1.0, 0.5 }))
window_modal:bind({},        'D', '50% →', sys.set_window_rect_fn({ 0.5, 0.0, 0.5, 1.0 }))

window_modal:add_help_seperator()
window_modal:bind({}, 'Q', "Quiet current window",        sys.set_window_rect_fn({1/8, 8/14, 6/8, 5.5/14}))
window_modal:bind({}, 'F', 'Maximize',                    sys.set_window_rect_fn({ 0, 0, 1, 1 }))
window_modal:bind({}, 'G', 'Grid' ,                       hs.grid.show)
window_modal:bind({}, 'R', 'Apply layout to window',      layout.apply_current_window)
window_modal:bind({}, 'T', 'Apply Default Layout',        function() layout.apply_layout("Default") end)
window_modal:bind({}, 'E', 'Apply Media Layout',          function() layout.apply_layout("Media") end)
window_modal:bind({}, 'C', 'Apply Communications Layout', function() layout.apply_layout("Communications") end)

finder_modal:bind({}, 'G', 'Home',        sys.select_app_fn('Finder', { window = sys.who_am_i(), new_window = sys.open_finder_fn('~/') }))
finder_modal:bind({}, 'W', 'Workspace',   sys.select_app_fn('Finder', { window = 'ws', new_window = sys.open_finder_fn('~/ws') }))
finder_modal:bind({}, 'R', 'Remote Home', sys.select_app_fn('Finder', { window = REMOTE_SHARE_FOLDER, new_window = sys.open_finder_fn('/Volumes/' .. REMOTE_SHARE_FOLDER) }))

music_modal:bind({}, 'S', 'Play/Pause',    music.fn('playpause'),     { shiftable = true })
music_modal:bind({}, 'A', 'Previous',      music.fn('previousTrack'), { shiftable = true })
music_modal:bind({}, 'D', 'Next',          music.fn('nextTrack'),     { shiftable = true })
music_modal:bind({}, 'R', 'Shuffle',       music.fn('shuffle'),       { shiftable = true })
music_modal:bind({}, 'C', 'Select player', function() sys.select_app(music.current_player_bundleID()) end)
music_modal:add_help_seperator()
music_modal:bind({}, 'W', 'Raise volume', audio.update_output_volume_fn( 1), { shiftable = true })
music_modal:bind({}, 'X', 'Lower volume', audio.update_output_volume_fn(-1), { shiftable = true })

power_modal:bind({}, 'S', 'Screen Saver', hs.caffeinate.startScreensaver)
for i = 1,6 do
    power_modal:bind({}, tostring(i), 'Caffeine on ' .. i .. '0 Minutes', function() caffeine.timed_on_m(i * 10) end)
end

if REMOTE_SHARE_HOST and REMOTE_SHARE_FOLDER then
    sys.mount_smb(REMOTE_SHARE_HOST, REMOTE_SHARE_FOLDER)
end

require('default_layout')

local function on_device_change()
    grid.setup_screen()
    grid.select_layout()
    audio.setup_output('usb')
end

local function on_caffeinate_change(arg)
    -- No need to re-run hammerspoon initialization when system is going to sleepish state
    local IGNORE_EVENTS = {}
    IGNORE_EVENTS[hs.caffeinate.watcher.screensaverDidStart]    = true
    IGNORE_EVENTS[hs.caffeinate.watcher.screensaverWillStop]    = true
    IGNORE_EVENTS[hs.caffeinate.watcher.screensDidLock]         = true
    IGNORE_EVENTS[hs.caffeinate.watcher.screensDidSleep]        = true
    IGNORE_EVENTS[hs.caffeinate.watcher.sessionDidResignActive] = true
    IGNORE_EVENTS[hs.caffeinate.watcher.systemWillPowerOff]     = true
    IGNORE_EVENTS[hs.caffeinate.watcher.systemWillSleep]        = true

    if not IGNORE_EVENTS[arg] then
        print("caffeinate event:", EVENT_NAMES[arg])
        on_device_change()
    else
        print("caffeinate ignored event:", EVENT_NAMES[arg])
    end
end

on_device_change()

hs.screen.watcher.new(on_device_change):start()
hs.caffeinate.watcher.new(on_caffeinate_change):start()
hs.usb.watcher.new(on_device_change):start()
