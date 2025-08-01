local print = require('ms.logger').new('ms.layout')

local sys = require 'ms.sys'
local fs = require 'ms.fs'

--[[ export]]
local function move_window(window, rect, screen)
    window:move(rect, screen or window:screen())
end

--[[ export ]]
local function resize_window(window, width, height)
    local frame = window:frame()

    frame.w = width
    frame.h = height

    window:setFrame(frame)
end

--[[ export ]]
local function center_window(window, screen)
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

local resize_and_center_window = function(window, width, height, screen)
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

local function _layout_score_str_tbl(array, str)
    return nil ~= table.find(array, function(e)
        if '' == e then
            return str == e
        else
            return str:match(e:lower())
        end
    end)
end

local function _layout_score_rule(category, app_name, win_name, rule)
    if category then
        if not rule.categories then
            return -1
        end

        category = category:lower()
        -- categories are converted at loading time to a list of lowercased names.
        if not table.find(rule.categories, function(e) return e == category end) then
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

--[[ export:layout_mt ]]
local function _layout_apply_to_window(self, category, window)
    window = window or hs.window.focusedWindow()

    local app_name = window:application():name():lower()
    local win_name = window:title():lower()

    local top_score, rule, screen = -1, nil, nil
    table.ieach(self:layout(), function(layout)
        table.ieach(layout, function(curr_rule)
            local score = _layout_score_rule(category, app_name, win_name, curr_rule)

            if score > top_score then
                top_score = score
                rule = curr_rule
                screen = layout.screen
            end
        end)
    end)

    if rule then
        if rule.section then
            self:move_window_to_section(window, rule.section)
        elseif rule.center then
            center_window(window, screen)
        elseif rule.resize_center then
            resize_and_center_window(window, rule.resize_center[1], rule.resize_center[2], screen)
        elseif 'function' == type(rule.rect) then
            move_window(window, rule.rect(window), screen)
        elseif rule.rect then
            move_window(window, rule.rect, screen)
        else
            error("layout:apply_to_window requires the rule to have one of rect, section, or center.")
        end
    end
end

--[[ export:layout_mt ]]
local function _layout_apply(self, category, windows)
    if not windows then
        windows = hs.window.allWindows()
    end

    table.ieach(windows, function(window)
        _layout_apply_to_window(self, category, window)
    end)
end

--[[ export:layout_mt ]]
local function _layout_get_screen(self, index)
    return self:layout()[index].screen
end

--[[ export:layout_mt ]]
local function _layout_move_window_to_section(self, window, section_n)
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
    for _, v in ipairs(self:layout()) do
        local screen = _layout_lookup_screen(v.screen)
        if not screen then
            return false
        end

        v.screen = screen
    end

    return true
end

local function _layout_init_layout(self)
    table.ieach(self:layout(), function(screen)
        table.ieach(screen, function(rule)
            if rule.app then
                rule.app = toarray(rule.app)
            end

            if rule.window then
                rule.window = toarray(rule.window)
            end

            if rule.categories then
                rule.categories = table.map(
                    toarray(rule.categories),
                    function(e) return e:lower() end
                )
            end
        end)
    end)
end

local _layout_mt = {
    __index = {
        apply = _layout_apply,
        apply_to_window = _layout_apply_to_window,

        move_window_to_section = _layout_move_window_to_section,

        get_screen = _layout_get_screen,
    }
}

local function _layout_new(input, name)
    local self = {
        name = function(_self) return name end,
        sections = function(_self) return input.sections end,
        layout = function(_self) return input.layout end,
        is_work_computer = function(_self) return input.is_work_computer == true end,
        is_fallback = function(_self) return input.fallback == true end,
    }

    _layout_init_layout(self)

    -- If an expected screen is missing then don't load the layout
    if not _layout_init_screens(self) then
        print:debug("'" .. name .. "' screens not found")
        return nil
    end

    -- If the layout is for work and it's not a work computer then don't
    -- load the layout
    if self:is_work_computer() and not sys.is_work_computer() then
        print("'" .. name .. "' not a work computer")
        return nil
    end

    print:debug("'" .. name .. "' layout fits")

    setmetatable(self, _layout_mt)

    return self
end

local function load_screen_configurations()
    local screen_configs = {}
    local layout_files = fs.ls(fs.get_resource_path() .. '/layouts')

    table.each(layout_files, function(filename)
        if filename:match('.lua$') then
            local name = filename:gsub('.lua$', '')
            local file = '/layouts/' .. filename
            local layout = _layout_new(fs.do_file_resources(file), name)

            if layout ~= nil then
                table.insert(screen_configs, layout)
            end
        end
    end)

    return screen_configs
end

local function filter_configs(screen_configs)
    if not sys.is_work_computer() then
        print:debug("Filtering out work layouts.")
        screen_configs = table.filter(screen_configs, function(v) return not v:is_work_computer() end)
    else
        print:debug("filtering out non-work layouts.")
        screen_configs = table.filter(screen_configs, function(v) return v:is_work_computer() end)
    end

    if #screen_configs > 1 then
        print:debug("Multiple screen layouts found, filtering out fallback layouts.")
        screen_configs = table.filter(screen_configs, function(v) return not v:is_fallback() end)
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

--[[ export ]]
local function apply(category, windows)
    get_config():apply(category, windows)
end

--[[ export ]]
local function apply_to_window(category, window)
    get_config():apply_to_window(category, window)
end

--[[ export ]]
local function move_window_to_section(window, section)
    get_config():move_window_to_section(window, section)
end

--[[ export ]]
local function move_window_fn(rect, screen_n)
    return function()
        local screen = get_config():get_screen(screen_n or 1)
        move_window(hs.window.focusedWindow(), rect, screen)
    end
end

--[[ export]]
local function resize_window_fn(width, height)
    return function()
        resize_window(hs.window.focusedWindow(), width, height)
    end
end

--[[ export ]]
local function center_window_fn()
    return function() center_window(hs.window.focusedWindow()) end
end
-- [[ export]]
local function current_layout_has_section(section_n)
    local sections = get_config():sections()

    if sections and nil ~= sections[section_n] then
        return true
    end

    return false
end

return {
    apply = apply,
    apply_fn = function(categories)
        return function() apply(categories) end
    end,
    apply_to_window = apply_to_window,

    center_window = center_window,
    center_window_fn = center_window_fn,

    move_window = move_window,
    move_window_fn = move_window_fn,
    move_window_to_section = move_window_to_section,
    move_window_to_section_fn = function(section)
        return function() move_window_to_section(hs.window.focusedWindow(), section) end
    end,

    resize_window = resize_window,
    resize_window_fn = resize_window_fn,

    resize_and_center_window = resize_and_center_window,

    current_layout_has_section = current_layout_has_section,
    current_layout_has_section_fn = function(section)
        return function() return current_layout_has_section(section) end
    end,
}
