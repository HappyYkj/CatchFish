local env, conn
local datasource, username, password, host, port

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
    local failmsg
    conn, failmsg = env:connect(datasource, username, password, host, port)

    if conn then
        -- 设置数据库的编码格式
        conn:execute"SET NAMES UTF8"
    else
        -- 关闭数据库环境
        env:close()
        env = nil
    end

    -- 返回数据库连接
    return conn, failmsg
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

local function create_mysql(...)
    datasource, username, password, host, port = ...
    return ensure_mysql()
end

local function destory_mysql()
    if env then
        if conn then
            -- 关闭数据库连接
            conn:close()
            conn = nil
        end

        -- 关闭数据库环境
        env:close()
        env = nil
    end
end

local function execute_mysql(func, data)
    local ok, result
    for idx = 1, 10 do
        local client, failmsg = ensure_mysql()
        if client then
            ok, result = pcall(func, client, data)
            if ok then
                break
            end
        else
            print("luasql_failmsg : " .. failmsg)
        end
        verify_mysql()
    end
    return ok, result
end

return {
    create  = create_mysql,
    destory = destory_mysql,
    execute = execute_mysql,
}
