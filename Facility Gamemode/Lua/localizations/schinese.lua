FG.localizations['Simplified Chinese'] = {
	GUIRespawnTime = '在 {time} 之后重生',
	GUIRespawnTimeJet = '对于T阵营',
	GUIRespawnTimeMercs = '对于Nex制药公司。',
	GUIRespawnTimeRandom = '对于随机的一个队伍',
	GUIDeconTime = '在 {time} 之后净化',
	GUIDeconStart = '净化已开始',
	
	serverMessageText = [[模组由 Sharp-Shark 制作！发送 /help 获取命令。
DISCORD: https://discord.gg/c7Qnp8S4yB

]],
	joinMessageText = [[_欢迎游玩由Sharp-Shark开发的 Facility Gamemode。请遵循规则。如果你愿意，加入我们的Discord。
	
_游戏开始时，你的目标是成为最后一支幸存的队伍。
_如果你是文职成员，尝试逃离设施并为你的队伍获得入场券，入场券决定了你队伍的重生次数。
_如果你是武装成员，消灭其他队伍并帮助你队伍中的文职成员在他们的任务中逃脱。
	
_你选择的职业可能会被游戏模式的自动平衡脚本覆盖，但脚本仍旧会尝试为你分配所选职业。此外，只有是首选职业才会被脚本考虑。
	
_发送 /help 查看命令列表。]],
	dieMessageText = [[如果你死了。发送 /respawn 查询重生预计时间和入场券的数量。若死去的人越多，重生速度越快。

如果你认为你的死亡是因bug导致，或者是有人违反规则而造成的，在我们的Discord中反馈。
Discord: https://discord.gg/c7Qnp8S4yB]],

	gamemodeInfo = '游戏模式信息：{text}',

	commandRoundNotStarted = '巡回还未开始。',
	commandAdminOnly = '仅管理员命令！',
	commandHelp = [[/help - 查看命令列表。
/boo - 我是一个令人毛骨悚然的鬼魂！
/vote - 发起一个游戏模式的投票。
/admin - 引起管理员的注意。
/admin <text> - 发送文本给管理员。
/players - 查看玩家列表及其职责。
/tickets - 查看JET（朱庇特精英部队）和MERCS（机动紧急救援作战小组）的入场券总数。
/decon - 查看净化完成时间。
/gamemodes - 查看所有游戏模式。
/gamemode - 查看当前游戏模式的数据。
/gamemode <name> - 查看指定游戏模式的数据。
]],
	commandHelpAdmin = [[/corpses - 开关尸体生成。
/spectator - 切换为观看者。
/spectator <player> - 切换玩家(player)为观看者。
/spectators - 查看观看者。
/vote <arguments> - 发起投票。
/cfg <arguments> - 管理员配置模式
]],
	commandPlayersTerroristCivilian = ' 是一名T阵营的文职成员。',
	commandPlayersTerroristMilitant = ' 是一名T阵营的武装成员。',
	commandPlayersNexpharmaCivilian = ' 是一名Nex制药公司的文职成员。',
	commandPlayersNexpharmaMilitant = ' 是一名Nex制药公司的武装成员。',
	commandPlayersMutatedMantis = ' 是一只变异的虾脊螳螂。',
	commandPlayersMutatedCrawler = ' 是一只变异的藻鬃爬行者。',
	commandPlayersHusk = ' 是一副躯壳。',
	commandPlayersGoblin = ' 是一个哥布林。',
	commandPlayersTroll = ' 是一头巨怪。',
	commandRespawnTime = '重生：{text}.',
	commandRespawnNoTickets = '没有入场券，无法重生。',
	commandTickets = [[T阵营拥有 {terroristTickets} 张入场券。
Nex制药公司拥有 {nexpharmaTickets} 张入场券。
拥有入场券数量更多的队伍将重生。在数量相同的情况下，随机选择队伍进行重生。]],
	commandDeconTime = '在 {time} 之后净化',
	commandDeconStart = '净化已开始',
	
	booGainedXP = '/boo: you have gained {xp} xp.',
	booLevelUp = '/boo: ascended to level {level}.',
	booPowerNeeded = '/boo: {power} needed.',
	booPowerLeft = '/boo: {power} power left.',
	booActionFailed = '/boo: ghost action failed.',
	booRespawnEnabled = '/boo: respawning enabled.',
	booRespawnDisabled = '/boo: respawning disabled.',
	
	deconTimeStart = '设施净化已经开始。',
	deconTimeTenSeconds = '还剩 10 秒完成设施净化。',
	deconTimeCountdown = '还剩 {time} 秒...',
	deconTimeMinute = '还剩 1 分钟完成设施净化。',
	deconTimeMinutes = '还剩 {time} 分钟完成设施净化。',
	
	ticketsEveryoneOutOfTickets = '所有入场券已消耗殆尽 — 无法重生！',
	ticketsTerroristsOutOfTickets = 'T阵营已无入场券 — 无法重生！',
	ticketsNexpharmaOutOfTickets = 'Nex制药公司已无入场券 — 无法重生！',
	ticketsInmateEscape = 'T阵营赢得了 2 张入场券 — 文职成员逃脱了！剩余 {tickets} 张入场券！',
	ticketsStaffEscape = 'Nex制药公司赢得了 1 张入场券 — 文职成员逃脱了！剩余 {tickets} 张入场券！',
	ticketsStaffCuffedEscape = 'T阵营赢得了 1.5 张入场券 — 已经逮捕了！剩余 {tickets} 张入场券！',
	ticketsInmateCuffedEscape = 'Nex制药公司赢得了 1.5 张入场券 — 已经逮捕了！剩余 {tickets} 张入场券！',
	ticketsTerroristInfectedDown = 'T阵营赢得了 0.5 张入场券 — 杀害感染体！剩余 {tickets} 张入场券！',
	ticketsNexpharmaInfectedDown = 'Nex制药公司赢得了 0.5 张入场券 — 杀害感染体！剩余 {tickets} 张入场券！',
	ticketsTerroristMonsterDown = 'T阵营赢得了 2 张入场券 — 杀害怪物！剩余 {tickets} 张入场券！',
	ticketsNexpharmaMonsterDown = 'Nex制药公司赢得了 2 张入场券 — 杀害怪物！剩余 {tickets} 张入场券！',
	ticketsTerroristHumanDownByInmate = 'T阵营赢得了 1 张入场券 — 囚禁人员杀害人类！剩余 {tickets} 张入场券！',
	ticketsTerroristHumanDown = 'T阵营赢得了 0.5 张入场券 — 杀害人类目标！剩余 {tickets} 张入场券！',
	ticketsNexpharmaHumanDown = 'Nex制药公司赢得了 0.5 张入场券 — 杀害人类目标！剩余 {tickets} 张入场券！',
	ticketsTerroristGoblinDown = 'T阵营赢得了 0.5 张入场券 — 杀害哥布林！剩余 {tickets} 张入场券！',
	ticketsNexpharmaGoblinDown = 'Nex制药公司赢得了 0.5 张入场券 — 杀害哥布林！剩余 {tickets} 张入场券！',
	ticketsTerroristTrollDown = 'T阵营赢得了 1.5 张入场券 — 杀害巨魔！剩余 {tickets} 张入场券！',
	ticketsNexpharmaTrollDown = 'Nex制药公司赢得了 1.5 张入场券 — 杀害巨魔！剩余 {tickets} 张入场券！',
	
	castVote = '你已为 "{option}" 投票，不能更改！',
	castVoteCount = '当前，有 {total} 分之 {current} 的玩家投票。',
	
	voteMidMatch = "无法在巡回中途投票。",
	voteGamemodeAlreadyEnded = '游戏模式投票已经结束了！',
	voteStarted = '投票已经开始了，发送"/vote end"。',
	voteNotStarted = '没有投票正在进行。',
	
	voteStartHeader = '民主时间！为下列其中一项进行投票：',
	voteStartFooter = '在聊天框键入你想投票的选项。',
	
	voteRepeatHeader = '键入其中一项进行投票：',
	voteRepeatItem = '{option} 有 {votes} 票，',
	
	voteEndHeader = '投票已结束！结果在下方。',
	voteEndItem = '选项 "{option}" 得到了 {votes} 票。',
	voteEndFooter = '选中者为：',
	
	ending = '在 {time} 之后结束',
	endStalemate = '本次巡回以僵局告终 — 没有任何存活的玩家。',
	endTerrorist = '巡回结束，T阵营获胜 — 已铲除所有其他队伍。',
	endNexpharma = '巡回结束，Nex制药公司获胜 — 已铲除所有其他队伍。',
	endMonster = '巡回结束，怪物获胜 — 已铲除所有其他队伍。',
	endPlayer = '巡回结束，{name} 获胜 — 所有其他玩家被淘汰。',
	
	settingsReceived = '您的预设设置在服务器提交列表中。',
	settingsApplied = '您的预设设置已被服务器加载。',
	
	FFEnabled = '允许友军伤害。',
	
	overseerInfo = 'Nex制药公司的文职成员，与机动紧急救援作战小组（MERCS）和警卫合作并逃离设施。作为高层人员，配备了左轮手枪和监工ID卡（行政3级）。',
	researcherInfo = 'Nex制药公司的文职成员，与机动紧急救援作战小组（MERCS）和警卫合作并逃离设施。一名低级研究人员。',
	repairmenInfo = 'Nex制药公司的文职成员，与机动紧急救援作战小组（MERCS）和警卫合作并逃离设施。基础维护人员。',
	inmateInfo = 'T阵营的文职成员，与其他T阵营成员合作并逃离设施。遭受压迫、忍受考验、视为卑微的存在——兄弟们，今夜，我们要挣脱束缚！配备了一些违禁物品。',
	jetInfo = "T阵营的武装成员，消灭怪物和Nex制药公司人员，帮助囚禁人员逃离设施。朱庇特精英部队（JET），给他们点颜色瞧瞧！装备了重武器、药物和JET设备（行政2级、武装3级）。",
	mercsInfo = 'Nex制药公司的武装成员，消灭怪物和T阵营，帮助员工逃离设施。机动紧急救援作战小组（MERCS）报告！装备了重武器、药物和MERCS\'ID卡（行政3级、武装3级）。',
	eliteguardInfo = 'Nex制药公司的武装成员，消灭怪物和囚禁人员，帮助员工逃离设施。高级别安保人员，主要负责指挥其他警卫，配备了手枪、防弹衣和精英警卫ID卡（行政2级、武装2级）。',
	enforcerguardInfo = 'Nex制药公司的武装成员，消灭怪物和囚禁人员，帮助员工逃离设施。现场安保人员，只负责控制囚禁人员，配备了PWD、防弹衣和执行警卫钥匙卡（行政1级、武装1级）。',
	mutatedMantisInfo = '一只移动不便、虚弱无力但生命力极强的怪物。与剩下的怪物杀死所有人类！你可以啃食尸体，打开普通的门、驾驶电车和使用本地语音。',
	mutatedCrawlerInfo = '一只快速、蛮横且生命力顽强的怪物。与剩下的怪物杀死所有人类！你可以啃食尸体，打开普通的门、驾驶电车和使用本地语音。',
	greenskinInfo = '一只灵活的两栖生物，喜欢和猎物玩游戏。被戴上面具的活人会变成哥布林。躲藏在哥布林箱内可以恢复生命。',
	huskInfo = '一个虚弱但灵巧及具有传染性的怪物。与你的同族一起杀死所有人类！你可以感染、开门、使用物品以及使用本地语音。',
	
	empty = ''
}

FG.loadedFiles['schinese'] = true