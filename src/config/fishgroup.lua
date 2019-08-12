local tbl = CONFIG_D:get_table("fishgroup")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id              -- 索引
    config.frame = row.frame        -- 帧号
    config.trace = row.trace        -- 轨迹
    config.arrId = row.arrId        -- 鱼串号
    config.endframe = row.endframe  -- 末尾帧

    config.fisharray = function () return FISH_ARRAY_CONFIG:get_config_by_id(config.arrId) end
    config.get_index = function () return math.floor(config.id / 100000) % 10 end

    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

FISH_GROUP_CONFIG = {}

function FISH_GROUP_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end
    return config
end

function FISH_GROUP_CONFIG:get_fishgroup_index(id)
    local config = configs[id]
    if not config then
        return
    end
    return math.floor(config.id / 100000) % 10
end

function FISH_GROUP_CONFIG:generate_random_fishgroup_index()
    local arr = {}
    for id, _ in pairs(configs) do repeat
        local fishgroup_index = self:get_fishgroup_index(id)
        if not fishgroup_index then
            break
        end
        arr[fishgroup_index] = 1
    until true end
    return randomchoice(table.keys(arr))
end

function FISH_GROUP_CONFIG:get_fishgroup_endframe(index)
    local endframes = {}
    for id, fishgroup in pairs(configs) do repeat
        local fishgroup_index = self:get_fishgroup_index(id)
        if not fishgroup_index then
            break
        end

        if fishgroup_index ~= index then
            break
        end

        endframes[#endframes + 1] = fishgroup.endframe
    until true end
    return math.max(0, table.unpack(endframes))
end
