local lanes = require "lanes"
local redis = require "redis"
local DEBUG_VERSION = true

---! 监听频道
local listen_channel = {}

---! redis上下文
local context = nil

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
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

            local reply = _client:brpop("login_channel", "game_channel_lua", "charge_channel", 3)
            if type(reply) ~= "table" or #reply ~= 2 then
                verify_redis()
                break
            end

            if reply[1] and reply[2] then
                linda:send(reply[1], reply[2])
            end
        until true end
    end)()
end)

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
LISTEN_D = {}

function LISTEN_D:register_listen_channel(channel, func)
    listen_channel[channel] = func
end

function LISTEN_D:dispatch_listen_channel(channel, data)
    local func = listen_channel[channel]
    if not func then
        return false
    end

    THREAD_D:create(function()
        xpcall(function() func(data) end, function(err)
            spdlog.error(err)
        end)
    end)
    return true
end
