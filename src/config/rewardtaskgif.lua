local tbl = CONFIG_D:get_table("rewardtaskgif")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id  -- 索引

    -- 礼包获得奖励
    if row.reward ~= "" then
        local tbl = {}
        local fields = string.split(row.reward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.size(tbl) > 0 then
            config.reward = tbl
        end
    end

    -- 分享获得奖励
    if row.share_reward ~= "" then
        local tbl = {}
        local fields = string.split(row.share_reward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.size(tbl) > 0 then
            config.share_reward = tbl
        end
    end

    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

REWARD_TASK_GIFT_CONFIG = {}

function REWARD_TASK_GIFT_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end

    return config
end
