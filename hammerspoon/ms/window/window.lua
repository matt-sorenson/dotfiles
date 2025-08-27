--[[ export ]]
local function move(window, rect, screen)
    window:move(rect, screen or window:screen())
end

--[[ export ]]
local function resize(window, width, height)
    local frame = window:frame()

    frame.w = width
    frame.h = height

    window:setFrame(frame)
end

--[[ export ]]
local function center(window, screen)
    screen = screen or window:screen()

    local screen_rect = screen:frame()
    local window_rect = window:frame()
    local rect = {
        screen_rect.x + (screen_rect.w - window_rect.w) / 2,
        screen_rect.y + (screen_rect.h - window_rect.h) / 2,
        window_rect.w,
        window_rect.h,
    }

    window:move(rect, screen)
end

--[[ export ]]
local resize_and_center = function(window, width, height, screen)
    screen = screen or window:screen()

    local screen_rect = screen:frame()
    local rect = {
        screen_rect.x + (screen_rect.w - width) / 2,
        screen_rect.y + (screen_rect.h - height) / 2,
        width,
        height,
    }

    window:move(rect, screen)
end

return {
    move = move,
    move_fn = function(rect)
        return function()
            move(hs.window.focusedWindow(), rect)
        end
    end,

    resize = resize,
    resize_fn = function(width, height)
        return function()
            resize(hs.window.focusedWindow(), width, height)
        end
    end,

    center = center,
    center_fn = function()
        return function() center(hs.window.focusedWindow()) end
    end,

    resize_and_center = resize_and_center,
}