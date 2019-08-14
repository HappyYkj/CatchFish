local msg_dipatcher = {
    ["read_common_content"]  = require "data.read_common_content",
    ["write_common_content"] = require "data.write_common_content",
    ["read_mail_content"]  = require "data.read_mail_content",
    ["write_mail_content"] = require "data.write_mail_content",
    ["update_mail_content"] = require "data.update_mail_content",
    ["write_charge_content"] = require "data.write_charge_content",
    ["update_charge_content"] = require "data.update_charge_content",
    ["read_charge_content"] = require "data.read_charge_content",
}

local env, conn
local function ensure_mysql()
    if env then
        if conn then
            -- 返回数据库连接
            return conn
        end

        -- 关闭数据库环境
        env:close()
    end

    -- 创建环境对象
    local luasql = require "luasql.mysql"
    env = luasql.mysql()

    -- 连接数据库
    local config = require "config"
    local datasource = config.mysql.data
    local username = config.mysql.user
    local password = config.mysql.auth
    local host = config.mysql.host
    local port = config.mysql.port
    conn = env:connect(datasource, username, password, host, port)

    -- 设置数据库的编码格式
    conn:execute"SET NAMES UTF8"

    -- 返回数据库连接
    return conn
end

local function verify_mysql()
    if not conn then
        return
    end

    local reply = conn:ping()
    if not reply then
        -- 关闭数据库连接
        conn:close()
        conn = nil
    end
end

local function processor(linda)
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

        local ok, result
        for idx = 1, 10 do
            local client = ensure_mysql()
            if client then
                ok, result = pcall(func, client, msg)
                if ok then
                    linda:send("coroutine_resume", table.pack(id, ok, result))
                    break
                end
            end

            verify_mysql()
        end
    until true end
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
SERVICE_D:create(processor)
