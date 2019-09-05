---! 鱼线播放时间
local FISH_GROUP_TIME = 60 * 10

---! 离开桌子原因
local LEAVEDESK_REASON = {
    NONE = 0,           -- 无
    GUNRATE_ERROR = 1,  -- 炮倍错误
    GRADE_ERROR = 2,    -- 等级错误
}

---! 桌子映射关系表
local room_desk_map = {}

---! 桌子自增Id
local room_desk_id = 0
-------------------------------------------------------------------------------
---! 内部接口
-------------------------------------------------------------------------------

---! 创建桌子对象
local function create_desk(desk_type)
    local desk_lst = room_desk_map[desk_type] or {}

    ---! 桌子自增Id
    room_desk_id = room_desk_id + 1

    ---! 分配桌子Id
    local desk_id = room_desk_id

    ---! 创建桌子对象
    local desk_ob = DESK_OB:create()

    ---！ 记录桌子Id
    desk_ob:set_id(desk_id)

    ---! 记录桌子等级
    desk_ob:set_grade(desk_type)

    ---! 关联桌子对象
    desk_ob:set_id(desk_id)
    desk_lst[desk_id] = desk_ob
    room_desk_map[desk_type] = desk_lst

    ---! 返回桌子对象
    return desk_ob
end

---! 搜索空闲桌子
local function search_desk(desk_type)
    ---! 查找桌子分类
    local desk_lst = room_desk_map[desk_type]
    if not desk_lst then
        return
    end

    for _, desk in pairs(desk_lst) do repeat
        if desk:query_temp("destory") then
            break
        end

        if desk:get_player_count() >= 4 then
            break
        end

        return desk
    until true end
end

---! 随机生成鱼线
local function generate_random_timeline(desk)
    ---! 随机生成鱼线
    local level, index = FISH_D:generate_random_timeline_index(desk:get_grade())
    desk:set_temp("timelineLevel", level)
    desk:set_temp("timelineIndex", index)

    ---! 当前状态改为鱼线
    desk:set_temp("isInTimeline", true)

    ---! 重置鱼潮通知标记
    desk:set_temp("fishGroupComingNotified", false)

    ---! 重置鱼线开始时间
    desk:set_temp("startTickCount", os.clock())

    ---! 清空所有杀鱼记录
    desk:remove_all_killed_fishes()

    ---! 清空历史冰冻状态
    desk:reset_freeze()

    ---! 随机生成悬赏任务
    ----todo:

    ---! 广播鱼线消息
    local result = {}
    result.index = desk:get_timeline_index_ex()
    desk:brocast_packet("MSGS2CStartTimeline", result)
    spdlog.debug("desk", string.format("desk [%s] play timeline : %s", desk:get_id(), index))
end

---! 随机生成鱼潮
local function generate_random_fishgroup(desk)
    local index = FISH_GROUP_CONFIG:generate_random_fishgroup_index()
    desk:set_temp("timelineLevel", 0)
    desk:set_temp("timelineIndex", index)

    ---! 当前状态改为鱼潮
    desk:set_temp("isInTimeline", false)

    ---! 重置鱼线开始时间
    desk:set_temp("startTickCount", os.clock())

    ---! 清空所有杀鱼记录
    desk:remove_all_killed_fishes()

    ---! 清空历史冰冻状态
    desk:reset_freeze()

    ---! 清理当前悬赏任务
    ----todo:

    ---! 广播鱼线消息
    local result = {}
    result.index = desk:get_timeline_index_ex()
    desk:brocast_packet("MSGS2CStartFishGroup", result)
    spdlog.debug("desk", string.format("desk [%s] play fishgroup : %s, endframe : %s", desk:get_id(), index, FISH_GROUP_CONFIG:get_fishgroup_endframe(index)))
end

