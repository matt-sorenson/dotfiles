local menubar
local timer

local function is_on()
    return hs.caffeinate.get('displayIdle')
end

local function set(enabled)
    if timer then
        timer:stop();
        timer = nil
    end

    hs.caffeinate.set('displayIdle', enabled)

    if is_on() then
        --menubar:setIcon(hs.configdir .. '/icons/caffeine-active@2x.png')
    else
        --menubar:setIcon(hs.configdir .. '/icons/caffeine-inactive@2x.png')
    end
end

local function off()
    set(false)
end

local function on()
    set(true)
end

local function timed_on(time_in_sec)
    on()
    timer = hs.timer.doAfter(time_in_sec, off)
end

local function timed_on_m(time_in_min)
    timed_on(hs.timer.minutes(time_in_min))
end

--[[
if not menubar then
    menubar = hs.menubar.new(false)
    set(is_on())
    menubar:returnToMenuBar()
end

add_cleanup_fn(function()
    if menubar then
        menubar:delete();
        menubar = nil
    end
end)

if menubar then
    menubar:setMenu(function(keys)
        local out = {
            { title = ((is_on() and "Turn Off") or "Turn On"), fn = ((is_on() and off) or on) },
            { title = '-' },
            --{ title = '10 Seconds', fn = function() timed_on(10) end }, -- Uncomment this line for testing
            { title = '30 Minutes', fn = function() timed_on_m(30) end },
            { title = '60 Minutes', fn = function() timed_on_m(60) end }
        }

        if timer then
            local time_left = timer:nextTrigger()
            local fmt

            if time_left < 60 then
                fmt = '%is remaining'
            else
                fmt = '%im remaining'
                time_left = math.floor(time_left / 60)
            end

            table.insert(out, 1, { title = string.format(fmt, time_left) })
            table.insert(out, 2, { title = '-' })
        end

        return out;
    end)
end

--]]

return {
    set = set,
    off = off,
    on = on,
    toggle = function() set(not is_on()) end,
    timed_on = timed_on,
    timed_on_m = timed_on_m,

    is_on = is_on,
    is_off = function() return not is_on() end,
}
