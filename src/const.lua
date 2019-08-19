GameCmdType = {
    NONE = 0,
    HALL = 1,
    DESK = 2,
}

GamePropIds = {
    kGamePropIdsFishIcon = 1,           -- 鱼币
    kGamePropIdsCrystal = 2,            -- 水晶
    kGamePropIdsFreeze = 3,             -- 冰冻
    kGamePropIdsAim = 4,                -- 瞄准
    kGamePropIdsCallFish = 5,           -- 神灯
    kGamePropIdsNBomb = 6,              -- 炸弹
    kGamePropIdsFrameCrystal = 7,       -- 烈焰结晶
    kGamePropIdsIceCrystal = 8,         -- 寒冰结晶
    kGamePropIdsWindCrystal = 9,        -- 狂风结晶
    kGamePropIdsEarthCrystal = 10,      -- 厚土结晶
    kGamePropIdsCrystalEnerge = 11,     -- 结晶能量
    kGamePropIdsViolent = 17,           -- 狂暴
    kGamePropIdsFishTicket = 18,        -- 鱼券
    kGamePropIdsTomorrowGift = 2007,    -- 明日礼包
    kGamePropIdsNewbieGift = 2009,      -- 启航礼包
}

PropChangeType = {
    kPropChangeTypeKillFish = 1,                   -- 杀鱼
    kPropChangeTypeSendBullet = 2,                 -- 发射子弹
    kPropChangeTypeUpgradeCannonDrop = 3,          -- 升级炮倍奖励
    kPropChangeTypeGameDraw = 4,                   -- 游戏内抽奖
    kPropChangeTypeLoginDraw = 5,                  -- 登陆抽奖
    kPropChangeTypeVipDraw = 6,                    -- vip抽奖
    kPropChangeTypeMonthCard = 7,                  -- 月卡
    kPropChangeTypeSignIn = 8,                     -- 签到
    kPropChangeTypeAlm = 9,                        -- 救济金
    kPropChangeTypeSecret = 10,                    -- 秘籍
    kPropChangeTypeBuyWithCrystal = 11,            -- 用水晶购买获得
    kPropChangeTypeBuyCost = 12,                   -- 购买消耗
    kPropChangeTypeUseProp = 13,                   -- 使用道具
    kPropChangeTypeUseCrystal = 14,                -- 使用用水晶
    kPropChangeTypeForgeCost = 15,                 -- 锻造消耗
    kPropChangeTypeForgeDrop = 16,                 -- 锻造掉落
    kPropChangeTypeShare = 17,                     -- 分享
    kPropChangeTypeUpgradeCannonCost = 18,         -- 升级炮倍消耗
    kPropChangeTypeDecomposeCost = 19,             -- 锻造材料分解消耗
    kPropChangeTypeDecomposeDrop = 20,             -- 锻造材料分解获得
    kPropChangeTypeFreezeWithCrystal = 21,         -- 用水晶冰冻
    kPropChangeTypeAimWithCrystal = 22,            -- 用水晶瞄准
    kPropChangeTypeUseCrystalWithCallFish = 23,    -- 用水晶召唤鱼
    kPropChangeTypeMail = 24,                      -- 邮件
    kPropChangeTypeUpgrade = 25,                   -- 升级
    kPropChangeTypeViolentWithCrystal = 26,        -- 使用钻石狂暴
    kPropChangeTypeCannonUse = 27,                 --
    kPropChangeTypeNewTaskReward = 28,             -- 新手任务奖励
    kPropChangeTypeSell = 29,                      -- 道具出售
    kPropChangeTypeNewerReward = 30,               -- 新手奖励
    kPropChangeTypeCharge = 31,                    -- 充值
    kPropChangePayFreetime = 32,                   -- 免费场缴费
    kPropChangeSeperateGunForge = 33,              -- 分身炮台锻造
    kPropChangeTomorrowGift = 34,                  -- 明日礼包
    kPropChangeSupermaketFishTicket = 35,          -- 商城鱼券兑换
    kPropChangeTypeOnlineReward = 36,              -- 在线时长奖励
    kPropChagneTypeGetVipGift = 37,                -- 领取vip礼包获得
}

ShareTypes = {
    kShareTypesCharge = 1,                  -- 充值分享
    kShareTypesInvite = 2,                  -- 邀请好友
    kShareTypesUpgradeCannonNoCrystal = 3,  -- 炮倍水晶不足分享
    kShareTypesUpgrade = 4,                 -- 升级成功
    kShareTypesUpgradeCannon = 5,           -- 炮倍升级成功
    kShareTypesKillBoss = 6,                -- 击杀boss分享
    kShareTypesFishTicketDraw = 7,          -- 渔券抽奖分享
    kShareTypesRewardTask = 8,              -- 悬赏任务分享
    kShareTypesNewerTask = 9,               -- 新手任务分享
    kShareTypesGift = 10,                   -- 购买礼包分享
    kShareTypesForge = 11,                  -- 锻造分享
    kShareTypesNoFishIcon = 12,             -- 鱼币不足分享
    kShareTypesDaily = 13,                  -- 每日分享
    kShareTypesLoginDraw = 14,              -- 每日转盘分享
    kShareTypesNoCrystal = 15,              -- 道具水晶不足分享
    kShareTypesFreeCrystal = 16,            -- 水晶赛比赛报名
    kShareTypesBankruptcy = 17,             -- 破产分享
    kShareTypesFishTicket = 18,             -- 渔券赛比赛报名
    kShareTypesMaster = 19,                 -- 大师赛比赛报名
    kShareTypesFishIcon = 20,               -- 8人免费赛
    kShareTypesDayGift = 21,                -- 每日礼包
    kShareTypesNbomb = 22,                  -- 弹头赛
    kShareTypesRewardBonus = 24,            -- 奖金池抽奖
    kShareTypeFreeTimeFourPeople = 27,      -- 8人免费赛自动参加
    kShareTypeFreeTimeeCrystal = 28,        -- 水晶赛自动参加
    kShareTypeFreeTimeTicket = 29,          -- 渔券赛自动参加
    kShareTypesFinishRookieTask = 30,       -- 新手任务分享后可完成
    kShareTypesAdvertisement = 32,          -- 观看有礼广告分享
}

UpgradeResult = {
    kUpgradeResultSuccess = 0,
    kUpgradeResultInRewardTask = 1,
    kUpgradeResultErrorGunRate = 2,
    kUpgradeResultConfigNotFound = 3,
    kUpgradeResultCrystalNoEnough = 4,
    kUpgradeResultPropNoEnough = 5,
    kUpgradeResultFailed = 6,
    kUpgradeResultOther = 99,
}

ForgeResult = {
    kForgeResultSuccess = 0,
    kForgeResultGunRateError = -1,
    kForgeResultConfigNotFound = -2,
    kForgeResultPropNoEnough = -3,
    kForgeResultCrystalNoEnough = -4,
    kForgeResultCrystalPowerNoEnough = -5,
    kForgeResultFailed = -6
}

-- 各类库值的最大值
MAX_DROP_RATE = 1000000000

GetDeskFailReason = {
    kGetDeskFailReasonNone = 0,
    kGetDeskFailReasonAlreadyInDesk = 1,
    kGetDeskFailReasonErrorGrade = 2,
    kGetDeskFailReasonDeskOccupied = 3,
    kGetDeskFailReasonRoomFull = 4,
    kGetDeskFailReasonGunRateError = 5,
    kGetDeskFailReasonGradeError = 6,
}

INVALID_GRADE = 0
INVALID_DESK = 65535
INVALID_CHAIR = 65535
