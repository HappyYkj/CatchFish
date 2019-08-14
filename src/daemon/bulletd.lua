---! 通知无效子弹
local function notify_invalid_bullet(player, bullet)
    ---! 广播射击消息
    local result = {}
    result.validate = false
    result.bulletId = bullet.bulletId
    result.angle = bullet.angle
    result.playerId = bullet.playerId
    result.gunRate = bullet.gunRate
    result.timelineId = bullet.timelineId
    result.fishArrayId = bullet.fishArrayId
    result.pointX = bullet.pointX
    result.pointY = bullet.pointY
    result.frameCount = bullet.frameCount
    result.isViolent = bullet.isViolent
    result.nViolentRatio = bullet.nViolentRatio
    result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    player:send_packet("MSGS2CPlayerShoot", result)
end

---! 判断是否是无效子弹
local function check_invalid_bullet(player, bullet)
    ---! 判断当前未处理的子弹数量是否超过限额
    local bullet_count = player:get_desk():get_player_bullet_count(player:get_id())
    if bullet_count >= 20 then
        return true
    end

    if bullet.gunRate > player:get_max_gunrate() then
        return true
    end

    return false
end

---! 获取有效的鱼
local function get_validate_hit_fishes(desk, fishes)
    local hit_fishes = CATCH_POLICY_D:get_validate_hit_fishes(desk, fishes)

    ---! 根据鱼的分数，从大到小进行排序
    if #hit_fishes > 0 then
        table.sort(hit_fishes, function (hit_fish1, hit_fish2)
            local fish_type1 = FISH_CONFIG:get_config_by_id(hit_fish1.fishId)
            local fish_type2 = FISH_CONFIG:get_config_by_id(hit_fish2.fishId)
            return fish_type1.true_score > fish_type2.true_score
        end)
    end

    return hit_fishes
end

