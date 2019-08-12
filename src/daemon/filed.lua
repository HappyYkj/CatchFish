-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
FILE_D = {}

function FILE_D:write_common_content(path, name, branch, content)
    local rpc = {}
    rpc.method = "write_common_content"
    rpc.path = path and tostring(path) or ""
    rpc.name = name and tostring(name) or ""
    rpc.branch = branch and tostring(branch) or ""
    rpc.content = content and tostring(content) or ""
    return THREAD_D:send("database_yield", rpc)
end

function FILE_D:read_common_content(path, name, branch)
    local rpc = {}
    rpc.method = "read_common_content"
    rpc.path = path and tostring(path) or ""
    rpc.name = name and tostring(name) or ""
    rpc.branch = branch and tostring(branch) or ""
    return THREAD_D:send("database_yield", rpc)
end

function FILE_D:write_mail_content(playerId, mail)
    local rpc = {}
    rpc.method = "write_mail_content"
    rpc.playerId = playerId
    rpc.mail = mail
    return THREAD_D:send("database_yield", rpc)
end

function FILE_D:read_mail_content(playerId, id, count)
    local rpc = {}
    rpc.method = "read_mail_content"
    rpc.playerId = playerId
    rpc.id = id
    rpc.count = count
    return THREAD_D:send("database_yield", rpc)
end

function FILE_D:update_mail_content(playerId, id, status)
    local rpc = {}
    rpc.method = "update_mail_content"
    rpc.playerId = playerId
    rpc.id = id
    rpc.status = status
    return THREAD_D:send("database_yield", rpc)
end

function FILE_D:write_charge_content(user_id, order_id, goods_tag)
    local rpc = {}
    rpc.method = "write_charge_content"
    rpc.user_id = user_id
    rpc.order_id = order_id
    rpc.goods_tag = goods_tag
    return THREAD_D:send("database_yield", rpc)
end

function FILE_D:update_charge_content(user_id, order_id)
    local rpc = {}
    rpc.method = "update_charge_content"
    rpc.user_id = user_id
    rpc.order_id = order_id
    return THREAD_D:send("database_yield", rpc)
end

function FILE_D:read_charge_content(user_id, count)
    local rpc = {}
    rpc.method = "read_charge_content"
    rpc.user_id = user_id
    rpc.count = count
    return THREAD_D:send("database_yield", rpc)
end
