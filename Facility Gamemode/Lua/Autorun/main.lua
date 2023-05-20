print('...')
print('[!] Loading Facility Gamemode...')

-- Husk Gamemode
global_huskMode = false
global_huskPlayers = {}

-- Disables auto round end - turn to false for testing
global_allowEnd = true

-- Automatically give players a job - turn to false for testing
global_autoJob = true

-- Server message text aka server description
global_serverMessageText = [[MOD BY Sharp-Shark! DO /help FOR COMMANDS.
DISCORD: https://discord.gg/c7Qnp8S4yB

]]

-- Load other files
global_loadedFiles = {autoJob = false, commands = false, death = false, loadoutTables = false, lootTables = false, spawning = false, utilities = false}
require 'autoJob'
require 'commands'
require 'death'
require 'loadoutTables'
require 'lootTables'
require 'spawning'
require 'utilities'

-- Used for debugging other files
global_failedFiles = {}
print('...')
for name, value in pairs(global_loadedFiles) do
	if value then
		print('[!] File ' .. name .. ' was loaded successfully.')
	else
		table.insert(global_failedFiles, name)
	end
end
if table.size(global_failedFiles) > 0 then
	print('...')
	for i, name in pairs(global_failedFiles) do
		print('[!] File ' .. name .. ' failed to load!')
	end
end
print('...')

-- Husk Control cuz WHY NOT?!
 Game.EnableControlHusk(true)

-- Manual Spectator List
global_spectators = {}

-- Tells you if the round is ending
global_endGame = false

-- Decontamination starts at 12min15s
global_decontaminationTimer = 60*12 + 15

-- Respawn timer isn't 6min (value is variable)
global_respawnTimer = 360

-- Counts amounts the think hook has been called, might be reset, don't use it as a total call counter
global_thinkCounter = 0

-- Player roles set at the start of the match
global_playerRole = {}

-- Whenever a player dies, add them to here (since if they are alive, they would have to be a JET or MERCS)
global_militantPlayers = {}

-- Respawn tickets for JET and MERCS
global_terroristTickets = 3
global_nexpharmaTickets = 5

-- Monster counter for setclientcharacter when multiple players pick the same monster
global_monsterCount = {mantis = 0, crawler = 0}

-- Respawns escapee as militant and rewards team with 1 tickets
function promoteEscapee (client)

	-- Heal escapee incase he was hurt
	Game.ExecuteCommand('heal ' .. client.Character.Name)
	Game.ExecuteCommand('revive ' .. client.Character.Name)

	-- Spawn escapee as militant
	global_militantPlayers[client.Name] = true
	if isCharacterTerrorist(client.Character) then
		-- Update Ticket Count
		global_terroristTickets = global_terroristTickets + 2
		Game.ExecuteCommand('say Terrorists have gained 2 tickets - civilian has escaped! ' .. global_terroristTickets .. ' tickets left!' )
		-- Spawns JET
		spawnPlayerMilitant(client, 'JET')
	elseif isCharacterNexpharma(client.Character) then
		-- Update Ticket Count
		global_nexpharmaTickets = global_nexpharmaTickets + 1
		Game.ExecuteCommand('say Nexpharma has gained 1 ticket - civilian has escaped! ' .. global_nexpharmaTickets .. ' tickets left!' )
		-- Spawns MERCS
		spawnPlayerMilitant(client, 'MERCS')
	end

end

