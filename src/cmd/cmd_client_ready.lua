local function main (userOb, msgData)
    ---! 是否是第一个玩家
    ROOM_D:check_first_player(userOb)

    ---! 获取当前桌子帧数
    local frame_count = userOb:get_desk():get_frame_count()

    ---! 获取当前玩家对象
    local players = userOb:get_desk():get_players()

    ---! 发送当前子弹信息
    for _, player in ipairs(players) do repeat
        local bullets = userOb:get_desk():get_player_bullets(player:get_id())
        if #bullets <= 0 then
            break
        end

        local result = {}
        result.bullets = bullets
        userOb:send_packet("MSGS2CBulletStatus", result)
    until true end

    local result = {}
    result.frameId = frame_count
    result.playerId = userOb:get_id()
    result.isInGroup = userOb:get_desk():is_in_fishgroup()
    result.timelineIndex = userOb:get_desk():get_timeline_index_ex()
    result.isInFreeze = userOb:get_desk():is_in_freeze()
    result.freezePlayerId = userOb:get_desk():get_freeze_player_id()
    result.fishGroupComing = userOb:get_desk():check_fishgroup_coming(frame_count)
    result.leftFishGroupSeconds = userOb:get_desk():get_fishgroup_left_seconds(frame_count)
    result.killedFishes = userOb:get_desk():get_killed_fishes_on_frame(frame_count)
    result.calledFishes = userOb:get_desk():get_visable_callfishes()

    ---! 当前被召唤的鱼
    result.calledFishes = {}

    ---! 当前的悬赏任务
    ----todo:

    ---! 当前所有的玩家
    local playerInfos = {}
    for _, player in ipairs(players) do
        playerInfos[#playerInfos + 1] = player:generate_player_info()
    end
    result.playerInfos = playerInfos

    ---! 发送场景信息
    userOb:send_packet("MSGS2CGameStatus", result)

    ---! 广播加入消息
    local result = {}
    result.playerInfo = userOb:generate_player_info()
    userOb:brocast_packet("MSGS2CPlayerJion", result, userOb)

    ----todo: post_ready_desk
    --[[
    ---! 触发相关事件
    ----todo: POST_EVENT(EVENT_READY_DESK, player);
    ]]
    do
        ---! 刷新奖金鱼奖池
        FISH_DRAW_D:send_fish_reward(userOb)

        ---! 刷新在线奖励
        ONLINE_REWARD_D:send_online_reward_data(userOb)
    end
end

COMMAND_D:register_command("MSGC2SClientReady", GameCmdType.DESK, main)
