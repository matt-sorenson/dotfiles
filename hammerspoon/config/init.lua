local audio      = require 'ms.audio'
local bind       = require 'ms.bind'
local fs         = require 'ms.fs'
local streamdeck = require 'ms.streamdeck'
local sys        = require 'ms.sys'
local work       = require 'ms.work'

sys.add_allowed_global('REMOTE_SHARES')
REMOTE_SHARES = {
    config = {}
}

if not work.is_work_computer() then
    REMOTE_SHARES['matt-srv'] = { 'matt-srv', 'media' }
    REMOTE_SHARES.config = {}
    REMOTE_SHARES.config.home = 'matt-srv'
end

local _audio_device_configs = {
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

hs.window.animationDuration = 0

local modal = bind.init(require('config.keymap'))
--luacheck: no unused
local deck = streamdeck.new(require('config.streamdeck'))

if REMOTE_SHARES.config.home then
    local finder_modal = modal.children['global'].children['finder']
    finder_modal:bind({
        key = 'R',
        msg = 'Remote Home',
        fn = sys.select_app_fn(
            'Finder',
            REMOTE_SHARES.config.home,
            sys.open_finder_fn('/Volumes/' .. REMOTE_SHARES.config.home)
        )
    })
end

local function on_device_change()
    -- On home machine mount NAS shares
    if #REMOTE_SHARES > 0 then
        fs.samba.mount_shares(REMOTE_SHARES)
    end

    audio.init(_audio_device_configs, false)
end

on_device_change()
audio.init(_audio_device_configs)

hs.caffeinate.watcher.new(on_device_change):start()
hs.usb.watcher.new(on_device_change):start()