---! 检查当前鱼线
local function check_timeline(desk)
    --[[
    if not desk:query_temp("isInTimeline") then
        spdlog.debug("desk", string.format("desk [%s] grade : %s play fishgroup : %s, frame : %s, endframe : %s", desk:get_id(), desk:get_grade(), desk:query_temp("timelineIndex"), desk:get_frame_count(), FISH_GROUP_CONFIG:get_fishgroup_endframe(desk:query_temp("timelineIndex"))))
    else
        spdlog.debug("desk", string.format("desk [%s] grade : %s play timeline : %s, frame : %s, endframe : %s", desk:get_id(), desk:get_grade(), desk:query_temp("timelineIndex"), desk:get_frame_count(), FISH_GROUP_TIME * 20))
    end
    --]]

    ---! 当前是否处于鱼线状态下
    if not desk:query_temp("isInTimeline") then
        ---! 获取当前鱼线Id
        local index = desk:query_temp("timelineIndex") or 0

        ---! 获取鱼潮结束帧数
        local end_frame = FISH_GROUP_CONFIG:get_fishgroup_endframe(index)

        ---! 获取当前鱼潮帧数
        local frame_count = desk:get_frame_count()

        ---! 判断鱼潮是否结束
        if frame_count < end_frame then
            -- 若尚未结束，则不继续处理
            return
        end

        ---! 随机生成鱼线
        return generate_random_timeline(desk)
    end

    if desk:query_temp("ignore_fishgroup") then
        if FISH_GROUP_TIME * 1000 < desk:get_frame_count() * 50 then
            ---! 随机生成鱼线
            return generate_random_timeline(desk)
        end
        return
    end

    ---! 计算鱼潮到来时间
    local fishgroup_time = FISH_GROUP_TIME * 1000 - desk:get_frame_count() * 50

    ---! 鱼潮是否尚未来临
    if fishgroup_time > 0 then
        ---! 鱼潮是否即将来临
        if fishgroup_time <= FISH_SERVER_CONFIG.fishGroupNotifySeconds * 1000 then
            if not desk:query_temp("fishGroupComingNotified") then
                desk:set_temp("fishGroupComingNotified", true)

                ---! 广播鱼潮即将来临
                local result = {}
                desk:brocast_packet("MSGS2CFishGroupNotify", result)
            end
        end

        -- 鱼潮尚未来临，则不继续处理
        return
    end

    ---! 随机生成鱼潮
    generate_random_fishgroup(desk)
end

---! 检查所有玩家
local function check_players(desk)
    for _, player in ipairs(desk:get_players()) do
        ---! 检查玩家上次心跳
        ----todo:

        ---! 检查玩家上次射击
        ----todo:

        ---! 检查玩家狂暴状态
        ----todo:

        ---! 检查玩家锁定状态
        ----todo:

        ---! 检查玩家任务状态(开心30秒任)
        ----todo:
    end
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
ROOM_D = {}

function ROOM_D:assign_desk(player, desk_type)
    if player:get_desk() then
        spdlog.debug("desk", string.format("player is in desk %s, assign desk fail!", player:get_id()))
        return
    end

    local desk = search_desk(desk_type)
    if not desk then
        desk = create_desk(desk_type)
        if not desk then
            spdlog.debug("desk", "desk not created.")
            return
        end
        spdlog.debug("desk", string.format("desk [%s] created", desk:get_id()))
    end

    local chair_id = desk:assign_chair(player)
    if not chair_id then
        spdlog.debug("desk", string.format("desk %s is full.", desk:get_id()))
        return
    end

    spdlog.debug("desk", string.format("player %s, assign desk:%s, chair:%s", player:get_id(), desk:get_id(), chair_id))
    return desk
end

function ROOM_D:assign_match_desk(players, desk_type)
    local desk = create_desk(desk_type)
    if not desk then
        spdlog.debug("desk", "desk not created.")
        return
    end

    spdlog.debug("desk", string.format("desk [%s] created", desk:get_id()))

    for _, player in ipairs(players) do
        local chair_id = desk:assign_chair(player)
        if not chair_id then
            spdlog.debug("desk", string.format("desk %s is full.", desk:get_id()))
            ROOM_D:destory_desk(desk)
            return
        end
        spdlog.debug("desk", string.format("player %s, assign desk:%s, chair:%s", player:get_id(), desk:get_id(), chair_id))
    end

    spdlog.debug("desk", string.format("desk [%s] assigned", desk:get_id()))
    return desk
end

function ROOM_D:destory_desk(desk, notify)
    ---! 注销定时器
    local timeline_timer_id = desk:query_temp("timeline_timer_id")
    if timeline_timer_id then
        TIMER_D:cancel_timer(timeline_timer_id)
    end

    local players_timer_id = desk:query_temp("players_timer_id")
    if players_timer_id then
        TIMER_D:cancel_timer(players_timer_id)
    end

    ---! 清理玩家对象
    local players = desk:get_players()
    for _, player in ipairs(players) do
        ROOM_D:leave_desk(player, notify)
    end

    ---! 清理关系映射标
    local desk_type = desk:get_grade()
    local desk_lst = room_desk_map[desk_type]
    if desk_lst then
        local desk_id = desk:get_id()
        desk_lst[desk_id] = nil
        room_desk_map[desk_type] = desk_lst
    end
