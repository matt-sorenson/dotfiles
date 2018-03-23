local sys = require 'ms.sys'

local DEVICE_UIDS = {
    monitor = 'AppleHDAEngineOutputDP:3,0,1,0:0:{AC10-A0A6-3034594C}',
}

if sys.is_work_computer() then
    DEVICE_UIDS['usb'] = 'AppleUSBAudioEngine:Unknown Manufacturer:C_Media USB Audio Device   :14120000:2,1'
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

--[[export]] local function update_volume_fn(d_volume)
    return function() update_volume(d_volume) end
end

--[[export]] local function setup_output(device_name)
    local requested_uid = DEVICE_UIDS[device_name] or device_name

    if nil == requested_uid then return end

    local default_device_uid = hs.audiodevice.defaultOutputDevice():uid();

    if default_device_uid ~= requested_uid then
        local work_device = hs.audiodevice.findDeviceByUID(requested_uid)
        if work_device then
            work_device:setDefaultOutputDevice()
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
