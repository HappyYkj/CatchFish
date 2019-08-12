GameCmdType = {
    NONE = 0,
    HALL = 1,
    DESK = 2,
}

CallFishFailType = {
    kCallFishFailTypeNone = 0,
    kCallFishFailTypeNoCrystal = 1,
    kCallFishFailTypeFishIsFull = 2
}

VipLoginDrawFailType = {
    kVipLoginDrawFailTypeNone = 0,
    kVipLoginDrawFailTypeNoFishIcon = 1,
    kVipLoginDrawFailTypeNoTimes = 2,
    kVipLoginDrawFailTypeOnTimeHourGlass = 3
}

GamePropIds = {
    kGamePropIdsFishIcon = 1,       -- 鱼币
    kGamePropIdsCrystal = 2,        -- 水晶
    kGamePropIdsFreeze = 3,         -- 冰冻
    kGamePropIdsAim = 4,            -- 瞄准
    kGamePropIdsCallFish = 5,       -- 神灯
    kGamePropIdsNBomb = 6,          -- 炸弹
    kGamePropIdsFrameCrystal = 7,   -- 烈焰结晶
    kGamePropIdsIceCrystal = 8,     -- 寒冰结晶
    kGamePropIdsWindCrystal = 9,    -- 狂风结晶
    kGamePropIdsEarthCrystal = 10,  -- 厚土结晶
    kGamePropCrystalEnerge = 11,    -- 结晶能量
    kGamePropLotteryTicket = 12,    -- 奖券
    kGamePropRoomCard = 13,         -- 普通房卡
    kGamePropTimeHourGlass = 14,    -- 时光沙漏
    kGamePropSMALLBOMB = 15,        -- 小核弹
    kGamePropBIGBOMB = 16,          -- 大核弹
    kGamePropViolent = 17,          -- 狂暴
    kGamePropFishTicket = 18,       -- 鱼券
    kGamePropRedpackage = 19,       -- 新手红包
    kGamePropWarheadBronze = 21,    -- 青铜弹头
    kGamePropWarheadSilver = 22,    -- 白银弹头
    kGamePropWarheadLightning = 23, -- 闪电弹头
    kGamePropRedPackage_3yuan = 24, -- 3元兑换红包
    kGamePropMonsterStone = 25,     -- 召唤石头
    kGamePropMonsterJigsaw1 = 26,   -- 拼图1
    kGamePropMonsterJigsaw2 = 27,   -- 拼图1
    kGamePropMonsterJigsaw3 = 28,   -- 拼图1
    kGamePropMonsterJigsaw4 = 29,   -- 拼图1
    kGamePropMonsterJigsaw5 = 30,   -- 拼图1
    kGamePropMonsterJigsaw6 = 31,   -- 拼图1
    kGamePropMonsterJigsaw7 = 32,   -- 拼图1
    kGamePropMonsterJigsaw8 = 33,   -- 拼图1
    kGamePropMonsterJigsaw9 = 34,   -- 拼图1
    kGamePropWarheadIron = 35,      -- 黑铁弹头
}

GameSeniorPropIds = {
    kGameSeniorPropIdsRoomCard = 1001,              -- 高级房卡
    kGameSeniorPropIdsCannon1 = 1002,               -- 限时炮台
    kGameSeniorPropIdsCannon2 = 1003,               -- 限时炮台
    kGameSeniorPropIdsCannon3 = 1004,               -- 限时炮台
    kGameSeniorPropIdsCannon4 = 1005,               -- 限时炮台
    kGameSeniorPropIdsCannon5 = 1006,               -- 限时炮台
    kGameSeniorPropIdsLuckyChest1 = 2004,           -- 幸运宝箱1
    kGameSeniorPropIdsLuckyChest2 = 2005,           -- 幸运宝箱2
    kGameSeniorPropIdsXianJinRedPackage = 2006,     -- 现金红包
    kGameSeniorPropIdsTomorrowGift = 2007,          -- 明日礼包
    kGameSeniorPropIdsCatchFishRate = 2008,         -- 提升捕获概率
    kGameSeniorPropIdsNewbieGift = 2009,            -- 启航礼包
    kGameSeniorPropIdsAutoShoot = 2010,             -- 自动开炮
}

