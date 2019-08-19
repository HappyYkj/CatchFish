---! 获取升级至目标炮倍，所需材料和奖励道具
local function get_upgrade_gunrate(player, gunrate)
    ---! 解锁消耗物品
    local unlock_item = {}

    ---! 获得奖励物品
    local phase_reward = {}

    ---! 下一升级炮倍
    local new_gunrate = gunrate
    local next_gunrate = CANNON_CONFIG:get_next_gunrate(player:get_max_gunrate())
    while next_gunrate <= gunrate do
        local cannon_config = CANNON_CONFIG:get_config_by_gunrate(next_gunrate)
        if not cannon_config then
            break
        end

        ---! 获取升级炮倍所需水晶
        local propId = GamePropIds.kGamePropIdsCrystal
        if not unlock_item[propId] then
            unlock_item[propId] = cannon_config.unlock_gem
        else
            unlock_item[propId] = unlock_item[propId] + cannon_config.unlock_gem
        end

        ---! 获取升级炮倍所需道具
        for propId, propCount in pairs(cannon_config.unlock_item) do
            if not unlock_item[propId] then
                unlock_item[propId] = propCount
            else
                unlock_item[propId] = unlock_item[propId] + propCount
            end
        end

        ---! 获取升级炮倍所需金币
        local propId = GamePropIds.kGamePropIdsFishIcon
        if not phase_reward[propId] then
            phase_reward[propId] = cannon_config.unlock_award
        else
            phase_reward[propId] = phase_reward[propId] + cannon_config.unlock_award
        end

        ---! 获取升级炮倍奖励道具
        for propId, propCount in pairs(cannon_config.phaseReward) do
            if not phase_reward[propId] then
                phase_reward[propId] = propCount
            else
                phase_reward[propId] = phase_reward[propId] + propCount
            end
        end

        ---! 修正最新炮倍
        new_gunrate = next_gunrate

        ---! 获取下一炮倍
        next_gunrate = CANNON_CONFIG:get_next_gunrate(next_gunrate)
    end

    local cost_props = {}
    for propId, propCount in pairs(unlock_item) do
        cost_props[#cost_props + 1] = { propId = propId, propCount = propCount, }
    end

    local drop_props = {}
    for propId, propCount in pairs(phase_reward) do
        drop_props[#drop_props + 1] = { propId = propId, propCount = propCount, }
    end

    ---! 返回最终炮倍，消耗物品，奖励物品
    return new_gunrate, cost_props, drop_props
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

CANNON_D = {}

---! 升级炮倍
function CANNON_D:upgrade_gunrate(player, gunrate)
    if gunrate > 1000 or gunrate <= player:get_max_gunrate() then
        local result = {}
        result.playerId = player:get_id()
        result.errorCode = UpgradeResult.kUpgradeResultErrorGunRate
        player:send_packet("MSGS2CUpgradeCannonResult", result)
        return
    end

    ---! 悬赏任务中，禁止升级炮倍
    ----todo:
    if false then
        local result = {}
        result.playerId = player:get_id()
        result.errorCode = UpgradeResult.kUpgradeResultInRewardTask
        player:send_packet("MSGS2CUpgradeCannonResult", result)
        return
    end

    ---! 获取升级相关信息
    local next_gunrate, cost_props, drop_props = get_upgrade_gunrate(player, gunrate)

    ---! 检查消耗物品是否充足
    for _, cost_prop in ipairs(cost_props) do repeat
        if player:get_prop_count(cost_prop.propId) >= cost_prop.propCount then
            break
        end

        local result = {}
        result.playerId = player:get_id()
        result.errorCode = cost_prop.propId == GamePropIds.kGamePropIdsCrystal and UpgradeResult.kUpgradeResultCrystalNoEnough or UpgradeResult.kUpgradeResultPropNoEnough
        player:send_packet("MSGS2CUpgradeCannonResult", result)
        return
    until true end

    ---! 消耗物品
    for _, cost_prop in ipairs(cost_props) do
        player:change_prop_count(cost_prop.propId, -cost_prop.propCount, PropChangeType.kPropChangeTypeUpgradeCannonCost)
    end

    ---! 修改炮倍
    player:set_max_gunrate(next_gunrate)

    ---! 给与奖励
    for _, drop_prop in pairs(drop_props) do
        player:change_prop_count(drop_prop.propId, drop_prop.propCount, PropChangeType.kPropChangeTypeUpgradeCannonDrop)
    end

    ---! 升级成功
    local result = {}
    result.playerId = player:get_id()
    result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    result.newGunRate = next_gunrate
    result.dropProps = drop_props
    result.costProps = cost_props
    result.errorCode = UpgradeResult.kUpgradeResultSuccess
    player:brocast_packet("MSGS2CUpgradeCannonResult", result)

    ---! 更新升级炮倍任务
    TASK_D:update_gunrate_task(player)

    local desk = player:get_desk()
    if desk and not ROOM_CONFIG:is_gunrate_validate(desk:get_grade(), next_gunrate) then
        ROOM_D:force_leave_desk(player, 1)
    end
end

---! 免费升级炮倍
function CANNON_D:upgrade_gunrate_free(player, gunrate)
    if gunrate > 1000 or gunrate <= player:get_max_gunrate() then
        return
    end

    ---! 获取升级相关信息
    local next_gunrate, _, drop_props = get_upgrade_gunrate(player, gunrate)

    ---! 修改炮倍
    player:set_max_gunrate(next_gunrate)

    ---! 给与奖励
    for _, drop_prop in pairs(drop_props) do
        player:change_prop_count(drop_prop.propId, drop_prop.propCount, PropChangeType.kPropChangeTypeUpgradeCannonDrop)
    end

    ---! 更新升级炮倍任务
    TASK_D:update_gunrate_task(player)

    ---! 升级成功
    local result = {}
    result.playerId = player:get_id()
    result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    result.newGunRate = next_gunrate
    result.dropProps = drop_props
    result.errorCode = UpgradeResult.kUpgradeResultSuccess
    player:brocast_packet("MSGS2CUpgradeCannonResult", result)
end

---! 通过完成新手任务，同步升级炮倍
function CANNON_D:upgrade_gunrate_finish_task(player, gunrate)
    if gunrate > 1000 or gunrate <= player:get_max_gunrate() then
        return
    end

    ---! 获取升级相关信息
    local next_gunrate, _, drop_props = get_upgrade_gunrate(player, gunrate)

    ---! 修改炮倍
    player:set_max_gunrate(next_gunrate)

    ---! 返回奖励物品
    return drop_props
end

---! 锻造炮台
function CANNON_D:forge_cannon(player, use_crystal_power)
    local max_gunrate = player:get_max_gunrate()
    if max_gunrate < 1000 then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        result.errorCode = ForgeResult.kForgeResultGunRateError
        player:send_packet("MSGS2CForge", result)
        return
    end

    ---! 根据当前最大炮倍，获取下一级锻造的炮倍
    local next_gunrate = CANNON_CONFIG:get_next_gunrate(max_gunrate)
    if not next_gunrate then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        result.errorCode = ForgeResult.kForgeResultGunRateError
        player:send_packet("MSGS2CForge", result)
        return
    end

    ---! 根据下一级炮倍获取锻造配置
    local cannon_config = CANNON_CONFIG:get_config_by_gunrate(next_gunrate)
    if not cannon_config then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        result.errorCode = ForgeResult.kForgeResultConfigNotFound
        player:send_packet("MSGS2CForge", result)
        return
    end

    ---! 判断水晶是否充足
    if player:get_prop_count(GamePropIds.kGamePropIdsCrystal) < cannon_config.unlock_gem then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        result.errorCode = ForgeResult.kForgeResultCrystalNoEnough
        player:send_packet("MSGS2CForge", result)
        return
    end

    ---! 判断道具是否充足
    for propId, propCount in ipairs(cannon_config.unlock_item) do
        if player:get_prop_count(propId) < propCount then
            local result = {}
            result.isSuccess = false
            result.playerId = player:get_id()
            result.errorCode = ForgeResult.kForgeResultPropNoEnough
            player:send_packet("MSGS2CForge", result)
            return
        end
    end

    ---! 判断结晶能量是否充足
    if use_crystal_power and player:get_prop_count(GamePropIds.kGamePropIdsCrystalEnerge) < cannon_config.succ_need then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        result.errorCode = ForgeResult.kForgeResultCrystalPowerNoEnough
        player:send_packet("MSGS2CForge", result)
        return
    end

    ---! 消耗集合
    local cost_props = {}

    ---! 掉落结合
    local drop_props = {}

    ---! 需要消耗的水晶
    cost_props[#cost_props + 1] = { propId = GamePropIds.kGamePropIdsCrystal, propCount = cannon_config.unlock_gem, }

    ---! 需要消耗的道具
    for propId, propCount in ipairs(cannon_config.unlock_item) do
        cost_props[#cost_props + 1] = { propId = propId, propCount = propCount, }
    end

    ---! 需要消耗的结晶能量
    if use_crystal_power then
        cost_props[#cost_props + 1] = { propId = GamePropIds.kGamePropIdsCrystalEnerge, propCount = cannon_config.succ_need, }
    end

    ---! 扣除所需消耗的材料
    for _, cost_prop in ipairs(cost_props) do
        player:change_prop_count(cost_prop.propId, -cost_prop.propCount, PropChangeType.kPropChangeTypeForgeCost)
    end

    ---! 按照配置的概率，随机锻造结果
    if not use_crystal_power and cannon_config.unlock_prob < math.random(100) then
        ---! 锻造失败获取的水晶能量
        local times = 0
        for _, propCount in ipairs(cannon_config.unlock_item) do
            times = times + propCount
        end

        ---! 计算掉落结晶能量的数量
        local enengy_crystal_count = FISH_SERVER_CONFIG:get_enengy_crystal_count(times)
        if enengy_crystal_count > 0 then
            drop_props[#drop_props + 1] = { propId = GamePropIds.kGamePropIdsCrystalEnerge, propCount = enengy_crystal_count, }
        end

        ---! 给与所有掉落的道具
        for _, drop_prop in ipairs(drop_props) do
            player:change_prop_count(drop_prop.propId, drop_prop.propCount, PropChangeType.kPropChangeTypeForgeDrop)
        end

        ---! 锻造失败
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        result.newCrystalPower = player:get_prop_count(GamePropIds.kGamePropIdsCrystalEnerge)
        result.crystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
        result.errorCode = ForgeResult.kForgeResultFailed
        player:send_packet("MSGS2CForge", result)

        ---! 广播消息
        local result = {}
        result.playerId = player:get_id()
        result.errorCode = UpgradeResult.kUpgradeResultFailed
        result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
        result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
        result.costProps = cost_props
        result.dropProps = drop_props
        player:brocast_packet("MSGS2CUpgradeCannonResult", result, player)
        return
    end

    ---! 更新最大炮倍
    player:set_max_gunrate(next_gunrate)

    ---! 解锁奖励道具
    for propId, propCount in pairs(cannon_config.phaseReward) do
        drop_props[#drop_props + 1] = { propId = GamePropIds.kGamePropIdsCrystalEnerge, propCount = enengy_crystal_count, }
    end

    ---! 给与奖励道具
    for _, drop_prop in ipairs(drop_props) do
        player:change_prop_count(drop_prop.propId, drop_prop.propCount, PropChangeType.kPropChangeTypeForgeDrop)
    end

    ---! 锻造成功
    local result = {}
    result.isSuccess = true
    result.playerId = player:get_id()
    result.newCrystalPower = player:get_prop_count(GamePropIds.kGamePropIdsCrystalEnerge)
    result.crystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    result.errorCode = ForgeResult.kForgeResultSuccess
    result.newGunRate = next_gunrate
    player:send_packet("MSGS2CForge", result)

    ---! 广播消息
    local result = {}
    result.playerId = player:get_id()
    result.errorCode = UpgradeResult.kUpgradeResultSuccess
    result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    result.newGunRate = next_gunrate
    result.costProps = cost_props
    result.dropProps = drop_props
    player:brocast_packet("MSGS2CUpgradeCannonResult", result, player)
end

---! 锻造分身
function CANNON_D:forge_seperate_cannon(player)
    ---! 获取当前分身类型
    local forge_config = FORGE_CONFIG:get_config(player:get_sep_guntype() + 1, player:get_max_gunrate())
    if not forge_config then
        -- 分身炮台配置不存在
        local result = {}
        result.errorCode = -2
        result.useType = use_type
        result.playerId = player:get_id()
        result.newSeperateGunType = player:get_sep_guntype()
        result.forgeFailCount = player:get_sep_guntype_forge_count()
        player:send_packet("MSGS2CSeperateGunForge", result)
        return
    end

    for propId, propCount in pairs(forge_cannon.props) do
        if player:get_prop_count(propId) < propCount then
            -- 道具不足
            local result = {}
            result.errorCode = -3
            result.useType = use_type
            result.playerId = player:get_id()
            result.newSeperateGunType = player:get_sep_guntype()
            result.forgeFailCount = player:get_sep_guntype_forge_count()
            player:send_packet("MSGS2CSeperateGunForge", result)
            return
        end
    end

    ---! 扣除道具
    for propId, propCount in pairs(forge_cannon.props) do
        player:change_prop_count(propId, propCount, PropChangeType.kPropChangeSeperateGunForge)
    end

    ---! 累加锻造次数
    player:add_sep_guntype_forge_count(1)

    ---! 锻造是否成功
    if not FORGE_CONFIG:get_forge_result(forge_config, player:get_sep_guntype_forge_count()) then
        -- 锻造失败
        local result = {}
        result.errorCode = -4
        result.useType = use_type
        result.playerId = player:get_id()
        result.newSeperateGunType = player:get_sep_guntype()
        result.forgeFailCount = player:get_sep_guntype_forge_count()
        player:send_packet("MSGS2CSeperateGunForge", result)
        return
    end

    ---! 清空锻造次数
    player:del_sep_guntype_forge_count()

    ---! 设置分身类型
    player:set_sep_guntype(sep_guntype + 1)

    ---! 锻造成功
    local result = {}
    result.useType = use_type
    result.playerId = player:get_id()
    result.newSeperateGunType = player:get_sep_guntype()
    result.forgeFailCount = player:get_sep_guntype_forge_count()
    player:send_packet("MSGS2CSeperateGunForge", result)
end

---! 使用炮台
function CANNON_D:use_cannon(player, prop_id, use_type)
    ---! 查找对应炮台的相关配置
    local item_config = ITEM_CONFIG:get_config_by_id(prop_id)
    if not item_config then
        local result = {}
        result.isSuccess = false
        result.useType = use_type
        result.playerID = player:get_id()
        result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
        player:send_packet("MSGS2CUsePropCannon", result)
        return
    end

    ---! 判断是否已经持有对应道具
    local senior_prop = player:get_senior_prop_by_id(prop_id)
    if not senior_prop then
        ---! 尝试购买道具
        if use_type == 0 then
            local result = {}
            result.isSuccess = false
            result.useType = use_type
            result.playerID = player:get_id()
            result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
            player:send_packet("MSGS2CUsePropCannon", result)
            return
        end

        ---! 判断购买费用
        if player:get_prop_count(item_config.price_type) < item_config.price_value then
            local result = {}
            result.isSuccess = false
            result.useType = use_type
            result.playerID = player:get_id()
            result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
            player:send_packet("MSGS2CUsePropCannon", result)
            return
        end

        ---! 扣除消耗
        player:change_prop_count(item_config.price_type, - item_config.price_value, PropChangeType.kPropChangeTypeCannonUse)

        ---! 给与道具
        senior_prop = player:add_senior_prop_quick(prop_id)
    end

    ---! 使用成功
    local result = {}
    result.isSuccess = true
    result.useType = use_type
    result.playerID = player:get_id()
    result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    player:brocast_packet("MSGS2CUsePropCannon", result)
end

---! 分解炮台
function CANNON_D:decompose_cannon(player, prop_id)
    local item_config = ITEM_CONFIG:get_config_by_id(prop_id)
    if not item_config then
        local result = {}
        result.isSuccess = false
        result.newCrystalPower = player:get_prop_count(GamePropIds.kGamePropIdsCrystalEnerge)
        player:send_packet("MSGS2CDecompose", result)
        return
    end

    if prop_id < GamePropIds.kGamePropIdsFrameCrystal or prop_id > GamePropIds.kGamePropIdsEarthCrystal then
        local result = {}
        result.isSuccess = false
        result.newCrystalPower = player:get_prop_count(GamePropIds.kGamePropIdsCrystalEnerge)
        player:send_packet("MSGS2CDecompose", result)
        return
    end

    if player:get_prop_count(prop_id) < FISH_SERVER_CONFIG.decomposeCrystalRequire then
        local result = {}
        result.isSuccess = false
        result.newCrystalPower = player:get_prop_count(GamePropIds.kGamePropIdsCrystalEnerge)
        player:send_packet("MSGS2CDecompose", result)
        return
    end

    local enengy_crystal_count = FISH_SERVER_CONFIG:get_enengy_crystal_count(1)
    if enengy_crystal_count <= 0 then
        local result = {}
        result.isSuccess = false
        result.newCrystalPower = player:get_prop_count(GamePropIds.kGamePropIdsCrystalEnerge)
        player:send_packet("MSGS2CDecompose", result)
        return
    end

    ---! 扣除目标道具
    player:change_prop_count(prop_id, -FISH_SERVER_CONFIG.decomposeCrystalRequire, PropChangeType.kPropChangeTypeDecomposeCost)

    ---! 给与分解材料
    player:change_prop_count(GamePropIds.kGamePropIdsCrystalEnerge, enengy_crystal_count, PropChangeType.kPropChangeTypeDecomposeDrop)

    ---! 分解成功
    local result = {}
    result.isSuccess = true
    result.newCrystalPower = player:get_prop_count(GamePropIds.kGamePropIdsCrystalEnerge)
    player:send_packet("MSGS2CDecompose", result)
end

---! 切换炮倍
function CANNON_D:change_gunrate(player, new_gunrate)
    ---! 检查炮倍是否有效
    local config = CANNON_CONFIG:get_config_by_gunrate(new_gunrate)
    if not config then
        return
    end

    if new_gunrate ~= player:get_cur_gunrate() then
        ---! 有效炮倍，切换新炮倍
        player:set_cur_gunrate(new_gunrate)
    end

    ---! 广播切换成功
    local result = {}
    result.playerId = player:get_id()
    result.newGunRate = new_gunrate
    player:brocast_packet("MSGS2CGunRateChange", result)
end

---! 切换炮台类型
function CANNON_D:change_guntype(player, new_guntype)
    if new_guntype <= 0 then
        return
    end

    if new_guntype > 1 then
        local vip_config = VIP_CONFIG:get_config_by_vip_exp(player:get_vip_exp())
        if not vip_config then
            return
        end

        ---! 超过当前VIP等级能使用的 再判断是否限时炮台道具有
        if vip_config.cannon_type < new_guntype and not MONTHCARD_D:is_use_remain_cannon(player, new_guntype) then
            -- 当前VIP等级不够且没有使用限时炮台
            local result = {}
            result.isSuccess = false
            result.playerId = player:get_id()
            result.newGunType = new_guntype
            player:send_packet("MSGS2CGunTpyeChange", result)
            return
        end
    end

    ---! 设置炮台类型
    player:set_guntype(new_guntype)

    ---! 切换成功
    local result = {}
    result.isSuccess = true
    result.playerId = player:get_id()
    result.newGunType = new_guntype
    player:brocast_packet("MSGS2CGunTpyeChange", result)
end
