local audio    = require 'ms.audio'
local bind     = require 'ms.bind'
local grid     = require 'ms.grid'
local sys      = require 'ms.sys'

if sys.is_work_computer() then
    REMOTE_SHARE_HOST = 'sorensm.aka.amazon.com'
    REMOTE_SHARE_FOLDER = 'desktop'
else
    REMOTE_SHARE_HOST = 'matt-srv'
    REMOTE_SHARE_FOLDER = 'matt-srv'
end

hs.window.animationDuration = 0

hs.hotkey.bind('alt', 'space', sys.select_app_fn('iTerm', nil, {'Shell', 'New Window'}))
local modal = bind.init(require('keymap'))

if REMOTE_SHARE_HOST and REMOTE_SHARE_FOLDER then
    sys.mount_smb(REMOTE_SHARE_HOST, REMOTE_SHARE_FOLDER)

    local finder_modal = modal.children['global'].children['finder']
    finder_modal:bind({ key = 'R', msg = 'Remote Home', fn = sys.select_app_fn('Finder', REMOTE_SHARE_FOLDER, sys.open_finder_fn('/Volumes/' .. REMOTE_SHARE_FOLDER)) })
end

local function on_device_change()
    audio.setup_output('usb')
end

local function on_caffeinate_change(new_state)
    -- No need to re-run hammerspoon initialization when system is going to sleepish state
    local IGNORE_EVENTS = {
        hs.caffeinate.watcher.screensaverDidStart,
        hs.caffeinate.watcher.screensaverWillStop,
        hs.caffeinate.watcher.screensDidLock,
        hs.caffeinate.watcher.screensDidSleep,
        hs.caffeinate.watcher.sessionDidResignActive,
        hs.caffeinate.watcher.systemWillPowerOff,
        hs.caffeinate.watcher.systemWillSleep,
    }

    local new_state_name = table.find(hs.caffeinate.watcher, new_state)
    if table.find(IGNORE_EVENTS, new_state) then
        print('caffeinate ignored event:', new_state_name)
    else
        print('caffeinate event:', new_state_name)
        on_device_change()
    end
end

on_device_change()

hs.screen.watcher.new(on_device_change):start()
hs.caffeinate.watcher.new(on_caffeinate_change):start()
hs.usb.watcher.new(on_device_change):start()
