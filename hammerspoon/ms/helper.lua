local print = require('ms.logger').logger_fn('ms.helper')

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

    return {input}
end

--- this function returns a list of all the keys in a table
table.keys = function(t)
    local out = {}

    for k, _ in pairs(t) do
        table.insert(out, k)
    end

    return out
end

--- append all elements of the second table to the first table
table.append = function(t1, ...)
    for _, t2 in ipairs({...}) do
        for _, v in ipairs(t2) do
            table.insert(t1, v)
        end
    end

    return t1
end

--- Find the key of a value in a table
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

--- Execute a function on each element of a table (unordered iteration)
-- @param t table to iterate over
-- @param fn function to execute on each element, takes one argument, the value stored in the table
table.each = function(t, fn)
    for _, v in pairs(t) do
        fn(v)
    end
end

--- Execute a function on each element of an array
-- @param t table to iterate over
-- @param fn function to execute on each element, takes one argument, the value stored in the array
table.ieach = function(t, fn)
    for _, v in ipairs(t) do
        fn(_, v)
    end
end

--- Filter a table, the input table is not modified
-- @param t table to filter
-- @param fn
--    function to execute on each element, takes one argument,
--    the value stored in the table,
--    returns true if the element should be included in the output table
-- @return table of elements that passed the filter function
table.filter = function(t, fn)
    local out = {}

    for k, v in pairs(t) do
        if fn(v) then
            out[k] = v
        end
    end

    return out
end

table.map = function(t, fn)
    local out = {}

    for k, v in pairs(t) do
        out[k] = fn(v)
    end

    return out
end

--- Map a function over an array
-- @param t array to map over
-- @param fn
--    function to execute on each element, takes one argument, the value in the array
--    return value is stored in output.
--    `nil` return value is dropped from output array.
-- @return array of results from the function
table.imap = function(t, fn)
    local out = {}

    for _, v in ipairs(t) do
        table.insert(out, fn(v))
    end

    return out
end

--- Create a shallow copy of a table
table.shallow_copy = function(t)
    local out = {}

    for k, v in pairs(t) do
        out[k] = v
    end

    return out
end

local function _deep_copy(t, ref_table, table_refs_to_not_copy, out)
    if not out then
        out = {}
    end

    for k, v in pairs(t) do
        if 'table' == type(v) then
            if table.find(table_refs_to_not_copy, v) then
                out[k] = v
            else
                out[k] = ref_table[v]

                if not out[k] then
                    local copy = {}
                    ref_table[v] = copy

                    _deep_copy(v, ref_table, copy)

                    out[k] = copy
                end
            end
        else
            ref_table[k] = v
        end
    end

    return out
end

--- Create a deep copy of a table
-- @param t table to copy
--    should handle circular references
--    If input table has multiple references to the same table the output table
--    will copy the referenced table once and use that copy for all references
-- @param table_refs_to_not_copy
--    Any tables in thist list will be copied as references
table.deep_copy = function(t, table_refs_to_not_copy)
    out = {}
    ref_table = {
        [t] = out
    }

    if not table_refs_to_not_copy then
        table_refs_to_not_copy = {}
    end

    return _deep_copy(t, ref_table, table_refs_to_not_copy, out)
end
