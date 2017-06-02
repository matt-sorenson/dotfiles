local sys = require 'ms.sys'

local menubar
local screen_configurations = {}

local function layout_score(self)
    local score = 0

    if #(self:screens()) == #self.layout then
        score = score + #self.layout
    else
        return -1
    end

    if self.is_work_computer then
        if sys.is_work_computer() then
            score = score + 1
        else
            return -1
        end
    end

    return score
end

local function layout_screens(self)
    local out = {}
    layout = self.layout

    for _, screen_layout in ipairs(layout) do
        local screen = hs.screen(screen_layout.screen)

        if screen then
            table.insert(out, screen)
        end
    end

    return out
end

local function layout_layout_names(self)
    local layout_names = {}

    print('here')

    for _, screen in ipairs(self.layout) do
        print(screen.screen)
        for _, rule in ipairs(screen) do
            print(rule.app, rule.layouts, type(rule.layouts))
            if type(rule.layouts) == 'string' then
                layout_names[rule.layouts] = true
            elseif type(rule.layouts) == 'table' then
                for _, layout in ipairs(rule.layouts) do
                    layout_names[layout] = true
                end
            end
        end
    end

    local out = {}

    for layout, _ in pairs(layout_names) do
        table.insert(out, layout)
        print(layout)
    end

    return out
end

local function score_str_tbl(str, array)
    for _, v in ipairs(toarray(array)) do
        if str:match(v:lower()) then
            return true
        end
    end

    return false
end

local function score_rule(layout_name, app_name, win_name, rule)
    local score = 0
    local correct_layout = false

    if layout_name or rule.no_default then
        if not score_str_tbl(layout_name, rule.layouts) then
            return -1
        end
    end

    if app_name and rule.app then
        if not score_str_tbl(app_name, rule.app) then
            return -1
        end

        score = score + 1
    end

    if win_name and rule.window then
        if not score_str_tbl(win_name, rule.window) then
            return -1
        end

        score = score + 2
    end

    return score
end

local function move_window(window, rect, screen)
    screen = screen or window:screen()

    window:setFrame(screen:fromUnitRect(rect))
end

local function layout_apply_to_window(self, layout_name, window, screens)
    if layout_name then
        layout_name = layout_name:lower()
    end

    local app_name = window:application():name():lower()
    local win_name = window:title():lower()

    local score, rule, screen_id = 0, nil, nil
    for curr_screen_id, screen in ipairs(layout) do
        for _, curr_rule in ipairs(screen) do
            local curr_score = score_rule(layout_name, app_name, win_name, curr_rule)

            if curr_score > score then
                score = curr_score
                rule = curr_rule
                screen_id = curr_screen_id
            end
        end
    end

    if rule then
        screens = screens or self:screens()
        move_window(window, rule.rect, screens[screen_id])
    end
end

local function layout_apply(self, layout_name, windows)
    local screens = self:screens()
    windows = (windows and toarray(windows)) or hs.window.allWindows()

    hs.fnutils.ieach(windows, function(window)
        layout_apply_to_window(self, layout_name, window, screens)
    end)
end

local layout_mt = { __index = {} }
layout_mt.__index.apply = layout_apply
layout_mt.__index.screens = layout_screens
layout_mt.__index.score = layout_score
layout_mt.__index.layout_names = layout_layout_names

local function layout_new(layout)
    local out = {}

    out.layout = layout
    setmetatable(out, layout_mt)

    return out
end

local function load_screen_configurations()
    local layout_files = sys.ls('~/.hammerspoon/layouts/')

    for _, filename in pairs(layout_files) do
        if filename:match('.lua$') then
            local require_str = 'layouts.' .. filename:gsub('.lua$', '')
            local layout = layout_new(require(require_str))

            table.insert(screen_configurations, layout)
        end
    end
end

local function get_screen_layout()
    local curr_score = 0
    local curr_layout = nil

    for _, layout in ipairs(screen_configurations) do
        local score = layout:score()

        if score > curr_score then
            curr_score = score
            curr_layout = layout
        end
    end

    return curr_layout
end

--[[ export ]] local function apply(layout_name, windows)
    get_screen_layout():apply(layout_name, windows)
end

--[[ export ]] local function apply_to_window(layout_name, window)
    window = window or hs.window.focusedWindow()
    apply(layout_name, window)
end

--[[ export ]] local function apply_fn(layout_name)
    return function() apply(layout_name) end
end

--[[ export ]] local function move_window_fn(rect, screen_id)
    return function()
        screen = get_screen_layout():screens()[screen_id]
        move_window(hs.window.focusedWindow(), rect, screen)
    end
end

load_screen_configurations()

menubar = hs.menubar.new(false)
menubar:setIcon(hs.configdir .. '/icons/monitor@2x.png')
menubar:returnToMenuBar()

menubar:setMenu(function()
    local out = {
        { title = 'Default', fn = apply }
    }

    for _, layout in ipairs(get_screen_layout():layout_names()) do
        local title = layout:sub(1,1):upper() .. layout:sub(2)
        table.insert(out, { title = title, fn = apply_fn(layout) })
    end

    return out
end)

add_cleanup_fn(function() menubar:delete(); menubar = nil end)

return {
    apply_to_window = apply_to_window,
    apply = apply,
    apply_fn = apply_fn,

    move_window_fn = move_window_fn,
}
