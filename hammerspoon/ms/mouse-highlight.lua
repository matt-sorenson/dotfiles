colors = require('ms.colors').monokai

local circle = nil
local timer = nil

local stroke_color = colors.green
local fill_color = table.shallow_copy(colors.green)
fill_color.alpha = 0.2

local function mouse_highlight()
    if circle then
        circle:delete()
        circle = nil
    end
    if timer then
        timer:stop()
        timer = nil
    end

    local mouse_pos = hs.mouse.getAbsolutePosition()
    circle = hs.drawing.circle(
        hs.geometry.rect(mouse_pos.x - 30, mouse_pos.y - 30, 60,  60)
    )

    circle:setStrokeColor(stroke_color)
    circle:setFillColor(fill_color)
    circle:setStrokeWidth(3)
    circle:show()

    timer = hs.timer.doAfter(1, function()
        circle:delete()
        circle = nil
    end)
end

return mouse_highlight