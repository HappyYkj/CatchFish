local uuid = 0

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
local function do_call(linda, reply, data)
    local ok, ret = pcall(load(string.format("local tmp = %s; return tostring(tmp);", data)))
    if ok then
        linda:send(10.0, reply, table.pack(true, ret))
        return
    end

    local ok, ret = pcall(load(data))
    if ok then
        local str = string.splitv(data, "=")
        local ok, ret2 = pcall(load(string.format("local tmp = %s; return tostring(tmp);", str)))
        if ok then
            linda:send(10.0, reply, table.pack(true, ret2))
            return
        end

        linda:send(10.0, reply, table.pack(true, ret))
        return
    end

    local ok, ret = pcall(load("return tostring(" .. data .. ")"))
    if ok then
        linda:send(10.0, reply, table.pack(true, ret))
        return
    end

    linda:send(10.0, reply, table.pack(false, "error : " .. ret))
end

local function do_repl(linda, name)
    while not cancel_test() do repeat
        io.write("> ")
        local data = io.read()
        if not data then
            break
        end

        data = data:match("^[%s]*(.-)[%s]*$")
        if #data <= 0 then
            break
        end

        local output = false
        if string.byte(data, 1) == 39 then
            if #data <= 1 then
                break
            end
            output, data = true, string.sub(data, 2)
        end

        uuid = uuid + 1
        local reply = string.format(">>%s#%d", name, uuid)
        --local reply = "console#" .. uuid.hex()

        linda:send(name, table.pack(reply, data))
        local ok, result = linda:receive(10.0, reply)
        if not ok then
            -- Maybe timeout
            break
        end

        if type(result) ~= "table" then
            -- Maybe type is wrong
            break
        end

        local ok, result = table.unpack(result)
        if not ok then
            print(result)
            break
        end

        if output then
            print(result)
        end
    until true end
end

-------------------------------------------------------------------------------
---! 启动模块
-------------------------------------------------------------------------------
register_post_init(function()
    local uuid = require "global.common.uuid"
    local name = "console#"..uuid.hex()
    SERVICE_D:register(name, do_call)
    SERVICE_D:create(do_repl, name)
end)
