local timer

--[[export]] local function is_on()
    return hs.caffeinate.get('displayIdle')
end

--[[export]] local function set(enabled)
    if timer then
        timer:stop();
        timer = nil
    end

    hs.caffeinate.set('displayIdle', enabled)
end

--[[export]] local function off()
    set(false)
end

--[[export]] local function on()
    set(true)
end

--[[export]] local function timed_on(time_in_sec)
    on()
    timer = hs.timer.doAfter(time_in_sec, off)
end

--[[export]] local function timed_on_m(time_in_min)
    timed_on(hs.timer.minutes(time_in_min))
end

return {
    is_on = is_on,
    is_off = function() return not is_on() end,
    set = set,
    off = off,
    on = on,
    toggle = function() set(not is_on()) end,
    timed_on = timed_on,
    timed_on_m = timed_on_m,
}
