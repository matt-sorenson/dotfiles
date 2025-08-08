local print = require('ms.logger').new('ms.sys')

local WHO_AM_I = os.getenv('USER')

--[[ export ]]
local function gc()
    print:debug("Pre GC: " .. math.floor(collectgarbage("count")) .. 'kb')
    collectgarbage("collect")
    print:debug("Post GC: " .. math.floor(collectgarbage("count")) .. 'kb')
end

--[[ export ]]
local function find_usb_device_by_name(name)
    name = name:lower()
    return table.unpack(table.filter(hs.usb.attachedDevices(), function(dev)
        if dev.productName and dev.productName:lower():match(name) then
            return true
        end
    end))
end

--[[ export ]]
local function select_app(app_name, win_name, new_window)
    local app = hs.appfinder.appFromName(app_name)
    if not app then
        hs.application.open(app_name)
        return
    end

    local win
    if win_name then
        win = app:findWindow(win_name)
    else
        win = app:mainWindow()
    end

    if win then
        return win:focus()
    elseif 'function' == type(new_window) then
        new_window(app)
        return app:focusedWindow()
    elseif 'table' == type(new_window) then
        app:selectMenuItem(new_window)
        return app:focusedWindow()
    end
end

local function app_window_names_match(window, app_name, win_name)
    if nil == window then
        return false
    end

    local focused_app_title = window:application():title():lower()
    local focused_window_title = window:title():lower()

    app_name = app_name and app_name:lower() or nil
    win_name = win_name and win_name:lower() or nil

    if (nil ~= app_name) and (nil == focused_app_title:match(app_name)) then
        return false
    end

    if (nil ~= win_name) and (nil == focused_window_title:match(win_name)) then
        return false
    end

    return true
end

--[[ export ]]
local function toggle_select_app_fn(app_name, win_name, new_window)
    local prev_window = nil;

    return function()
        local focused_window = hs.application.frontmostApplication():focusedWindow()

        if nil ~= prev_window then
            if app_window_names_match(focused_window, app_name, win_name) then
                -- Ensure that we haven't left the selected app before toggling
                -- away from it.
                prev_window:focus()
                prev_window = nil
                return
            end
        end

        new_window = select_app(app_name, win_name, new_window)

        if new_window ~= focused_window then
            prev_window = focused_window
        end
    end
end

--[[ export ]]
local function open_finder_fn(path)
    return function()
        hs.execute('open ' .. (path or '~'))
    end
end

--[[ export ]]
local function select_app_fn(app_name, win_name, new_window)
    return function() select_app(app_name, win_name, new_window) end
end

--[[ export ]]
local function trigger_system_key_fn(key)
    return function()
        hs.eventtap.event.newSystemKeyEvent(key, true):post()
    end
end

--[[ export ]]
local function using_moonlander()
    return find_usb_device_by_name('Moonlander Mark I')
end

--[[ export ]]
local function get_current_window_size()
    local size = hs.window.focusedWindow():size()

    local msg = string.format("Window Size: %dx%d", size.w, size.h)

    hs.alert(msg)
end

return {
    find_usb_device_by_name = find_usb_device_by_name,
    select_app = select_app,
    toggle_select_app_fn = toggle_select_app_fn,

    trigger_system_key_fn = trigger_system_key_fn,

    who_am_i = function() return WHO_AM_I end,

    open_finder_fn = open_finder_fn,
    select_app_fn = select_app_fn,

    gc = gc,

    using_moonlander = using_moonlander,

    get_current_window_size = get_current_window_size,
}
