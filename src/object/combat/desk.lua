DESK_OB = class("DESK_OB")
DESK_OB:inherit(F_COMN_DBASE)
DESK_OB:inherit(F_COMBAT_BOMB)
DESK_OB:inherit(F_COMBAT_FISH)
DESK_OB:inherit(F_COMBAT_FREEZE)
DESK_OB:inherit(F_COMBAT_BULLET)
DESK_OB:inherit(F_COMBAT_CALLFISH)

local max_chair_count = 4

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

function DESK_OB:set_id(id)
    return self:set("id", id)
end

function DESK_OB:get_id()
    return self:query("id")
end

function DESK_OB:assign_chair(user_ob)   
    local chair_lst = self:query("chair") or {}
    for chair_id = 1, max_chair_count do repeat
        if chair_lst[chair_id] then
            break
        end

        ---! 分配桌子位置
        chair_lst[chair_id] = user_ob
        self:set("chair", chair_lst)

        ---! 记录桌子对象
        user_ob:set_desk(self)

        ---! 返回分配位置
        return chair_id - 1
    until true end
end

function DESK_OB:leave_chair_by_player(user_ob)
    local chair_lst = self:query("chair")
    if not chair_lst then
        return
    end

    for chair_id = 1, max_chair_count do repeat
        if chair_lst[chair_id] ~= user_ob then
            break
        end

        ---! 清理桌子位置
        chair_lst[chair_id] = nil
        self:set("chair", chair_lst)

        ---! 移除相关关联
        user_ob:set_desk(nil)

        ---! 返回清理位置
        return chair_id - 1
    until true end
end

function DESK_OB:get_chair_by_player(user_ob)
    local chair_lst = self:query("chair")
    if not chair_lst then
        return INVALID_CHAIR
    end

    for chair_id = 1, max_chair_count do
        if chair_lst[chair_id] == user_ob then
            return chair_id - 1
        end
    end
end

function DESK_OB:get_players()
    local players = {}
    local chair_lst = self:query("chair")
    if not chair_lst then
        return players
    end

    for chair_id = 1, max_chair_count do repeat
        local user_ob = chair_lst[chair_id]
        if not user_ob then
            break
        end
        
        players[#players + 1] = user_ob
    until true end
    return players
end

function DESK_OB:get_player_count()
    local chair_lst = self:query("chair")
    if not chair_lst then
        return 0
    end

    local count = 0
    for chair_id = 1, max_chair_count do repeat
        local user_ob = chair_lst[chair_id]
        if not user_ob then
            break
        end
        
        count = count + 1
    until true end
    return count
end

function DESK_OB:set_grade(grade)
    self:set_temp("grade", grade)
end

function DESK_OB:get_grade()
    return self:query_temp("grade") or 0
end

function DESK_OB:is_in_fishgroup()
    if not self:query_temp("isInTimeline") then
        return true
    end
    return false
end

function DESK_OB:get_timeline_index()
    return self:query_temp("timelineIndex") or 0
end

function DESK_OB:get_timeline_index_ex()
    local level = self:query_temp("timelineLevel") or 0
    local index = self:query_temp("timelineIndex") or 0
    return level * 100 + index
end

function DESK_OB:check_fishgroup_coming(frame_count)
    return ROOM_D:check_fishgroup_coming(self, frame_count)
end

function DESK_OB:get_fishgroup_left_seconds(frame_count)
    return ROOM_D:get_fishgroup_left_seconds(self, frame_count)
end

function DESK_OB:get_frame_count()
    return ROOM_D:get_frame_count(self)
end

function DESK_OB:brocast_packet(MsgType, MsgValue, exclude_player_ids)
    local players = self:get_players()
    if not players then
        return
    end

    for _, player in ipairs(players) do repeat
        player:send_packet(MsgType, MsgValue, exclude_player_ids)
    until true end
end

function DESK_OB:destory(notify)
    return ROOM_D:destory_desk(self, notify)
end

function DESK_OB:destory_delay(secs)
    return ROOM_D:destory_desk_delay(self, secs)
end
