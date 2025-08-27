local print = require('ms.logger').new('ms.test')

local assert = require 'ms.test.assert'

local function run_test_obj(path, t)
    for k, v in pairs(t) do
        if 'function' == type(v) then
            local result, err = pcall(v)

            local test_case = path .. '.' .. k
            if not result then
                if 'table' ~= type(err) then
                    err = {
                        message = err,
                        type = 'UNKNOWN_ERROR',
                    }
                end

                err.message = err.message or ('Failed to run test.')
                err.type = err.type or 'UNKNOWN_ERROR'

                if 'function' == type(err.expected) then
                    err.expected = err.expected()
                end

                if 'function' == type(err.actual) then
                    err.actual = err.actual()
                end

                if 'function' == type(err.message) then
                    err.message = err.message()
                end

                if err.expected or err.actual then
                    print:errorf('%s: %s\n%s\nExpected: %s\nActual: %s',
                        test_case,
                        err.type,
                        err.message,
                        err.expected,
                        err.actual)
                else
                    print:errorf('%s: %s\n%s', test_case, err.type, err.message)
                end
            else
                print:infof('%s: %s', test_case, 'SUCCESS')
            end
        elseif 'table' == type(v) then
            run_test_obj(path .. '.' .. k, v)
        end
    end
end

local function _run_tests(path, t, inspected_tables)
    inspected_tables = inspected_tables or {}

    for k, v in pairs(t) do
        if 'table' == type(v) and not inspected_tables[k] then
            if '__tests' == k then
                run_test_obj(path .. '.' .. k, v)
            else
                _run_tests(path .. '.' .. k, v, inspected_tables)
            end

            inspected_tables[k] = true
        end
    end
end

local function run_tests()
    _run_tests('ms', require('ms'), {})
end

return {
    assert = assert,

    run_tests = run_tests,
}
