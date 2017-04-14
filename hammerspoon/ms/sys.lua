local WHO_AM_I = os.getenv('USER')

-- hs.host.names() is insanely slow (something like 5 seconds)
local IS_WORK_COMPUTER = string.find(hs.execute('hostname'), '.ant.')

local function mount_smb(host, share)
    if hs.fs.volume.allVolumes()['/Volumes/' .. share] then
        return
    end

    pcall(function()
        hs.applescript.applescript([[
            tell application "Finder"
                try
                    mount volume "smb://]] .. host .. ":445/" .. share .. [["
                end try
            end tell
        ]])
    end)
end

local function find_usb_device_by_name(name)
    name = name:lower()
    return table.unpack(hs.fnutils.filter(hs.usb.attachedDevices(), function(dev)
        if dev.productName and dev.productName:lower():match(name) then
            return true
        end

        return false
    end))
end

local function open_finder_fn(path)
    return function()
        hs.execute('open ' .. (path or os.getenv('HOME')))
    end
end

local function select_app(app_name, cfg)
    cfg = cfg or {}

    local app = hs.appfinder.appFromName(app_name)
    if not app then
        hs.application.open(app_name)
        return
    end

    local win
    if cfg.window then
        win = app:findWindow(cfg.window)
    else
        win = app:mainWindow()
    end

    if win then
        if win ~= hs.window.focusedWindow() then
            win:focus()
        elseif cfg.toggle then
            app:hide()
        end
    elseif cfg.new_window then
        if 'function' == type(cfg.new_window) then
            cfg.new_window(app)
        elseif 'table' == type(cfg.new_window) then
            app:selectMenuItem(cfg.new_window)
        end
    end
end

local function select_app_fn(app, cfg)
    return function() select_app(app, cfg) end
end

return {
    find_usb_device_by_name = find_usb_device_by_name,
    is_work_computer = function() return IS_WORK_COMPUTER end,
    mount_smb = mount_smb,
    select_app = select_app,
    who_am_i = function() return WHO_AM_I end,

    open_finder_fn = open_finder_fn,
    select_app_fn = select_app_fn
}
