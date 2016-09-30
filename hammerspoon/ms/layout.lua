local sys      = require 'ms.sys'

local screen_layout = {
    { id = 722476045 },
    { id = 722476558 },
    { id = 724070605 },
    { resolution = { w = 3840, h = 2160 } },
    { resolution = { w = 2160, h = 3840 } },
    { resolution = { w = 3008, h = 1692 } },
    { resolution = { w = 1692, h = 3008 } },
    { resolution = { w = 3440, h = 1440 } },
    { name = 'DELL U3415W' },
    { resolution = { w = 2560, h = 1440 } },
    { resolution = { w = 1440, h = 2560 } },
    { id = 69731904 },
    { resolution = { w = 1920, h = 1200 } },
    { resolution = { w = 1680, h = 1050 } },
    { name = 'Color LCD' }
}

local function get_screens_helper(screen)
    local out = { hs.screen.find(screen.id) }

    if #out > 0 then
        return out
    end

    out = { hs.screen.find(screen.name) }

    local resolution

    if screen.resolution then
        resolution = screen.resolution.w .. 'x' .. screen.resolution.h
    end

    if #out > 0 then
        return out
    end

    return { hs.screen.find(resolution) }
end

local function get_screens(screen_descs)
    local out = {}
    local hash = {}

    hs.fnutils.ieach(screen_descs, function(screen_desc)
        local screens = get_screens_helper(screen_desc)

        hs.fnutils.ieach(screens, function(screen)
            if hash[screen:id()] == nil then
                table.insert(out, screen)
                hash[screen:id()] = true
            end
        end)
    end)

    return out
end

local function calc_screens()
    local primary, secondary, laptop = table.unpack(get_screens(screen_layout))

    if not primary then
        if secondary then
            primary = secondary
            secondary = nil
        elseif laptop then
            primary = laptop
            laptop = nil
        else
            primary = hs.screen.allScreens()[1]
        end
    end

    if (not secondary) and laptop then
        secondary = laptop
        laptop = nil
    end

    return { primary = primary, secondary = secondary, laptop = laptop }
end

local current_layout = {}

local function move_window(window, rect, screen)
    window = (('string' == type(window)) and hs.window.find(window)) or window
    if not window then return end

    screen = screen or window:screen()

    window:setFrame(screen:fromUnitRect(rect))
end

local function add_app(app_name, window_name, screen_name, x, y, w, h)
    table.insert(current_layout, {
        app    = ((app_name and app_name:lower()) or nil),
        window = ((window_name and window_name:lower()) or nil),
        screen = screen_name:lower(),
        rect   = {x, y, w, h}
    })
end

local function score_layout(win_name, app_name, layout)
    local score = 0

    if app_name and layout.app and app_name:match(layout.app) then
        score = score + 1
    end

    if win_name and layout.window and win_name:match(layout.window) then
        score = score + 2
    end

    return score;
end

local function find_layout(window, layouts)
    local win_name = window:title():lower()
    local app_name = window:application():name():lower()

    local curr_score = 0
    local curr_layout = nil

    hs.fnutils.ieach(layouts, function(layout)
        local score = score_layout(win_name, app_name, layout)

        if score > curr_score then
            curr_score = score
            curr_layout = layout
        end
    end)

    return curr_layout
end

local function apply()
    local screens = calc_screens()

    hs.fnutils.ieach(hs.window.allWindows(), function(window)
        local layout = find_layout(window, current_layout)

        if layout then
            move_window(window, layout.rect, screens[layout.screen])
        end
    end)
end

return {
    apply = apply,
    add_app = add_app,
    move_window = move_window
}
