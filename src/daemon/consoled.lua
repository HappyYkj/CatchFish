--[[
local lanes = require "lanes"
local linda = lanes.linda()

-------------------------------------------------------------------------------
---! 监听接口
-------------------------------------------------------------------------------
local function listen(host, port)
    local socket = require "socket"
    local server = socket.bind(host, port)

    local copas = require "copas"
    copas.addserver(server, function (skt)
      local client = copas.wrap(skt)
      while true do
        local data = client:receive()
        if data and #data > 0 then
          if data == "quit" then
            break
          end

          client:send(data.."\n")
          local func = load(data)
          local ret = func()
          client:send(tostring(ret).."\n")
        end
      end
    end)
    copas.loop()
end
lanes.gen("*", listen)("127.0.0.1", 5267)
--]]

--[[
local socket = require "socket"
local copas = require "copas"
copas.addserver(server, function (skt)

end)
--]]
