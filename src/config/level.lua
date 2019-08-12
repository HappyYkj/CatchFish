local tbl = CONFIG_D:get_table("level")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.level = row.level
    config.exp = row.exp
    config.doubleshare = row.doubleshare
    
    -- 奖励物品
    config.level_reward = {}
    if row.level_reward ~= "" then
        local tbl = {}
        local fields = split(row.level_reward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.level_reward = tbl
        end
    end
    
    configs[config.level] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

LEVEL_CONFIG = {}

function LEVEL_CONFIG:get_config_by_level(level)
    local config = configs[level]
    if not config then
        return
    end

    return config
end

function LEVEL_CONFIG:get_grade_by_exp(exp)
    local currentGrade = 1
    local expAcculate = 0
    for _, level in pairs(table.keys(configs)) do
        local config = configs[level]
        expAcculate = expAcculate + config.exp;
        if exp >= expAcculate then
            currentGrade = config.level
        end
    end

    return currentGrade
end

function LEVEL_CONFIG:get_exp_by_grade(grade)
    local keys = table.keys(configs)
    table.sort(keys)

    local expAcculate = 0
    for _, key in pairs(keys) do
        local config = LEVEL_CONFIG:get_config_by_level(key)

        if grade < config.level then
            break
        end

        expAcculate = expAcculate + config.exp
    end

    return expAcculate
end

function LEVEL_CONFIG:get_max_grade()
    local keys = table.keys(configs)
    if #keys > 0 then
        table.sort(keys)
        return keys[#keys]
    end

    return 1
end
