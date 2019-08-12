local function main (userOb, msgData)
    local now = os.time()
    local polling = userOb:query_temp("polling", "MSGC2SFreeArenaGetSignup")
    if polling and now - polling < 3 then
        return
    end
    
    userOb:set_temp("polling", "MSGC2SFreeArenaGetSignup", now)

    return FREE_ARENA_D:send_signup_info(userOb, msgData.arenaType)
end

COMMAND_D:register_command("MSGC2SFreeArenaGetSignup", GameCmdType.HALL, main)
