local print = require('ms.logger').new('ms.icon.from_text')
local colors = require('ms.colors').streamdeck

local valid_alignments = { 'left', 'right', 'center', 'justified', 'natural' }

local function get_alignment(alignment)
    if alignment then
        if table.find(valid_alignments, alignment) then
            return alignment
        end

        print:error('invalid alignment: \'' .. alignment .. '\' using default: center')
    end

    return 'center'
end

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
                    alignment = get_alignment(options.text_alignment)
                },
                backgroundColor = background_color,
                color = options.text_color or colors.off_white,
            }),
            transformation = options.transform,
        }
    }
end

return get_canvas_from_text
