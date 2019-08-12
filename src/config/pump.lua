local tbl = CONFIG_D:get_table("pump")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    for id, val in pairs(row) do
        if id ~= "id" then
            config[tonumber(id)] = tonumber(val)
        end
    end
    configs[key] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

PUMP_CONFIG = {}

function PUMP_CONFIG:get_fish_pump(fishId, roomType)
    local fishId = fishId % 100000000
    local fish_pump = configs[fishId]
    if not fish_pump then
        return 0
    end
    return fish_pump[roomType] or 0
end
