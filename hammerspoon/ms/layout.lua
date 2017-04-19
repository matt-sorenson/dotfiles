local sys      = require 'ms.sys'

local screen_layout = {
    { w = 3840, h = 2160 },
    { w = 2160, h = 3840 },
    { w = 3008, h = 1692 },
    { w = 1692, h = 3008 },
    { w = 3440, h = 1440 },
    'DELL U3415W',
    { w = 2560, h = 1440 },
    { w = 1440, h = 2560 },
    { w = 1920, h = 1200 },
    { w = 1680, h = 1050 },
    'Color LCD'
}

local layouts = {}

local function get_screens_helper(screen)
    local query = screen

    if 'table' == type(screen) then
        query = screen.w .. 'x' .. screen.h
    end

    return { hs.screen.find(screen.id) }
end

local function get_screens(screen_descs)
    local out = {}
    local hash = {}

    local primary = hs.screen.primaryScreen()

    hs.fnutils.ieach(screen_descs, function(screen_desc)
        local screens = get_screens_helper(screen_desc)

        if hs.fnutils.contains(screens, primary) then
            screens = hs.fnutils.ifilter(screens, function(e) return e == primary end )
            table.insert(screens, 1, primary)
        end

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
        primary = hs.screen.primaryScreen()
    end

    return { primary = primary, secondary = secondary, laptop = laptop }
end

local function move_window(window, rect, screen)
    window = (('string' == type(window)) and hs.window.find(window)) or window
    if not window then return end

    screen = screen or window:screen()

    window:setFrame(screen:fromUnitRect(rect))
end

local function add_app(layout_name, app_name, window_name, screen_name, x, y, w, h)
    layout_name = layout_name:lower()

    layouts[layout_name] = layouts[layout_name] or {}

    table.insert(layouts[layout_name], {
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

local function find_layout(window, name)
    local win_name = window:title():lower()
    local app_name = window:application():name():lower()
    name = (name or "default"):lower()

    local curr_score = 0
    local curr_layout = nil

    hs.fnutils.ieach(layouts[name], function(layout)
        local score = score_layout(win_name, app_name, layout)

        if score > curr_score then
            curr_score = score
            curr_layout = layout
        end
    end)

    return curr_layout
end

local function apply_to_window(window, screens, name)
    screens = screens or calc_screens()
    local app_layout = find_layout(window, name)

    if app_layout then
        move_window(window, app_layout.rect, screens[app_layout.screen])
    end
end

local function apply_layout(name)
    local screens = calc_screens()

    hs.fnutils.ieach(hs.window.allWindows(), function(window)
        apply_to_window(window, screens, name)
    end)
end

local function apply_current_window(name)
    apply_to_window(hs.window.focusedWindow(), nil, name)
end

return {
    add_app = add_app,
    move_window = move_window,

    apply_layout = apply_layout,
    apply_layout_fn = function(name) return function() apply_layout(name) end end,
    apply_to_window = apply_to_window,
    apply_current_window = apply_current_window
}
