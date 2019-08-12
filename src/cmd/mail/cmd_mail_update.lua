local function main (userOb, msgData)
    return MAIL_D:update_mail(userOb, msgData.id, msgData.op)
end

COMMAND_D:register_command("MSGC2SMailUpdate", GameCmdType.NONE, main)
