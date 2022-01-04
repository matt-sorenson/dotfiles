local sys = require 'ms.sys'

local DEVICE_NAMES = {
    audioengine = 'Audioengine 2+  ',
    builtin = 'MacBook Pro Speakers',
    monitor = 'LS49AG95',
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

--[[export]] local function update_volume_fn(d_volume)
    return function() update_volume(d_volume) end
end

--[[export]] local function setup_output(device_name)
    local requested_name = DEVICE_NAMES[device_name] or device_name

    if nil == requested_name then return end

    local default_device_name = hs.audiodevice.defaultOutputDevice():name();

    if debug_output.audio then
        print("default uid:   '" .. default_device_uid .. "'")
        print("requested uid: '" .. requested_name .. "'")
    end

    if default_device_name ~= requested_name then
        local new_device = hs.audiodevice.findOutputByName(requested_name)
        if new_device then
            new_device:setDefaultOutputDevice()
        else
            print("could not find audio device '" .. requested_name .. "'")
        end
    end
end

return {
    get_volume = get_volume,
    set_volume = set_volume,
    update_volume_fn = update_volume_fn,
    update_volume = update_volume,

    setup_output = setup_output
}
