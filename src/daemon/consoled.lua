local uuid = require "global.common.uuid"
local dump = require "global.common.dump"

local host, port = "127.0.0.1", 5267

local EOT = 'HappyServer :>'

-------------------------------------------------------------------------------
---! CREATE LINDA TO HOLD MESSAGE QUEUE
-------------------------------------------------------------------------------
local mqueue = SERVICE_D:queue()

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
local function console(linda)
    local socket = require "socket"
    local client = socket.connect(host, port)
    if not client then
        print("connect failed")
        return
    end

    while true do
        io.write('\n> ')
        local data = io.read()
        if not data then
            break
        end

        data = data:match("^[%s]*(.-)[%s]*$")
        if #data > 0 then
          client:send(data .. '\n')

          while true do
            local data = client:receive()
                if not data then
                    break
                end

                if data == EOT then
                    break
                end

                io.write(data .. '\n')
          end
        end
    end
end

local function listen(linda)
    local socket = require "socket"
    local server = socket.bind(host, port)

    local copas = require "copas"
    copas.addserver(server, function (skt)
        skt = copas.wrap(skt)
        local ip, port = skt:getpeername()
        print("new conn from " .. ip .. ":" .. port)

        local client_id = "client#" .. uuid.hex()
        while true do
            local data = skt:receive()
            if data then
                if data == "quit" then
                    break
                end

                linda:send("console_channel", table.pack(client_id, data))
                while true do
                    local id, data = mqueue:receive(client_id)
                    if id == client_id then
                        skt:send(data .. '\n')
                        if data == EOT then
                            break
                        end
                    end
                end
            end
        end
    end)
    copas.loop()
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
SERVICE_D:create(listen)

local global = _G
SERVICE_D:register("console_channel", function(data)
    local id, data = table.unpack(data)
    if not id then
        return
    end

    local write = function (...) end
    if data then
        if string.byte(data, 1) == 39 then
            write = function (...)
                mqueue:send(id, ...)
            end

            data = string.sub(data, 2)
        end

        if #data > 0 then
            local elem = global[data]
            if elem then
                if type(elem) == "function" then
                    pcall(elem)
                else
                    write(dump(elem))
                end
            else
                local wrap = load('return ' .. data)
                local ok, ret = pcall(wrap)
                if ok and ret then
                    write(dump(ret))
                end
            end
        end
    end
    mqueue:send(id, EOT)
end)

register_post_init(function()
    SERVICE_D:create(console)
end)
