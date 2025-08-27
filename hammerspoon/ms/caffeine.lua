local timer

--[[ export ]]
local function is_on()
    return hs.caffeinate.get('displayIdle')
end

--[[ export ]]
local function set(enabled)
    if timer then
        timer:stop();
        timer = nil
    end

    hs.caffeinate.set('displayIdle', enabled)
end

--[[ export ]]
local function off()
    set(false)
end

--[[ export ]]
local function on()
    set(true)
end

--[[ export ]]
local function timed_on_s(time_in_sec)
    on()
    timer = hs.timer.doAfter(time_in_sec, off)
end

--[[ export ]]
local function timed_on_m(time_in_min)
    timed_on_s(hs.timer.minutes(time_in_min))
end

local function time_remaining()
    if timer then
        return timer:nextTrigger()
    end

    return 0
end

local function secondsToHumanReadable(time_in_sec)
    local minutes = math.floor(time_in_sec / 60)
    local hours = math.floor(minutes / 60)

    if hours > 0 then
        minutes = minutes - (60 * hours)

        if minutes == 0 then
            return string.format("%dh", hours)
        end

        return string.format("%dh %dm", hours, minutes)
    elseif minutes > 0 then
        return string.format("%dm", minutes)
    end

    return string.format("%ds", time_in_sec)
end

--[[ export ]]
local function alert_status()
    if is_on() then
        if timer then
            hs.alert("Caffeine is Enabled: " .. secondsToHumanReadable(time_remaining()))
        else
            hs.alert("Caffeine is Enabled")
        end
    else
        hs.alert("Caffeine is Disabled")
    end
end

local function lock_screen()
    hs.caffeinate.lockScreen()
end

return {
    is_on = is_on,
    is_off = function() return not is_on() end,
    set = set,
    off = off,
    on = on,
    toggle = function() set(not is_on()) end,
    timed_on_s = timed_on_s,
    timed_on_m = timed_on_m,
    alert_status = alert_status,

    lock_screen = lock_screen,
}
