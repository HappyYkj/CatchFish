local tbl = CONFIG_D:get_table("exclusive")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do repeat
    local config = {}
    config.id = tonumber(row.id)      -- 索引：房间Id
    config.para = tonumber(row.para)  -- 参数

    -- 奖励列表
    config.rewards = {}
    if row.rewards ~= "" then
        local tbl = {}
        local fields = string.split(row.rewards, "^")
        for i = 1, #fields, 1 do
            local item = string.split(fields[i], "-")
            if #item == 2 then
                tbl[tonumber(item[1])] = tonumber(item[2])
            end
        end

        if table.size(tbl) > 0 then
            config.rewards = tbl
        end
    end

    configs[config.id] = config
until true end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
EXCLUSIVE_CONFIG = {}

function EXCLUSIVE_CONFIG:get_config_by_id(room_id)
    local config = configs[room_id]
    if not config then
        return
    end

    return config
end

-- 专属boss捕获公式 ： 实际倍率=显示倍率+ROUNDUP（参数/当前炮倍，0）
--- @room_id    : 房间类型
--- @gunrate    : 当前炮倍
--- @score      : 显示倍率
--- @true_score : 真实倍率
function EXCLUSIVE_CONFIG:get_kill_score(room_id, gunrate, score, true_score)
    local config = configs[room_id]
    if not config then
        return true_score
    end

    local kill_score = score + math.ceil(1.0 * config.para / gunrate)
    if kill_score < 0 then
        return true_score
    end

    return kill_score
end
