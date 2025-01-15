local print = require('ms.logger').logger_fn('ms:streamdeck:init')

local colors = require 'ms.colors'
local icon = require 'ms.icon'

local button = require 'ms.streamdeck.button'
local deck_frame = require 'ms.streamdeck.deck_frame'
local encoder = require 'ms.streamdeck.encoder'

return {
    new = deck_frame.new,
}