PropRecieveType = {
    kPropChangeTypeKillFish = 300,                  -- 杀鱼
    kPropChangeTypeSendBullet = 301,                -- 发射子弹
    kPropChangeTypeUpgradeCannonDrop = 302,         -- 升级炮倍奖励
    kPropChangeTypeGameDraw = 303,                  -- 游戏内抽奖
    kPropChangeTypeLoginDraw = 304,                 -- 登陆抽奖
    kPropChangeTypeVipDraw = 305,                   -- vip抽奖
    kPropChangeTypeMonthCard = 306,                 -- 月卡
    kPropChangeTypeSignIn = 307,                    -- 签到
    kPropChangeTypeInitial = 308,                   -- 新玩家赠送
    kPropChangeTypeAlm = 309,                       -- 救济金
    kPropChangeTypeReturn = 310,                    -- 击中的鱼被其他人打死，返还鱼币
    kPropChangeTypeSecret = 311,                    -- 秘籍
    kPropChangeTypeBuyWithCrystal = 312,            -- 用水晶购买获得
    kPropChangeTypeBuyCost = 313,                   -- 购买消耗
    kPropChangeTypeKillFishDrop = 314,              -- 杀鱼掉落
    kPropChangeTypeUseProp = 315,                   -- 使用道具
    kPropChangeTypeUseCrystal = 316,                -- 使用用水晶
    kPropChangeTypeForgeCost = 317,                 -- 锻造消耗
    kPropChangeTypeForgeDrop = 318,                 -- 锻造掉落
    kPropChangeTypeInvite = 319,                    -- 邀请
    kPropChangeTypeShare = 320,                     -- 分享
    kPropChangeTypeTimeHourGlass = 321,             -- 时光沙漏
    kPropChangeTypeUpgradeCannonCost = 322,         -- 升级炮倍消耗
    kPropChangeTypeDecomposeCost = 323,             -- 锻造材料分解消耗
    kPropChangeTypeDecomposeDrop = 324,             -- 锻造材料分解获得
    kPropChangeTypeTaskReward = 325,                -- 任务奖励
    kPropChangeTypeActiveReward = 326,              -- 活跃奖励
    kPropChangeTypeVipDailyReward = 327,            -- vip每日总送
    kPropChangeTypeVipFishIconRecruit = 328,        -- vip鱼币补足
    kPropChangeTypeFreezeWithCrystal = 329,         -- 用水晶冰冻
    kPropChangeTypeAimWithCrystal = 330,            -- 用水晶瞄准
    kPropChangeTypeNBombWithCrystal = 331,          -- 用水晶核弹
    kPropChangeTypeNBombWithCallFish = 332,         -- 用水晶召唤鱼
    kPropChangeTypeMail = 333,                      -- 邮件
    kPropChangeTypeRecievePhoneFare = 334,          -- 话费兑换消耗
    kPropChangeTypeRecievePhoneFareReturn = 335,    -- 花费兑换失败返还
    kPropChangeTypeUpgrade = 336,                   -- 升级
    kPropChangeTypeViolentWithCrystal = 337,        -- 使用钻石狂暴
    kPropChangeTypeCannonUse = 338,                 --
    kPropChangeTypeNewTaskReward = 340,             -- 新手任务奖励
    kPropChangeTypeSell = 341,                      -- 道具出售
    kPropChangeTypeSellDrop = 342,                  -- 道具出售获得
    kPropChangeTypeNewerReward = 343,               -- 新手奖励
    kPropChangeTypeCharge = 344,                    -- 充值
    kPropChangeTypeFishTicketDrawCost = 345,        -- 鱼券抽奖消耗
    kPropChangeTypeFishTicketDrawGet = 346,         -- 鱼券抽奖获得
    kPropChangeTypeRedPackage = 347,                -- 红包领取
    kPropChangeTypeRewardTask = 348,                -- 悬赏任务获得
    kPropChangeCommonShare = 349,                   -- 通用分享
    kPropChangeMasterSignup = 350,                  -- 大师赛报名
    kPropChangePayFreetime = 352,                   -- 免费场缴费
    kPropChangeTypeFreeFishIcon = 353,              -- 免费渔币
    kPropChangeTypeBonusPool = 354,                 -- 奖金池奖励
    kPropChangeTypeBossReward = 355,                -- 专属boss额外奖励
    kPropChangeSeperateGunForge = 356,              -- 分身炮台锻造
    kPropChangeTomorrowGift = 357,                  -- 明日礼包
    kPropChangeSupermaketFishTicket = 358,          -- 商城鱼券兑换
    kPropChangeHappyThirtySec = 359,                -- 开心30秒
    kPropGuessSize = 360,                           -- 押大小
    kPropChangeMonster = 361,                       -- 打怪兽
    kPropChangeMermaid = 362,                       -- 美人鱼
    kPropChangeTypeOnlineReward = 363,              -- 在线时长奖励
    kPropChagneTypeGetVipGift = 364,                -- 领取vip礼包获得
    kPropChangeTypeBatchBullet = 365,               -- 批量发射子弹
	kPropChangeTypeMagicOrbs = 366,                 -- 魔法宝珠（兑换或清除）
}


