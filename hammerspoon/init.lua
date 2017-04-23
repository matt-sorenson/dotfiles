local cleanupfns = {}

function add_cleanup_fn(fn)
    table.insert(cleanupfns, fn)
end

-- Easy reloading of config file
hs.hotkey.bind({'ctrl', 'cmd'}, 'R', function()
    hs.fnutils.ieach(cleanupfns, function(fn) fn() end)

    hs.reload()
end)

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
