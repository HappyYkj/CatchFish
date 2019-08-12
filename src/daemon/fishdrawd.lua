-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
FISH_DRAW_D = {}

---! 累加奖池
function FISH_DRAW_D:generate_reward_rate(player, fishes, gunrate, fishicon)
    local drop_draw_rate = 0
    for _, fish in ipairs(fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(fish.fishId)
        if not fish_type then
            break
        end

        if not fish_type:isRewardFish() then
            -- 不是奖金鱼，跳过
            break
        end

        -- 增加当日击杀奖金鱼数量
        player:add_kill_reward_fish(1)

        -- 百分之十的价值投入奖池
        drop_draw_rate = drop_draw_rate + 0.1 * fish_type.true_score * gunrate
    until true end

    if drop_draw_rate > 0 then
        ---! 鱼币取整
        drop_draw_rate = math.floor(drop_draw_rate)

        ---! 增加奖池
        player:add_draw_rate(drop_draw_rate)

        ---! 扣除鱼币
        fishicon = fishicon - drop_draw_rate

        ---! 广播消息
        local result = {}
        result.rewardRate = player:get_draw_rate()
        result.killRewardFishInDay = player:get_kill_reward_fish()
        result.drawRequireRewardFishCount = FISH_SERVER_CONFIG:get_fish_draw_require(player:get_draw_count())
        player:send_packet("MSGS2CDrawStatusChange", result)
    end

    ---! 返回剩余鱼币
    return fishicon 
end

---! 游戏内抽奖
function FISH_DRAW_D:draw(player, msgData)
    ---! 奖池不足，抽奖失败
    if player:get_kill_reward_fish() < FISH_SERVER_CONFIG:get_fish_draw_require(player:get_draw_count()) then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        player:send_packet("MSGS2CDrawResult", result)
        return
    end

    ---! 获取抽奖配置
    local draw_rate = player:get_draw_rate()
    local fishticket = player:get_prop_count(GamePropIds.kGamePropFishTicket)
    local crystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    local grade = player:get_grade()
    local reward_config = REWARD_CONFIG:get_config_by_draw_rate(draw_rate, fishticket, crystal, grade)
    if not reward_config then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        player:send_packet("MSGS2CDrawResult", result)
        return
    end

    ---! 生成抽奖结果
    local propId, propCount = REWARD_CONFIG:get_item_by_config(reward_config)
    if not propId or not propCount then
        local result = {}
        result.isSuccess = false
        result.playerId = player:get_id()
        player:send_packet("MSGS2CDrawResult", result)
        return
    end

    ---! 清空当前奖池
    player:del_draw_rate()

    ---! 清空击杀次数
    player:del_kill_reward_fish()

    ---! 累加抽奖次数
    player:add_draw_count(1)

    ---! 发放抽奖奖励
    local props = {}
    local seniorProps = {}
    local item_config = ITEM_CONFIG:get_config_by_id(propId)
    if item_config then
        if not item_config.if_senior then
            player:change_prop_count(propId, propCount, PropRecieveType.kPropChangeTypeGameDraw)
            props[#props + 1] = { propId = propId, propCount = propCount, }
        else
            for idx = 1, propCount do 
                seniorProps[#seniorProps + 1] = player:add_senior_prop_quick(propId)
            end
        end
    end

    ---! 通知抽奖结果
    local result = {}
    result.isSuccess = true
    result.playerId = player:get_id()
    result.drawRequireRewardFishCount = FISH_SERVER_CONFIG:get_fish_draw_require(player:get_draw_count())
    result.killRewardFishInDay = player:get_kill_reward_fish()
    result.rewardRate = player:get_draw_rate()
    result.props = props
    result.seniorProps = seniorProps
    player:brocast_packet("MSGS2CDrawResult", result)
end

---! 刷新奖池
function FISH_DRAW_D:send_fish_reward(player)
    local result = {}
    result.playerId = player:get_id()
    result.drawRequireRewardFishCount = FISH_SERVER_CONFIG:get_fish_draw_require(player:get_draw_count())
    result.killRewardFishInDay = player:get_kill_reward_fish()
    result.rewardRate = player:get_draw_rate()
    player:send_packet("MSGS2CDrawStatusChange", result)
end
