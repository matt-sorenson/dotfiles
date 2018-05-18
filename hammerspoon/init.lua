-- Easy reloading of config file
hs.hotkey.bind({'ctrl', 'cmd'}, 'R', function()
    hs.notify.show('Hammerspoon', 'Reloading', '')
    hs.reload()
end)

-- If the input is not a table then insert it as the first element of an array
-- and return that array. Usefull for functions that take 1 or more of a value
function toarray(input)
    if 'table' == type(input) then
        return input
    end

    return {input}
end

table.keys = function(t)
    local out = {}

    for k, _ in pairs(t) do
        table.insert(out, k)
    end

    return out
end

table.append = function(t1, ...)
    for _, t2 in ipairs({...}) do
        for _, v in ipairs(t2) do
            table.insert(t1, v)
        end
    end

    return t1
end

table.find = function(haystack, needle)
    for k,v in pairs(haystack) do
        if v == needle then
            return k
        end
    end

    return nil
end

-- use pcall to load the file so we can put the error in the console and
-- continue to have the reload hotkey working
result, msg = pcall(function() require 'config' end)

if result then
    hs.notify.show('Hammerspoon', 'Config (re)loaded', '')
    print('Hammerspoon config (re)loaded')
else
    hs.notify.new(hs.openConsole, {
        title = 'Hammerspoon',
        subTitle = 'Failed to (re)load',
        informativeText = ''
    }):send()
    print("--- Failed to load ms.init ---\n" .. msg .. "\n--- ---")
end

local function gc()
    collectgarbage("collect")
end

-- Initialization creates lots of garbage
gc()

hs.timer.doEvery(hs.timer.hours(1), gc)
