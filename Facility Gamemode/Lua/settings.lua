-- All the Settings and their default values
FG.settingsDefault = {
	inherit = 'default',
	hide = true,
	info = 'all other presets inherit from this preset incase a setting value is left unspecified.',
	author = 'Sharp-Shark',
	ghosts = 'regular',
	gamemode = 'default',
	monsterSpawn = 'default',
	lighting = 'default',
	terrorRadius = true,
	friendlyFire = false,
	allowEnd = true,
	allowEndMinPlayers = 2,
	endType = 'default',
	autoJob = true,
	autoJobMinPlayers = 2,
	autoJobRoleSequence = 'xsiig-isxisig',
	autoJobIgnorePreference = false,
	terroristSquadSequence = '0210',
	nexpharmaSquadSequence = '0210',
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
	ghosts = {
		'disabled',
		'regular',
		'poltergeist'
	},
	gamemode = {
		'default',
		'husk',
		'greenskin',
		'brood'
	},
	monsterSpawn = {
		'default',
		'staff',
		'inmate',
		'corpse'
	},
	lighting = {
		'default',
		'greenskin',
		'emergency',
		'clown',
		'blackout'
	},
	endType = {
		'default',
		'battleroyale'
	},
	respawnType = {
		'default',
		'classic',
		'infiniteguards',
		'infiniteinmates'
	}
}

-- For FG Config Editor GUI - for string settings which only have some legal characters
FG.settingsLegalChars = {
	autoJobRoleSequence = 'xosegijm-',
	terroristSquadSequence = '01234',
	nexpharmaSquadSequence = '01234'
}

