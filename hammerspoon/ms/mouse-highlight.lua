local colors = require('ms.colors').monokai

local circle = nil
local timer = nil
local eventtap = nil

local stroke_color = colors.green
local fill_color = colors.green:clone_with_alpha(0.2)

local function mouse_highlight()
    if circle then
        circle:delete()
        circle = nil
    end
    if timer then
        timer:stop()
        timer = nil
    end

    if eventtap then
        eventtap:stop()
        eventtap = nil
    end

    local mouse_pos = hs.mouse.absolutePosition()
    circle = hs.drawing.circle(
        hs.geometry.rect(mouse_pos.x - 30, mouse_pos.y - 30, 60,  60)
    )

    circle:setStrokeColor(stroke_color)
    circle:setFillColor(fill_color)
    circle:setStrokeWidth(3)
    circle:show()

    timer = hs.timer.doAfter(1, function()
        if circle then
            circle:delete()
            circle = nil
        end

        if eventtap then
            eventtap:stop()
            eventtap = nil
        end

        if timer then
            timer:stop()
            timer = nil
        end
    end)

    eventtap = hs.eventtap.new(
        {hs.eventtap.event.types.mouseMoved},
        function(event)
            if hs.eventtap.event.types.mouseMoved ~= event:getType() then
                return
            elseif not circle then
                return
            end

            local mouse_pos = hs.mouse.absolutePosition()
            circle:setFrame(
                hs.geometry.rect(mouse_pos.x - 30, mouse_pos.y - 30, 60,  60)
            )
        end
    )
    eventtap:start()
end

return mouse_highlight
