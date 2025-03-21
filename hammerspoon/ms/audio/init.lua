local print = require('ms.logger').new('ms.audio.init')

local devices = require('ms.audio.devices')

--[[export]]
local function get_volume()
    local result, value = pcall(function()
        return devices.get_output_device():outputVolume()
    end)

    if not result or 'number' ~= type(value) then
        print:error('Error getting volume', value)
        return 0
    end

    return value
end

--[[export]]
local function set_volume(new_volume)
    devices.get_output_device():setOutputVolume(new_volume)
end

--[[export]]
local function update_volume(d_volume)
    set_volume(math.max(0, math.min(100, get_volume() + d_volume)))
end

--[[export]]
local function increase_volume(opt_delta)
    if opt_delta then
        update_volume(opt_delta)
    else
        local config = devices.get_output_config()

        update_volume(config.min_delta)
    end
end

--[[export]]
local function decrease_volume(opt_delta)
    if opt_delta then
        update_volume(-opt_delta)
    else
        local config = devices.get_output_config()

        update_volume(-config.min_delta)
    end
end

--[[export]]
local function set_mute(muted)
    devices.get_output_device():setOutputMuted(muted)
end

--[[export]]
local function is_muted()
    return devices.get_output_device():outputMuted()
end

--[[export]]
local function toggle_mute()
    set_mute(not is_muted())
end

--[[export]]
local function set_input_mute(muted)
    devices.get_input_device():setInputMuted(muted)
end

--[[export]]
local function is_input_muted()
    return devices.get_input_device():inputMuted()
end

--[[export]]
local function toggle_input_mute()
    set_input_mute(not is_input_muted())
end

return {
    get_volume = get_volume,
    set_volume = set_volume,

    update_volume = update_volume,
    increase_volume = increase_volume,
    decrease_volume = decrease_volume,

    set_mute = set_mute,
    toggle_mute = toggle_mute,
    is_muted = is_muted,

    set_input_mute = set_input_mute,
    toggle_input_mute = toggle_input_mute,
    is_input_muted = is_input_muted,

    add_input_watcher_callback = devices.add_input_watcher_callback,
    remove_input_watcher_callback = devices.remove_input_watcher_callback,

    add_output_watcher_callback = devices.add_output_watcher_callback,
    remove_output_watcher_callback = devices.remove_output_watcher_callback,

    init = devices.init
}
