local function button_label(message, valign)
    valign = valign or 'bottom'

    local frame
    if valign == 'bottom' then
        frame = { x = 0, y = 96 - 30, w = 96, h = 22 }
    elseif valign == 'top' then
        frame = { x = 0, y = 0, w = 96, h = 22 }
    end

    return {
        text = message,
        font_size = 20,
        text_alignment = 'center',
        frame = frame,
        background_color = { red = 0, green = 0, blue = 0, alpha = .75 },
    }
end

local function button_icon(path)
    local frame = { x = 10, y = 10, w = 76, h = 76 }
    return { path = path, frame = frame }
end


local function button_icon_label(path, message, valign)
    return {
        button_icon(path),
        button_label(message, valign),
    }
end

return {
    button_label = button_label,
    button_icon = button_icon,
    button_icon_label = button_icon_label,
}