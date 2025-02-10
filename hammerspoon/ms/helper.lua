local print = require('ms.logger').logger_fn('ms.helper')

-- I end up looking up how to clear the console each time cause I forget about
-- `Console` on the end of the method name.
hs.console.clear = hs.console.clearConsole

-- If the input is not a table then insert it as the first element of an array
-- and return that array. Usefull for functions that take 1 or more of a value
function toarray(input)
    if 'table' == type(input) then
        return input
    end

    return {input}
end

-- this function returns a list of all the keys in a table
table.keys = function(t)
    local out = {}

    for k, _ in pairs(t) do
        table.insert(out, k)
    end

    return out
end

-- append all elements of the second table to the first table
table.append = function(t1, ...)
    for _, t2 in ipairs({...}) do
        for _, v in ipairs(t2) do
            table.insert(t1, v)
        end
    end

    return t1
end

-- Find the key of a value in a table
--
-- Generally expected to be used with arrays, but will work with tables
table.find = function(haystack, needle)
    for k,v in pairs(haystack) do
        if v == needle then
            return k
        end
    end

    return nil
end
