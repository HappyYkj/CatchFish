local function main (userOb, msgData)
    local roomType = msgData.level
    if userOb:get_desk() then
        local result = {}
        result.errorCode = GetDeskFailReason.kGetDeskFailReasonAlreadyInDesk
        userOb:send_packet("MSGS2CGetDesk", result)
        return
    end

    local roomConfig = ROOM_CONFIG:get_config_by_roomtype(roomType)
    if not roomConfig then
        local result = {}
        result.errorCode = GetDeskFailReason.kGetDeskFailReasonErrorGrade
        userOb:send_packet("MSGS2CGetDesk", result)
        return
    end

    if not ROOM_CONFIG:is_gunrate_validate(roomConfig, userOb:get_max_gunrate()) then
        local result = {}
        result.errorCode = GetDeskFailReason.kGetDeskFailReasonGunRateError
        userOb:send_packet("MSGS2CGetDesk", result)
        return
    end

    if not ROOM_CONFIG:is_grade_validate(roomConfig, userOb:get_grade()) then
        local result = {}
        result.errorCode = GetDeskFailReason.kGetDeskFailReasonGradeError
        userOb:send_packet("MSGS2CGetDesk", result)
        return
    end

    ---! 桌子管理器分配桌子
    if not ROOM_D:assign_desk(userOb, roomType) then
        local result = {}
        result.errorCode = GetDeskFailReason.kGetDeskFailReasonRoomFull
        userOb:send_packet("MSGS2CGetDesk", result)
        return
    end

    ---! 分配桌子成功
    ROOM_D:enter_desk(userOb)
end

COMMAND_D:register_command("MSGC2SGetDesk", GameCmdType.HALL, main)
