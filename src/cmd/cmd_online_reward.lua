local function main (userOb, msgData)
    ONLINE_REWARD_D:send_online_reward_data(userOb)
end

COMMAND_D:register_command("MSGC2SRequestOnlineReward", GameCmdType.NONE, main)
