local math_max = math.max
local math_random = math.random

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
---! 破产后，增加补贴库的概率（万分比）
local function get_alm_allowance_percent()
    return 0
end

---! 破产后，补贴库增加倍数
local function get_alm_allowance_rate()
    return 20
end

---! 破产后，增加补贴库值
local function add_allowance_rate(player)
    local percent = get_alm_allowance_percent()
    if percent <= 0 then
        return
    end

    if math_random(10000) < percent then
        player:add_allowance_rate(player:get_max_gunrate() * get_alm_allowance_rate())
    end
end

---! 获取指定次数可领取的鱼币数量
local function get_alm_fishicon(alm_config, gunrate, times)
    if gunrate <= alm_config.alms_gun_level then
        return gunrate * alm_config.alms_gun_multiply
    end

    if not alm_config.alms_reward_array then
        return 0
    end

    local alms_reward = alms_reward_array[times]
    if not alms_reward then
        return 0
    end

    return alms_reward[GamePropIds.kGamePropIdsFishIcon] or 0
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
ALM_D = {}

---! 检查破产
function ALM_D:check_bankup(player)
    local desk = player:get_desk()
    if not desk then
        return
    end

    -- 若鱼币不为0，退出
    if player:get_prop_count(GamePropIds.kGamePropIdsFishIcon) > 0 then
        return
    end

    ---! 获取玩家ID
    local player_id = player:get_id()

    -- 若剩余子弹不为0，退出
    if desk:get_player_bullet_count(player_id) > 0 then
        return
    end

    ---! 记录玩家破产
    player:record_backup_time()

    ---! 累加补贴库值
    add_allowance_rate(player)

    ---! 发送破产消息
    local result = {}
    result.playerId = player_id
    desk:brocast_packet("MSGC2SBankup", result)
end

---! 发送救济金信息
function ALM_D:send_alm_info(player)
    local alm_config = ALM_CONFIG:get_config_by_vip_level(player:get_vip_grade())
    if not alm_config then
        local result = {}
        result.cd = -1
        result.leftCount = 0
        result.totalCount = 0
        player:send_packet("MSGS2CAlmInfo", result)
        return
    end

    ---! 当前可获得的救济金次数
    local total_count = #alm_config.alms_cd_array

    ---! 当前已领取的救济金次数
    local today_count = player:get_today_count()

    ---! 当前可获得的救济金剩余次数
    local left_count = total_count - today_count
    if left_count <= 0 then
        local result = {}
        result.cd = -1
        result.leftCount = left_count
        result.totalCount = total_count
        player:send_packet("MSGS2CAlmInfo", result)
        return
    end

    ---! 当前可获得的救济金的等待时长
    local alm_cd = math_max(0, alm_config.alms_cd_array[today_count + 1] + player:get_last_backup_time() - os.time())

    ---! 发送消息
    local result = {}
    result.cd = alm_cd
    result.leftCount = left_count
    result.totalCount = total_count
    player:send_packet("MSGS2CAlmInfo", result)
end

---! 申请救济金
function ALM_D:apply_alm(player)
    local alm_config = ALM_CONFIG:get_config_by_vip_level(player:get_vip_grade())
    if not alm_config then
        return
    end

    ---! 获取当前玩家Id
    local player_id = player:get_id()

    ---! 获取当前剩余鱼币
    local fishicon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)

    ---! 当前可获得的救济金次数
    local total_count = #alm_config.alms_cd_array

    ---! 当前已领取的救济金次数
    local today_count = player:get_today_count()

    ---! 当前可获得的救济金剩余次数
    local left_count = total_count - today_count
    if left_count <= 0 then
        ---! 已经使用全部救济金机会，失败
        local result = {}
        result.success = false
        result.player_id = player_id
        result.lectCount = left_count
        result.totalCount = total_count
        result.newFishIcon = fishicon
        player:send_packet("MSGS2CApplyAlmResult", result)
        return
    end

    if fishicon > 0 then
        ---! 非破产状态，禁止申请救济金，失败
        local result = {}
        result.success = false
        result.player_id = player_id
        result.lectCount = left_count
        result.totalCount = total_count
        result.newFishIcon = fishicon
        player:send_packet("MSGS2CApplyAlmResult", result)
        return
    end

    local desk = player:get_desk()
    if desk and desk:get_player_bullet_count(player_id) > 0 then
        ---! 还有子弹，禁止申请救济金，失败
        local result = {}
        result.success = false
        result.player_id = player_id
        result.lectCount = left_count
        result.totalCount = total_count
        result.newFishIcon = fishicon
        player:send_packet("MSGS2CApplyAlmResult", result)
        return
    end

    ---! 累加当日领取救济金次数
    player:add_today_count(1)

    ---! 重新获取领取救济金次数
    today_count = player:get_today_count()

    ---! 增加当前救济金获取的鱼币
    local alm_fishicon = get_alm_fishicon(alm_config, player:get_max_gunrate(), today_count)
    if alm_fishicon > 0 then
        player:change_prop_count(GamePropIds.kGamePropIdsFishIcon, alm_fishicon, PropChangeType.kPropChangeTypeAlm)
    end

    ---! 广播消息
    local result = {}
    result.success = true
    result.playerId = player_id
    result.lectCount = total_count - today_count
    result.totalCount = total_count
    result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    player:brocast_packet("MSGS2CApplyAlmResult", result)
end
