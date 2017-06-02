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

local modal = bind.init(require('keymap'))

if REMOTE_SHARE_HOST and REMOTE_SHARE_FOLDER then
    sys.mount_smb(REMOTE_SHARE_HOST, REMOTE_SHARE_FOLDER)

    local finder_modal = modal.children['global'].children['finder']
    finder_modal:bind({ key = 'R', msg = 'Remote Home', fn = sys.select_app_fn('Finder', { window = REMOTE_SHARE_FOLDER, new_window = sys.open_finder_fn('/Volumes/' .. REMOTE_SHARE_FOLDER) }) })
end

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
        print("caffeinate event:", table.find(hs.caffeinate.watcher, arg))
        on_device_change()
    else
        print("caffeinate ignored event:", table.find(hs.caffeinate.watcher, arg))
    end
end

on_device_change()

hs.screen.watcher.new(on_device_change):start()
hs.caffeinate.watcher.new(on_caffeinate_change):start()
hs.usb.watcher.new(on_device_change):start()
