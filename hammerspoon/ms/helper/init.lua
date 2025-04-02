-- I end up looking up how to clear the console each time cause I forget about
-- `Console` on the end of the method name.
hs.console.clear = hs.console.clearConsole

--- If the input is not a table then insert it as the first element of an array
-- and return that array. Useful for functions whose input can be a singular
-- value or an array of values.
function toarray(input)
    if 'table' == type(input) then
        return input
    end

    return { input }
end

require 'ms.helper.table'
