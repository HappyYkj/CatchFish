local function main (userOb, msgData)
    TASK_D:get_task_reward(userOb)
end

COMMAND_D:register_command("MSGC2SGetNewTaskReward", GameCmdType.DESK, main)
