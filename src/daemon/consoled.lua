local function main(host, port)
    local socket = require "socket"
    local server = socket.bind(host, port)

    local copas = require "copas"
    copas.addserver(server, function (skt)
        skt = copas.wrap(skt)
        while true do
          local data = skt:receive()
          if data == "quit" then
            break
          end
          skt:send(data.."\n")
        end
    end)
    copas.loop()
end

local lanes = require "lanes"
lanes.gen("*", main)("127.0.0.1", 5267)