end

function ROOM_D:destory_desk_delay(desk, secs)
    ---! 注销定时器
    local timeline_timer_id = desk:query_temp("timeline_timer_id")
    if timeline_timer_id then
        TIMER_D:cancel_timer(timeline_timer_id)
    end

    local players_timer_id = desk:query_temp("players_timer_id")
    if players_timer_id then
        TIMER_D:cancel_timer(players_timer_id)
    end

    ---! 标记当前桌子已销毁
    desk:set_temp("destory", os.time())

    ---! 设置销毁桌子的回调
    local callback = function ()
        ---! 清理玩家对象
        local players = desk:get_players()
        for _, player in ipairs(players) do
            ROOM_D:leave_desk(player, notify)
        end

        ---! 清理关系映射标
        local desk_type = desk:get_grade()
        local desk_lst = room_desk_map[desk_type]
        if desk_lst then
            local desk_id = desk:get_id()
            desk_lst[desk_id] = nil
            room_desk_map[desk_type] = desk_lst
        end
    end

    if secs > 0 then
        ---! 延迟调用
        return TIMER_D:start_timer(secs, 1, callback)
    end

    ---! 直接调用
    return callback()
end

function ROOM_D:enter_desk(player)
    ---! 设置相关回调
    player:set_temp("disconnect_callback", function ()
        -- 尝试清理玩家离开桌子
        ROOM_D:leave_desk(player, true)
    end)

    local result = {}
    result.errorCode = GetDeskFailReason.kGetDeskFailReasonNone
    player:send_packet("MSGS2CGetDesk", result)
end

function ROOM_D:leave_desk(player, notify)
    local desk = player:get_desk()
    if not desk then
        return false
    end

    local chair_id = desk:leave_chair_by_player(player)
    if not chair_id then
        return false
    end

    ---! 清理狂暴数据
    player:clear_violent()

    ---! 清理相关回调
    player:delete_temp("disconnect_callback")
    player:delete_temp("reconnect_callback")

    if notify then
        ---! 广播玩家离开桌子
        local result = {}
        result.errorCode = 0
        result.chairId = chair_id
        result.playerId = player:get_id()
        desk:brocast_packet("MSGS2CLeaveDesk", result)
    end

    spdlog.debug("desk", string.format("player %s, Recycle desk:%s, chair:%s", player:get_id(), desk:get_id(), chair_id))
    return true
end

function ROOM_D:force_leave_desk(player, reason)
    local desk = player:get_desk()
    if not desk then
        return false
    end

    ---! 通知玩家离开桌子
    local result = {}
    result.reason = reason
    player:send_packet("MSGS2CDeskKickPlayer", result)

    ---! 复用leave_desk接口
    return self:leave_desk(player)
end

function ROOM_D:check_first_player(player)
    local desk = player:get_desk()
    if not desk then
        return false
    end

    if desk:query_temp("timeline_timer_id") then
        return false
    end

    ---! 状态开启
    check_timeline(desk)

    ---! 启动定时
    desk:set_temp("timeline_timer_id", TIMER_D:start_timer(1, function() check_timeline(desk) end))
    desk:set_temp("players_timer_id", TIMER_D:start_timer(3, function() check_players(desk) end))
    return true
end

function ROOM_D:check_fishgroup_coming(desk, frame_count)
    local frame_count = frame_count or desk:get_frame_count()
    return FISH_GROUP_TIME * 20 - frame_count < FISH_SERVER_CONFIG.fishGroupNotifySeconds * 20
end

function ROOM_D:get_fishgroup_left_seconds(desk, frame_count)
    if not desk:query_temp("isInTimeline") then
        return 0
    end

    local frame_count = frame_count or desk:get_frame_count()
    return math.floor((FISH_GROUP_TIME * 20 - frame_count) / 20)
end

function ROOM_D:get_frame_count(desk)
    ---! 获取开始帧数
    local startTickCount = desk:query_temp("startTickCount") or 0

    ---! 计算时间跨度
    local timespan = os.clock() - startTickCount

    ---! 扣除冰冻时长
    timespan = timespan - desk:get_freeze_timespan()

    ---! 计算当前帧数
    return math.floor(timespan * 20)
end
