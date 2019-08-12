local lanes = require "lanes"
local redis = require "redis"
local DEBUG_VERSION = true

local context = nil
local function ensure_redis()
    if context then
        return context
    end

    ---! redis
    if not DEBUG_VERSION then
        context = redis.connect({ host = '54.210.5.255', port = 6379, timeout = 30 })
    else
        context = redis.connect({ host = '127.0.0.1', port = 6379, timeout = 30 })
    end

    if not context then
        print("can't allocate redis context")
        return
    end

    local reply = context:auth('syg23333')
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

register_post_init(function(linda)
    lanes.gen("*", function()
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
    end)()
end)
