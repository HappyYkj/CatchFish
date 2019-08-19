local msg_dipatcher = {
    ["read_common_content"] = require "data.read_common_content",
    ["write_common_content"] = require "data.write_common_content",
    ["read_mail_content"] = require "data.read_mail_content",
    ["write_mail_content"] = require "data.write_mail_content",
    ["update_mail_content"] = require "data.update_mail_content",
    ["write_charge_content"] = require "data.write_charge_content",
    ["update_charge_content"] = require "data.update_charge_content",
    ["read_charge_content"] = require "data.read_charge_content",
}

local config = require "config"
local datasource = config.mysql.data
local username = config.mysql.user
local password = config.mysql.auth
local host = config.mysql.host
local port = config.mysql.port

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

    -- print(string.format("data_comm %s create succ.", decoda_name))
    while true do repeat
        local key, rpc = linda:receive("database_yield")
        if key ~= "database_yield" then
            break
        end

        local id, msg = table.unpack(rpc)
        if not id or not msg then
            break
        end

        local method = msg.method
        if not method then
            break
        end

        local func = msg_dipatcher[msg.method]
        if not func then
            break
        end

        local ok, result = mysql.execute(func, msg)
        linda:send("coroutine_resume", table.pack(id, ok, result))
    until true end
end

-------------------------------------------------------------------------------
---! 启动接口
-------------------------------------------------------------------------------
register_post_init(function()
    for idx = 1, 4 do
        SERVICE_D:create(processor)
    end
end)
