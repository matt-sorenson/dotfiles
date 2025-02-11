local print = require('ms.logger').logger_fn('ms.audio')

local sys = require 'ms.sys'

local DEVICE_CONFIG = {
    audioengine = {
        device_name = 'Audioengine 2+',
        min_delta = 7,
    },
    builtin = {
        device_name = 'MacBook Pro Speakers',
        min_delta = 5,
    },
    default = {
        min_delta = 5,
    },
}

local DEVICE_NAMES = {}
table.each(DEVICE_CONFIG, function(config)
    if config.device_name then
        DEVICE_NAMES[config.device_name] = true
    end
end)

local function get_device_config()
    local device = get_device()
    local device_name = device:name()

    for k, config in pairs(DEVICE_CONFIG) do
        if device_name == config.device_name then
            return config
        end
    end

    return DEVICE_CONFIG.default
end

--[[export]] local function get_device()
    return hs.audiodevice.defaultOutputDevice()
end

--[[export]] local function get_volume()
    return get_device():outputVolume()
end

--[[export]] local function set_volume(volume)
    return get_device():setOutputVolume(volume)
end

--[[export]] local function update_volume(d_volume)
    set_volume(math.max(0, math.min(100, get_volume() + d_volume)))
end

--[[export]] local function increase_volume()
local device = get_device()
    local device_config = get_device_config()
    update_volume(device_config.audioengine.min_delta)
end

--[[export]] local function decrease_volume()
local device = get_device()
    local device_config = get_device_config()
    update_volume(-device_config.audioengine.min_delta)
end

--[[export]] local function toggle_mute()
    local device = get_device()
    device:setOutputMuted(not device:outputMuted())
end

--[[export]] local function is_muted()
    return get_device():outputMuted()
end

--[[export]] local function setup_output(requested_device_name)
    if nil == requested_device_name then return end

    local default_device_name = hs.audiodevice.defaultOutputDevice():name();

    if default_device_name ~= requested_device_name then
        local new_device = hs.audiodevice.findOutputByName(requested_device_name)
        if new_device then
            new_device:setDefaultOutputDevice()
        else
            print("could not find audio device '" .. requested_device_name .. "'")
        end
    end
end

--[[ export ]] local function toggle_mic_mute()
    local device = hs.audiodevice.defaultInputDevice()
    device:setInputMuted(not device:inputMuted())
end

--[[ export ]] local function is_mic_muted()
    return hs.audiodevice.defaultInputDevice():inputMuted()
end

return {
    get_volume = get_volume,
    set_volume = set_volume,

    increase_volume = increase_volume,
    decrease_volume = decrease_volume,

    update_volume = update_volume,

    toggle_mute = toggle_mute,
    is_muted = is_muted,

    toggle_mic_mute = toggle_mic_mute,
    is_mic_muted = is_mic_muted,

    setup_output = setup_output,

    device_names = DEVICE_NAMES,
}
