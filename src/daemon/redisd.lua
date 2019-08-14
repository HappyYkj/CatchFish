local config = require "config"

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
local context
local function ensure_redis()
    if context then
        return context
    end

    ---! redis
    local redis = require "redis"
    context = redis.connect{ host = config.redis.host, port = config.redis.port, timeout = 30 }

    if not context then
        print("can't allocate redis context")
        return
    end

    local reply = context:auth(config.redis.auth)
    if not reply then
        print("can't auth redis context")
        context = nil
        return
    end

    return context
end

local function verify_redis()
    if not context then
        return
    end

    local reply = context:ping()
    if not reply then
        context = nil
    end
end

local function producer(linda)
    while true do repeat
        local _client = ensure_redis()
        if not _client then
            break
        end

        local key, reply = linda:receive(3.0, "client_channel")
        if key ~= "client_channel" then
            break
        end

        if type(reply) ~= "table" or #reply ~= 2 then
            break
        end

        for i = 1, 10 do
            local ret = _client:lpush(reply[1], reply[2])
            if ret then
                -- spdlog.trace("redis", string.format("succ, lpush channel = %s data = %s, ret = %s", reply[1], reply[2], ret))
                break
            end

            if i == 10 then
                -- spdlog.error("redis", string.format("fail, lpush channel = %s data = %s, ret = %s", reply[1], reply[2], ret))
            end
        end
    until true end
end

local function consumer(linda)
    while true do repeat
        local _client = ensure_redis()
        if not _client then
            break
        end

        local reply = _client:brpop("login_channel", "game_channel_lua", "charge_channel", 3)
        if type(reply) ~= "table" or #reply ~= 2 then
            verify_redis()
            break
        end

        if reply[1] and reply[2] then
            linda:send(reply[1], reply[2])
        end
    until true end
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
SERVICE_D:create(producer)
SERVICE_D:create(consumer)
