local print = require('ms.logger').logger_fn('config')

local audio = require 'ms.audio'
local bind  = require 'ms.bind'
local streamdeck = require 'ms.streamdeck'
local sys   = require 'ms.sys'

REMOTE_SHARES = {}

if not sys.is_work_computer() then
    REMOTE_SHARES['matt-srv'] = { 'matt-srv', 'media' }
    REMOTE_HOME = 'matt-srv'
end

hs.window.animationDuration = 0

local modal = bind.init(require('config-keymap'))
local deck = streamdeck.new(require('config-streamdeck'))

if REMOTE_HOME then
    local finder_modal = modal.children['global'].children['finder']
    finder_modal:bind({ key = 'R', msg = 'Remote Home', fn = sys.select_app_fn('Finder', REMOTE_HOME, sys.open_finder_fn('/Volumes/' .. REMOTE_HOME)) })
end

local function on_device_change()
    audio.setup_output(audio.device_names.audioengine)

    -- On home machine mount NAS shares
    if not sys.is_work_computer() then
        sys.mount_smb_shares(REMOTE_SHARES)
    end
end

on_device_change()

hs.caffeinate.watcher.new(on_device_change):start()
hs.usb.watcher.new(on_device_change):start()
