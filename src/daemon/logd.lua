local config = require "config"
local datasource = config.dblog.data
local username = config.dblog.user
local password = config.dblog.auth
local host = config.dblog.host
local port = config.dblog.port

-------------------------------------------------------------------------------
---! CREATE TABLE TO HOLD MSG DISPATCH
-------------------------------------------------------------------------------
local lanes = require "lanes"
local msg_dipatcher = lanes.linda("share_data")

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
local function processor(linda)
    local mysql = require "global.db.mysql"

    while true do
        local ok, failmsg = mysql.create(datasource, username, password, host, port)
        if ok then
            break
        end

        print("luasql_failmsg : " .. failmsg)
        sleep(3)
    end

    -- print(string.format("write_log %s create succ.", decoda_name))
    while true do repeat
        local key, val = linda:receive("write_log")
        if key ~= "write_log" then
            break
        end

        local log_name, log_data = table.unpack(val)
        if not log_name or not log_data then
            break
        end

        local func = msg_dipatcher:get(log_name)
        if not func then
            break
        end

        mysql.execute(func, log_data)
    until true end
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
LOG_D = {}

function LOG_D:register(log_name, log_func)
    msg_dipatcher:set(log_name, log_func)
end

function LOG_D:write_log(log_name, log_data)
    THREAD_D:post("write_log", log_name, log_data)
end

function LOG_D:write_item_log(log_data)
    return LOG_D:write_log("item_log", log_data)
end

-------------------------------------------------------------------------------
---! 启动接口
-------------------------------------------------------------------------------
register_post_init(function()
    for idx = 1, 16 do
        SERVICE_D:create(processor)
    end
end)
