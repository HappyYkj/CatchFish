socket = require "socket"

---! [[uuid format : (32bits timestamp)(6bits machine)(10bits service)(16bits sequence)]]
local uuid = {}

---! 2019.07.04 09:00:00
local scale = os.time({ day=4, month=7, year=2019, hour=9, })

---! (6bits machine)(16bits service)
local service = ((1 & 0x3f) << 26) | ((1 & 0x3ff) << 16)

---! timestamp
local function gettimestamp ()
    local timestamp
    timestamp = os.time() - scale
    timestamp = (timestamp << 32) | service
    return timestamp
end

local timestamp
local sequence
function uuid.gen ()
    sequence = sequence or 0
    sequence = sequence + 1

    if sequence > 0xffff then
        local _timestamp = gettimestamp()
        timestamp = _timestamp ~= timestamp and _timestamp or nil
        sequence = 0

        if not timestamp then
            socket.select(nil, nil, 1)
        end
    end

    if not timestamp then
        timestamp = gettimestamp()
    end

    return (timestamp | sequence)
end

function uuid.hex (id)
    local id = id or uuid.gen()
    return string.format("%X", id)
end

function uuid.split (id)
    local ts = (id >> 32) + scale
    local harbor   = (id & 0xffffffff) >> 26
    local service  = (id & 0x3ffffff) >> 16
    local sequence = id & 0xffff
    return ts, harbor, service, sequence
end

return uuid
