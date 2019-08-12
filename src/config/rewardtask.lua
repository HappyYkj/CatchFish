
local tbl = CONFIG_D:get_table("rewardtask")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id                      -- 索引
    config.roomid = row.roomid              -- 房间id
    config.beginFrame = row.begin           -- 任务开始帧数
    config.endFrame = row["end"]            -- 任务结束帧数
    config.timelineId = row.timelineid      -- 鱼线ID
    config.rank = row.rank                  -- 触发任务概率

    -- 捕鱼目的（鱼ID,数量）
    config.task_data = {}
    if row.task_data ~= "" then
        local tbl = {}
        local fields = split(row.task_data, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.task_data = tbl
        end
    end

    -- 获得宝箱(宝箱id,概率)
    config.reward = {}
    if row.reward ~= "" then
        local tbl = {}
        local fields = split(row.reward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.reward = tbl
        end
    end
    
    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

REWARD_TASK_CONFIG = {}

function REWARD_TASK_CONFIG:get_config(timelineId, roomType)
    local config = configs[roomType * 10 + timelineId]
    if not config then
        return
    end
    return config
end

function REWARD_TASK_CONFIG:get_gift_id(config)
    if table.len(config.reward) > 0 then
        return weightedchoice(config.reward)
    end
end

function REWARD_TASK_CONFIG:get_fish_count(config, fishId)
    return config.task_data[fishId] or 0
end

function REWARD_TASK_CONFIG:get_fish_types(config)
    local fish_types = {}
    for fish_type, _ in pairs(config.task_data) do
        fish_types[fish_type % 10000] = 1
    end
    return table.keys(fish_types)
end
