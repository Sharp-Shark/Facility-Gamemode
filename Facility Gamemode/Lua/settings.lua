-- All the Settings and their default values
FG.settingsDefault = {
	info = 'the default classic PvPvE Facility Gamemode settings.',
	author = 'Sharp-Shark',
	gamemode = 'default',
	monsterSpawn = 'default',
	friendlyFire = false,
	allowEnd = true,
	allowEndMinPlayers = 2,
	autoJob = true,
	autoJobMinPlayers = 2,
	autoJobRoleSequence = 'xsiig-xisig',
	decontaminationTimer = 60*12 + 15,
	terroristTickets = 3.5,
	nexpharmaTickets = 4.5,
	respawnType = 'default',
	respawnSpeed = 16.5,
	respawnAccel = 1.5,
	initialTrollPercentage = 20,
	conversionTrollPercentage = 20
}

-- For FG Config Editor GUI - for string settings which have a set of predefined values
FG.settingsDropdown = {
	gamemode = {
		'default',
		'husk',
		'greenskin'
	},
	monsterSpawn = {
		'default',
		'staff',
		'inmate',
		'corpse'
	},
	respawnType = {
		'default',
		'split',
		'infiniteguards'
	}
}

-- For FG Config Editor GUI - for string settings which only have some legal characters
FG.settingsLegalChars = {
	autoJobRoleSequence = 'xosegijm-'
}

-- For FG Config Editor GUI - description for each setting
FG.settingsDescription = {
	info = 'the description of your settings preset.',
	author = 'whoever made the settings preset (fancy name for gamemode).',
	gamemode = 'changes a critical detail about the gamemode.',
	monsterSpawn = 'determines which spawnpoint the monster will be placed in.',
	friendlyFire = 'lets people of the same team hurt each other.',
	allowEnd = 'whether the round can end.',
	allowEndMinPlayers = 'minimun players for round to end. Takes priority over "allowEnd".',
	autoJob = 'whether jobs will be overriden for balance.',
	autoJobMinPlayers = 'minimun players for autojob. Takes priority over "autoJob".',
	autoJobRoleSequence = 'the sequence of roles that will be assigned to players.',
	decontaminationTimer = 'the time in seconds until decontamination.',
	terroristTickets = 'initial terrorist ticket count.',
	nexpharmaTickets = 'initial nexpharma ticket count.',
	respawnType = 'determines the respawn system used.',
	respawnSpeed = 'determines how short the respawn wait time is.',
	respawnAccel = 'determines by how much the respawn timer increases after each respawn wave.',
	initialTrollPercentage = 'the chance for a goblin to be a troll instead at the start of the round.',
	conversionTrollPercentage = 'the chance for a goblin to be a troll instead when they are converted.'
}

