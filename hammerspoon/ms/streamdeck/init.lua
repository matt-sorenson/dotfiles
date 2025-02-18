local print = require('ms.logger').logger_fn('ms.streamdeck.init')

local deck_frame = require 'ms.streamdeck.deck_frame'

return {
    new = deck_frame.new,
}
