local tbl = CONFIG_D:get_table("config")
if not tbl then
    return
end

-- 普通神灯召唤的鱼类Id
local callfish_ids = {}
if tbl[990000029] then
    for _, field in ipairs(split(tbl[990000029].data, ";")) do
        callfish_ids[#callfish_ids + 1] = tonumber(field)
    end
end

-- 神灯召唤出来的鱼线Id
local callfish_paths = {}
if tbl[990000030] then
    for _, field in ipairs(split(tbl[990000030].data, ";")) do
        callfish_paths[#callfish_paths + 1] = tonumber(field) + 300000000
    end
end

-- 使用神灯召唤鱼的最大数量
local callfish_max_count = {}
if tbl[990000034] then
    for grade, field in ipairs(split(tbl[990000034].data, ";")) do
        callfish_max_count[grade] = tonumber(field)
    end
end

-- 神灯卡掉落的满足值
local callfish_drop_require = 0
if tbl[990000035] then
    callfish_drop_require = tonumber(tbl[990000035].data)
end

-- 高级神灯所需的最低vip等级
local callfish_min_vip_grade = 0
if tbl[990000084] then
    callfish_min_vip_grade = tonumber(tbl[990000084].data)
end

-- 高级神灯召唤的鱼类Id
local callfish_vip_ids = {}
if tbl[990000085] then
    local fields = split(tbl[990000085].data, ";")
    for i = 1, #fields, 2 do
        local key, val = fields[i], fields[i + 1]
        if key and val then
            callfish_vip_ids[tonumber(key)] = tonumber(val)
        end
    end
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

CALLFISH_CONFIG = {}

function CALLFISH_CONFIG:get_callfish_id(grade)
    if grade >= callfish_min_vip_grade then
        return weightedchoice(callfish_vip_ids) + 100000000
    end

    return randomchoice(callfish_ids) + 100000000
end

function CALLFISH_CONFIG:get_callfish_path(grade)
    return randomchoice(callfish_paths)
end

function CALLFISH_CONFIG:get_callfish_max_count(grade)
    local count = callfish_max_count[grade]
    if not count then
        return 20
    end
    return count
end

function CALLFISH_CONFIG:get_callfish_drop_require()
    return callfish_drop_require
end
