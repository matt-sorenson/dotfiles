local sys = require 'ms.sys'

local print = require('ms.logger').logger_fn('audio')

local DEVICE_NAMES = {
    audioengine = 'Audioengine 2+',
    builtin = 'MacBook Pro Speakers'
}

local DEVICE_CONFIG = {
    audioengine = {
        min_delta = 7
    },
    default = {
        min_delta = 5
    }
}

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
    if device:name() == DEVICE_NAMES.audioengine then
        update_volume(DEVICE_CONFIG.default.min_delta)
    end
end

--[[export]] local function decrease_volume()
local device = get_device()
    if device:name() == DEVICE_NAMES.audioengine then
        update_volume(-DEVICE_CONFIG.audioengine.min_delta)
    else
        update_volume(-DEVICE_CONFIG.default.min_delta)
    end
end

--[[export]] local function toggle_mute()
    local device = get_device()
    device:setOutputMuted(not device:outputMuted())
end

--[[export]] local function is_muted()
    return get_device():outputMuted()
end

--[[export]] local function setup_output(device_name)
    local requested_name = device_name

    if nil == requested_name then return end

    local default_device_name = hs.audiodevice.defaultOutputDevice():name();

    if default_device_name ~= requested_name then
        local new_device = hs.audiodevice.findOutputByName(requested_name)
        if new_device then
            new_device:setDefaultOutputDevice()
        else
            print("could not find audio device '" .. requested_name .. "'")
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
