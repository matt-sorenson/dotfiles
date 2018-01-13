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

on_device_change()

hs.caffeinate.watcher.new(on_device_change):start()
hs.usb.watcher.new(on_device_change):start()
