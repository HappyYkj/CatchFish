local lanes = require "lanes"
lanes.configure{ with_timers = false }

-------------------------------------------------------------------------------
---! CREATE LINDA TO HOLD MESSAGE QUEUE
-------------------------------------------------------------------------------
local linda = lanes.linda()

-------------------------------------------------------------------------------
---! CREATE TABLE TO HOLD SERVICES
-------------------------------------------------------------------------------
local service_map = {}

-------------------------------------------------------------------------------
---! CREATE TABLE TO HOLD THREADS
-------------------------------------------------------------------------------
local threads = {}

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
SERVICE_D = {}

function SERVICE_D:mainloop(seconds_)
    seconds_ = seconds_ or 3.0
    while not has_been_stop() do repeat
        self.service_channels = self.service_channels or table.keys(service_map)
        if #self.service_channels <= 0 then
            lanes.sleep(seconds_)
            break
        end

        local name, data = linda:receive(seconds_, table.unpack(self.service_channels))
        if not name then
            break
        end

        if SERVICE_D:dispatch(name, data) then
            break
        end

        spdlog.warn("service", string.format("linda recvive name = %s undefined, data = %s", name, data))
    until true end
end

function SERVICE_D:exit(mode)
    mode = mode or "soft"
    for _, thread in ipairs(threads) do
        thread:cancel("soft")
    end

    ---! Make sure all threads finished
    for _, thread in ipairs(threads) do
        thread:join()
    end

    threads = {}
end

function SERVICE_D:register(name, func)
    if service_map[name] then
        if self.service_channels then
            self.service_channels = nil
        end
    end
    service_map[name] = func
end

function SERVICE_D:dispatch(name, data)
    local func = service_map[name]
    if not func then
        return false
    end
    if name ~= "coroutine_resume" then
        THREAD_D:create(function()
            return func(linda, table.unpack(data))
        end)
    else
        func(linda, table.unpack(data))
    end
    return true
end

function SERVICE_D:create(func, ...)
    local wrap = function(...)
        require "global.core.preload"
        xpcall(func, error_traceback, ...)
    end

    local thread = lanes.gen("*", wrap)(linda, ...)
    table.insert(threads, thread)
end

function SERVICE_D:post(channel, ...)
    return linda:send(channel, table.pack(...))
end

for _, func in pairs(SERVICE_D) do
    PROFILE_D:prevent(func)
end