-- Prepackaged Settings Presets or "SubGameModes"
FG.settingsPresetsDefault = {
	default = FG.settingsDefault,
	['nomonsters'] = {
		info = 'the default gamemode with all monsters removed.',
		author = 'Sharp-Shark',
		autoJobRoleSequence = 'siig-isig'
	},
	['huskmode'] = {
		info = 'monsters are now player controlled husks.',
		author = 'Sharp-Shark',
		gamemode = 'husk',
		monsterSpawn = 'corpse'
	},
	['jetinvasion'] = {
		info = 'a PvP only mode where staff+guards defend agaisnt the JET.',
		author = 'Sharp-Shark',
		autoJobRoleSequence = 'jogs',
		terroristTickets = 0,
		nexpharmaTickets = 99,
		respawnType = 'split'
	},
	['prisonescape'] = {
		info = 'a PvP only mode where the guards must kill all the escapees.',
		author = 'Sharp-Shark',
		autoJobRoleSequence = 'igie',
		terroristTickets = 4,
		nexpharmaTickets = 0.5
	},
	['scp:cb'] = {
		info = 'inspired by SCP:CB, JET+inmates fight agaisnt the monsters and people only respawn as MERCS.',
		author = 'SonicHegehodge',
		autoJobRoleSequence = 'xiiji-xji',
		terroristTickets = 0,
		nexpharmaTickets = 3,
		respawnSpeed = 10
	},
	['surfacetension'] = {
		info = 'endless team PvP gamemode with JET vs MERCS at surface zone.',
		author = 'Sharp-Shark',
		autoJobRoleSequence = 'mj',
		decontaminationTimer = 60*0.2 + 15,
		terroristTickets = 1.5,
		nexpharmaTickets = 1.5,
		respawnType = 'split',
		respawnSpeed = 999,
		respawnAccel = 1
	},
	['ffa'] = {
		info = 'endless FFA (Free For All) gamemode with guards. No decontamination.',
		author = 'Sharp-Shark',
		friendlyFire = true,
		allowEnd = false,
		autoJobMinPlayers = 0,
		autoJobRoleSequence = 'g',
		decontaminationTimer = 999999,
		respawnType = 'infiniteguards',
		respawnSpeed = 999,
		respawnAccel = 1
	},
	['trollmode'] = {
		info = 'monsters are now player controlled trolls, a stronger and dumber subspecies of goblins.',
		author = 'Sharp-Shark',
		gamemode = 'greenskin',
		initialTrollPercentage = 100
	},
	['greenskinlair'] = {
		info = 'the facility has become a greenskin lair and the JET are here to clean things up.',
		author = 'Sharp-Shark',
		gamemode = 'greenskin',
		monsterSpawn = 'staff',
		autoJobRoleSequence = 'jxx',
		decontaminationTimer = 60*9 + 15,
		terroristTickets = 1,
		nexpharmaTickets = -99
	},
	['vietnam'] = {
		info = 'the facility has become a greenskin lair and the MERCS are here to clean things up.',
		author = 'Sharp-Shark',
		gamemode = 'greenskin',
		monsterSpawn = 'staff',
		autoJobRoleSequence = 'mxx',
		decontaminationTimer = 60*9 + 15,
		terroristTickets = -99,
		nexpharmaTickets = -1
	}
}

-- Sets the settings presets to the default
FG.settingsPresets = table.copy(FG.settingsPresetsDefault)

-- Sets the current settings to the default
FG.settings = table.copy(FG.settingsDefault)

-- Settings presets sent by clients
FG.settingsPresetsReceived = {}

-- Saves FG.settingsPresets to the config
function saveSettingsPresets()
	if not pcall(function ()
		File.Write(FG.path .. '/config.json', json.serialize(FG.settingsPresets))
	end) then
		print('[!] Error when saving settings presets to config!')
	end
end

-- Loads the config to FG.settingsPresets
function loadSettingPresets()
	if not pcall(function ()
		FG.settingsPresets = json.parse(File.Read(FG.path .. '/config.json'))
	end) then
		print('[!] Error when loading settings presets from config!')
	end
end

-- Load settings presets from config file if it exists or create one
if File.Exists(FG.path .. '/config.json') then
	loadSettingPresets()
else
	print('[!] Settings presets config file missing! Creating one...')
	saveSettingsPresets()
end

-- Receive config file from admins
Networking.Receive("loadClientPreset", function (message, client)
	print('[!] Received settings preset from a client.')
	if client.HasPermission(ClientPermissions.ConsoleCommands) then
		FG.settings = table.copy(FG.settingsDefault)
		local receivedSettings = json.parse(message.ReadString())
		for key, value in pairs(receivedSettings) do
			FG.settings[key] = value
		end
		messageClient(client, 'text-general', string.localize('settingsApplied', nil, client.Language))
	else
		local settingsPresetReceived = json.parse(message.ReadString())
		if settingsPresetReceived.author == nil then
			settingsPresetReceived.author = client.Name
		end
		FG.settingsPresetsReceived[client.Name] = {[message.ReadString()] = settingsPresetReceived}
		messageClient(client, 'text-general', string.localize('settingsReceived', nil, client.Language))
	end
end)

FG.loadedFiles['settings'] = true