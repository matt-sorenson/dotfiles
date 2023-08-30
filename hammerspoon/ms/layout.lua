local sys = require 'ms.sys'

local function move_window(window, rect, screen)
    screen = screen or window:screen()

    window:setFrame(screen:fromUnitRect(rect))
end

local function _layout_score_str_tbl(array, str)
    for _, v in ipairs(array) do
        if str:match(v:lower()) then
            return true
        end
    end

    return false
end

local function _layout_score_rule(category, app_name, win_name, rule)
    if category then
        if not rule.categories then
            return -1
        elseif not hs.fnutils.find(rule.categories, function(e) return e == category end) then
            return -1
        end
    end

    local score = 0

    if rule.app and app_name then
        if not _layout_score_str_tbl(rule.app, app_name) then
            return -1
        end

        score = score + 1
    end

    if rule.window and win_name then
        if not _layout_score_str_tbl(rule.window, win_name) then
            return -1
        end

        score = score + 2
    end

    return score
end

--[[ export ]]  local function _layout_apply_to_window(self, category, window)
    window = window or hs.window.focusedWindow()

    local app_name = window:application():name():lower()
    local win_name = window:title():lower()

    local top_score, rule, screen = -1, nil, nil
    for i, layout in ipairs(self:layout()) do
        for j, curr_rule in ipairs(layout) do
            local score = _layout_score_rule(category, app_name, win_name, curr_rule)

            if score > top_score then
                top_score = score
                rule = curr_rule
                screen = layout.screen
            end
        end
    end

    if rule then
        if rule.section then
            self:move_window_to_section(window, rule.section)
        elseif rule.rect then
            move_window(window, rule.rect, screen)
        else
            error("layout:apply_to_window requires the rule to have either rect or section.")
        end
    end
end

--[[ export ]] local function _layout_apply(self, category, windows)
    windows = hs.window.allWindows()

    hs.fnutils.ieach(windows, function(window)
        _layout_apply_to_window(self, category, window)
    end)
end

--[[ export ]] local function _layout_get_screen(self, index)
    return self:layout()[index].screen
end

--[[ export ]] local function _layout_move_window_to_section(self, window, section_n)
    local sections = self:sections()

    if sections and sections[section_n] then
        local section = sections[section_n]
        local screen = self:get_screen(section.screen or 1)

        move_window(window, section.rect, screen)
    end
end

local function _layout_lookup_screen(needles)
    for _, needle in ipairs(needles) do
        local screen = hs.screen(needle)

        if screen then
            return screen
        end
    end

    return nil
end

local function _layout_init_screens(self)
    for i, v in ipairs(self:layout()) do
        local screen = _layout_lookup_screen(v.screen)
        if not screen then
            return false
        end

        v.screen = screen
    end

    return true
end

local function _layout_init_layout(self)
    for _, screen in ipairs(self:layout()) do
        for _, rule in ipairs(screen) do
            if rule.app then
                rule.app = toarray(rule.app)
            end

            if rule.window then
                rule.window = toarray(rule.window)
            end

            if rule.categories then
                rule.categories = toarray(rule.categories)
            end
        end
    end
end

local _layout_mt = {
    __index = {
        apply = _layout_apply,
        apply_to_window = _layout_apply_to_window,

        move_window_to_section = _layout_move_window_to_section,

        score = _layout_score,
        get_screen = _layout_get_screen,
    }
}

local function _layout_new(input, name)
    local self = {
        name = function(self) return name end,
        sections = function(self) return input.sections end,
        layout = function(self) return input.layout end,
        is_work_computer = function(self) return input.is_work_computer == true end,
        is_fallback = function(self) return input.fallback == true end,
    }

    _layout_init_layout(self)

    -- If an expected screen is missing then don't load the layout
    if not _layout_init_screens(self) then
        print("['" .. name .. "'] screens not found")
        return nil
    end

    -- If the layout is for work and it's not a work computer then don't
    -- load the layout
    if self:is_work_computer() and not sys.is_work_computer() then
        print("['" .. name .. "'] not a work computer")
        return nil
    end

    print("['" .. name .. "'] layout fits")

    setmetatable(self, _layout_mt)

    return self
end

local function load_screen_configurations()
    local screen_configs = {}
    local layout_files = sys.ls('~/.hammerspoon/resources/layouts')

    for _, filename in pairs(layout_files) do
        if filename:match('.lua$') then
            local name = filename:gsub('.lua$', '')
            local require_str = 'resources.layouts.' .. name
            local layout = _layout_new(require(require_str), name)

            if layout ~= nil then
                table.insert(screen_configs, layout)
            end
        end
    end

    return screen_configs
end

local function filter_configs(screen_configs)
    if #screen_configs > 1 then
        local tmp = screen_configs
        screen_configs = {}

        for _, v in ipairs(tmp) do
            if true ~= v:is_fallback() then
                table.insert(screen_configs, v)
            else
                print("['" .. v:name() .. "]' excluded fallback")
            end
        end
    end

    return screen_configs
end

local function get_config()
    local screen_configs = load_screen_configurations()

    screen_configs = filter_configs(screen_configs)

    if 1 < #screen_configs then
        error('too many screen layouts found.')
    elseif 0 == #screen_configs then
        error('no valid screen layouts found.')
    end

    return screen_configs[1]
end

local current_config = get_config()

--[[ export ]] local function apply(category, windows)
    current_config:apply(categories, windows)
end

--[[ export ]] local function apply_to_window(category, window)
    current_config:apply_to_window(categories, window)
end

--[[ export ]] local function move_window_to_section(window, section)
    current_config:move_window_to_section(window, section)
end

--[[ export ]] local function move_window_fn(rect, screen_n)
    return function()
        local screen = current_config:get_screen(screen_n or 1)
        move_window(hs.window.focusedWindow(), rect, screen)
    end
end

return {
    apply = apply,
    apply_fn = function(categories, windows)
        return function() apply(layout_name, windows) end
    end,
    apply_to_window = apply_to_window,

    move_window_fn = move_window_fn,
    move_window_to_section = move_window_to_section,
    move_window_to_section_fn = function(section)
        return function() move_window_to_section(hs.window.focusedWindow(), section) end
    end
}