RecordFishIconType = {
    kRecordFishIconTypeEnterGame = 0,
    kRecordFishIconTypeLeaveGame = 1,
    kRecordFishIconTypeTimer = 2
}

SendDataScenario = {
    kGroupSend = 0,
    kDeskSend = 1
}

GiftIds = {
    kGiftIdsLuckyChest1 = 1024,
    kGiftIdsLuckyChest2 = 1025
}

SPECIAL_PROP_START_ID = 2000
SpecialPropIDs = {
    kSpecialPropIDsVipExp = 2001,
    kSpecialPropIDsMonthCard = 2002
}

SellItemErrorCode = {
    kSellItemErrorCodeSuccess = 0,
    kSellItemErrorCodeItemNotExist = 1,
    kSellItemErrorCodeNoEnough = 2,
    kSellItemErrorCodeCannotSell = 3,
    kSellItemErrorCodeErrorCount = 4
}

ChangeNickNameType = {
    kChangeNickNameTypeNormal = 0,
    kChangeNickNameTypeWeChat = 1
}

NewerRewardResult = {
    kNewerRewardResultSuccess = 0,
    kNewerRewardResultNoReward = -1
}

TickRewardDrawStatus = {
    kTickRewardDrawStatusNone = 0,
    kTickRewardDrawStatusGroup = 1,
    kTickRewardDrawStatusDesk = 2

}

GunType = {
    kGunTypeMonthCard = 30
}

VipRecruitFishIconResult = {
    kVipRecruitFishIconResultSuccess = 0,
    kVipRecruitFishIconResultLevelToLow = -1,
    kVipRecruitFishIconResultRecruited = -2,
    kVipRecruitFishIconResultToManyFishIcon = -3,
    kVipRecruitFishIconResultConfigNotFound = -4
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

-- 竞技场类型
ArenaGameType = {
    kArenaGameTypeFreeGame = 500001001,     -- 8人免费
    kArenaGameTypeCrystalGame = 500001002,  -- 水晶
    kArenaGameTypeFishTicket = 500001003,   -- 鱼券
    kArenaGameTypeNBomb = 500001004,        -- 弹头赛
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

MermaidFishID = {
    kMermaidFishLow = 100000601,
}

-- 各类库值的最大值
MAX_DROP_RATE = 1000000000

--玩家属性枚举
EPlayerAttrKeys = {
    eAttrKey_LastOnlineTime = 2,  -- 2上一次在线时间
    eAttrKey_ContinueLoginDays,   -- 3连续登录天数
    eAttrKey_GetVipGifts,         -- 4领取礼包记录，按位取值
    eAttrKey_CurUseHeadFrame,     -- 5当前使用的头像框高级道具物品ID，对应propItemId
    eAttrKey_IsDraw,              -- 6是否已首抽
    eAttrKey_OnlineTime,          -- 7在线时长(秒)，只是个大概值不精确
    eAttrKey_GetDanTou,           -- 8首次获得弹头
}

--物品类型枚举
EItemTypes = {
    eItemType_Gun = 1,          -- 炮台类型
    eItemType_HeadFrame = 2,    -- 头像框
    eItemType_Buff = 3,         -- buff类型
    eItemType_DanTou = 4,       -- 弹头类型
}

GetDeskFailReason = {
    kGetDeskFailReasonNone = 0,
    kGetDeskFailReasonAlreadyInDesk = 1,
    kGetDeskFailReasonErrorGrade = 2,
    kGetDeskFailReasonDeskOccupied = 3,
    kGetDeskFailReasonRoomFull = 4,
    kGetDeskFailReasonGunRateError = 5,
    kGetDeskFailReasonGradeError = 6,
}

-- 新手任务类型
NEWTASK_TYPE = {
    ID_NEWTASKTYPE_KILLGETFISHICON  = 1,    -- 杀死鱼获得鱼币
    ID_NEWTASKTYPE_KILLFISH         = 2,    -- 捕获任意鱼
    ID_NEWTASKTYPE_KILLGETCRYSTAL   = 3,    -- 杀鱼获得水晶
    ID_NEWTASKTYPE_UPGUNRATE        = 4,    -- 升级炮倍
    ID_NEWTASKTYPE_SKILL            = 5,    -- 使用技能
    ID_NEWTASKTYPE_KILLREWARDFISH   = 6     -- 捕获奖金鱼
}

INVALID_GRADE = 0
INVALID_DESK = 65535
INVALID_CHAIR = 65535

DEBUG_VERSION = true
