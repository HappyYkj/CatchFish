local function main (userOb, msgData)
    ONLINE_REWARD_D:get_online_reward(userOb)
end

COMMAND_D:register_command("MSGC2SRequestGetOnlineReward", GameCmdType.NONE, main)
