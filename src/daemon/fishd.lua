local is_fisharray_on_frame = function (frame, timelineId, fisharrayId, pointRate)
    ---! 鱼线
    local timeline = TIMELINE_CONFIG:get_config_by_id(timelineId)
    if timeline then
        if timeline.fishid ~= 100 then
            -- 单条鱼
            local fishpath = FISH_PATH_CONFIG:get_config_by_id(timeline.pathid + 300000000)
            if not fishpath then
                return false
            end

            -- 起始帧
            local start_frame = timeline.frame
            if start_frame > frame then
                return false
            end

            -- 总帧数
            local frame_count = #fishpath.pointdata
            if frame_count <= 0 then
                return false
            end

            -- 结束帧
            local end_frame = start_frame + frame_count * pointRate
            if end_frame < frame then
                return false
            end
        else
            local fisharray = FISH_ARRAY_CONFIG:get_config_by_id(fisharrayId)
            if not fisharray then
                return false
            end
            
            if timeline.pathid ~= fisharray.arrId then
                return false
            end

            local fishpath = FISH_PATH_CONFIG:get_config_by_id(fisharray.trace + 300000000)
            if not fishpath then
                return false
            end

            -- 起始帧
            local start_frame = timeline.frame + fisharray.frame
            if start_frame > frame then
                return false
            end
            
            -- 总帧数
            local frame_count = #fishpath.pointdata
            if frame_count <= 0 then
                return false
            end

            -- 结束帧
            local end_frame = start_frame + frame_count * pointRate
            if end_frame < frame then
                return false
            end
        end
        return true
    end

    ---! 鱼潮
    local fishgroup = FISH_GROUP_CONFIG:get_config_by_id(timelineId)
    if fishgroup then
        local fisharray = FISH_ARRAY_CONFIG:get_config_by_id(fisharrayId)
        if not fisharray then
            return false
        end

        if fishgroup.arrId ~= fisharray.arrId then
            return false
        end
        
        local fishpath = FISH_PATH_CONFIG:get_config_by_id(fisharray.trace + 300000000)
        if not fishpath then
            return false
        end

        -- 起始帧
        local start_frame = fishgroup.frame + fisharray.frame
        if start_frame > frame then
            return false
        end
            
        -- 总帧数
        local frame_count = #fishpath.pointdata
        if frame_count <= 0 then
            return false
        end

        -- 结束帧
        local end_frame = start_frame + frame_count * pointRate
        if end_frame < frame then
            return false
        end
        return true
    end
    return false
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
FISH_D = {}

function FISH_D:generate_random_timeline_index(roomType)
    local config = ROOM_CONFIG:get_config_by_roomtype(roomType)
    if not config then
        return 0
    end

    local level = randomchoice(table.keys(config.timeline_groupid))
    local index = config.timeline_groupid[level]
    return level, index
end

function FISH_D:generate_random_fishgroup_index()
    return FISH_GROUP_CONFIG:generate_random_fishgroup_index()
end

function FISH_D:get_fishgroup_endframe(index)
    return FISH_GROUP_CONFIG:get_fishgroup_endframe(index)
end

---! 鱼在当下时间是否还是可见
function FISH_D:is_fish_exist_and_alived(desk, frame, timelineId, fisharrayId)
    if not is_fisharray_on_frame(frame, timelineId, fisharrayId, FISH_SERVER_CONFIG.pointRate) then
        -- 当前帧鱼不可见
        spdlog.debug("fish", string.format("timelineId = %s fisharrayId = %s not on frame %s", timelineId, fisharrayId, frame))
        return false
    end

    if desk:query_temp("killed_fishes", timelineId, fisharrayId) then
        -- 这条鱼已经被杀死了
        spdlog.debug("fish", string.format("timelineId = %s fisharrayId = %s found in killed fish", timelineId, fisharrayId))
        return false
    end

    return true
end

---! 获取当前帧可见的鱼
function FISH_D:get_killed_fishes_on_frame(desk, frame)
    local fishes = {}
    local killed_fishes = desk:query_temp("killed_fishes")
    if not killed_fishes then
        return fishes
    end

    for timelineId, fisharrayId_map in pairs(killed_fishes) do
        timelineId = tonumber(timelineId)
        for fisharrayId, fish in pairs(fisharrayId_map) do
            fisharrayId = tonumber(fisharrayId)
            if is_fisharray_on_frame(frame, timelineId, fisharrayId, FISH_SERVER_CONFIG.pointRate) then
                fishes[#fishes + 1] = fish
            end
        end
    end
    return fishes
end

---! 增加被杀死的鱼
function FISH_D:add_killed_fish(desk, timelineId, fisharrayId)
    if timelineId == 0 then
        return
    end

    if timelineId < 0 then
        ---! 召唤鱼，转由召唤管理器进行处理
        desk:remove_callfish(-timelineId, fisharrayId)
        return
    end

    --[[ ----undo: timelineId 与 fisharrayId 在外部调用时，已经做过校验，该鱼一定可见
    if not is_fisharray_on_frame(desk:get_frame_count(), timelineId, fisharrayId, FISH_SERVER_CONFIG.pointRate) then
        -- 该鱼当前不可见
        return
    end
    --]]

    local fish = {}
    fish.timelineId = timelineId
    fish.fisharrayId = fisharrayId
    desk:set_temp("killed_fishes", timelineId, fisharrayId, fish)
end

---! 获取当前鱼使用的id
function FISH_D:get_fishid_by_fisharray(desk, timelineId, fisharrayId)
    ---! 鱼线
    local timeline = TIMELINE_CONFIG:get_config_by_id(timelineId)
    if timeline then
        if timeline.fishid ~= 100 then
            return timeline.fishid
        end

        local fisharray = FISH_ARRAY_CONFIG:get_config_by_id(fisharrayId)
        if not fisharray then
            return
        end

        if timeline.pathid ~= fisharray.arrId then
            return
        end

        return fisharray.fishid
    end

    ---! 鱼潮
    local fishgroup = FISH_GROUP_CONFIG:get_config_by_id(timelineId)
    if fishgroup then
        local fisharray = FISH_ARRAY_CONFIG:get_config_by_id(fisharrayId)
        if not fisharray then
            return false
        end

        if fishgroup.arrId ~= fisharray.arrId then
            -- 鱼串id不匹配
            return false
        end
        
        return fisharray.fishid
    end
end

---! 获取当前鱼使用的真实id
function FISH_D:get_true_fish_type(desk, fishId, timelineId, fisharrayId)
    local true_fish_id = desk:query_temp("hiited_fishes", timelineId, fisharrayId)
    if not true_fish_id then
        true_fish_id = IRON_CONFIG:get_true_fish_id(fishId, desk:get_grade())
        desk:set_temp("hiited_fishes", timelineId, fisharrayId, true_fish_id)
    end
    return FISH_CONFIG:get_config_by_id(true_fish_id)
end

---! 移除所有已经被杀死的鱼
function FISH_D:remove_all_killed_fishes(desk)
    desk:delete_temp("hiited_fishes")
    desk:delete_temp("killed_fishes")
end
