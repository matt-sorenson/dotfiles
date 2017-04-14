local cleanupfns = {}

function add_cleanup_fn(fn)
    table.insert(cleanupfns, fn)
end

-- Easy reloading of config file
hs.hotkey.bind({'ctrl', 'cmd'}, 'R', function()
    hs.fnutils.ieach(cleanupfns, function(fn) fn() end)

    hs.reload()
end)

-- use pcall to load the file so we can put the error in the console and continue to have the reload hotkey working
result, msg = pcall(function() require 'config' end)

if result then
    hs.notify.show('Hammerspoon', '', 'Config (re)loaded')
    print('Hammerspoon config (re)loaded')
else
    hs.notify.show('Hammerspoon', 'Failed to (re)load', msg)
    print("--- Failed to load ms.init ---\n" .. msg .. "\n--- ---")
end
