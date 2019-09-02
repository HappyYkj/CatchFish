local context
local host, port, auth

local function ensure_redis()
    if context then
        -- 返回数据库正文
        return context
    end

    ---! redis
    local redis = require "redis"
    context = redis.connect{ host =host, port = port, timeout = 30 }

    if not context then
        return nil, "can't allocate redis context"
    end

    local reply = context:auth(auth)
    if not reply then
        return nil, "can't auth redis context"
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

local function create_redis(...)
    host, port, auth = ...
    return ensure_redis()
end

local function destory_redis()
    ----! todo:
end

local function lpush_redis(...)
    local ok, result
    for idx = 1, 10 do
        local client, failmsg = ensure_redis()
        if client then
            ok, result = pcall(client.lpush, client, ...)
            if ok then
                break
            end
        else
            print("redis_failmsg : " .. failmsg)
        end
        verify_redis()
    end
    return ok, result
end

local function brpop_redis(...)
    local client = ensure_redis()
    if not client then
        verify_redis()
        return
    end

    return client:brpop(...)
end

return {
    create  = create_redis,
    destory = destory_redis,
    lpush = lpush_redis,
    brpop = brpop_redis,
}
