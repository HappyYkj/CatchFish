local config = require "config"
local host = config.redis.host
local port = config.redis.port
local auth = config.redis.auth

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
local function producer(linda)
    local redis = require "global.db.redis"

    while true do
        if cancel_test() then
            return
        end

        local ok, failmsg = redis.create(host, port, auth)
        if ok then
            break
        end

        print("redis_failmsg : " .. failmsg)
        sleep(3)
    end

    printf("redis [%s:%s producer] start ...", host, port)
    while not cancel_test() do repeat
        local key, reply = linda:receive(3.0, "client_channel")
        if key ~= "client_channel" then
            break
        end

        if type(reply) ~= "table" or #reply ~= 2 then
            break
        end

        redis.lpush(reply[1], reply[2])
    until true end

    redis.destory()
    printf("redis [%s:%s consumer] quit ...", host, port)
end

local function consumer(linda)
    local redis = require "global.db.redis"

    while true do
        if cancel_test() then
            return
        end

        local ok, failmsg = redis.create(host, port, auth)
        if ok then
            break
        end

        print("redis_failmsg : " .. failmsg)
        sleep(3)
    end

    printf("redis [%s:%s consumer] start ...", host, port)
    while not cancel_test() do repeat
        local reply = redis.brpop("login_channel", "game_channel_lua", "charge_channel", 3)
        if type(reply) ~= "table" or #reply ~= 2 then
            break
        end

        if reply[1] and reply[2] then
            linda:send(reply[1], table.pack(reply[2]))
        end
    until true end

    redis.destory()
    printf("redis [%s:%s consumer] quit ...", host, port)
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
SERVICE_D:create(producer)
SERVICE_D:create(consumer)
