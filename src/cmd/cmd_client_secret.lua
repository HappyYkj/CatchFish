local function main (userOb, msgData)
    if #msgData.newProps < 1 then
        return
    end

    SECRET_D:process_command(userOb, msgData.newProps[1])
end

COMMAND_D:register_command("MSGC2SSetProp", GameCmdType.NONE, main)
