local audio = require 'ms.audio'
local bind  = require 'ms.bind'
local grid  = require 'ms.grid'
local sys   = require 'ms.sys'

local icon = require 'ms.icon'
local streamdeck = require 'ms.streamdeck'

REMOTE_SHARES = {}

debug_output = {
    audio = false,
    grid = true,
}

if not sys.is_work_computer() then
    REMOTE_SHARES['matt-srv'] = { 'matt-srv', 'media' }
    REMOTE_HOME = 'matt-srv'
end

hs.window.animationDuration = 0

local modal = bind.init(require('keymap'))

local deck = streamdeck.new({
    buttons = {
        {
            type = 'folder',

            buttons = {
                'up',
                'blank',
                'blank',
                'blank',

                'blank',
                'blank',
                'blank',
                'blank',
            }
        },
        'blank',
        'blank',
        {
            on_press = function(self, deck)
                audio:toggle_mic_mute()
                return true
            end,

            get_icon = function(self)
                if audio:is_mic_muted() then
                    return icon.get_icon({
                        path = 'mic-muted.png',
                    })
                else
                    return icon.get_icon({
                        path = 'mic-unmuted.png',
                    })
                end
            end,
        },

        'blank',
        'blank',
        'blank',
        {
            on_press = function(self, deck)
                audio:toggle_mute()
                return true
            end,

            get_icon = function(self)
                if audio:is_muted() then
                    return icon.get_icon({
                        path = 'speaker-muted.png',
                    })
                else
                    return icon.get_icon({
                        path = 'speaker-unmuted.png',
                    })
                end
            end,
        },
    }
})


if REMOTE_HOME then
    local finder_modal = modal.children['global'].children['finder']
    finder_modal:bind({ key = 'R', msg = 'Remote Home', fn = sys.select_app_fn('Finder', REMOTE_HOME, sys.open_finder_fn('/Volumes/' .. REMOTE_HOME)) })
end

local function on_device_change()
    audio.setup_output('audioengine')
    if not sys.is_work_computer() then
        sys.mount_smb_shares(REMOTE_SHARES)
    end
end

on_device_change()

hs.caffeinate.watcher.new(on_device_change):start()
hs.usb.watcher.new(on_device_change):start()
