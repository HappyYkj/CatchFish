local function main (userOb, msgData)
    return MAIL_D:get_mail_list(userOb, msgData.id, msgData.count)
end

COMMAND_D:register_command("MSGC2SMailList", GameCmdType.NONE, main)
