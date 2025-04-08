--[[ export ]]
local function mount_smb(host, share)
    local smb_share = 'smb://' .. host .. ':445/' .. share
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
