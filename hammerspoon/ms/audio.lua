local sys = require 'ms.sys'

local setup_output

if sys.is_work_computer() then
    local DEVICE_UIDS = {
        monitor = 'AppleHDAEngineOutputDP:3,0,1,0:0:{AC10-A0A6-3034594C}',
        usb = 'AppleUSBAudioEngine:Unknown Manufacturer:C_Media USB Audio Device   :14120000:2,1'
    }

    setup_output = function(device_name)
        local requested_uid = DEVICE_UIDS[device_name]

        if nil == requested_uid then return end

        local default_device_uid = hs.audiodevice.defaultOutputDevice():uid();

        if default_device_uid ~= requested_uid then
            local work_device = hs.audiodevice.findDeviceByUID(requested_uid)
            if work_device then
                work_device:setDefaultOutputDevice()
            end
        end
    end
else
    setup_output = function() end
end

local function update_volume(d_volume)
    local default_out = hs.audiodevice.defaultOutputDevice()
    local curr_volume = default_out:outputVolume()
    default_out:setOutputVolume(math.max(0, math.min(100, curr_volume + d_volume)))
end

local function update_volume_fn(d_volume)
    return function() update_volume(d_volume) end
end

return {
    update_volume_fn = update_volume_fn,
    update_volume = update_volume,
    setup_output = setup_output
}
