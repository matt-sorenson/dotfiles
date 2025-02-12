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

local AUDIO_DEVICE_CONFIGS = {
    audioengine = {
        device_name = 'Audioengine 2+',
        name = 'audioengine',
        min_delta = 7,
        is_default = true,
    },
    builtin = {
        device_name = 'MacBook Pro Speakers',
        name = 'builtin',
        min_delta = 5,
    },
    default = {
        min_delta = 5,
    },
}
audio.init(AUDIO_DEVICE_CONFIGS)

hs.window.animationDuration = 0

local modal = bind.init(require('config-keymap'))
local deck = streamdeck.new(require('config-streamdeck'))

if REMOTE_HOME then
    local finder_modal = modal.children['global'].children['finder']
    finder_modal:bind({ key = 'R', msg = 'Remote Home', fn = sys.select_app_fn('Finder', REMOTE_HOME, sys.open_finder_fn('/Volumes/' .. REMOTE_HOME)) })
end

local function on_device_change()
    -- On home machine mount NAS shares
    if not sys.is_work_computer() then
        sys.mount_smb_shares(REMOTE_SHARES)
    end
end

on_device_change()

hs.caffeinate.watcher.new(on_device_change):start()
hs.usb.watcher.new(on_device_change):start()
