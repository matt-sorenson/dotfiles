-- Create a function that takes in 2 bundle ids and rects for each along with a
-- default. If both bundle ids point to apps that are open then the rect for the
-- specific bundle id is returned, but if only the one app is open then the
-- default is used.
local function combined_window_rect_fn(
    bundle_id_1, rect_1,
    bundle_id_2, rect_2,
    rect_default
)
    return function(win)
        local inBundledId = win:application():bundleID()

        if inBundledId == bundle_id_1 then
            if hs.application.find(bundle_id_2) then
                return rect_1
            end
        elseif inBundledId == bundle_id_2 then
            if hs.application.find(bundle_id_1) then
                return rect_2
            end
        end

        return rect_default
    end
end

return {
    combined_window_rect_fn = combined_window_rect_fn,
}