-- For FG Config Editor GUI - description for each setting
FG.settingsDescription = {
	inherit = 'from which preset this should inherit from. Leave blank for default.',
	hide = 'blacklists the gamemode from voting.',
	info = 'the description of your settings preset.',
	author = 'whoever made the settings preset (fancy name for gamemode).',
	ghosts = 'determines if ghosts are allowed and how powerful they are.',
	gamemode = 'changes a critical detail about the gamemode.',
	monsterSpawn = 'determines which spawnpoint the monster will be placed in.',
	lighting = 'determines the lighting inside the facility - does not change surface.',
	terrorRadius = 'toggles terror radius which lets humans know if a monster is nearby.',
	friendlyFire = 'lets people of the same team hurt each other.',
	allowEnd = 'whether the round can end.',
	allowEndMinPlayers = 'minimun players for round to end. Takes priority over "allowEnd".',
	endType = 'determines the end conditions and how each team can win.',
	autoJob = 'whether jobs will be overriden for balance.',
	autoJobMinPlayers = 'minimun players for autojob. Takes priority over "autoJob".',
	autoJobRoleSequence = 'the sequence of roles that will be assigned to players.',
	autoJobIgnorePreference = 'ignore player preferences when assigning roles.',
	terroristSquadSequence = 'the sequence that dictates how JET subclasses will be given.',
	nexpharmaSquadSequence = 'the sequence that dictates how MERCS subclasses will be given.',
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
	['default'] = FG.settingsDefault,
	['regular'] = {
		info = 'the default classic PvPvE Facility Gamemode settings.',
		author = 'Sharp-Shark',
	},
	['babymode'] = {
		info = 'monsters are replaced with their hatchling variants.',
		author = 'Sharp-Shark',
		gamemode = 'brood',
		autoJobRoleSequence = 'xsixig'
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
		autoJobRoleSequence = 'jsgiejo',
		terroristTickets = 1,
		nexpharmaTickets = 1,
		respawnType = 'classic'
	},
	['prisonescape'] = {
		info = 'a PvP only mode where the guards must kill all the escapees.',
		author = 'Sharp-Shark',
		autoJobRoleSequence = 'ig',
		terroristTickets = 99,
		nexpharmaTickets = 1,
		respawnType = 'classic'
	},
	['scp:cb'] = {
		info = 'inspired by SCP:CB, JET+inmates fight agaisnt the monsters and people only respawn as MERCS.',
		author = 'SonicHegehodge',
		autoJobRoleSequence = 'xieji-xigji',--'xiiji-xji',
		terroristTickets = 1,
		nexpharmaTickets = 99,
		respawnType = 'classic'
	},
	['surfacetension'] = {
		info = 'team deathmatch with JET vs MERCS at surface zone.',
		author = 'Sharp-Shark',
		autoJobRoleSequence = 'mj',
		decontaminationTimer = 60*0.2 + 15,
		terroristTickets = 1.5,
		nexpharmaTickets = 1.5,
		respawnType = 'classic',
		respawnSpeed = 999,
		respawnAccel = 1
	},
	['ffa'] = {
		hide = true,
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
	['battleroyale'] = {
		hide = true,
		info = 'last player standing wins! Free for all.',
		author = 'Sharp-Shark',
		friendlyFire = true,
		endType = 'battleroyale',
		autoJobMinPlayers = 0,
		autoJobRoleSequence = 'i',
		decontaminationTimer = 60*6 + 15,
		terroristTickets = -99,
		nexpharmaTickets = -99,
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
		lighting = 'greenskin',
		terrorRadius = false,
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
		lighting = 'greenskin',
		terrorRadius = false,
		autoJobRoleSequence = 'mxx',
		nexpharmaSquadSequence = '01',
		decontaminationTimer = 60*9 + 15,
		terroristTickets = -99,
		nexpharmaTickets = 1
	},
	['jetpack'] = {
		hide = true,
		info = 'jetpack joyride free for all.',
		author = 'Sharp-Shark',
		friendlyFire = true,
		allowEnd = false,
		autoJobMinPlayers = 0,
		autoJobRoleSequence = 'm',
		terroristSquadSequence = '3',
		nexpharmaSquadSequence = '3',
		decontaminationTimer = 999999,
		terroristTickets = -99,
		nexpharmaTickets = 999999,
		respawnSpeed = 999,
		respawnAccel = 1
	}
}

-- Sets the settings presets to the default
FG.settingsPresets = table.copy(FG.settingsPresetsDefault)

-- Sets the current settings to the default
FG.settings = table.copy(FG.settingsDefault)

-- Settings presets sent by clients
FG.settingsPresetsReceived = {}

-- Save path
local savePath = 'LocalMods/Facility Gamemode.json'

-- Build settings table and returns it for use
function getSettingsPreset(preset)
	-- Get default
	local settings = table.copy(FG.settingsDefault)
	
	-- Apply inheritance
	local inherit = FG.settingsDefault.inherit
	if preset.inherit ~= nil then inherit = preset.inherit end
	if FG.settingsPresets[inherit] ~= nil then
		for settingName, settingValue in pairs(FG.settingsPresets[inherit]) do
			settings[settingName] = settingValue
		end
	end
	
	-- Apply setting
	for key, value in pairs(preset) do
		settings[key] = value
	end
	
	return settings
end

-- Saves FG.settingsPresets to the config
function saveSettingsPresets()
	if not pcall(function ()
		File.Write(savePath, json.serialize(FG.settingsPresets))
	end) then
		print('[!] Error when saving settings presets to config!')
	end
end

-- Loads the config to FG.settingsPresets
function loadSettingsPresets()
	if not pcall(function ()
		FG.settingsPresets = json.parse(File.Read(savePath))
	end) then
		print('[!] Error when loading settings presets from config!')
	end
end

-- Load a settings preset (singular)
function loadSettingsPreset (preset)
	FG.settings = getSettingsPreset(preset)
end

-- Load settings presets from config file if it exists or create one
if File.Exists(savePath) then
	loadSettingsPresets()
else
	print('[!] Settings presets config file missing! Creating one...')
	saveSettingsPresets()
end

-- Receive settings preset from clients & admins
Networking.Receive("loadClientPreset", function (message, client)
	if not SERVER then return end
	print('[!] Received settings preset from a client.')
	if client.HasPermission(ClientPermissions.ConsoleCommands) then
		local receivedSettings = json.parse(message.ReadString())
		loadSettingsPreset(receivedSettings)
		messageClient(client, 'text-general', string.localize('settingsApplied', nil, client.Language))
	else
		local settingsPresetReceived = json.parse(message.ReadString())
		settingsPresetReceived.author = client.Name
		--[[
		if (settingsPresetReceived.author == nil) then
			settingsPresetReceived.author = client.Name
		end
		--]]
		FG.settingsPresetsReceived[client.Name] = {[message.ReadString()] = settingsPresetReceived}
		messageClient(client, 'text-general', string.localize('settingsReceived', nil, client.Language))
	end
end)

-- Receive config file from admins
Networking.Receive("loadClientConfig", function (message, client)
	if not SERVER then return end
	if client.HasPermission(ClientPermissions.ConsoleCommands) then
		print('[!] Received config from a client.')
		if not pcall(function ()
			File.Write(savePath, message.ReadString())
		end) then
			print('[!] Error when saving settings presets to config!')
		end
		
		loadSettingsPresets()
		
		messageClient(client, 'text-general', string.localize('settingsApplied', nil, client.Language))
	end
end)

if FG.settingsPresetsDefault.regular ~= nil then loadSettingsPreset(FG.settingsPresetsDefault.regular) end

FG.loadedFiles['settings'] = true