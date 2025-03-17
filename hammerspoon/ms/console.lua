local colors = require 'ms.colors'

local function setTheme() 
    -- Set default console font
    hs.console.consoleFont('Berkeley Mono')

    hs.console.darkMode(true)
    hs.console.outputBackgroundColor(colors.black)
    hs.console.inputBackgroundColor(colors.black)

    hs.console.consoleCommandColor(colors.blue)
    hs.console.consolePrintColor(colors.off_white)
    hs.console.consoleResultColor(colors.blue)
end

return {
    setTheme = setTheme
}
