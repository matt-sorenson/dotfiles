local print = require('ms.logger').print_fn('ms.colors')

local function get_colors()
    local system_colors = hs.drawing.color.lists().System

    local colors = {}

    colors.alternateSelectedControlTextColor = system_colors.alternateSelectedControlTextColor
    colors.alternatingContentBackgroundColor = system_colors.alternatingContentBackgroundColor
    colors.controlAccentColor = system_colors.controlAccentColor
    colors.controlBackgroundColor = system_colors.controlBackgroundColor
    colors.controlColor = system_colors.controlColor
    colors.controlTextColor = system_colors.controlTextColor
    colors.disabledControlTextColor = system_colors.disabledControlTextColor
    colors.findHighlightColor = system_colors.findHighlightColor
    colors.gridColor = system_colors.gridColor
    colors.headerTextColor = system_colors.headerTextColor
    colors.keyboardFocusIndicatorColor = system_colors.keyboardFocusIndicatorColor
    colors.labelColor = system_colors.labelColor
    colors.linkColor = system_colors.linkColor
    colors.placeholderTextColor = system_colors.placeholderTextColor
    colors.quaternaryLabelColor = system_colors.quaternaryLabelColor
    colors.secondaryLabelColor = system_colors.secondaryLabelColor
    colors.selectedContentBackgroundColor = system_colors.selectedContentBackgroundColor
    colors.selectedControlColor = system_colors.selectedControlColor
    colors.selectedControlTextColor = system_colors.selectedControlTextColor
    colors.selectedMenuItemTextColor = system_colors.selectedMenuItemTextColor
    colors.selectedTextBackgroundColor = system_colors.selectedTextBackgroundColor
    colors.selectedTextColor = system_colors.selectedTextColor
    colors.separatorColor = system_colors.separatorColor
    colors.tertiaryLabelColor = system_colors.tertiaryLabelColor
    colors.textBackgroundColor = system_colors.textBackgroundColor
    colors.textColor = system_colors.textColor
    colors.underPageBackgroundColor = system_colors.underPageBackgroundColor
    colors.unemphasizedSelectedContentBackgroundColor = system_colors.unemphasizedSelectedContentBackgroundColor
    colors.unemphasizedSelectedTextBackgroundColor = system_colors.unemphasizedSelectedTextBackgroundColor
    colors.unemphasizedSelectedTextColor = system_colors.unemphasizedSelectedTextColor
    colors.windowBackgroundColor = system_colors.windowBackgroundColor
    colors.windowFrameTextColor = system_colors.windowFrameTextColor

    colors.tintColor = colors.systemOrangeColor
    colors.systemBackgroundColor = colors.windowBackgroundColor
    colors.systemTextColor = colors.textColorlabelColor

    colors.systemBlueColor = system_colors.systemBlueColor
    colors.systemBrownColor = system_colors.systemBrownColor
    colors.systemGrayColor = system_colors.systemGrayColor
    colors.systemGreenColor = system_colors.systemGreenColor
    colors.systemIndigoColor = system_colors.systemIndigoColor
    colors.systemOrangeColor = system_colors.systemOrangeColor
    colors.systemPinkColor = system_colors.systemPinkColor
    colors.systemPurpleColor = system_colors.systemPurpleColor
    colors.systemRedColor = system_colors.systemRedColor
    colors.systemTealColor = system_colors.systemTealColor
    colors.systemYellowColor = system_colors.systemYellowColor

    colors.off_white = { red = .98, green = .97, blue = .96, alpha = 1 }
    colors.white = { red = 1, green = 1, blue = 1, alpha = 1 }
    colors.black = { red = 0, green = 0, blue = 0, alpha = 1 }
    colors.blue = system_colors.systemBlueColor
    colors.brown = system_colors.systemBrownColor
    colors.gray = system_colors.systemGrayColor
    colors.green = system_colors.systemGreenColor
    colors.indigo = system_colors.systemIndigoColor
    colors.orange = system_colors.systemOrangeColor
    colors.pink = system_colors.systemPinkColor
    colors.purple = system_colors.systemPurpleColor
    colors.red = system_colors.systemRedColor
    colors.teal = system_colors.systemTealColor
    colors.yellow = system_colors.systemYellowColor

    return colors
end

return get_colors()
