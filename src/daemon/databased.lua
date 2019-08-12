local lanes = require "lanes"
local DEBUG_VERSION = true

local env, conn
local function ensure_mysql()
    local luasql = require "luasql.mysql"
    if env then
        if conn then
            -- 返回数据库连接
            return conn
        end

        -- 关闭数据库环境
        env:close()
    end

    -- 创建环境对象
    env = luasql.mysql()

    -- 连接数据库
    if not DEBUG_VERSION then
        conn = env:connect("catchfish","root","weile2018","39.96.52.103",3306)
    else
        conn = env:connect("catchfish","root","weile2018","127.0.0.1",3306)
    end

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

-------------------------------------------------------------------------------
---!
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
register_post_init(function(linda)
    lanes.gen("*", function()
        while true do repeat
            local key, rpc = linda:receive("database_yield")
            if key ~= "database_yield" then
                break
            end

            local id, msg = table.unpack(rpc)
            if not id or not msg then
                break
            end

            local method = msg_dipatcher[msg.method]
            if not method then
                break
            end

            local ok, result
            for idx = 1, 1 do repeat
                local client = ensure_mysql()
                if not client then
                    break
                end

                ok, result = pcall(method, client, msg)
                if not ok then
                    break
                end

                linda:send("database_resume", table.pack(id, ok, result))
            until true end

            verify_mysql()
        until true end
    end)()
end)
