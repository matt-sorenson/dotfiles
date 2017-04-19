local spaces = require("hs._asm.undocumented.spaces")
local sys = require 'ms.sys'

local screen_layouts = {}

local function load_screen_layouts()
    local layout_files = sys.ls('~/.hammerspoon/layouts/')

    for _, filename in pairs(layout_files) do
        if filename:match('.lua$') then
            local require_str = 'layouts.' .. filename:gsub('.lua$', '')

            screen_layouts[require_str] = require(require_str);
        end
    end
end

function get_screen_layout()
    local curr_score = 0
    local curr_layout = nil

    for _, layout in pairs(screen_layouts) do
        local score = layout:score()

        if score > curr_score then
            curr_score = score
            curr_layout = layout
        end
    end

    return curr_layout
end

local function score_str_tbl(str, array, score)
    if type(array) ~= 'table' then
        array = {array}
    end

    for _, v in ipairs(array) do
        if str:match(v:lower()) then
            return score
        end
    end

    return -1
end

local function score_element(layout_name, app_name, win_name, element)
    local score = 0
    local correct_layout = false

    if ('default' ~= layout_name) or element.no_default then
        if 0 > score_str_tbl(layout_name, element.layouts, 1) then
            return -1
        end
    end

    if app_name and element.app then
        local app_score = score_str_tbl(app_name, element.app, 1)
        if 0 > app_score then
            return -1
        end

        score = score + app_score
    end

    if win_name and element.window then
        local win_score = score_str_tbl(win_name, element.window, 2)
        if 0 > win_score then
            return -1
        end

        score = score + win_score
    end

    return score;
end

local function find_element_in_layout(layout_name, layout, window)
    local app_name = window:application():name():lower()
    local win_name = window:title():lower()

    layout_name = (layout_name or 'default'):lower()

    local curr_score = 0
    local curr_element, curr_screen, curr_ws = nil

    for screen_i, screen in ipairs(layout) do
        for ws_i, workspace in ipairs(screen) do
            if workspace.app or workspace.window then
                local score = score_element(layout_name, app_name, win_name, workspace)

                if score > curr_score then
                    curr_score = score
                    curr_element = nil
                    curr_screen = nil
                    curr_ws = nil
                end
            else
                for _, element in ipairs(workspace) do
                    local score = score_element(layout_name, app_name, win_name, element)

                    if score > curr_score then
                        curr_score = score
                        curr_element = element
                        curr_screen = screen_i
                        curr_ws = ws_i
                    end
                end
            end
        end
    end

    return curr_element, curr_screen, curr_ws
end

local function move_window(window, element, screen_layout, screen_id, ws_id)
    window = (('string' == type(window)) and hs.window.find(window)) or window
    if not window then
        return
    end

    local screen = screen_layout.screens()[screen_id] or window:screen()

    if ws_id and screen_layout.layout[screen_id][ws_id].fullscreen then
        window:moveToScreen(screen)
        window:setFullScreen(true)
    else
        window:setFrame(screen:fromUnitRect(element.rect))
    end
end

local function apply_to_window(layout_name, window, screen_layout)
    screen_layout = screen_layout or get_screen_layout()

    local element, screen, ws = find_element_in_layout(layout_name, screen_layout.layout, window)

    if element then
        move_window(window, element, screen_layout, screen, ws)
    end
end

local function apply_to_current_window(layout_name)
    apply_to_window(layout_name, hs.window.focusedWindow())
end

local function apply_layout(layout_name)
    local screen_layout = get_screen_layout()

    hs.fnutils.ieach(hs.window.allWindows(), function(window)
        apply_to_window(layout_name, window, screen_layout)
    end)
end

local function apply_layout_fn(layout_name)
    return function() apply_layout(layout_name) end
end

load_screen_layouts()

return {
    apply_to_window = apply_to_window,
    apply_to_current_window = apply_to_current_window,
    apply_layout = apply_layout,
    apply_layout_fn = apply_layout_fn,
}