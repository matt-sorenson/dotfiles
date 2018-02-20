local WHO_AM_I = os.getenv('USER')

-- hs.host.names() is insanely slow (something like 5 seconds)
-- so just use hs.exectute('hostname') instead
local IS_WORK_COMPUTER = string.find(hs.execute('hostname'), '.ant.')

local function mount_smb(host, share)
    local smb_share = 'smb://' .. host .. ':445/' .. share
    local out = hs.osascript.applescript('mount volume "' .. smb_share .. '"')

    return out
end

local function mount_smb_shares(shares_map)
    for host, shares in pairs(shares_map) do
        for _, share in ipairs(shares) do
            mount_smb(host, share)
        end
    end
end


local function find_usb_device_by_name(name)
    name = name:lower()
    return table.unpack(hs.fnutils.filter(hs.usb.attachedDevices(), function(dev)
        if dev.productName and dev.productName:lower():match(name) then
            return true
        end
    end))
end

local function open_finder_fn(path)
    return function()
        hs.execute('open ' .. (path or '~'))
    end
end

local function select_app(app_name, win_name, new_window)
    cfg = cfg or {}

    local app = hs.appfinder.appFromName(app_name)
    if not app then
        hs.application.open(app_name)
        return
    end

    local win
    if win_name then
        win = app:findWindow(win_name)
    else
        win = app:mainWindow()
    end

    if win then
        win:focus()
    elseif 'function' == type(new_window) then
        new_window(app)
    elseif 'table' == type(new_window) then
        app:selectMenuItem(new_window)
    end
end

local function select_app_fn(app_name, win_name, new_window)
    return function() select_app(app_name, win_name, new_window) end
end

local function ls(dir)
    local _, iter = hs.fs.dir('~/.hammerspoon/layouts')
    local contents = {}

    repeat
        local filename = iter:next()

        if(filename and ('..' ~= filename) and ('.' ~= filename)) then
            table.insert(contents, filename)
        end
    until filename == nil
    iter:close()

    return contents
end

return {
    find_usb_device_by_name = find_usb_device_by_name,
    is_work_computer = function() return IS_WORK_COMPUTER end,
    mount_smb = mount_smb,
    mount_smb_shares = mount_smb_shares,
    select_app = select_app,
    who_am_i = function() return WHO_AM_I end,

    ls = ls,

    open_finder_fn = open_finder_fn,
    select_app_fn = select_app_fn
}