-- Execute when someone joins
Hook.Add("client.connected", "characterDied", function (connectedClient)

	messageClient(connectedClient, 'popup', [[_Welcome to Facility Gamemode by Sharp-Shark. Please have fun and respect the rules. If you want, join our discord.
	
	_When the game starts, your objective is to be the last team standing.
	_If you are a civilian, try and escape to grant your team tickets. Tickets determine the amount of respawns your team has.
	_If you are a militant, kill the other teams and help the civilians from your team in their quest to escape.
	
	_Your preferred job may be overriden by the gamemode's autobalance script, but the script will try and give you your desired job if possible. Also, only the 1st job in your preferred jobs list matters.]])

end)

-- Executes constantly
Hook.Add("think", "thinkCheck", function ()
	global_thinkCounter = global_thinkCounter + 1
	local rect = 0
	
	-- Only execute once every 1/2 a second for performance
	if global_thinkCounter % 30 == 0 then
		Game.ServerSettings['AllowRespawn'] = global_serverSettings['AllowRespawn']
	
		if string.sub(Game.ServerSettings.ServerMessageText, 1, #global_serverMessageText) ~= global_serverMessageText then
			Game.ServerSettings.ServerMessageText = global_serverMessageText .. Game.ServerSettings.ServerMessageText
		end
	
		-- Only execute the following code if the round has started
		if not Game.RoundStarted then return end
		
		-- Apply affliction to everyone inside of area for anti-camping
		for item in findItemsByTag('fg_justice') do
			rect = item.WorldRect
			for char in Character.CharacterList do
				-- Item center is at its top left corner
				if math.abs(char.WorldPosition.X - rect.X - rect.Width/2) <= rect.Width/2 and math.abs(char.WorldPosition.Y - rect.Y + rect.Height/2) <= rect.Height/2 then
					giveAfflictionCharacter(char, 'justice', char.MaxHealth * 0.01)
				end
			end
		end
		
		-- Respawn timer
		if global_respawnTimer > 0 then
			-- Count dead players
			local dead = 0
			local total = 0
			for player in Client.ClientList do
				if player.Character == nil or player.Character.IsDead then
					dead = dead + 1
				end
				total = total + 1
			end
			local deadPercentage = dead/total
			-- Decrement timer
			global_respawnTimer = global_respawnTimer - 30 / #Client.ClientList * deadPercentage
		elseif not Game.ServerSettings['AllowRespawn'] then
			-- Respawn dead players
			local balance = 0
			for player in Client.ClientList do
				if player.Character == nil or player.Character.IsDead then
					if (global_playerRole[player.Name] == 'monster' or global_playerRole[player.Name] ==  'inmate' or global_playerRole[player.Name] == 'jet') and global_terroristTickets >= 1 then
						global_playerRole[player.Name] = 'jet'
						spawnPlayerMilitant(player, 'jet')
						global_terroristTickets = global_terroristTickets - 1
					elseif (global_playerRole[player.Name] == 'staff' or global_playerRole[player.Name] ==  'guard' or global_playerRole[player.Name] == 'mercs') and global_nexpharmaTickets >= 1 then
						global_playerRole[player.Name] = 'mercs'
						spawnPlayerMilitant(player, 'mercs')
						global_nexpharmaTickets = global_nexpharmaTickets - 1
					else
						if (balance > 0 or global_nexpharmaTickets < 1) and global_terroristTickets >= 1 then
							global_playerRole[player.Name] = 'jet'
							spawnPlayerMilitant(player, 'jet')
							global_terroristTickets = global_terroristTickets - 1
							balance = balance - 1
						elseif global_nexpharmaTickets >= 1 then
							global_playerRole[player.Name] = 'mercs'
							spawnPlayerMilitant(player, 'mercs')
							global_nexpharmaTickets = global_nexpharmaTickets - 1
							balance = balance + 1
						end
					end
				end
			end
			-- Reset
			global_respawnTimer = 360
		end
		
		-- Decontamination
		if global_decontaminationTimer > 0 then
			global_decontaminationTimer = global_decontaminationTimer - 0.5
			-- Announce time until decontamination at certain time stamps
			if global_decontaminationTimer == 0 then
				Game.ExecuteCommand('say Complete facility decontamination has been initiated.')
			elseif global_decontaminationTimer == 10 then
				Game.ExecuteCommand('say T-10 seconds until complete facility decontamination.')
			elseif global_decontaminationTimer == 60 then
				Game.ExecuteCommand('say T-1 minute until complete facility decontamination.')
			elseif global_decontaminationTimer % 120 == 0 then
				Game.ExecuteCommand('say T-' .. global_decontaminationTimer / 60 .. ' minutes until complete facility decontamination.')
			elseif global_decontaminationTimer <= 10 and global_decontaminationTimer % 1 == 0 then
				Game.ExecuteCommand('say T-' .. global_decontaminationTimer .. '...')
			end
		else
			-- Apply affliction to everyone outside of surface after decontamination started
			local chars = {}
			for item in findItemsByTag('fg_surface') do
				rect = item.WorldRect
				for char in Character.CharacterList do
					-- Item center is at its top left corner
					if not (math.abs(char.WorldPosition.X - rect.X - rect.Width/2) <= rect.Width/2 and math.abs(char.WorldPosition.Y - rect.Y + rect.Height/2) <= rect.Height/2) then
						table.insert(chars, char)
					end
				end
			end
			for char in chars do
				giveAfflictionCharacter(char, 'intoxicated', char.MaxHealth * 0.01)
			end
		end
		
		-- Check for escapees
		for item in findItemsByTag('fg_extractionpoint') do
			for player in Client.ClientList do
				if player.Character ~= nil and player.Character.SpeciesName == 'human' and (player.Character.HasJob('inmate') or player.Character.HasJob('repairmen') or player.Character.HasJob('researcher')) and
				distance(item.WorldPosition, player.Character.WorldPosition) < 200 and not global_militantPlayers[player.Name] then
					promoteEscapee(player)
				end
			end
		end
	end
	
	return true
end)

-- Execute at round start
Hook.Add("roundStart", "prepareMatch", function (createdCharacter)

	-- Disables friendly fire
	Game.ServerSettings['AllowFriendlyFire'] = false
	-- Resets round end
	global_endGame = false
	-- Reset decon timer to 12m15s
	global_decontaminationTimer = 60*12 + 15
	-- Resets respawn timer
	global_respawnTimer = 360
	-- Refresh think call counter
	global_thinkCounter = 0
	-- Refresh Militant Player List
	global_militantPlayers = {}
	-- Refresh Monster Count
	global_monsterCount = {mantis = 0, crawler = 0}
	-- Refresh Tickets
	global_terroristTickets = 3
	global_nexpharmaTickets = 5
	-- Enabling cheats is necessary for ExecuteCommand method
	Game.ExecuteCommand('enablecheats')
	-- Helps with trams not getting stuck
	--Submarine.MainSub.LockX = false
	--Submarine.MainSub.LockY = true
	-- Disables tripophobia menace
	Submarine.MainSub.ImmuneToBallastFlora = true
	-- Stops the facility from being destroyed by players
	Game.ExecuteCommand('godmode_mainsub')
	for sub in Submarine.Loaded do
		sub.GodMode = true
	end
	
	-- Randomized loot Spawning
	Timer.Wait(function ()
		-- Iterate through all the items in the main map
		for item in Submarine.MainSub.GetItems(false) do
			if item.HasTag('container') or item.HasTag('fg_office1') or item.HasTag('fg_trash') then
				-- Iterate through all of the tags of the loot tables
				for tag, content in pairs(global_lootTables) do
					if item.HasTag(tag) then
						-- Iterate through all the items in the loot table and do spawning procedure
						for loot in content do
							for n = 1, loot[3] do
								if loot[2] > math.random() then
									for n = 1, loot[4] do
										Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(loot[1]), item.OwnInventory, nil, nil, nil)
									end
								end
							end
						end
					end
				end
			end
		end
	end, 100)
	
	-- Infect
	if global_huskMode then
		Timer.Wait(function ()
			for playerName, value in pairs(global_huskPlayers) do
				local char = findClientByUsername(playerName).Character
				char.CharacterHealth.ApplyAffliction(char.AnimController.MainLimb, AfflictionPrefab.Prefabs["huskinfection"].Instantiate(100))
			end
		end, 5*1000)
	end

    return true
end)

-- Executes when a human is transformed
Hook.Add("husk.clientControl", "humanTransformed", function (client, husk)

	Timer.Wait(function ()
		messageClient(client, 'info', 'You are now a Husk! A weak but infectious and dexterious monster. Work with your fellow monsters to kill all humans! You may infect, use doors, use items and use local voicechat.')
	end, 5*1000)
	
	return true
end)

-- Server settings to be applied
global_serverSettings = {
    AllowDisguises = false,
    AllowFileTransfers = true,
    AllowFriendlyFire = false,
    AllowLinkingWifiToChat = false,
    AllowModDownloads = true,
    AllowModeVoting = false,
    AllowRagdollButton = true,
    AllowRespawn = false,--Using custom respawn
    AllowRewiring = false,
    AllowSpectating = true,
    AllowSubVoting = false,
    BotCount = 0,
    DisableBotConversations = true,
    ExtraCargo = {},
    GameModeIdentifier = 'sandbox',
    KarmaEnabled = false,
    KillableNPCs = true,
    LockAllDefaultWires = true,
    LosMode = 2,--Opaque    
    MaxTransportTime = 5,--Duration of respawn transport
    MinRespawnRatio = 0,--Minimun players to respawn
    ModeSelectionMode = 0,--Manual
    MonsterEnabled = {},
    PlayStyle = 3,--Rampage
    RespawnInterval = 2*60,
    SelectedShuttle = '_Respawn',
    SelectedSubmarine = '_Facility',
    ServerDetailsChanged = true,
    ShowEnemyHealthBars = 0,
    SubSelectionMode = 0,--Manual
    TraitorsEnabled = 0,
    UseRespawnShuttle = true,
    VoiceChatEnabled = true
}

-- Applies settings to server
for setting, value in pairs(global_serverSettings) do
    if not pcall(function ()
        Game.ServerSettings[setting] = value
    end) then
        LuaUserData.MakeMethodAccessible(Descriptors['Barotrauma.Networking.ServerSettings'], 'set_' .. setting)
        Game.ServerSettings['set_' .. setting](value)
    end
end
-- Actually applies the settings
Game.ServerSettings.ForcePropertyUpdate()
-- Set difficulty to 0%
Game.NetLobbyScreen.SetLevelDifficulty(0)

-- Sucess Message
print('[!] Facility Gamemode by Sharp-Shark!')
print('...')