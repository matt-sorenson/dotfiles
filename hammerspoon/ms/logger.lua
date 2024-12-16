local logger_systems_to_skip = {}

--[[ export ]] local function logger_skip_system(system)
    logger_systems_to_skip[system] = true
end

--[[ export ]] local function logger_unskip_system(system)
    logger_systems_to_skip[system] = nil
end

local function system_logger(system, message)
    if logger_systems_to_skip[system] then
        return
    end

    print('[' .. system .. '] ' .. message)
end

--[[ export ]] local function logger_fn(system)
    return function(message)
        system_logger(system, message)
    end
end

return {
  logger_skip_system = logger_skip_system,
  logger_unskip_system = logger_unskip_system,
  logger_fn = logger_fn,
}
