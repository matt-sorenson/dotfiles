local default_samba_port = 445

--[[ export ]]
local function mount_smb(host, share, port)
    if not host then
        error('host is required for mount_smb')
    elseif not share then
        error('share is required for mount_smb')
    end

    port = port or default_samba_port

    local smb_share = 'smb://' .. host .. ':' .. port .. '/' .. share
    local out = hs.osascript.applescript('mount volume "' .. smb_share .. '"')

    return out
end

--[[ export ]]
local function mount_smb_shares(shares_map)
    for host, shares in pairs(shares_map) do
        table.ieach(shares, function(share) mount_smb(host, share) end)
    end
end

return {
    mount = mount_smb,
    mount_shares = mount_smb_shares,
}
