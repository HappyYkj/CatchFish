---! 限时赛排位信息
local limit_arena_rank = {}

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
---! 获取当前限时赛活动时间
local function get_match_start_end_time(match_config)
    ---! 获取整点时间
    local ti = os.date("*t")
    ti.min = 0
    ti.sec = 0

    ---! 活动开始时间
    local start_time = os.time(ti)

    ---! 活动结束时间
    local end_time = start_time + 86400

    ---! 返回活动时间
    return start_time, end_time
end

---! 获取当前限时赛报名时间
local function get_signup_start_end_time(match_config)
    ---! 获取活动时间
    local start_time, end_time = get_match_start_end_time(match_config)

    ---! 返回报名时间
    return start_time, end_time - 600
end

---! 获取当前排位信息
local function get_limit_arena_map(arena_type)
    ---! 获取当前时间
    local now_time = os.time()

    ---! 获取比赛信息
    local limit_arena_map = limit_arena_rank[arena_type]
    if limit_arena_map then
        ---! 比较活动开始时间
        if not limit_arena_map.match_start_time or now_time < limit_arena_map.match_start_time then
            limit_arena_rank[arena_type] = nil
        ---! 比较活动结束时间
        elseif not limit_arena_map.match_end_time or now_time >= limit_arena_map.match_end_time then
            limit_arena_rank[arena_type] = nil
        end
    end

    ---! 重新获取比赛信息
    local limit_arena_map = limit_arena_rank[arena_type]
    return limit_arena_map
end

---! 获取当前玩家信息
local function get_player_map(player, arena_type)
    ---! 获取当前时间
    local now_time = os.time()

    ---! 获取比赛信息
    local limit_arena_map = player:query_temp("limit_arena", arena_type)
    if limit_arena_map then
        ---! 比较活动开始时间
        if not limit_arena_map.match_start_time or now_time < limit_arena_map.match_start_time then
            limit_arena_map = nil
        ---! 比较活动结束时间
        elseif not limit_arena_map.match_end_time or now_time >= limit_arena_map.match_end_time then
            limit_arena_map = nil
        end
    end

    if not limit_arena_map then
        ---! 设置当前活动信息
        limit_arena_map = player:set_temp("limit_arena", arena_type, {})

        ---! 获取当前活动时间
        local match_start_time, match_end_time = get_match_start_end_time()
        limit_arena_map.match_start_time = match_start_time
        limit_arena_map.match_end_time = match_end_time
    end

    return limit_arena_map
end

