local resourceName = GetCurrentResourceName()
local zero_utils = 'zero_utils'
local LoadResourceFile = LoadResourceFile
local debug_getinfo = debug.getinfo

if not Config then Config = {} end
if not Config.Bridge then Config.Bridge = {} end

local function loadModule(self, module)
    local paths = {
        ("modules/%s/%s.lua"):format(module, self.context),
        ("modules/%s/shared.lua"):format(module),
        ("shared/%s.lua"):format(module),
    }

    for _, path in ipairs(paths) do
        local chunk = LoadResourceFile(zero_utils, path)
        if chunk then
            local fn, err = load(chunk, ('@@zero_utils/%s'):format(path))
            if fn then
                local result = fn()
                if result then
                    self[module] = result
                    return result
                end
            else
                printerr("Error importing module (%s): %s", path, err)
            end
        end
    end
end
local function call(self, index, ...)
    local module = rawget(self, index)

    if module then
        return module
    end

    module = loadModule(self, index)

    if module then
        rawset(self, index, module)
        return module
    end

    -- Handle fallback for functions only
    if type(exports[index]) == "function" then
        local function method(...)
            return exports[index](nil, ...)
        end

        if not ... then
            rawset(self, index, method)
        end

        return method
    else
        printerr("Failed to load module (%s). Make sure function is correct!", index)
    end
end

local zutils = setmetatable({
    name = resourceName,
    context = IsDuplicityVersion() and 'server' or 'client',
    initialized = false
}, {
    __newindex = function(self, name, fn)
        rawset(self, name, fn)
        if resourceName ~= zero_utils then return end
        if debug_getinfo(2, 'S').short_src:find('.*@zero%_utils.*') then
            exports(name, fn)
        end
    end,
    __index = call,
    __call = call
})
_ENV.zutils = zutils

zutils.require = function(path)
    local chunk = LoadResourceFile("zero_utils", path)
    if not chunk then return error(("failed to find module (%s)"):format(path)) end
    local fn, err = load(chunk, ('@@zero_utils/%s'):format(path))
    if not fn or err then return error(('\n^1Error importing module (%s): %s^0'):format(path, err), 3) end
    if not fn or err then return error(("failed to import module (%s) %s"):format(path, err)) end
    return fn()
end
if zutils.name == "zero_utils" then
    Config = Config or {}
    Config.Debug = true
end
zutils.require('/shared/printutils.lua')
zutils.require('/shared/utils.lua')
zutils.require('/shared/core_loader.lua')

zutils.initialized = true

local _ = zutils.cache
printdb("zero_utils initialized: %s", zutils.initialized)