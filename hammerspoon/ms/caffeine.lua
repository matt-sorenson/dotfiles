local menubar
local timer

local function isOn()
    return hs.caffeinate.get('displayIdle')
end

local function set(enabled)
    if timer then
        timer:stop();
        timer = nil
    end

    hs.caffeinate.set('displayIdle', enabled)

    if isOn() then
        menubar:setIcon(hs.configdir .. '/icons/caffeine-active@2x.png')
    else
        menubar:setIcon(hs.configdir .. '/icons/caffeine-inactive@2x.png')
    end
end

local function off()
    set(false)
end

local function on()
    set(true)
end

local function toggle()
    set(not isOn())
end

local function timed_on(time_in_sec)
    on()
    timer = hs.timer.doAfter(time_in_sec, off)
end

local function timed_on_m(time_in_min)
    timed_on(hs.timer.minutes(time_in_min))
end

local function lock_screen()
    hs.caffeinate.lockScreen()
end

if not menubar then
    menubar = hs.menubar.new(false)
    set(isOn())
    menubar:returnToMenuBar()
end

add_cleanup_fn(function() menubar:removeFromMenuBar(); menubar = nil end)

menubar:setMenu(function(keys)
    local out = {
        { title = ((isOn() and "Turn Off") or "Turn On"), fn = ((isOn() and off) or on) },
        { title = '-' },
        --{ title = '10 Seconds', fn = function() timed_on(10) end }, -- Uncomment this line for testing
        { title = '30 Minutes', fn = function() timed_on_m(30) end },
        { title = '60 Minutes', fn = function() timed_on_m(60) end }
    }

    if timer then
        local time_left = timer:nextTrigger()

        local time_str
        if time_left < 60 then
            time_str = string.format('%i seconds remaining', math.floor(time_left))
        else
            time_str = string.format('%i minutes remaining', math.floor(time_left / 60))
        end

        table.insert(out, 1, { title = time_str })
        table.insert(out, 2, { title = '-' })
    end

    return out;
end)

return {
    set = set,
    off = off,
    on = on,
    toggle = toggle,
    timed_on = timed_on,
    timed_on_m = timed_on_m,

    isOn = isOn,

    lock_screen = lock_screen
}
