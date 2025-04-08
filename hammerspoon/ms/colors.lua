local _color_mt = {
    __index = {
        clone = function(self)
            return table.shallow_copy(self)
        end,

        clone_with_alpha = function(self, alpha)
            local out = self:clone()
            out.alpha = alpha

            return out
        end,
    }
}

--- Take in a RGBA pair and convert to a normalized color. Inputs should be
--- between 0 and 255, output will be between 0 and 1.
local function rgba(r, g, b, a)
    if a == nil then
        a = 255
    end

    local out = {
        red = r / 255,
        green = g / 255,
        blue = b / 255,
        alpha = a / 255
    }

    setmetatable(out, _color_mt)

    return out
end

local function rgb(r, g, b)
    return rgba(r, g, b, 255)
end

local function get_colors()
    local system_colors = hs.drawing.color.lists().System

    local colors = {
        -- magenta is used as 'missing' color as it's bright and obvious
        missing = rgb(255, 0, 255),

        off_white = rgb(250, 248, 245),
        white = rgb(255, 255, 255),
        black = rgb(0, 0, 0),

        red = rgb(255, 0, 0),
        blue = rgb(0, 0, 255),
        green = rgb(0, 255, 0),

        brown = rgb(222, 184, 135),
        gray = rgb(211, 211, 211),
        indigo = rgb(75, 0, 130),
        orange = rgb(255, 165, 0),
        pink = rgb(255, 192, 203),
        purple = rgb(221, 160, 221),
        teal = rgb(0, 128, 128),
        yellow = rgb(255, 255, 0),
    }

    local mt = {
        __index = function(self, key)
            if key == 'rgb' then
                return rgb
            elseif key == 'rgba' then
                return rgba
            elseif key == 'grey' then
                return self.gray
            elseif key == 'off_white' then
                return self.white
            else
                -- Doing this so that we can use colors in the logger
                require('ms.logger').new('ms.colors')('Missing color: ' .. key)
                return colors.missing
            end
        end
    }

    setmetatable(colors, mt)

    return colors
end

local function get_monokai_colors()
    local colors = get_colors()

    colors.off_white = nil

    colors.white = rgb(214, 214, 214)
    colors.black = rgb(39, 40, 34)

    colors.red = rgb(255, 97, 61)
    colors.blue = rgb(120, 220, 232)
    colors.green = rgb(169, 220, 118)

    colors.orange = rgb(252, 152, 103)
    colors.purple = rgb(171, 157, 242)
    colors.yellow = rgb(255, 216, 102)

    return colors
end

local out = {
    default = get_colors(),
    monokai = get_monokai_colors(),
}

local mt = {
    __index = function() return out.default end,
}

setmetatable(out, mt)

return out
