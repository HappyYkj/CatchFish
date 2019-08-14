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
---! 内部接口
-------------------------------------------------------------------------------
local sleep_func = function(id, secs)
    sleep(secs)
    linda:send("coroutine_resume", table.pack(id))
end
local sleep_lane = lanes.gen("string,table", { globals =  { sleep = lanes.sleep } }, sleep_func)

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
SERVICE_D = {}

function SERVICE_D:start()
    while true do repeat
        local name, data = linda:receive(table.unpack(table.keys(service_map)))
        if SERVICE_D:dispatch(name, data) then
            break
        end

        spdlog.warn("service", string.format("linda recvive name = %s undefined, data = %s", name, data))
    until true end
end

function SERVICE_D:register(name, func)
    service_map[name] = func
end

function SERVICE_D:dispatch(name, data)
    local func = service_map[name]
    if not func then
        return false
    end

    local wrap = function()
        return func(data)
    end

    if name ~= "coroutine_resume" then
        THREAD_D:create(wrap)
    else
        wrap()
    end
    return true
end

function SERVICE_D:create(func, ...)
    local opt = select(1, ...)
    local thread
    if type(opt) == "table" then
        thread = lanes.gen("*", opt, func)
    else
        thread = lanes.gen("*", func)
    end
    thread(linda)
end

function SERVICE_D:sleep(id, secs)
    return sleep_lane(id, secs)
end

function SERVICE_D:post(channel, ...)
    return linda:send(channel, table.pack(...))
end