---! 上报当前玩家积分
local function report_player_score(player, arena_type, score)
    if score <= 0 then
        ---! 积分不足，无需处理
        return
    end

    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        ---! 配置不存在，无需处理
        return
    end

    ---! 获取当前时间
    local now_time = os.time()

    ---! 获取比赛信息
    local limit_arena_map = get_limit_arena_map(arena_type)
    if not limit_arena_map then
        ---! 设置当前活动信息
        limit_arena_rank[arena_type] = {}
        limit_arena_map = limit_arena_rank[arena_type]

        ---! 获取当前活动时间
        local match_start_time, match_end_time = get_match_start_end_time()
        limit_arena_map.match_start_time = match_start_time
        limit_arena_map.match_end_time = match_end_time
        limit_arena_map.match_rank_list = {}
    end

    ---! 获取当前玩家ID
    local playerId = player:get_id()

    ---! 获取当前玩家昵称
    local nick_name = player:get_nick_name()

    ---! 遍历所有玩家ID
    for _, rank_map in ipairs(limit_arena_map.match_rank_list) do
        if rank_map.playerId == playerId then
            ---! 更新当前积分
            rank_map.score = score

            ---! 更新玩家昵称
            rank_map.nick_name = nick_name

            ---! 重新进行排序
            table.sort(limit_arena_map.match_rank_list, function(rank_map1, rank_map2)
                return rank_map1.score > rank_map2.score
            end)
            return
        end
    end

    ---! 添加新玩家排名
    local rank_map = { playerId = playerId, nick_name = nick_name, score = score }
    table.insert(limit_arena_map.match_rank_list, rank_map)

    ---! 重新进行排序
    table.sort(limit_arena_map.match_rank_list, function(rank_map1, rank_map2)
        return rank_map1.score > rank_map2.score
    end)

    ---! 保留有效排名
    local reward = match_config.reward[#match_config.reward]
    for idx = reward.rank + 1, #limit_arena_map.match_rank_list do
        limit_arena_map.match_rank_list[idx] = nil
    end
end

---! 获取当前玩家排名
local function get_player_rank(player, arena_type)
    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        ---! 配置不存在，无需处理
        return
    end

    local limit_arena_map = get_limit_arena_map(arena_type)
    if not limit_arena_map then
        return
    end

    ---! 获取当前玩家ID
    local playerId = player:get_id()

    ---! 遍历所有玩家ID
    for rank, rank_map in ipairs(limit_arena_map.match_rank_list) do
        if rank_map.playerId == playerId then
            return rank
        end
    end
end

---! 限时赛开启处理
local function start_limit_arena(player, arena_type)
    local desk = player:get_desk()
    if not desk then
        return
    end

    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        -- 配置未找到
        return
    end

    ---! 设置房间类型
    if not desk:query_temp("arena_type") then
        desk:set_temp("arena_type", arena_type)
    end

    ---! 设置忽略鱼潮
    if not desk:query_temp("ignore_fishgroup") then
        desk:set_temp("ignore_fishgroup", true)
    end

    ---! 累计报名次数
    if match_config.maxnum > 0 then
        player:add_match_signup_count(arena_type)
    end

    ---! 获取比赛信息
    local limit_arena_map = get_player_map(player, arena_type)

    ---! 重置当前比赛积分
    limit_arena_map.match_score = 0

    ---! 设置当前最高积分
    limit_arena_map.max_match_score = limit_arena_map.max_match_score or 0

    ---! 获取当前比赛时间
    local now_time = os.time()
    limit_arena_map.start_time = now_time
    limit_arena_map.end_time = now_time + match_config.time

    ---! 设置比赛子弹数量
    limit_arena_map.cur_bullet_num = match_config.bulletnum
    limit_arena_map.max_bullet_num = match_config.bulletnum

    ---! 设置当前比赛炮倍
    limit_arena_map.gunrate = 1

    ---! 设置重连回调
    player:set_temp("reconnect_callback", function(player)
        ---! 延迟调用
        THREAD_D:create(function()
            ---! 发送通知玩家开始游戏的消息
            local result = {}
            result.errorCode = 0
            result.arenaType = arena_type
            result.reconnect = true
            player:send_packet("MSGS2CLimitArenaStart", result)
        end)
    end)

    ---! 发送通知玩家开始游戏的消息
    local result = {}
    result.errorCode = 0
    result.arenaType = arena_type
    result.reconnect = false
    player:send_packet("MSGS2CLimitArenaStart", result)
end

---! 生成指定玩家信息
local function generate_player_info(player, arena_type)
    local limit_arena_map = player:query_temp("limit_arena", arena_type)
    if not limit_arena_map then
        limit_arena_map = player:set_temp("limit_arena", arena_type, {})
    end

    ---! 获取子弹与积分信息
    local cur_gunrate = limit_arena_map.gunrate or 1
    local cur_bullet_num = limit_arena_map.cur_bullet_num or 0
    local max_bullet_num = limit_arena_map.max_bullet_num or 0
    local match_score = limit_arena_map.match_score or 0

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
    player_info.gunRate = cur_gunrate
    player_info.bulletCount = cur_bullet_num
    player_info.maxBulletCount = max_bullet_num
    player_info.score = match_score

    ---! 返回玩家基本信息
    return player_info
end

---! 生成所有玩家信息
local function generate_all_player_info(desk, arena_type)
    local all_player_info = {}
    for _, player in ipairs(desk:get_players()) do
        all_player_info[#all_player_info + 1] = generate_player_info(player, arena_type)
    end
    return all_player_info
end

---! 清理玩家
local function kickout_player(player, arena_type)
    if not player:get_desk() then
        return
    end

    ---! 获取当前积分
    local score = player:query_temp("limit_arena", arena_type, "match_score") or 0

    ---! 获取最高积分
    local max_score = player:query_temp("limit_arena", arena_type, "max_match_score") or 0

    ---! 更新最高积分
    if score > max_score then
        max_score = player:set_temp("limit_arena", arena_type, "max_match_score", score)

        ---! 上报当前积分
        report_player_score(player, arena_type, score)
    end

    ---! 通知当前结果
    local result = {}
    result.score = score
    result.maxScore = max_score
    result.rank = get_player_rank(player, arena_type) or 0
    player:send_packet("MSGS2CLimitArenaComplete", result)

    ---! 广播玩家离场
    ROOM_D:leave_desk(player, true)
end

---! 销毁当前限时赛
local function destory_limit_arena(desk)
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

---! 结束限时赛当前轮次
local function finish_limit_arena_round()
    for arena_type, limit_arena_map in pairs(limit_arena_rank) do repeat
        local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
        if not match_config then
            break
        end

        if not limit_arena_map.match_rank_list then
            break
        end

        ---! 遍历排行信息
        for rank, rank_map in ipairs(limit_arena_map.match_rank_list) do repeat
            local prop_id, prop_count = MATCH_CONFIG:get_reward_by_rank(match_config, rank)
            if not prop_id or not prop_count then
                break
            end

            ---! 奖励通过邮件的形式进行发送
            local mail = {}
            mail.title = "System Rewards"
            mail.content = string.format("Congratulations on reaching the %d place in the %s and getting the following rewards", rank, match_config.name)
            mail.attach = string.format("%s,%s", prop_id, prop_count)
            MAIL_D:send_mail(rank_map.playerId, mail)
        until true end
    until true end

    ---! 重置比赛名单列表
    limit_arena_rank = {}

    ---! 下一个整点再结算
    local t = os.date("*t")
    t.hour = t.hour + 1
    t.min = 0
    t.sec = 0
    TIMER_D:start_timer(os.time(t) - os.time(), 1, finish_limit_arena_round)
end

-------------------------------------------------------------------------------
---! 初始启动
-------------------------------------------------------------------------------
register_post_init(finish_limit_arena_round)

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
LIMIT_ARENA_D = {}

---! 报名免费赛
function LIMIT_ARENA_D:signup(player, arena_type, signup_type)
    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        -- 配置未找到
        local result = {}
        result.errorCode = 1
        result.arenaType = arena_type
        result.signupType = signup_type
        player:send_packet("MSGS2CLimitArenaSignUp", result)
        return
    end

    if player:get_max_gunrate() < match_config.cannon then
        -- 炮倍不满足
        local result = {}
        result.errorCode = 2
        result.arenaType = arena_type
        result.signupType = signup_type
        player:send_packet("MSGS2CLimitArenaSignUp", result)
        return
    end

    local now_time = os.time()
    local start_time, end_time = get_signup_start_end_time(match_config)
    if now_time < start_time or now_time >= end_time then
        -- 不在活动期间
        local result = {}
        result.errorCode = 3
        result.arenaType = arena_type
        result.signupType = signup_type
        player:send_packet("MSGS2CLimitArenaSignUp", result)
        return
    end

    if match_config.maxnum > 0 and player:get_match_signup_count(arena_type) >= match_config.maxnum then
        -- 达到报名次数上限
        local result = {}
        result.errorCode = 4
        result.arenaType = arena_type
        result.signupType = signup_type
        player:send_packet("MSGS2CLimitArenaSignUp", result)
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
            player:send_packet("MSGS2CLimitArenaSignUp", result)
            return
        end

        if player:get_match_share_count(arena_type) >= share_config.awardnum then
            -- 达到广告次数上限
            local result = {}
            result.errorCode = 6
            result.arenaType = arena_type
            result.signupType = signup_type
            player:send_packet("MSGS2CLimitArenaSignUp", result)
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
            player:send_packet("MSGS2CLimitArenaSignUp", result)
            return
        until true end
    end

    local desk = ROOM_D:assign_desk(player, arena_type)
    if not desk then
        -- 房间分配失败
        local result = {}
        result.errorCode = 8
        result.arenaType = arena_type
        result.signupType = signup_type
        player:send_packet("MSGS2CLimitArenaSignUp", result)
        return
    end

    ---! 设置房间等级
    desk:set_grade(ROOM_CONFIG.LIMIT_ARENA_ROOM_TYPE)

    ---! 扣除报名费用
    local cost_props = {}
    if signup_type == 2 then
        ---! 通过广告的方式报名
        player:add_match_share_count(arena_type)
    else
        ---! 通过默认的方式报名
        for prop_id, prop_count in pairs(match_config.cost) do
            ---! 扣除费用
            player:change_prop_count(prop_id, -prop_count, PropChangeType.kPropChangePayFreetime)

            ---! 消费记录
            cost_props[#cost_props + 1] = { propId = prop_id, propCount = prop_count, }
        end
    end

    ---! 通知报名成功
    local result = {}
    result.errorCode = 0
    result.arenaType = arena_type
    result.signupType = signup_type
    result.props = cost_props
    player:send_packet("MSGS2CLimitArenaSignUp", result)

    ---! 通知开始游戏
    start_limit_arena(player, arena_type)
end

---! 获取报名信息
function LIMIT_ARENA_D:send_signup_info(player, arena_type)
    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        return
    end

    ---! 剩余报名次数
    local signup_count = match_config.maxnum
    if signup_count > 0 then
        signup_count = signup_count - player:get_match_signup_count(arena_type)
    end

    ---! 剩余看广告次数
    local share_count = 0
    local share_config = SHARE_CONFIG:get_config_by_type(match_config.freeshare_id)
    if share_config then
        share_count = share_config.awardnum - player:get_match_share_count(arena_type)
    end

    local result = {}
    result.arenaType = arena_type
    result.signupCount = signup_count
    result.shareCount = share_count
    player:send_packet("MSGS2CLimitArenaSignupInfo", result)
end

---! 准备就绪
function LIMIT_ARENA_D:go_ready(player, arena_type)
    if not arena_type then
        return
    end

    local desk = player:get_desk()
    if not desk then
        return
    end

    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        return
    end

    ---! 是否是第一个玩家
    if ROOM_D:check_first_player(player) then
        ---! 获取比赛活动时间
        local start_time, end_time = get_match_start_end_time()

        ---! 设置比赛开始时间
        desk:set_temp("start_time", start_time)

        ---! 计算比赛结束时间
        desk:set_temp("end_time", end_time)

        ---! 启动结束定时器
        desk:set_temp("finish_timer_id", TIMER_D:start_timer(1, function() LIMIT_ARENA_D:check_status(desk, arena_type) end))
    end

    ---! 获取当前桌子帧数
    local frame_count = desk:get_frame_count()

    ---! 发送当前子弹信息
    for _, other in ipairs(desk:get_players()) do repeat
        local bullets = desk:get_player_bullets(other:get_id())
        if #bullets <= 0 then
            break
        end

        local result = {}
        result.bullets = bullets
        player:send_packet("MSGS2CBulletStatus", result)
    until true end

    ---! 获取比赛开始时间
    local start_time = player:query_temp("limit_arena", arena_type, "start_time") or 0

    ---! 获取比赛结束时间
    local end_time = player:query_temp("limit_arena", arena_type, "end_time") or 0

    ---! 发送响应消息
    local result = {}
    result.arenaType = arena_type
    result.startSecond = start_time
    result.endSecond = end_time
    result.frameId = frame_count
    result.timelineIndex = desk:get_timeline_index_ex()
    result.killedFishes = desk:get_killed_fishes_on_frame(frame_count)
    result.calledFishes = desk:get_visable_callfishes()
    result.playerInfo = generate_all_player_info(desk, arena_type)
    player:send_packet("MSGS2CLimitArenaReady", result)

    ---! 广播加入消息
    local result = {}
    result.playerInfo = generate_player_info(player, arena_type)
    player:brocast_packet("MSGS2CLimitArenaPlayerJoin", result, player)
end

---! 射击子弹
function LIMIT_ARENA_D:shoot_bullet(player, data)
    local desk = player:get_desk()
    if not desk then
        return
    end

    local arena_type = desk:query_temp("arena_type")
    if not arena_type then
        return
    end

    ---! 获取当前时间
    local now_time = os.time()

    ---! 获取比赛开始时间
    local start_time = player:query_temp("limit_arena", arena_type, "start_time")
    if not start_time or now_time < start_time then
        return
    end

    ---! 获取比赛结束时间
    local end_time = player:query_temp("limit_arena", arena_type, "end_time")
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
    if table.size(bullets) >= room_config.max_bullet then
        local result = {}
        result.validate = false
        result.bulletId = data.bulletId
        player:send_packet("MSGS2CLimitArenaShoot", result)
        return
    end

    ---! 获取当前炮倍
    local cur_gunrate = player:query_temp("limit_arena", arena_type, "gunrate") or 1

    ---! 获取剩余子弹数量
    local cur_bullet_num = player:query_temp("limit_arena", arena_type, "cur_bullet_num") or 0
    if cur_bullet_num < cur_gunrate then
        local result = {}
        result.validate = false
        result.bulletId = data.bulletId
        player:send_packet("MSGS2CLimitArenaShoot", result)
        return
    end

    ---! 扣除射击次数
    local new_bullet_num = player:set_temp("limit_arena", arena_type, "cur_bullet_num", cur_bullet_num - cur_gunrate)

    ---! 记录当前子弹
    local bullet = {}
    bullet.playerId = playerId
    bullet.bulletId = data.bulletId
    bullet.angle = data.angle
    bullet.timelineId = data.timelineId
    bullet.fishArrayId = data.fishArrayId
    bullet.gunRate = cur_gunrate
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
    player:brocast_packet("MSGS2CLimitArenaShoot", result)
end

---! 碰撞子弹
function LIMIT_ARENA_D:hit_bullet(player, data)
    local desk = player:get_desk()
    if not desk then
        return
    end

    local arena_type = desk:query_temp("arena_type")
    if not arena_type then
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

    ---! 获取比赛信息
    local limit_arena_map = player:query_temp("limit_arena", arena_type)
    if not limit_arena_map then
        return
    end

    ---! 获取当前时间
    local now_time = os.time()

    ---! 比较比赛开始时间
    if not limit_arena_map.start_time or now_time < limit_arena_map.start_time then
        return
    end

    ---! 获取比赛结束时间
    if not limit_arena_map.end_time or now_time >= limit_arena_map.end_time then
        return
    end

    ---! 获取当前房间配置
    local room_config = ROOM_CONFIG:get_config_by_roomtype(ROOM_CONFIG.LIMIT_ARENA_ROOM_TYPE)
    if not room_config then
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
    local match_score = limit_arena_map.match_score or 0

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
        ---! 更新当前积分
        match_score = player:set_temp("limit_arena", arena_type, "match_score", match_score + total_fish_score)
    end

    local result = {}
    result.playerId = playerId
    result.bulletId = bullet.bulletId
    result.newScore = match_score
    result.killedFishes = killedFishes
    player:brocast_packet("MSGS2CLimitArenaHit", result)
end

---! 检查状态
function LIMIT_ARENA_D:check_status(desk, arena_type)
    if desk:query_temp("finish_time") then
        ---! 活动已经结束，不再继续处理
        return
    end

    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        ---! 配置未找到
        return
    end

    local now_time = os.time()
    for _, player in ipairs(desk:get_players()) do repeat
        local end_time = player:query_temp("limit_arena", arena_type, "end_time")
        if not end_time or now_time >= end_time then
            kickout_player(player, arena_type)
            break
        end

        ---! 获取剩余子弹数量
        local bullet_num = player:query_temp("limit_arena", arena_type, "cur_bullet_num")
        if not bullet_num then
            kickout_player(player, arena_type)
            break
        end

        if bullet_num <= 0 then
            ---! 判断子弹数量
            local bullets = desk:get_player_bullets(player:get_id())
            if table.size(bullets) <= 0 then
                kickout_player(player, arena_type)
                break
            end
        end
    until true end

    local end_time = desk:query_temp("end_time")
    if end_time and now_time < end_time then
        ---! 当前比赛未结束
        return
    end

    ---! 记录当前结束时间
    desk:set_temp("finish_time", now_time)

    ---! 广播所有玩家离场
    for _, player in ipairs(desk:get_players()) do
        kickout_player(player, arena_type)
    end

    ---! 销毁当前桌子对象
    destory_limit_arena(desk)
end

---! 设置当前炮倍
function LIMIT_ARENA_D:change_gunrate(player, new_gunrate)
    if not FISH_SERVER_CONFIG:is_limit_arena_gunrate(new_gunrate) then
        return
    end

    local desk = player:get_desk()
    if not desk then
        return
    end

    local arena_type = desk:query_temp("arena_type")
    if not arena_type then
        return
    end

    ---! 获取之前炮倍
    local old_gunrate = player:query_temp("arena", arena_type, "gunrate") or 0

    if old_gunrate == new_gunrate then
        ---! 通知炮倍修改成功
        local result = {}
        result.playerId = player:get_id()
        result.newGunRate = new_gunrate
        player:send_packet("MSGCS2CLimitArenaGunRateChange", result)
        return
    end

    ---! 修改当前炮倍
    player:set_temp("limit_arena", arena_type, "gunrate", new_gunrate)

    ---! 广播炮倍消息
    local result = {}
    result.playerId = player:get_id()
    result.newGunRate = new_gunrate
    player:brocast_packet("MSGCS2CLimitArenaGunRateChange", result)
end

---! 发送排名信息
function LIMIT_ARENA_D:send_rank_info(player, arena_type)
    local match_config = MATCH_CONFIG:get_config_by_id(arena_type)
    if not match_config then
        return
    end

    ---! 获取玩家信息
    local limit_arena_map = get_player_map(player, arena_type)
    if not limit_arena_map then
        return
    end

    ---! 获取当前积分
    local score = limit_arena_map.match_score or 0

    ---! 设置个人排名
    local owner = {
        playerId = player:get_id(),
        nickName = player:get_nick_name(),
        score = score,
        rank = 0,
        props = {},
    }

    ---! 获取比赛信息
    local limit_arena_map = get_limit_arena_map(arena_type)
    if not limit_arena_map then
        local result = {}
        result.arenaType = arena_type
        result.rank = {}
        result.owner = owner
        player:send_packet("MSGS2CLimitArenaRank", result)
        return
    end

    ---! 获取玩家ID
    local playerId = player:get_id()

    ---! 遍历排行信息
    local rank_list = {}
    for rank, rank_map in ipairs(limit_arena_map.match_rank_list) do
        local props = {}
        local prop_id, prop_count = MATCH_CONFIG:get_reward_by_rank(match_config, rank)
        if prop_id and prop_count then
            table.insert(props, { propId = prop_id, propCount = prop_count, })
        end

        local tbl = {}
        tbl.playerId = rank_map.playerId
        tbl.nickName = rank_map.nick_name
        tbl.score = rank_map.score
        tbl.rank = rank
        tbl.props = props
        table.insert(rank_list, tbl)

        if rank_map.playerId == playerId then
            owner = tbl
        end
    end

    local result = {}
    result.arenaType = arena_type
    result.rank = rank_list
    result.owner = owner
    player:send_packet("MSGS2CLimitArenaRank", result)
end

function LIMIT_ARENA_D:test_limit_arena()
    finish_limit_arena_round()
end
