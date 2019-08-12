local tbl = CONFIG_D:get_table("fish")
if not tbl then
    return
end

local traceType = {
    kFishGroup = 1,         -- 鱼群
    kNormalFish = 2,        -- 普通鱼
    kBonusFish = 3,         -- 奖金鱼
    kCombineFish = 4,       -- 组合鱼
    kBossFish = 5,          -- boss鱼
    kPartBombFish = 6,      -- 特殊鱼
    kThunderFish = 7,       -- 闪电鱼
    kSameKindBombFish = 8,  -- 同类炸弹鱼
    kChestFish = 9,         -- 奖券鱼
    kBowlBoss = 10,         -- 聚宝盆鱼
    kMoneyTreeFish = 11,    -- 摇钱树鱼
    kMermaidFish = 12,      -- 美人鱼（当前已修改为金蛋）
    kMagicOrbsFish = 13,    -- 魔法宝珠鱼
    kMagicOrbsBoss = 14,    -- 魔法宝珠Boss鱼
    kGhostFish = 15,        -- 幽灵船长小怪
    kGhostBoss = 16,        -- 幽灵船长boss
    kNagaFish = 17,         -- 娜迦小怪
    kNagaBoss = 18,         -- 娜迦女皇
    kExclusiveBoss = 19,    -- 房间专属Boss鱼
}

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id                  -- 鱼种id
    config.score = row.score            -- 分值
    config.true_score = row.true_score  -- 实际倍率
    config.trace_type = row.trace_type  -- 轨迹类型
    config.name = row.name              -- 名称
    configs[config.id] = config

    config.isPartBombFish = function () 
        return config.trace_type == traceType.kPartBombFish
    end

    config.isThunderFish = function ()
        return config.trace_type == traceType.kThunderFish
    end
    
    config.isSameKindBombFish = function ()
        return config.trace_type == traceType.kSameKindBombFish
    end

    config.isChestFish = function ()
        return config.trace_type == traceType.kChestFish
    end

    config.isBowlBoss = function ()
        return config.trace_type == traceType.kBowlBoss
    end

    config.isMoneyTreeFish = function ()
        return config.trace_type == traceType.kMoneyTreeFish
    end

    config.isExclusiveBoss = function ()
        return config.trace_type == traceType.kExclusiveBoss
    end

    config.isRewardFish = function ()
        return config.trace_type == traceType.kBonusFish or
               config.trace_type == traceType.kCombineFish
    end

    config.isBoss = function ()
        return config.trace_type == traceType.kBossFish or
               config.trace_type == traceType.kBowlBoss or
               config.trace_type == traceType.kExclusiveBoss
    end

    config.isSpecialFish = function ()
        return config.trace_type == traceType.kPartBombFish or
               config.trace_type == traceType.kThunderFish or
               config.trace_type == traceType.kSameKindBombFish or
               config.trace_type == traceType.kChestFish or
               config.trace_type == traceType.kMoneyTreeFish or
               config.trace_type == traceType.kMermaidFish
    end

    config.isSpecialFish = function ()
        return config.trace_type == traceType.kBonusFish or
               config.trace_type == traceType.kCombineFish or
               config.trace_type == traceType.kBossFish or
               config.trace_type == traceType.kMermaidFish or
               config.trace_type == traceType.kExclusiveBoss
    end

    config.getCommonFishType = function()
        if config.isBoss() then
            return 3
        end

        if config.isRewardFish() then
            return 2
        end

        return 1
    end
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

FISH_CONFIG = {}

function FISH_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end
    return config
end
