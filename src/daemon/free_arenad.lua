---! 比赛分组编号
local arena_group_id = 0

---! 报名玩家列表
local signup_players = {}

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
---! 获取所有报名玩家
local function get_match_signup_players(signup_group)
    local players = {}
    for player_id, _ in pairs(signup_group) do
        local player = USER_D:find_user(player_id)
        if player then
            players[#players + 1] = player
        end
    end
    return players
end

---! 广播所有报名玩家
local function brocast_signup_players(signup_group, msg_type, msg_data)
    for player_id, _ in pairs(signup_group) do
        local player = USER_D:find_user(player_id)
        if player then
            player:send_packet(msg_type, msg_data)
        end
    end
end

---! 构建当前排名信息
local function build_match_rank(players, match_config)
    ---! 获取排名信息
    local rank_list = {}
    for index, player in ipairs(players) do
        local rank = {}
        rank.playerId = player:get_id()
        rank.nickName = player:get_nick_name()
        rank.score = player:query_temp("free_arena", "match_score") or 0
        rank.bulletCount = player:query_temp("free_arena", "cur_bullet_num") or 0
        rank_list[index] = rank
    end

    ---! 根据积分排序
    table.sort(rank_list, function(rank1, rank2)
        return rank1.score > rank2.score
    end)

    ---! 设置排名奖励
    for _, reward in ipairs(match_config.reward) do repeat
        local rank = rank_list[reward.rank]
        if not rank then
            break
        end

        if rank.score <= 0 then
            break
        end

        local prop = {}
        prop.propId = reward.prop_id
        prop.propCount = reward.prop_count
        rank.props = { prop }
    until true end

    ---! 返回排名信息
    return rank_list
end

---! 广播当前排名信息
local function brocast_match_rank(players, match_config)
    local result = {}
    result.rank = build_match_rank(players, match_config)
    for _, player in ipairs(players) do
        player:send_packet("MSGS2CFreeArenaRank", result)
    end
end

---! 获取比赛报名分组
local function get_match_signup_group()
    local signup_group = signup_players[arena_group_id]
    if not signup_group then
        signup_players[arena_group_id] = {}
    end
    return signup_players[arena_group_id]
end

---! 免费赛重连处理
local function free_arena_reconnect(player)
end

---! 尝试开启免费赛
local function start_free_arena(signup_group, arena_type)
    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        ---! 配置未找到
        local result = {}
        result.errorCode = 1
        brocast_signup_players(signup_group, "MSGS2CFreeArenaStart", result)

        ----todo:
        ---! 解散当前报名分组
        return
    end

    local players = get_match_signup_players(signup_group)
    if #players < match_config.num then
        ---! 报名人数不足
        local result = {}
        result.errorCode = 2
        brocast_signup_players(signup_group, "MSGS2CFreeArenaStart", result)

        ----todo:
        ---! 解散当前报名分组
        return
    end

    for _, player in ipairs(players) do repeat
        if not player:get_desk() then
            break
        end

        ---! 正在游戏中
        local result = {}
        result.errorCode = 3
        brocast_signup_players(signup_group, "MSGS2CFreeArenaStart", result)

        ----todo:
        ---! 异常情况，需要清理分组中的异常玩家
        return
    until true end

    ---! 分配比赛房间
    local desk = ROOM_D:assign_match_desk(players, arena_type)
    if not desk then
        ---! 房间分配失败
        local result = {}
        result.errorCode = 4
        brocast_signup_players(signup_group, "MSGS2CFreeArenaStart", result)

        ----todo:
        ---! 解散当前报名分组
        return
    end

    ---! 自增分组编号
    arena_group_id = arena_group_id + 1

    ---! 记录分组编号
    desk:set_temp("arena_group_id", arena_group_id)

    ---! 设置房间等级
    desk:set_grade(ROOM_CONFIG.FREE_ARENA_ROOM_TYPE)

    for _, player in ipairs(players) do repeat
        ---! 累计报名次数
        if match_config.maxnum > 0 then
            player:add_match_signup_count(arena_type)
        end

        ---! 设置基本信息
        player:set_temp("free_arena", {
            match_score = 0,                            ---! 当前比赛积分
            cur_bullet_num = match_config.bulletnum,    ---! 当前子弹数量
            max_bullet_num = match_config.bulletnum,    ---! 最大子弹数量
            online_status = 1,                          ---! 当前在线状态
        })

        ---! 设置重连回调
        player:set_temp("reconnect_callback", function(player)
            ---! 延迟调用
            THREAD_D:create(function()
                ---! 发送通知玩家开始游戏的消息
                local result = {}
                result.errorCode = 0
                result.reconnect = true
                player:send_packet("MSGS2CFreeArenaStart", result)
            end)
        end)
    until true end

    ---! 通知进入游戏
    local result = {}
    result.errorCode = 0
    result.reconnect = false
    brocast_signup_players(signup_group, "MSGS2CFreeArenaStart", result)
end

---! 尝试结束免费赛
local function finish_free_arena(players, match_config)
    ---! 获取排名信息
    local rank_list = build_match_rank(players, match_config)

    ---! 发放奖励
    for _, rank in ipairs(rank_list) do repeat
        local player = USER_D:find_user(rank.playerId)
        if not player then
            break
        end

        if rank.score > 0 and rank.props then
            for _, prop in ipairs(rank.props) do
                player:change_prop_count(prop.propId, prop.propCount, ShareTypes.kShareTypesFishIcon)
            end
        end

        ---! 广播消息
        local result = {}
        result.props = rank.props or {}
        player:send_packet("MSGS2CFreeArenaComplete", result)
    until true end
end

---! 销毁当前免费赛
local function destory_free_arena(desk)
    ---! 获取定时器
    local finish_timer_id = desk:query_temp("finish_timer_id")
    if finish_timer_id then
        desk:delete_temp("finish_timer_id")

        ---! 注销定时器
        TIMER_D:cancel_timer(finish_timer_id)
    end

    ---! 销毁当前对象
    desk:destory_delay(3)
end

---! 获取当前玩家使用的炮倍
local function get_match_player_gunrate(cur_bullet_num)
    return FISH_SERVER_CONFIG:get_free_arena_gunrate(cur_bullet_num)
end

---! 生成免费赛的玩家信息
local function generate_all_player_info(desk)
    local all_player_info = {}
    for _, player in ipairs(desk:get_players()) do
        local free_arena_map = player:query_temp("free_arena")
        if not free_arena_map then
            free_arena_map = player:set_temp("free_arena", {})
        end

        ---! 获取子弹与积分信息
        local cur_bullet_num = free_arena_map.cur_bullet_num or 0
        local max_bullet_num = free_arena_map.max_bullet_num or 0
        local match_score = free_arena_map.match_score or 0

        ---! 添加玩家基本信息
        local player_info = {}
        player_info.playerId = player:get_id()
        player_info.nickName = player:get_nick_name()
        player_info.headFrameId = 0
        player_info.fishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
        player_info.crystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
        player_info.vipExp = player:get_vip_exp()
        player_info.chairId = player:get_chair_id()
        player_info.gunType = player:get_guntype()
        player_info.gunRate = get_match_player_gunrate(cur_bullet_num)
        player_info.bulletCount = cur_bullet_num
        player_info.maxBulletCount = max_bullet_num
        player_info.score = match_score
        all_player_info[#all_player_info + 1] = player_info
    end
    return all_player_info
end

---! 检查免费赛状态
local function check_free_arena_status(desk)
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
FREE_ARENA_D = {}

---! 报名免费赛
function FREE_ARENA_D:signup(player, arena_type, signup_type)
    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        -- 配置未找到
        local result = {}
        result.errorCode = 1
        result.arenaType = arena_type
        result.signupType = signup_type
        player:send_packet("MSGS2CFreeArenaSignUp", result)
        return
    end

    if player:get_max_gunrate() < match_config.cannon then
        -- 炮倍不满足
        local result = {}
        result.errorCode = 2
        result.arenaType = arena_type
        result.signupType = signup_type
        player:send_packet("MSGS2CFreeArenaSignUp", result)
        return
    end

    local player_id = player:get_id()
    local signup_group = get_match_signup_group()
    if signup_group[player_id] then
        -- 在游戏中
        local result = {}
        result.errorCode = 3
        result.arenaType = arena_type
        result.signupType = signup_type
        player:send_packet("MSGS2CFreeArenaSignUp", result)
        return
    end

    if match_config.maxnum > 0 and player:get_match_signup_count(arena_type) >= match_config.maxnum then
        -- 达到报名次数上限
        local result = {}
        result.errorCode = 4
        result.arenaType = arena_type
        result.signupType = signup_type
        player:send_packet("MSGS2CFreeArenaSignUp", result)
        return
    end

    if signup_type == 2 then
        ---! 通过广告的方式报名
        local share_config = SHARE_CONFIG:get_config_by_type(match_config.freeshare_id)
        if not share_config then
            ---! 广告配置不存在
            local result = {}
            result.errorCode = 5
            result.arenaType = arena_type
            result.signupType = signup_type
            player:send_packet("MSGS2CFreeArenaSignUp", result)
            return
        end

        if player:get_match_share_count(arena_type) >= share_config.awardnum then
            -- 达到广告次数上限
            local result = {}
            result.errorCode = 6
            result.arenaType = arena_type
            result.signupType = signup_type
            player:send_packet("MSGS2CFreeArenaSignUp", result)
            return
        end
    else
        ---! 通过默认的方式报名
        for prop_id, prop_count in pairs(match_config.cost) do repeat
            if player:get_prop_count(prop_id) >= prop_count then
                break
            end

            -- 道具不满足
            local result = {}
            result.errorCode = 7
            result.arenaType = arena_type
            result.signupType = signup_type
            player:send_packet("MSGS2CFreeArenaSignUp", result)
            return
        until true end
    end

    ---! 扣除报名费用
    local cost_props = {}
    if signup_type == 2 then
        ---! 通过广告的方式报名
        player:add_match_share_count(arena_type)

        ---! 登记玩家信息
        local signup = {}
        signup.share_count = 1
        signup_group[player_id] = signup
    else
        ---! 通过默认的方式报名
        for prop_id, prop_count in pairs(match_config.cost) do
            ---! 扣除费用
            player:change_prop_count(prop_id, -prop_count, PropChangeType.kPropChangePayFreetime)

            ---! 消费记录
            cost_props[#cost_props + 1] = { propId = prop_id, propCount = prop_count, }
        end

        ---! 登记玩家信息
        local signup = {}
        signup.cost_props = cost_props
        signup_group[player_id] = signup
    end

    ---! 设置断线回调
    player:set_temp("reconnect_callback", function(player)
        ---! 延迟调用
        THREAD_D:create(function()
            ---! 通知报名成功
            local result = {}
            result.errorCode = 0
            result.arenaType = arena_type
            result.signupType = 3
            player:send_packet("MSGS2CFreeArenaSignUp", result)

            ---! 刷新报名信息
            FREE_ARENA_D:send_signup_info(player, arena_type)
        end)
    end)

    ---! 通知报名成功
    local result = {}
    result.errorCode = 0
    result.arenaType = arena_type
    result.signupType = signup_type
    result.props = cost_props
    player:send_packet("MSGS2CFreeArenaSignUp", result)

    ---! 刷新报名信息
    FREE_ARENA_D:send_signup_info(player, arena_type)

    ---! 尝试开启比赛
    if table.len(signup_group) >= match_config.num then
        start_free_arena(signup_group, arena_type)
    end
end

---! 取消报名免费赛
function FREE_ARENA_D:cancel_signup(player, arena_type)
    local player_id = player:get_id()

    ---! 获取当前报名分组
    local signup_group = get_match_signup_group()

    ---! 获取玩家报名信息
    local signup = signup_group[player_id]
    if not signup then
        -- 在游戏中
        local result = {}
        result.errorCode = 1
        result.arenaType = arena_type
        player:send_packet("MSGS2CFreeArenaCancelSignup", result)
        return
    end

    ---! 移除断线回调
    player:delete_temp("reconnect_callback")

    ---! 移除玩家报名信息
    signup_group[player_id] = nil

    ---! 退还玩家报名费用
    if signup.cost_props then
        for _, prop in ipairs(signup.cost_props) do
            player:change_prop_count(prop.propId, prop.propCount, PropChangeType.kPropChangePayFreetime)
        end
    end

    ---! 刷新报名信息
    FREE_ARENA_D:send_signup_info(player, arena_type)

    ---! 通知取消报名成功
    local result = {}
    result.errorCode = 0
    result.arenaType = arena_type
    result.props = signup.cost_props
    player:send_packet("MSGS2CFreeArenaCancelSignup", result)
end

---! 获取报名信息
function FREE_ARENA_D:send_signup_info(player, arena_type)
    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        -- 配置未找到
        local result = {}
        result.errorCode = 1
        result.arenaType = arena_type
        player:send_packet("MSGS2CFreeArenaSignUp", result)
        return
    end

    local share_config = SHARE_CONFIG:get_config_by_type(match_config.freeshare_id)
    if not share_config then
        -- 配置未找到
        local result = {}
        result.errorCode = 1
        result.arenaType = arena_type
        player:send_packet("MSGS2CFreeArenaSignUp", result)
        return
    end

    local players = get_match_signup_players(get_match_signup_group())

    local result = {}
    result.playerCount = #players
    result.signupCount = match_config.maxnum - player:get_match_signup_count(arena_type)
    result.shareCount = share_config.awardnum - player:get_match_share_count(arena_type)
    player:send_packet("MSGC2SFreeArenaSignupInfo", result)
end

---! 准备就绪
function FREE_ARENA_D:go_ready(player)
    local desk = player:get_desk()
    if not desk then
        return
    end

    local arena_type = MATCH_CONFIG.FREE_ARENA_MATCH_ID
    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        return
    end

    ---! 是否是第一个玩家
    if ROOM_D:check_first_player(player) then
        ---! 设置比赛开始时间
        local start_time = os.time()
        desk:set_temp("start_time", start_time)

        ---! 计算比赛结束时间
        local end_time = start_time + match_config.time
        desk:set_temp("end_time", end_time)

        ---! 启动结束定时器
        desk:set_temp("finish_timer_id", TIMER_D:start_timer(1, function() FREE_ARENA_D:check_status(desk, arena_type) end))
    end

    ---! 获取当前桌子帧数
    local frame_count = desk:get_frame_count()

    ---! 获取当前玩家对象
    local players = desk:get_players()

    ---! 发送当前子弹信息
    for _, other in ipairs(players) do repeat
        local bullets = desk:get_player_bullets(other:get_id())
        if #bullets <= 0 then
            break
        end

        local result = {}
        result.bullets = bullets
        player:send_packet("MSGS2CBulletStatus", result)
    until true end

    ---! 获取比赛开始时间
    local start_time = desk:query_temp("start_time")

    ---! 获取比赛结束时间
    local end_time = desk:query_temp("end_time")

    ---! 通知准备就绪
    local result = {}
    result.startSecond = start_time
    result.endSecond = end_time
    result.frameId = frame_count
    result.timelineIndex = desk:get_timeline_index_ex()
    result.killedFishes = desk:get_killed_fishes_on_frame(frame_count)
    result.calledFishes = desk:get_visable_callfishes()
    result.playerInfo = generate_all_player_info(desk)
    player:send_packet("MSGS2CFreeArenaReady", result)

    ---! 发送排行榜信息
    local result = {}
    result.rank = build_match_rank(players, match_config)
    player:send_packet("MSGS2CFreeArenaRank", result)
end

---! 射击子弹
function FREE_ARENA_D:shoot_bullet(player, data)
    local desk = player:get_desk()
    if not desk then
        return
    end

    ---! 获取当前时间
    local now_time = os.time()

    ---! 获取比赛开始时间
    local start_time = desk:query_temp("start_time")
    if not start_time or now_time < start_time then
        return
    end

    ---! 获取比赛结束时间
    local end_time = desk:query_temp("end_time")
    if not end_time or now_time >= end_time then
        return
    end

    ---! 获取当前房间配置
    local room_config = ROOM_CONFIG:get_config_by_roomtype(desk:get_grade())
    if not room_config then
        return
    end

    ---! 获取玩家ID
    local playerId = player:get_id()

    ---! 判断子弹数量
    local bullets = desk:get_player_bullets(playerId)
    if table.len(bullets) >= room_config.max_bullet then
        local result = {}
        result.validate = false
        result.bulletId = data.bulletId
        player:send_packet("MSGS2CFreeArenaShoot", result)
        return
    end

    ---! 获取剩余子弹数量
    local cur_bullet_num = player:query_temp("free_arena", "cur_bullet_num") or 0
    if cur_bullet_num <= 0 then
        local result = {}
        result.validate = false
        result.bulletId = data.bulletId
        player:send_packet("MSGS2CFreeArenaShoot", result)
        return
    end

    ---! 扣除射击次数
    local new_bullet_num = player:set_temp("free_arena", "cur_bullet_num", cur_bullet_num - 1)

    ---! 记录当前子弹
    local bullet = {}
    bullet.playerId = playerId
    bullet.bulletId = data.bulletId
    bullet.angle = data.angle
    bullet.timelineId = data.timelineId
    bullet.fishArrayId = data.fishArrayId
    bullet.gunRate = get_match_player_gunrate(cur_bullet_num)
    desk:add_bullet(bullet)

    ---! 广播射击消息
    local result = {}
    result.validate = true
    result.playerId = bullet.playerId
    result.bulletId = bullet.bulletId
    result.angle = bullet.angle
    result.timelineId = bullet.timelineId
    result.fishArrayId = bullet.fishArrayId
    result.bulletCount = new_bullet_num
    result.gunRate = bullet.gunRate
    player:brocast_packet("MSGS2CFreeArenaShoot", result)
end

---! 碰撞子弹
function FREE_ARENA_D:hit_bullet(player, data)
    local desk = player:get_desk()
    if not desk then
        return
    end

    ---! 获取玩家ID
    local playerId = player:get_id()

    ---! 查找子弹
    local bullet = desk:get_bullet(playerId, data.bulletId)
    if not bullet then
        return
    end

    ---! 移除子弹
    desk:remove_bullet(playerId, data.bulletId)

    ---! 获取当前时间
    local now_time = os.time()

    ---! 获取比赛开始时间
    local start_time = desk:query_temp("start_time")
    if not start_time or now_time < start_time then
        return
    end

    ---! 获取比赛结束时间
    local end_time = desk:query_temp("end_time")
    if not end_time or now_time >= end_time then
        return
    end

    ---! 获取有效的碰撞的鱼
    local hit_fishes = CATCH_POLICY_D:get_validate_hit_fishes(desk, data.killedFishes)

    ---! 获取有效的受影响的鱼
    local effected_fishes = CATCH_POLICY_D:get_validate_hit_fishes(desk, data.effectedFishes)

    ---! 将有效的鱼传入，获得被杀死的鱼的列表
    local killed_fishes = CATCH_POLICY_D:get_killed_fishes(player, bullet, hit_fishes, effected_fishes)

    ---! 获取子弹炮倍
    local gunrate = bullet.gunRate

    ---! 获取当前积分
    local match_score = player:query_temp("free_arena", "match_score") or 0

    ---! 遍历所有鱼，计算杀鱼积分
    local killedFishes = {}
    local total_fish_score = 0
    for index, killed_fish in ipairs(killed_fishes) do repeat
        local fish_type = FISH_CONFIG:get_config_by_id(killed_fish.fishId)
        if not fish_type then
            break
        end

        ---! 击杀鱼时，获得的积分 = 击杀炮倍 * 鱼倍
        local fish_score = gunrate * fish_type.true_score

        ---! 累加积分
        total_fish_score = total_fish_score + fish_score

        ---! 添加鱼信息
        killedFishes[index] = { timelineId = killed_fish.timelineId, fishArrayId = killed_fish.fishArrayId, fishScore = fish_score, }
    until true end

    if total_fish_score > 0 then
        ---! 标记积分变化
        desk:set_temp("brocast_rank", true)

        ---! 更新当前积分
        match_score = player:set_temp("free_arena", "match_score", match_score + total_fish_score)
    end

    local result = {}
    result.playerId = playerId
    result.bulletId = bullet.bulletId
    result.newScore = match_score
    result.killedFishes = killedFishes
    player:brocast_packet("MSGS2CFreeArenaHit", result)
end

---! 检查状态
function FREE_ARENA_D:check_status(desk, arena_type)
    if desk:query_temp("finish_time") then
        ---! 活动已经结束，不再继续处理
        return
    end

    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        ---! 配置未找到

        ----todo:
        ---! 解散当前报名分组
        return
    end

    ---! 获取当前所有玩家
    local players = desk:get_players()
    if #players <= 0 then
        ----todo: 提前结束比赛
        return
    end

    ---! 判断是否刷新排行榜
    if desk:query_temp("brocast_rank") then
        ---! 移除刷新标记
        desk:delete_temp("brocast_rank")

        ---! 刷新排名信息
        brocast_match_rank(players, match_config)
    end

    local now_time = os.time()
    local end_time = desk:query_temp("end_time")
    if end_time and now_time < end_time then
        ---! 当前比赛未结束，需要判断所有玩家子弹玩家子弹是否已耗尽
        for _, player in ipairs(players) do repeat
            local cur_bullet_num = player:query_temp("free_arena", "cur_bullet_num")
            if not cur_bullet_num then
                break
            end

            if cur_bullet_num <= 0 then
                break
            end

            ---! 当前仍存在部分玩家子弹稍微耗尽，活动无法结束仍需等待
            return
        until true end
    end

    ---! 记录当前结束时间
    desk:set_temp("finish_time", now_time)

    ---! 判断当前免费赛是否结束
    finish_free_arena(players, match_config)

    ---! 销毁当前桌子对象
    destory_free_arena(desk)
end
