hs.notify.show('Hammerspoon', '(Re)loading', '')

require 'hs.ipc'
require 'ms.helper'

local sys = require 'ms.sys'

local print = require('ms.logger').logger_fn('init')

hs.ipc.cliInstall()

-- Easy reloading of config file
hs.hotkey.bind({'ctrl', 'cmd'}, 'R', function()
    hs.reload()
end)

-- use pcall to load the file so we can put the error in the console and
-- continue to have the reload hotkey working
result, msg = pcall(function() require 'config' end)

if result then
    hs.notify.show('Hammerspoon', 'Config (re)loaded', '')
    print('Hammerspoon config (re)loaded')
else
    hs.notify.new(hs.openConsole, {
        title = 'Hammerspoon',
        subTitle = 'Failed to (re)load',
        informativeText = ''
    }):withdrawAfter(0):send()
    print("--- Failed to load ms.init ---\n" .. msg .. "\n--- ---")
end

-- Initialization creates lots of garbage
sys.gc()

hs.timer.doEvery(hs.timer.hours(1), sys.gc)
