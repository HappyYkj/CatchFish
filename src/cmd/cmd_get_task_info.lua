local function main (userOb, msgData)
    TASK_D:send_task_info(userOb)
end

COMMAND_D:register_command("MSGC2SGetNewTaskInfo", GameCmdType.DESK, main)
