-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
---! 获取杀死的鱼
local function get_killed_hit_fishes(player, bullet, fishes)
    local desk_grade = player:get_desk_grade()

    ---! 计算鱼的总价值
    local total_score = 0
    for _, fish in ipairs(fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(fish.fishId)
        if not fish_type then
            break
        end

        if fish_type:isExclusiveBoss() then
            total_score = total_score + EXCLUSIVE_CONFIG:get_kill_score(desk_grade, bullet.gunRate, fish_type.score, fish_type.true_score)
            break
        end

         total_score = total_score + fish_type.true_score
    until true end

    ---! 获取子弹的狂暴系数
    local violent_multiply = VIOLENT_D:get_violent_multiply(bullet.gunRate, bullet.violentRate)

    ---! 获取子弹的锁定系数
    local lockHitRate = bullet.lockHitRate or 1

    local killed_fishes = {}
    for _, fish in ipairs(fishes) do
        ---! 基础概率
        local L = 1.0 / total_score

        ---! 鱼基础抽水
        local A = 1.0 * PUMP_CONFIG:get_fish_pump(fish.fishId, desk_grade) / 10000

        ---! 杀鱼万分比
        local percent = (1.0 - A) * L * violent_multiply * lockHitRate * 10000

        ---! 计算是否击杀
        local killed = math.random(10000) < percent

        spdlog.debug("fish", string.format("player [%s] hit_fish fishId = %s, timelineId = %s, fishArrayId = %s, L = %s, A = %s, percent = %s, killed = %s",
                             player:get_id(), fish.fishId, fish.timelineId, fish.fishArrayId, L, A, math.floor(percent), killed))

        if killed then
            killed_fishes[#killed_fishes + 1] = fish
        end
    end
    return killed_fishes
end

---! 获取击杀闪电鱼，被杀死的鱼
local function get_killed_fishes_for_thunder_fish(player, bullet, killed_fishes, effected_fishes)
    ---! 计算获得的闪电库值
    local thunder_rate = bullet.gunRate * 100

    ---! 累加已有的闪电库值
    thunder_rate = thunder_rate + player:get_thunder_rate()

    ---! 遍历受影响的鱼，加入杀死的鱼直到闪电库小于或等于0
    for _, effected_fish in ipairs(effected_fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(effected_fish.id)
        if not fish_type then
            -- 鱼类型错误，跳过
            break
        end

        if fish_type:isBoss() or
           fish_type:isRewardFish() or
           fish_type:isSpecialFish() then
            -- 特殊鱼，奖金鱼，boss忽略
            break
        end

        -- 计算所需的闪电库值
        local cost_thunder_rate = fish_type.true_score * bullet.gunRate
        if thunder_rate < cost_thunder_rate then
            -- 消耗的闪电库值不足，忽略
            break
        end

        -- 扣除所需的闪电库值
        thunder_rate = thunder_rate - cost_thunder_rate

        -- 将鱼加入到击杀表中
        killed_fishes[#killed_fishes + 1] = effected_fish
    until true end

    ---! 记录剩余的闪电库值
    player:set_thunder_rate(thunder_rate)

    ---! 返回所有被击杀的鱼
    return killed_fishes
end

---! 获取击杀同类炸弹鱼，被杀死的鱼
local function get_killed_fishes_for_same_kind_bomb_fish(player, bullet, killed_fishes, effected_fishes)
    --[[
    ---! 计算受影响鱼的总价值
    local total_score = 0
    for _, effected_fish in ipairs(effected_fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(effected_fish.fishId)
        if not fish_type then
            break
        end

        if fish_type:isBoss() or
           fish_type:isRewardFish() or
           fish_type:isSpecialFish() then
            break
        end

        total_score = total_score + fish_type.true_score
    until true end
    --]]

    --[[
    if  total_score > 0 then

        local violentRate = 1 ----todo: 获取子弹的狂暴系数
        local lockHitRate = 1 ----todo: 获取子弹的锁定系数

        if get_percent_result_for_score_fish(player, bullet, total_score, violentRate, lockHitRate) then
    --]]
            ---! 击杀成功，将所有受影响的鱼加入击杀表
            for _, effected_fish in ipairs(effected_fishes) do repeat
                local fish_type = FISH_CONFIG:get_config_by_id(effected_fish.fishId)
                if not fish_type then
                    -- 鱼类型错误，跳过
                    break
                end

                if fish_type:isBoss() or
                   fish_type:isRewardFish() or
                   fish_type:isSpecialFish() then
                    -- 特殊鱼，奖金鱼，boss忽略
                    break
                end

                -- 将鱼加入到击杀表中
                killed_fishes[#killed_fishes + 1] = effected_fish
            until true end
    --[[
        end
    end
    --]]
end

---! 获取击杀局部炸弹鱼，被杀死的鱼
local function get_killed_fishes_for_part_bomb_fish(player, bullet, killed_fishes, effected_fishes)
    ---! 获取玩家的炸弹库值
    local bomb_rate = player:get_bomb_rate()

    ---! 遍历受影响的鱼，加入杀死的鱼直到炸弹库小于或等于0
    for _, effected_fish in ipairs(effected_fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(effected_fish.id)
        if not fish_type then
            -- 鱼类型错误，跳过
            break
        end

        if fish_type:isBoss() or
           fish_type:isRewardFish() or
           fish_type:isSpecialFish() then
            -- 特殊鱼，奖金鱼，boss忽略
            break
        end

        -- 计算所需的炸弹库值
        local cost_bomb_rate = fish_type.true_score * bullet.gunRate
        if bomb_rate < cost_bomb_rate then
            -- 消耗的炸弹库值不足，忽略
            break
        end

        -- 扣除所需的炸弹库值
        bomb_rate = bomb_rate - cost_bomb_rate

        -- 将鱼加入到击杀表中
        killed_fishes[#killed_fishes + 1] = effected_fish
    until true end

    ---! 记录剩余的炸弹库值
    player:set_bomb_rate(bomb_rate)

    ---! 返回所有被击杀的鱼
    return killed_fishes
end

---! 获取击杀摇钱树鱼，被杀死的鱼
local function get_killed_fishes_for_money_tree_fish(player, bullet, killed_fishes, effected_fishes)
end

---! 获取被杀死的鱼列表
local function get_killed_fishes(player, bullet, hit_fishes, effected_fishes)
    local killed_fishes = get_killed_hit_fishes(player, bullet, hit_fishes)
    if #hit_fishes <= 0 then
        return killed_fishes
    end

    local hit_fish = hit_fishes[1]
    local fish_type = FISH_CONFIG:get_config_by_id(hit_fish.fishId)
    if not fish_type then
        return killed_fishes
    end

    ---! 闪电鱼
    if fish_type:isThunderFish() then
        return get_killed_fishes_for_thunder_fish(player, bullet, killed_fishes, effected_fishes)
    end

    ---! 同类炸弹
    if fish_type:isSameKindBombFish() then
        return get_killed_fishes_for_same_kind_bomb_fish(player, bullet, killed_fishes, effected_fishes)
    end

    ---! 局部炸弹
    if fish_type:isPartBombFish() then
        return get_killed_fishes_for_part_bomb_fish(player, bullet, hit_fishes, effected_fishes)
    end

    ---! 摇钱树鱼
    if fish_type:isMoneyTreeFish() then
        return get_killed_fishes_for_money_tree_fish(player, bullet, hit_fishes, effected_fishes)
    end

    return killed_fishes
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
CATCH_POLICY_D = {}

---! 获取有效的鱼
function CATCH_POLICY_D:get_validate_hit_fishes(desk, fishes)
    ---! 获取当前帧数
    local frame_count = desk:get_frame_count()

    ---! 遍历指定鱼群
    local hit_fishes = {}
    for _, fish in ipairs(fishes) do repeat
        local fish_id = 0
        if fish.timelineId > 0 then
            ---! 非召唤鱼
            if not desk:is_in_fishgroup() then
                -- 鱼线
                if desk:get_timeline_index() ~= TIMELINE_CONFIG:get_timeline_index(fish.timelineId) then
                    -- 时间线跟当前正在运行的时间线不对应
                    spdlog.debug("debug", string.format("timeline [%s] illigal timeline index, now desk play timeline is [%s]", fish.timelineId, desk:get_timeline_index()))
                    break
                end
            else
                -- 鱼潮
                if desk:get_timeline_index() ~= FISH_GROUP_CONFIG:get_fishgroup_index(fish.timelineId) then
                    -- 时间线跟当前正在运行的时间线不对应
                    spdlog.debug("debug", string.format("fishgroup [%s] illigal timeline index, now desk play timeline is [%s]", fish.timelineId, desk:get_timeline_index()))
                    break
                end
            end

            if not desk:is_fish_exist_and_alived(frame_count, fish.timelineId, fish.fishArrayId) then
                -- 指定的鱼已经不可见，或者已经被其他玩家杀死了
                spdlog.debug("debug", string.format("timeline [%s] fisharray [%s] not exist or dead", fish.timelineId, fish.fishArrayId));
                break
            end

            fish_id = desk:get_fishid_by_fisharray(fish.timelineId, fish.fishArrayId)
        else
            ---! 为召唤鱼，timelineId= -1 * playerId
            local callfish = desk:get_callfish(-fish.timelineId, fish.fishArrayId)
            if not callfish then
                break
            end

            ---! 普通召唤鱼
            if not desk:is_fish_visable(callfish) then
                spdlog.debug("debug", "illigal called fish id")
                break
            end

            fish_id = callfish.fishId
        end

        local fish_type = FISH_D:get_true_fish_type(desk, fish_id, fish.timelineId, fish.fishArrayId)
        if not fish_type then
            break
        end

        local hit_fish = {}
        hit_fish.fishId = fish_type.id
        hit_fish.timelineId = fish.timelineId
        hit_fish.fishArrayId = fish.fishArrayId
        hit_fishes[#hit_fishes + 1] = hit_fish
    until true end
    return hit_fishes
end

---! 获取被杀死的鱼列表
function CATCH_POLICY_D:get_killed_fishes(player, bullet, hit_fishes, effected_fishes)
    local killed_fishes = get_killed_hit_fishes(player, bullet, hit_fishes)
    if #hit_fishes <= 0 then
        return killed_fishes
    end

    local hit_fish = hit_fishes[1]
    local fish_type = FISH_CONFIG:get_config_by_id(hit_fish.fishId)
    if not fish_type then
        return killed_fishes
    end

    ---! 闪电鱼
    if fish_type:isThunderFish() then
        return get_killed_fishes_for_thunder_fish(player, bullet, killed_fishes, effected_fishes)
    end

    ---! 同类炸弹
    if fish_type:isSameKindBombFish() then
        return get_killed_fishes_for_same_kind_bomb_fish(player, bullet, killed_fishes, effected_fishes)
    end

    ---! 局部炸弹
    if fish_type:isPartBombFish() then
        return get_killed_fishes_for_part_bomb_fish(player, bullet, hit_fishes, effected_fishes)
    end

    ---! 摇钱树鱼
    if fish_type:isMoneyTreeFish() then
        return get_killed_fishes_for_money_tree_fish(player, bullet, hit_fishes, effected_fishes)
    end

    return killed_fishes
end
