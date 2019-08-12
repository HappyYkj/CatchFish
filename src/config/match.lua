local tbl = CONFIG_D:get_table("match")
if not tbl then
    return
end

local configs = {}
for _, row in pairs(tbl) do
    local config = {}
    config.id = row.id                      -- 索引
    config.type = row.type                  -- 比赛类型, 1=免费赛, 2=排位赛
    config.num = row.num                    -- 比赛人数上限
    config.time = row.time                  -- 比赛时长
    config.cannon = row.cannon              -- 炮倍条件
    config.bulletnum = row.bulletnum        -- 赠送子弹数量
    config.maxnum = row.maxnum              -- 比赛报名上限次数
    config.freeshare_id = row.freeshare_id  -- 分享对应ID
    config.name = row.name                  -- 比赛名称

    -- 道具消耗
    config.cost = {}
    if row.cost ~= "" then
        local tbl = {}
        local fields = split(row.cost, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.cost = tbl
        end
    end

    -- 比赛奖励
    config.reward = {}
    if row.reward ~= "" then
        local tbl = {}
        local fields = split(row.reward, ";")
        for i = 1, #fields, 3 do
            local rank, prop_id, prop_count = fields[i], fields[i + 1], fields[i + 2]
            if rank and prop_id and prop_count then
                tbl[#tbl + 1] = { rank = tonumber(rank), prop_id = tonumber(prop_id), prop_count = tonumber(prop_count), }
            end
        end

        if table.len(tbl) > 0 then
            table.sort(tbl, function(reward1, reward2)
                return reward1.rank < reward2.rank
            end)
            config.reward = tbl
        end
    end

    configs[config.id - 500000000] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
MATCH_CONFIG = {}
MATCH_CONFIG.FREE_ARENA_MATCH_ID = 1001

function MATCH_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end
    return config
end

function MATCH_CONFIG:get_reward_by_rank(config, rank)
    for _, reward in ipairs(config.reward) do
        if rank <= reward.rank then
            return reward.prop_id, reward.prop_count
        end
    end
end
