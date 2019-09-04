local function main (userOb, msgData)
    LOGIN_D:logout(userOb)
    ONLINE_REWARD_D:update_online_reward_data(userOb)
end

COMMAND_D:register_command("MSG_DISCONNECT", GameCmdType.NONE, main)
