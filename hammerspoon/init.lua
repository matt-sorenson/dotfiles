require 'ms.helper'
local console = require 'ms.console'

console.setTheme()

local print = require('ms.logger').new('init')

-- This kludges the hs.logger.new to use the ms.logger instead with a wrapper.
require 'ms.logger.hammerspoon-kludge'

hs.notify.show('Hammerspoon', '(Re)loading', '')

-- Used to trigger the reload of the config file from dotfiles update function in shell
require 'hs.ipc'
hs.ipc.cliInstall()

local sys = require 'ms.sys'

-- Easy reloading of config file
hs.hotkey.bind({ 'ctrl', 'cmd' }, 'R', function()
    hs.reload()
end)

-- use pcall to load the file so we can put the error in the console and
-- continue to have the reload hotkey working
local result, msg = pcall(function() require 'config' end)

if result then
    hs.notify.show('Hammerspoon', 'Config (re)loaded', '')
    print('Hammerspoon config (re)loaded')
else
    hs.notify.new(hs.openConsole, {
        title = 'Hammerspoon',
        subTitle = 'Failed to (re)load',
        informativeText = ''
    }):withdrawAfter(0):send()
    print:error("Failed to load config.init", msg)
end

-- Initialization can create a lot of garbage
sys.gc()

hs.timer.doEvery(hs.timer.hours(1), sys.gc)
