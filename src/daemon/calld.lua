local uuid = require "global.common.uuid"

local kCallFishFailTypeNone       = 0
local kCallFishFailTypeConfigLost = 1
local kCallFishFailTypeFishIsFull = 2
local kCallFishFailTypeNoItem     = 3
local kCallFishFailTypeNoCrystal  = 4
local kCallFishFailTypeFishError  = 5

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
CALL_D = {}

function CALL_D:call_fish(player, use_type)
    local desk = player:get_desk()
    if not desk then
        return
    end

    local item_config = ITEM_CONFIG:get_config_by_id(GamePropIds.kGamePropIdsCallFish)
    if not item_config then
        local result = {}
        result.isSuccess = false
        result.useType = use_type
        result.failType = kCallFishFailTypeConfigLost
        player:send_packet("MSGS2CCallFish", result)
        return
    end

    if use_type == 0 then
        -- 使用道具
        if player:get_prop_count(GamePropIds.kGamePropIdsCallFish) < 1 then
            local result = {}
            result.isSuccess = false
            result.useType = use_type
            result.failType = kCallFishFailTypeNoItem
            player:send_packet("MSGS2CCallFish", result)
            return
        end
    else
        -- 使用水晶
        if player:get_prop_count(GamePropIds.kGamePropIdsCrystal) < item_config.price_value then
            local result = {}
            result.isSuccess = false
            result.useType = use_type
            result.failType = kCallFishFailTypeNoCrystal
            player:send_packet("MSGS2CCallFish", result)
            return
        end
    end

    ---!获取可见的召唤鱼
    local callfishes = desk:get_visable_callfishes()

    ---! 召唤鱼个数大于配置的最大个数
    if #callfishes >= CALLFISH_CONFIG:get_callfish_max_count(desk:get_grade()) then
        local result = {}
        result.isSuccess = false
        result.useType = use_type
        result.failType = kCallFishFailTypeFishIsFull
        player:send_packet("MSGS2CCallFish", result)
        return
    end

    ---! 获取玩家的会员等级
    local vip_grade = player:get_vip_grade()

    ---! 根据vip等级获取召唤出来的鱼类型
    local fish_id = CALLFISH_CONFIG:get_fish_id(vip_grade)

    ---! 获取鱼的类型信息
    local fish_type = FISH_CONFIG:get_config_by_id(fish_id)
    if not fish_type then
        local result = {}
        result.isSuccess = false
        result.useType = use_type
        result.failType = kCallFishFailTypeFishError
        player:send_packet("MSGS2CCallFish", result)
        return
    end

    if use_type == 0 then
        -- 扣除道具
        player:change_prop_count(GamePropIds.kGamePropIdsCallFish, -1, PropChangeType.kPropChangeTypeUseProp)
    else
        -- 扣除水晶
        player:change_prop_count(GamePropIds.kGamePropIdsCrystal, -item_config.price_value, PropChangeType.kPropChangeTypeUseCrystalWithCallFish)
    end

    ---! 获取玩家Id
    local player_id = player:get_id()

    ---! 通过配置，随机获取召唤鱼的路径Id
    local path_id = CALLFISH_CONFIG:get_callfish_path(vip_grade)

    ---! 获取当前游戏帧数
    local frame_count = desk:get_frame_count()

    ---! 随机生成召唤Id
    local callfish_id = uuid.gen()

    ---! 将对象加入召唤鱼
    desk:add_callfish(player_id, path_id, fish_id, frame_count, callfish_id)

    ---! 更新使用技能任务
    local skill_config = SKILL_CONFIG:get_config_by_itemid(GamePropIds.kGamePropIdsCallFish)
    if skill_config then
        TASK_D:update_use_skill_task(player, skill_config.skill_id)
    end

    local result = {}
    result.isSuccess = true
    result.useType = use_type
    result.playerId = player_id
    result.pathId = path_id
    result.fishId = fish_id
    result.frameId = frame_count
    result.callFishId = callfish_id
    result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    player:brocast_packet("MSGS2CCallFish", result)
end
