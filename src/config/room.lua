local tbl = CONFIG_D:get_table("room")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id - 910000000              -- 索引, 房间类型Id
    config.name = row.name                      -- 房间名称
    config.roomname = row.roomname              -- 房间详情
    config.cannon_max = row.cannon_max          -- 房间最大炮倍限制
    config.cannon_min = row.cannon_min          -- 房间最小炮倍限制
    config.lv_max = row.lv_max                  -- 房间最大等级限制
    config.lv_min = row.lv_min                  -- 房间最小等级限制
    config.gold_max = row.gold_max              -- 房间最大金币限制
    config.gold_min = row.gold_min              -- 房间最小金币限制
    config.max_bullet = row.max_bullet          -- 单个玩家子弹数量上限
    config.deduct_n1 = row.deduct_n1            -- 抽水参数N1（万分比）
    config.special_bossid = row.special_bossid  -- 专属BOSS鱼种ID

    -- 特殊玩法配置
    if row.special_play ~= "" then
        local tbl = {}
        local fields = split(row.special_play, ";")
        for i = 1, #fields do
            local key = fields[i]
            if key then
                tbl[tonumber(key)] = true
            end
        end

        if table.len(tbl) > 0 then
            config.special_play = tbl
        end
    end

    -- 使用鱼线组号
    if row.timeline_groupid ~= "" then
        local tbl = {}
        local fields = split(row.timeline_groupid, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.timeline_groupid = tbl
        end
    end

    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
ROOM_CONFIG = {}
ROOM_CONFIG.FREE_ARENA_ROOM_TYPE    = 6
ROOM_CONFIG.LIMIT_ARENA_ROOM_TYPE   = 7

function ROOM_CONFIG:get_config_by_roomtype(roomtype)
    local config = configs[roomtype]
    if not config then
        return
    end

    return config
end

function ROOM_CONFIG:is_grade_validate(config, grade)
    if type(config) == "number" then
        config = self:get_config_by_roomtype(config)
    end

    if type(config) ~= "table" then
        return false
    end

    if config.lv_max > 0 and grade > config.lv_max then
        return false
    end

    if config.lv_min > 0 and grade < config.lv_min then
        return false
    end

    return true
end

function ROOM_CONFIG:is_gunrate_validate(config, gunrate)
    if type(config) == "number" then
        config = self:get_config_by_roomtype(config)
    end

    if type(config) ~= "table" then
        return false
    end
    
    if config.cannon_max > 0 and gunrate >= config.cannon_max then
        return false
    end

    if config.cannon_min > 0 and gunrate < config.cannon_min then
        return false
    end

    return true
end

function ROOM_CONFIG:has_special_play(roomtype, speical)
    local config = self:get_config_by_roomtype(roomtype)
    if not config then
        return false
    end

    if not config.special_play[speical] then
        return false
    end

    return true
end