---! 掉落鱼币
local function generate_drop_fishicon(player, killed_fishes, gunrate, drop_props)
    ---! 遍历被杀死的鱼
    local fish_score = 0
    for _, fish in ipairs(killed_fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(fish.fishId)
        if not fish_type then
            break
        end

        if fish_type:isThunderFish() then
            -- 闪电鱼不加积分
            break
        end

        if fish_type:isChestFish() then
            -- 鱼券鱼不掉奖券
            break
        end

        if fish_type:isExclusiveBoss() then
            -- 专属boss
            fish_score = fish_score + fish_type.score
            break
        end

        fish_score = fish_score + fish_type.true_score
    until true end

    ---! 鱼的分数*炮倍
    fish_score = fish_score * gunrate

    if fish_score > 0 then
        ---! 扣除根据获取的鱼币扣除补贴库值
        local allowance_rate = math.floor(math.min(player:get_allowance_rate(), 1.0 * fish_score * FISH_SERVER_CONFIG.allowanceDropRate / 10000))
        if allowance_rate > 0 then
            player:add_allowance_rate(-allowance_rate)
        end

        ---! 累加奖金池
        fish_score = FISH_DRAW_D:generate_reward_rate(player, killed_fishes, gunrate, fish_score)

        ---! 记录鱼币
        if not drop_props[GamePropIds.kGamePropIdsFishIcon] then
            drop_props[GamePropIds.kGamePropIdsFishIcon] = fish_score
        else
            drop_props[GamePropIds.kGamePropIdsFishIcon] = drop_props[GamePropIds.kGamePropIdsFishIcon] + fish_score
        end
    end

    return drop_props
end

---! 掉落水晶
local function generate_drop_crystal(player, killed_fishes, gunrate, drop_props)
    local fish = killed_fishes[1]
    local fish_type = FISH_CONFIG:get_config_by_id(fish.fishId)
    if not fish_type then
        return drop_props
    end

    if fish_type:isExclusiveBoss() then
        ---! 专属Boss鱼特殊掉落
        local exclusive_config = EXCLUSIVE_CONFIG:get_config_by_id(player:get_desk_grade())
        if exclusive_config then
            for prop_id, prop_count in pairs(exclusive_config.rewards) do
                if not drop_props[prop_id] then
                    drop_props[prop_id] = prop_count
                else
                    drop_props[prop_id] = drop_props[prop_id] + prop_count
                end
            end
        end
        return drop_props
    end

    if fish_type:isSpecialFish() then
        return drop_props
    end

    if fish_type:isBoss() then
        return drop_props
    end

    -- 获取掉落道具ID
    local drop_prop_id = CRYSTAL_CONFIG:get_crystal_rate_drop(fish_type:getCommonFishType(), gunrate)
    if drop_prop_id <= 0 then
        return drop_props
    end

    -- 获取水晶掉落历史
    local crystal_drop_history = player:get_crystal_drop_history()

    -- 获取水晶掉落条件
    local crystal_rate_cost = CRYSTAL_CONFIG:get_crystal_rate_cost(crystal_drop_history)

    -- 获取水晶掉落库值
    local crystal_drop_rate = player:get_crystal_drop_rate()

    if drop_prop_id == GamePropIds.kGamePropIdsCrystal then
        local drop_prop_count = 0
        if fish_type:isRewardFish() then
            -- 奖金鱼只掉一个
            drop_prop_count = 1
        else
            -- 水晶库值不足
            if crystal_drop_rate < crystal_rate_cost then
                return drop_props
            end

            -- 计算掉落数量
            drop_prop_count = math.floor(1.0 * crystal_drop_rate / crystal_rate_cost)
            drop_prop_count = math.min(drop_prop_count, CRYSTAL_CONFIG:get_crystal_max_drop_prop_count(gunRate))
        end

        -- 清空水晶掉落库值
        player:del_crystal_drop_rate()

        -- 增加水晶历史库值
        player:add_crystal_drop_history(drop_prop_count)

        -- 记录玩家增加水晶
        if not drop_props[drop_prop_id] then
            drop_props[drop_prop_id] = drop_count
        else
            drop_props[drop_prop_id] = drop_props[drop_prop_id] + drop_count
        end
    elseif drop_prop_id == GamePropIds.kGamePropFishTicket then
        -- 获取奖券鱼掉落数
        local drop_prop_count = FISHTICKET_CONFIG:getFishTicketFishDrop(player:get_desk_grade(), gunrate)
        if drop_prop_count <= 0 then
            return drop_props
        end

        -- 记录玩家增加鱼券
        if not drop_props[drop_prop_id] then
            drop_props[drop_prop_id] = drop_count
        else
            drop_props[drop_prop_id] = drop_props[drop_prop_id] + drop_count
        end
    end
    return drop_props
end

---! 掉落道具
local function generate_drop_item(player, killed_fishes, gunrate, drop_props)
    local max_skill_card_count = FISH_SERVER_CONFIG.maxSkillCardCount
    local skill_prop_percent = FISH_SERVER_CONFIG.skillPropPercent

    ---! 遍历被杀死的鱼
    local fish_score = 0
    for _, fish in ipairs(killed_fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(fish.fishId)
        if not fish_type then
            break
        end

        -- 获取技能库值
        local skill_drop_rate = player:get_skill_drop_rate()

        -- 技能库满足冰冻掉落
        local freeze_drop_require = 0
        if skill_drop_rate >= FISH_SERVER_CONFIG.freezeDropRequire and
           player:get_prop_count(GamePropIds.kGamePropIdsFreeze) < max_skill_card_count then
            freeze_drop_require = FISH_SERVER_CONFIG.freezeDropRequire
        end

        -- 技能库满足锁定掉落
        local aim_drop_require = 0
        if skill_drop_rate >= FISH_SERVER_CONFIG.aimDropRequire and
           player:get_prop_count(GamePropIds.kGamePropIdsAim) < max_skill_card_count then
            aim_drop_require = FISH_SERVER_CONFIG.aimDropRequire
        end

        -- 召唤鱼库满足召唤掉落
        local callfish_drop_require = 0
        if skill_drop_rate >= CALLFISH_CONFIG:get_callfish_drop_require() and
           player:get_prop_count(GamePropIds.kGamePropIdsCallFish) < max_skill_card_count then
            callfish_drop_require = CALLFISH_CONFIG:get_callfish_drop_require()
        end

        local total_drop_require = freeze_drop_require + aim_drop_require
        if total_drop_require > 0 and skill_prop_percent < math.random(10000) then
            -- 清空库值
            player:del_skill_drop_rate()

            -- 记录道具
            local prop_id = GamePropIds.kGamePropIdsAim
            if freeze_drop_require < math.random(total_drop_require) then
                prop_id = GamePropIds.kGamePropIdsFreeze
            end

            if not drop_props[prop_id] then
                drop_props[prop_id] = 1
            else
                drop_props[prop_id] = drop_props[prop_id] + 1
            end
        end

        if callfish_drop_require > 0 and skill_prop_percent < math.random(10000) then
            -- 清空库值
            player:del_skill_drop_rate()

            -- 记录道具
            drop_props[GamePropIds.kGamePropIdsCallFish] = drop_props[GamePropIds.kGamePropIdsCallFish] or 0 + 1
        end

        -- 炮倍大于1000倍，且打中奖金鱼，且锻造库满足要求
        if gunrate >= FISH_SERVER_CONFIG.minDropFrogeDropGunRate and fish_type:isRewardFish() then
            if player:get_material_rate() >= FISH_SERVER_CONFIG.forgeDropRequre then
                -- 掉落锻造材料
                local forgeMesteralDropWeights = FISH_SERVER_CONFIG.forgeMesteralDropWeights
                if table.len(forgeMesteralDropWeights) > 0 and skill_prop_percent < math.random(10000) then
                    local material_id = weightedchoice(forgeMesteralDropWeights)
                    local drop_count = math.floor(1.0 * player:get_material_rate() / FISH_SERVER_CONFIG.forgeDropRequre)

                    -- 清空库值
                    player:del_material_rate()

                    -- 记录道具
                    if not drop_props[material_id] then
                        drop_props[material_id] = drop_count
                    else
                        drop_props[material_id] = drop_props[material_id] + drop_count
                    end
                end
            end
        end

        if fish_type:isSpecialFish() then
            return drop_props
        end
    until true end
    return drop_props
end

---! 掉落鱼券
local function generate_drop_fishticket(player, killed_fishes, gunrate, drop_props)
    for _, fish in ipairs(killed_fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(fish.fishId)
        if not fish_type then
            break
        end

        if not fish_type:isChestFish() then
            break
        end

        -- 获取奖券鱼掉落数
        local drop_prop_count = FISHTICKET_CONFIG:getFishTicketFishDrop(player:get_desk_grade(), gunrate)
        if drop_prop_count <= 0 then
            break
        end

        -- 记录玩家增加鱼券
        if not drop_props[GamePropIds.kGamePropFishTicket] then
            drop_props[GamePropIds.kGamePropFishTicket] = drop_prop_count
        else
            drop_props[GamePropIds.kGamePropFishTicket] = drop_props[GamePropIds.kGamePropFishTicket] + drop_prop_count
        end
    until true end
    return drop_props
end

---! 掉落幸运宝箱
local function generate_drop_luckychest(player, killed_fishes, gunrate, drop_props)
    return drop_props
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
BULLET_D = {}

---! 玩家发射子弹
function BULLET_D:send_bullet(player, msgRecv)
    local desk = player:get_desk()
    if not desk then
        return
    end

    ---! 获取当前时间
    local tickCount = os.time()

    ---! 创建子弹信息
    local bullet = {}
    bullet.playerId = player:get_id()           -- 玩家id
    bullet.bulletId = msgRecv.bulletId          -- 子弹id
    bullet.angle = msgRecv.angle                -- 角度
    bullet.tickCount = tickCount                -- 时间
    bullet.gunRate = msgRecv.gunRate            -- 炮倍
    bullet.timelineId = msgRecv.timelineId      -- 时间线id
    bullet.fishArrayId = msgRecv.fishArrayId    -- 鱼线id
    bullet.pointX = msgRecv.pointX              -- 坐标X点
    bullet.pointY = msgRecv.pointY              -- 坐标Y点
    bullet.validate = true

    ---! 是否处于狂暴
    local isViolent = false
    if msgRecv.isViolent then
        isViolent = player:is_on_violent()
        if isViolent then
            bullet.violentRate = player:get_violent_ratio()
        end
    end

    bullet.isViolent = isViolent

    ---! 是否处于锁定
    local isLock = false
    if msgRecv.timelineId ~= 0 or msgRecv.fishArrayId ~= 0 then
        -- 鱼线ID和时间线ID不为0，说明是使用锁定
        isLock = player:is_on_aim_fish()
        if isLock then
            player:set_lock_fish_hit_rate(msgRecv.gunRate)
        end
    end
    bullet.isLock = isLock

    ---! 子弹是否无效
    if check_invalid_bullet(player, bullet) then
        notify_invalid_bullet(player, bullet)
        return
    end

    ---! 计算子弹费用
    if bullet.isViolent then
        bullet.needCost = bullet.gunRate * bullet.violentRate
    elseif bullet.isLock then
        bullet.needCost = bullet.gunRate * FISH_SERVER_CONFIG.nLockFishCostRate
    else
        bullet.needCost = bullet.gunRate
    end

    if player:get_prop_count(GamePropIds.kGamePropIdsFishIcon) < bullet.needCost then
        ----! 无效子弹
        notify_invalid_bullet(player, bullet)
        return
    end

    ---! 扣除相关费用
    if bullet.needCost > 0 then
        player:change_prop_count(GamePropIds.kGamePropIdsFishIcon, -bullet.needCost, PropRecieveType.kPropChangeTypeSendBullet)
    end

    ---! 加入到子弹管理模块中
    desk:add_bullet(bullet)

    ---! 累加水晶库值
    if player:get_crystal_drop_history() < MAX_DROP_RATE then
        player:add_crystal_drop_history(bullet.gunRate)
    end

    ---! 累加技能库值
    if player:get_skill_drop_rate() < MAX_DROP_RATE then
        if player:get_prop_count(GamePropIds.kGamePropIdsFreeze) < FISH_SERVER_CONFIG.maxSkillCardCount or
        player:get_prop_count(GamePropIds.kGamePropIdsAim) < FISH_SERVER_CONFIG.maxSkillCardCount then
            local cannon_times = CANNON_CONFIG:get_config_id_by_gunrate(player:get_max_gunrate())
            player:add_skill_drop_rate(SKILL_DROP_CONFIG:get_diamond_cost_by_cannon_times(cannon_times))
        end
    end

    ---! 累加召唤库值
    if player:get_callfish_drop_rate() < MAX_DROP_RATE then
        if player:get_prop_count(GamePropIds.kGamePropIdsCallFish) < FISH_SERVER_CONFIG.maxSkillCardCount then
            local cannon_times = CANNON_CONFIG:get_config_id_by_gunrate(player:get_max_gunrate())
            player:add_callfish_drop_rate(SKILL_DROP_CONFIG:get_callfish_drop_rate_by_cannon_times(cannon_times))
        end
    end

    ---! 累加炸弹库值
    if player:get_bomb_rate() < MAX_DROP_RATE then
        player:add_bomb_rate(math.floor(1.0 * FISH_SERVER_CONFIG.bombAccurateRate * 10000 * bullet.gunRate))
    end

    ---! 广播射击消息
    local result = {}
    result.validate = true
    result.bulletId = bullet.bulletId
    result.angle = bullet.angle
    result.playerId = bullet.playerId
    result.gunRate = bullet.gunRate
    result.timelineId = bullet.timelineId
    result.fishArrayId = bullet.fishArrayId
    result.pointX = bullet.pointX
    result.pointY = bullet.pointY
    result.frameCount = bullet.frameCount
    result.isViolent = bullet.isViolent
    result.nViolentRatio = bullet.violentRate
    result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    player:brocast_packet("MSGS2CPlayerShoot", result)
end

---! 批量射击消息
function BULLET_D:batch_bullet(player, msgRecv)
    local desk = player:get_desk()
    if not desk then
        return
    end

    local isOnViolent = false
    if msgRecv.isViolent then
        isOnViolent = player:is_on_violent()
    end

    ---! 获取当前鱼币
    local fishicon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)

    ---! 需要消耗鱼币
    local money_cost = 0

    ---! 获取当前时间
    local tickCount = os.time()

    local bullets = {}
    for _, msgBullet in ipairs(msgRecv.bullets) do repeat
        local bullet = {}
        bullet.playerId = player:get_id()               -- 玩家id
        bullet.bulletId = msgBullet.bulletId            -- 子弹id
        bullet.angle = msgBullet.angle                  -- 角度
        bullet.tickCount = tickCount                    -- 时间
        bullet.gunRate = msgRecv.gunRate                -- 炮倍
        bullet.timelineId = msgBullet.timelineId        -- 时间线id
        bullet.fishArrayId = msgBullet.fishArrayId      -- 鱼线id
        bullet.pointX = msgBullet.pointX                -- 坐标X点
        bullet.pointY = msgBullet.pointY                -- 坐标Y点
        bullet.validate = true
        bullets[#bullets + 1] = bullet

        bullet.isViolent = isOnViolent
        bullet.violentRate = player:get_violent_ratio() -- 狂暴系数

        ---! 是否锁定
        local isLock = false
        if msgRecv.timelineId ~= 0 or msgRecv.fishArrayId ~= 0 then
            -- 鱼线ID和时间线ID不为0，说明是使用锁定
            isLock = player:is_on_aim_fish()
            if isLock then
                player:set_lock_fish_hit_rate(msgRecv.gunRate)
            end
        end
        bullet.isLock = isLock

        ---! 子弹是否无效
        if check_invalid_bullet(player, bullet) then
            bullet.validate = false
            break
        end

        ---! 计算子弹费用
        if bullet.isViolent then
            bullet.needCost = bullet.gunRate * bullet.violentRate
        elseif bullet.isLock then
            bullet.needCost = bullet.gunRate * FISH_SERVER_CONFIG.nLockFishCostRate
        else
            bullet.needCost = bullet.gunRate
        end

        if fishicon < money_cost + bullet.needCost then
            ----! 无效子弹
            bullet.validate = false
            break
        end

        ---! 累加子弹费用
        money_cost = money_cost + bullet.needCost
    until true end

    ---! 扣除相关费用
    if money_cost > 0 then
        player:change_prop_count(GamePropIds.kGamePropIdsFishIcon, -money_cost, PropRecieveType.kPropChangeTypeSendBullet)
    end

    ---! 加入到子弹管理模块中
    for _, bullet in ipairs(bullets) do
        if bullet.validate then
            desk:add_bullet(bullet)

            ---! 累加水晶库值
            if player:get_crystal_drop_history() < MAX_DROP_RATE then
                player:add_crystal_drop_history(bullet.gunRate)
            end

            ---! 累加技能库值
            if player:get_skill_drop_rate() < MAX_DROP_RATE then
                if player:get_prop_count(GamePropIds.kGamePropIdsFreeze) < FISH_SERVER_CONFIG.maxSkillCardCount or
                   player:get_prop_count(GamePropIds.kGamePropIdsAim) < FISH_SERVER_CONFIG.maxSkillCardCount then
                    local cannon_times = CANNON_CONFIG:get_config_id_by_gunrate(player:get_max_gunrate())
                    player:add_skill_drop_rate(SKILL_DROP_CONFIG:get_diamond_cost_by_cannon_times(cannon_times))
                end
            end

            ---! 累加召唤库值
            if player:get_callfish_drop_rate() < MAX_DROP_RATE then
                if player:get_prop_count(GamePropIds.kGamePropIdsCallFish) < FISH_SERVER_CONFIG.maxSkillCardCount then
                    local cannon_times = CANNON_CONFIG:get_config_id_by_gunrate(player:get_max_gunrate())
                    player:add_callfish_drop_rate(SKILL_DROP_CONFIG:get_callfish_drop_rate_by_cannon_times(cannon_times))
                end
            end

            ---! 累加炸弹库值
            if player:get_bomb_rate() < MAX_DROP_RATE then
                player:add_bomb_rate(math.floor(1.0 * FISH_SERVER_CONFIG.bombAccurateRate * 10000 * bullet.gunRate))
            end
        end
    end

    ---! 广播发射子弹消息
    local result = {}
    result.playerId = player:get_id()
    result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    result.moneyCost = money_cost
    result.gunRate = msgRecv.gunRate
    result.frameCount = msgRecv.frameCount
    result.isViolent = msgRecv.isViolent
    result.nViolentRatio = msgRecv.violentRate

    local retBullets = {}
    for _, bullet in ipairs(bullets) do
        local retBullet = {}
        retBullet.bulletId = bullet.bulletId
        retBullet.angle = bullet.angle
        retBullet.pointX = bullet.pointX
        retBullet.pointY = bullet.pointY
        retBullet.timelineId = bullet.timelineId
        retBullet.fishArrayId = bullet.fishArrayId
        retBullet.validate = bullet.validate
        retBullets[#retBullets + 1] = retBullet
    end
    result.bullets = retBullets
    player:brocast_packet("MSGS2CBatchShoot", result)
end

---! 处理撞击消息
function BULLET_D:hit_bullet(player, hitMessage)
    local desk = player:get_desk()
    if not desk then
        return
    end

    local bullet = desk:get_bullet(player:get_id(), hitMessage.bulletId)
    if not bullet then
        return
    end

    ---! 移除子弹
    desk:remove_bullet(player:get_id(), hitMessage.bulletId)

    ---! 子弹炮倍
    local gunRate = bullet.gunRate

    ---! 是否狂暴
    local isViolent = bullet.isViolent

    ---! 获取有效的碰撞的鱼
    local hit_fishes = get_validate_hit_fishes(desk, hitMessage.killedFishes)

    ---! 获取有效的受影响的鱼
    local effected_fishes = get_validate_hit_fishes(desk, hitMessage.effectedFishes)

    ---! 将有效的鱼传入，获得被杀死的鱼的列表
    local killed_fishes = CATCH_POLICY_D:get_killed_fishes(player, bullet, hit_fishes, effected_fishes)

    ---! 根据杀死的鱼处理对应的掉落逻辑
    local drop_props = {}
    if #killed_fishes > 0 then
        ---! 将死掉的鱼加入鱼管理中
        for _, fish in ipairs(killed_fishes) do
            desk:add_killed_fish(fish.timelineId, fish.fishArrayId)
        end

        ---! 掉落鱼币
        drop_props = generate_drop_fishicon(player, killed_fishes, gunRate, drop_props)

        ---! 掉落水晶
        drop_props = generate_drop_crystal(player, killed_fishes, gunRate, drop_props)

        ---! 掉落技能道具(冰冻锁定等)
        drop_props = generate_drop_item(player, killed_fishes, gunRate, drop_props)

        ---! 掉落鱼券
        drop_props = generate_drop_fishticket(player, killed_fishes, gunRate, drop_props)

        ---! 掉落幸运宝箱
        drop_props = generate_drop_luckychest(player, killed_fishes, gunRate, drop_props)

        --[[
        ---! 更新悬赏任务
        -- desk->UpdateRewardTask(player, vecCaughtFish);
        --]]

        ---! 统一给玩家发放道具奖励
        for prop_id, prop_count in pairs(drop_props) do
            player:change_prop_count(prop_id, prop_count, PropRecieveType.kPropChangeTypeKillFish)
        end

        ---! 更新杀鱼任务
        TASK_D:update_kill_fish_task(player, killed_fishes)
    end

    local dropProps = {}
    for prop_id, prop_count in pairs(drop_props) do
        dropProps[#dropProps + 1] = { propId = prop_id, propCount = prop_count, }
    end

    local killedFishes = {}
    for _, killed_fish in ipairs(killed_fishes) do
        killedFishes[#killedFishes + 1] = { timelineId = killed_fish.timelineId, fishArrayId = killed_fish.fishArrayId, }
    end

    local result = {}
    result.playerId = player:get_id()
    result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    result.newThunderRate = player:get_thunder_rate()
    result.bulletId = bullet.bulletId
    result.frameId = frameCount
    result.killedFishes = killedFishes
    result.randomFishScore = 0
    result.isViolent = isViolent
    result.gunRate = gunRate
    result.dropProps = dropProps
    result.killFishScore = drop_props[GamePropIds.kGamePropIdsFishIcon] or 0
    desk:brocast_packet("MSGS2CPlayerHit", result)

    ----todo: after_hit_bullet
    do
        ---! 检测玩家是否升级
        USER_D:check_player_upgrade(player, drop_props[GamePropIds.kGamePropIdsFishIcon] or 0, gunRate)

        ---! 检查玩家是否破产
        ALM_D:check_bankup(player)
    end
end

---! 投掷炸弹
function BULLET_D:throw_bomb(player, msgData)
    local itemConfig = ITEM_CONFIG:get_config_by_id(msgData.nPropID)
    if not itemConfig then
        local result = {}
        result.isSuccess = false
        result.nBombId = msgData.nBombId
        result.useType = msgData.useType
        result.nPropID = msgData.nPropID
        result.playerId = player:get_id()
        player:send_packet("MSGS2CNBomb", result)
        return
    end

    local bombConfig = BOMB_CONFIG:get_config_by_id(itemConfig.id)
    if not bombConfig then
        local result = {}
        result.isSuccess = false
        result.nBombId = msgData.nBombId
        result.useType = msgData.useType
        result.nPropID = msgData.nPropID
        result.playerId = player:get_id()
        player:send_packet("MSGS2CNBomb", result)
        return
    end

    ---! 悬赏任务禁止使用核弹
    ---- todo:
    if false then
        local result = {}
        result.isSuccess = false
        result.nBombId = msgData.nBombId
        result.useType = msgData.useType
        result.nPropID = msgData.nPropID
        result.playerId = player:get_id()
        player:send_packet("MSGS2CNBomb", result)
        return
    end

    -- 使用道具
    if msgData.useType == 0 then
        -- 核弹个数-正在施放中的核弹=可用核弹个数
        if player:get_prop_count(msgData.nPropID) - player:get_desk():get_pending_bomb_count(player:get_id(), msgData.nPropID) <= 0 then
            -- 道具不足，失败
            local result = {}
            result.isSuccess = false
            result.nBombId = msgData.nBombId
            result.useType = msgData.useType
            result.nPropID = msgData.nPropID
            result.playerId = player:get_id()
            player:send_packet("MSGS2CNBomb", result)
            return
        end
    -- 使用水晶
    elseif msgData.useType == 1 then
        -- 当前水晶-正在施放的核弹水晶=可用水晶
        if player:get_prop_count(GamePropIds.kGamePropIdsCrystal) - player:get_desk():get_pending_crystal(player:get_id()) < itemConfig.price_value then
            local result = {}
            result.isSuccess = false
            result.nBombId = msgData.nBombId
            result.useType = msgData.useType
            result.nPropID = msgData.nPropID
            result.playerId = player:get_id()
            player:send_packet("MSGS2CNBomb", result)
            return
        end
    -- 其他方式
    else
        local result = {}
        result.isSuccess = false
        result.nBombId = msgData.nBombId
        result.useType = msgData.useType
        result.nPropID = msgData.nPropID
        result.playerId = player:get_id()
        player:send_packet("MSGS2CNBomb", result)
        return
    end

    ---! 将核弹加入核弹管理
    player:get_desk():add_bomb(player:get_id(), msgData.nBombId, msgData.useType, msgData.nPropID)

    ---! 广播核弹消息
    local result = {}
    result.isSuccess = true
    result.nBombId = msgData.nBombId
    result.useType = msgData.useType
    result.nPropID = msgData.nPropID
    result.pointX = msgData.pointX
    result.pointY = msgData.pointY
    result.newNBombRate = player:get_nbomb_rate()
    result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    result.playerId = player:get_id()
    player:brocast_packet("MSGS2CNBomb", result)
end

---! 处理爆炸
function BULLET_D:blast_bomb(player, msgData)
    local desk = player:get_desk()
    if not desk then
        return
    end

    local bombData = desk:get_bomb_use_type(player:get_id(), msgData.nBombId)
    if not bombData then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        player:send_packet("MSGS2CNBombBlast", result)
        return
    end

    local item_config = ITEM_CONFIG:get_config_by_id(bombData.propId)
    if not item_config then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        player:send_packet("MSGS2CNBombBlast", result)
        return
    end

    local bomb_config = BOMB_CONFIG:get_config_by_id(item_config.id)
    if not bomb_config then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        player:send_packet("MSGS2CNBombBlast", result)
        return
    end

    ---! 使用道具
    if bombData.useType == 0 then
        -- 核弹个数-正在施放中的核弹=可用核弹个数
        if player:get_prop_count(bombData.propId) - desk:get_pending_bomb_count(player:get_id(), msgData.nPropID) <= 0 then
            -- 道具不足，失败
            local result = {}
            result.isSuccess = false
            result.playerId = player:get_id()
            player:send_packet("MSGS2CNBombBlast", result)
            return
        end

        -- 扣除核弹道具
        player:change_prop_count(bombData.propId, -1, PropRecieveType.kPropChangeTypeUseProp)
    ---! 使用水晶
    elseif bombData.useType == 1 then
        -- 当前水晶-正在施放的核弹水晶=可用水晶
        if player:get_prop_count(GamePropIds.kGamePropIdsCrystal) - desk:get_pending_crystal(player:get_id()) < item_config.price_value then
            local result = {}
            result.isSuccess = false
            result.playerId = player:get_id()
            player:send_packet("MSGS2CNBombBlast", result)
            return
        end

        -- 扣除水晶道具
        player:change_prop_count(GamePropIds.kGamePropIdsCrystal, -item_config.price_value, PropRecieveType.kPropChangeTypeUseProp)
    ---! 其他方式
    else
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        player:send_packet("MSGS2CNBombBlast", result)
        return
    end

    ---! 移除核弹
    desk:remove_bomb(player:get_id(), msgData.nBombId)

    ---! 累加已有的炸弹库值
    nbomb_rate = player:get_nbomb_rate() + bomb_config.data

    ---! 获取有效的碰撞的鱼
    local hit_fishes = get_validate_hit_fishes(desk, msgData.killedFishes)

    ---! 计算所有鱼的总价值
    local total_score = 0
    for _, hit_fish in ipairs(hit_fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(hit_fish.fishId)
        if not fish_type then
            -- 鱼类型错误，跳过
            break
        end

        if fish_type:isBoss() or
           fish_type:isSpecialFish() then
            -- 特殊鱼，boss忽略
            break
        end

        total_score = total_score + fish_type.true_score
    until true end

    ---! 获取最大结算的分数
    local max_score = math.min(nbomb_rate, bomb_config.one_gold)

    ---! 获取最终结算的炮倍
    local use_gunrate = 0
    if total_score > 0 then
        -- 有效炸弹倍数
        use_gunrate = 1.0 * max_score / total_score

        -- 大于或者等于炮倍参数
        if use_gunrate >= bomb_config.cannon_data then
            use_gunrate = CANNON_CONFIG:get_integer_gunrate(use_gunrate)
        else
            use_gunrate = bomb_config.cannon_data
        end
    end

    local fish_score = 0
    local killed_fishes = {}
    for _, hit_fish in ipairs(hit_fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(hit_fish.fishId)
        if not fish_type then
            break
        end

        if fish_type:isBoss() or
           fish_type:isSpecialFish() then
            -- 特殊鱼，boss忽略
            break
        end

        -- 计算所需的炸弹库值
        local cost_nbomb_rate = fish_type.true_score * use_gunrate
        if fish_score + cost_nbomb_rate > max_score then
            -- 消耗的炸弹库值不足，忽略
            break
        end

        -- 记录当前消耗的分值
        fish_score = fish_score + cost_nbomb_rate

        -- 将鱼加入到击杀表中
        killed_fishes[#killed_fishes + 1] = hit_fish
    until true end

    ---! 将死掉的鱼加入鱼管理中
    for _, killed_fish in ipairs(killed_fishes) do
        desk:add_killed_fish(killed_fish.timelineId, killed_fish.fishArrayId)
    end

    ---! 记录剩余的炸弹库值
    player:set_nbomb_rate(math.max(0, nbomb_rate - fish_score))

    if fish_score > 0 then
        ---! 扣除根据获取的鱼币扣除补贴库值
        local allowance_rate = math.floor(math.min(player:get_allowance_rate(), 1.0 * fish_score * FISH_SERVER_CONFIG.allowanceDropRate / 10000))
        if allowance_rate > 0 then
            player:add_allowance_rate(-allowance_rate)
        end

        ---! 累加奖金池
        local fish_score = FISH_DRAW_D:generate_reward_rate(player, killed_fishes, use_gunrate, fish_score)

        ---! 给予相应鱼币
        player:change_prop_count(GamePropIds.kGamePropIdsFishIcon, fish_score, PropRecieveType.kPropChangeTypeKillFish)
    end

    ---! 更新杀鱼任务
    TASK_D:update_kill_fish_task(player, killed_fishes)

    ---! 广播杀鱼消息
    local killedFishes = {}
    for _, killed_fish in ipairs(killed_fishes) do
        killedFishes[#killedFishes + 1] = { timelineId = killed_fish.timelineId, fishArrayId = killed_fish.fishArrayId, }
    end

    local result = {}
    result.isSuccess = true
    result.nPropID = msgData.propId
    result.useType = msgData.useType
    result.moneyChange = fish_score
    result.gunRate = use_gunrate
    result.killedFishes = killedFishes
    result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    result.newNBombRate = player:get_nbomb_rate()
    result.playerId = player:get_id()
    player:brocast_packet("MSGS2CNBombBlast", result)

    ---! 检测玩家是否升级
    USER_D:check_player_upgrade(player, fish_score, use_gunrate)
end
