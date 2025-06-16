local print = require('ms.logger').new('ms.streamdeck.init')

local deck_frame = require 'ms.streamdeck.deck_frame'

return {
    new = deck_frame.new,
}
