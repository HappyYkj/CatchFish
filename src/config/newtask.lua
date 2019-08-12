local tbl = CONFIG_D:get_table("newtask")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id - 450000000                  -- 索引
    config.task_type = tonumber(row.task_type)      -- 任务类型
    config.task_data = tonumber(row.task_data)      -- 任务数据
    config.task_data2 = tonumber(row.task_data2)    -- 任务数据2
    
    -- 任务奖励
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
    
    -- 任务奖励备用配置
    config.reward_1 = {}
    if row.reward_1 ~= "" then
        local tbl = {}
        local fields = split(row.reward_1, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.reward_1 = tbl
        end
    end
    
    -- 任务分享获得奖励
    config.share_reward = {}
    if row.share_reward ~= "" then
        local tbl = {}
        local fields = split(row.share_reward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.share_reward = tbl
        end
    end
    
    configs[#configs + 1] = config
end

table.sort(configs, function(config1, config2)
    return config1.id < config2.id
end)

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

NEW_TASK_CONFIG = {}

function NEW_TASK_CONFIG:get_config_by_id(id)
    for _, config in ipairs(configs) do
        if config.id == id then
            return config
        end
    end
end

function NEW_TASK_CONFIG:get_first_config()
    local _, config = next(configs)
    return config
end

function NEW_TASK_CONFIG:get_next_config(id)
    for idx, config in ipairs(configs) do
        if config.id == id then
            local _, next_config = next(configs, idx)
            return next_config
        end
    end
end

function NEW_TASK_CONFIG:get_last_config(id)
    local last_config
    for _, config in ipairs(configs) do
        if config.id == id then
            return last_config
        end
        last_config = config
    end
end
