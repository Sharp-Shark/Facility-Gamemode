FG.localizations['English'] = {
	GUIRespawnTime = 'Respawn in {time}',
	GUIRespawnTimeJet = 'for the terrorists',
	GUIRespawnTimeMercs = 'for nexpharma corp.',
	GUIRespawnTimeRandom = 'for a random team',
	GUIDeconTime = 'Decontamination in {time}',
	GUIDeconStart = 'Decontamination initiated',
	
	serverMessageText = [[MOD BY Sharp-Shark! DO /help FOR COMMANDS.
DISCORD: https://discord.gg/c7Qnp8S4yB

]],
	joinMessageText = [[_Welcome to Facility Gamemode by Sharp-Shark. Please have fun and respect the rules. If you want, join our discord.
	
_When the game starts, your objective is to be the last team standing.
_If you are a civilian, try and escape to grant your team tickets. Tickets determine the amount of respawns your team has.
_If you are a militant, kill the other teams and help the civilians from your team in their quest to escape.
	
_Your preferred job may be overriden by the gamemode's autobalance script, but the script will try and give you your desired job if possible. Also, only the 1st job in your preferred jobs list matters.
	
_Do /help for a list of commands.]],
	dieMessageText = [[You have died. Do /respawn to get an estimated time until respawn and amount of tickets. Do /boo to haunt the living. If more people die, it will go down faster.

If you belive your death is a bug or was caused by someone breaking the rules, say so in our discord.
Discord: https://discord.gg/c7Qnp8S4yB]],

	gamemodeInfo = 'Gamemode Info: {text}',

	commandRoundNotStarted = 'Round has not started yet.',
	commandAdminOnly = 'Admin only command!',
	commandHelp = [[/credits - see who contributed to the creation of this mod.
/help - gives command list.
/boo - I'm a spooky ghost!
/vote - starts a gamemode poll.
/admin - calls admin attention.
/admin <text> - sends text to admin.
/players - gives a list of players and their roles.
/tickets - tells JET and MERCS ticket count.
/decon - tells the time until decontamination.
/gamemodes - lists all the gamemodes.
/gamemode - tells data about the current gamemode.
/gamemode <name> - tells data about a specific gamemode.
]],
	commandHelpAdmin = [[/corpses - toggles corpse spawning.
/spectator - toggles yourself as spectator.
/spectator <player> - toggles player as spectator.
/spectators - list spectators.
/vote <arguments> - to start polls.
/cfg <arguments> - for admins to configure the mod.
]],
	commandPlayersTerroristCivilian = ' is a civilian member of the terrorist faction.',
	commandPlayersTerroristMilitant = ' is a militant member of the terrorist faction.',
	commandPlayersNexpharmaCivilian = ' is a civilian member of the nexpharma corp.',
	commandPlayersNexpharmaMilitant = ' is a militant member of the nexpharma corp.',
	commandPlayersMutatedMantis = ' is a mutated mantis.',
	commandPlayersMutatedCrawler = ' is a mutated crawler.',
	commandPlayersHusk = ' is a husk.',
	commandPlayersGoblin = ' is a goblin.',
	commandPlayersTroll = ' is a troll.',
	commandRespawnTime = 'Respawn is going to be {text}.',
	commandRespawnNoTickets = 'No tickets, no respawns.',
	commandTickets = [[Terrorists have {terroristTickets} tickets left.
Nexpharma has {nexpharmaTickets} tickets left.
The team with more tickets respawns. In case of a tie, it's randomized.]],
	commandDeconTime = 'Decontamination in {time}',
	commandDeconStart = 'Decontamination initiated',
	
	booGainedXP = '/boo: you have gained {xp} xp.',
	booLevelUp = '/boo: ascended to level {level}.',
	booPowerNeeded = '/boo: {power} needed.',
	booPowerLeft = '/boo: {power} power left.',
	booActionFailed = '/boo: ghost action failed.',
	booRespawnEnabled = '/boo: respawning enabled.',
	booRespawnDisabled = '/boo: respawning disabled.',
	
	deconTimeStart = 'Complete facility decontamination has been initiated.',
	deconTimeTenSeconds = 'T-10 seconds until complete facility decontamination.',
	deconTimeCountdown = 'T-{time}...',
	deconTimeMinute = 'T-1 minute until complete facility decontamination.',
	deconTimeMinutes = 'T-{time} minutes until complete facility decontamination.',
	
	ticketsEveryoneOutOfTickets = 'Everyone is out of tickets - no more respawns!',
	ticketsTerroristsOutOfTickets = 'Terrorists is out of tickets - no more respawns!',
	ticketsNexpharmaOutOfTickets = 'Nexpharma is out of tickets - no more respawns!',
	ticketsInmateEscape = 'Terrorists have gained 2 tickets - civilian has escaped! {tickets} tickets left!',
	ticketsStaffEscape = 'Nexpharma has gained 1 ticket - civilian has escaped! {tickets} tickets left!',
	ticketsStaffCuffedEscape = 'Terrorists have gained 1.5 tickets - arrest has been made! {tickets} tickets left!',
	ticketsInmateCuffedEscape = 'Nexpharma has gained 1.5 tickets - arrest has been made! {tickets} tickets left!',
	ticketsTerroristInfectedDown = 'Terrorists have gained 0.5 tickets - infected eliminated! {tickets} tickets left!',
	ticketsNexpharmaInfectedDown = 'Nexpharma have gained 0.5 tickets - infected eliminated! {tickets} tickets left!',
	ticketsTerroristMonsterDown = 'Terrorists have gained 2 tickets - monster eliminated! {tickets} tickets left!',
	ticketsNexpharmaMonsterDown = 'Nexpharma have gained 2 tickets - monster eliminated! {tickets} tickets left!',
	ticketsTerroristHumanDownByInmate = 'Terrorists have gained 1 tickets - human eliminated by inmate! {tickets} tickets left!',
	ticketsTerroristHumanDown = 'Terrorists have gained 0.5 tickets - human target eliminated! {tickets} tickets left!',
	ticketsNexpharmaHumanDown = 'Nexpharma have gained 0.5 tickets - human target eliminated! {tickets} tickets left!',
	ticketsTerroristGoblinDown = 'Terrorists have gained 0.5 tickets - goblin eliminated! {tickets} tickets left!',
	ticketsNexpharmaGoblinDown = 'Nexpharma have gained 0.5 tickets - goblin eliminated! {tickets} tickets left!',
	ticketsTerroristTrollDown = 'Terrorists have gained 1.5 tickets - troll eliminated! {tickets} tickets left!',
	ticketsNexpharmaTrollDown = 'Nexpharma have gained 1.5 tickets - troll eliminated! {tickets} tickets left!',
	
	castVote = 'Your vote for "{option}" has been cast and cannot be changed!',
	castVoteCount = 'Currently, {current} out of {total} clients have voted.',
	
	voteMidMatch = "Can't start voting midmatch.",
	voteGamemodeAlreadyEnded = 'Gamemode voting has already been concluded!',
	voteStarted = 'Voting already happeng, do "/vote end".',
	voteNotStarted = 'No vote has been started.',
	
	voteStartHeader = 'Democracy time! Vote in one of these options: ',
	voteStartFooter = 'To vote, just type what you want in chat.',
	
	voteRepeatHeader = 'Just type one of these to vote: ',
	voteRepeatItem = '{option} has {votes} vote(s), ',
	
	voteEndHeader = 'Voting has ended! Results listed below.',
	voteEndItem = 'Option "{option}" got {votes} vote(s).',
	voteEndFooter = 'The winner(s) are: ',
	
	ending = 'ENDING IN {time}',
	endStalemate = 'The match has ended in a STALEMATE - there are no living players.',
	endTerrorist = 'The match has ended in a TERRORIST WIN - all other teams have been eliminated.',
	endNexpharma = 'The match has ended in a NEXPHARMA WIN - all other teams have been eliminated.',
	endMonster = 'The match has ended in a MONSTER WIN - all other teams have been eliminated.',
	endPlayer = 'The match has ended in a {name} WIN - all other players have been eliminated.',
	
	settingsReceived = 'Your settings preset is in the server submission list.',
	settingsApplied = 'Your settings preset has been loaded in by the server.',
	
	FFEnabled = 'FF ENABLED.',
	
	overseerInfo = 'Civilian Member of the Nexpharma team, escape the facility and collaborate with the MERCS and Guards. High-level personnel equipped with a brought-from-home revolver and overseer keycard (Admin Tier 3).',
	researcherInfo = 'Civilian Member of the Nexpharma team, escape the facility and collaborate with the MERCS and Guards. A low-level researcher, equipped with your research and your staff keycard (Admin Tier 1).',
	repairmenInfo = 'Civilian Member of the Nexpharma team, escape the facility and collaborate with the MERCS and Guards. Basic maintenance personnel, equipped with maintancen supplies and your staff keycard (Admin Tier 1).',
	inmateInfo = 'Civilian Member of the Terrorist team, escape the facility and collaborate with the Terrorists. Subjucated, tested on and treated like scum - tonight we escape brothers! Equipped with some contraband.',
	jetInfo = "Militant Member of the Terrorist team, kill monsters and nexpharma personnel, but help inmates escape. Jovian Elite Troops, give 'em hell! Equipped with heavy weaponry, medicine and a JET device (Admin Tier 2 and Weapon Tier 3).",
	mercsInfo = 'Militant Member of the Nexpharma team, kill monsters and terrorists, but help staff escape. Mobile Emergency Rescue and Combat Squad reporting for duty! Equipped with heavy weaponry, medicine and a MERCS keycard (Admin Tier 3 and Weapon Tier 3).',
	eliteguardInfo = 'Armed Member of the Nexpharma team, kill monsters and inmates, but help staff to escape. Senior security, mostly tasked with commanding the other guards, equipped with a pistol, body armor and an elite guard keycard (Admin Tier 2 and Weapon Tier 2).',
	enforcerguardInfo = 'Armed Member of the Nexpharma team, kill monsters and inmates, but help staff to escape. On-site security personnel only meant to keep the inmates in check, equipped with a PWD, body armor and an enforcer guard keycard (Admin Tier 1 and Weapon Tier 1).',
	mutatedMantisInfo = 'A slow and weak monster with lots of HP. Work with your fellow monsters to kill all humans! You may eat corpses, use regular doors, use the trams and use local voicechat.',
	mutatedCrawlerInfo = 'A fast and strong monster with decent HP. Work with your fellow monsters to kill all humans! You may eat corpses, use regular doors, use the trams and use local voicechat.',
	greenskinInfo = 'A kind of amphibious nimble critter that like playing games with their prey. Put masks on living humans to turn them into goblins. Hide in goblin crates to regenerate.',
	huskInfo = 'A weak but infectious and dexterious monster. Work with your fellow monsters to kill all humans! You may infect, use doors, use items and use local voicechat.',
	
	empty = ''
}

FG.loadedFiles['english'] = true