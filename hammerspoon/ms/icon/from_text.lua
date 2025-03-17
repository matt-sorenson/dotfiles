local print  = require('ms.logger').new('ms.icon.from_text')

local colors = require('ms.colors').streamdeck

local function get_canvas_from_text(text, options)
    local background_color = options.background_color or colors.black
    if options.skip_background_color then
        background_color = nil
    end

    return {
        {
            type = "text",
            frame = options.frame,
            text = hs.styledtext.new(text, {
                font = {
                    name = options['font'] or ".AppleSystemUIFont",
                    size = options['font_size'] or 70
                },
                paragraphStyle = {
                    alignment = options.text_alignment or "center"
                },
                backgroundColor = background_color,
                color = options.text_color or colors.off_white,
            }),
            transformation = options.transform,
        }
    }
end

return get_canvas_from_text
