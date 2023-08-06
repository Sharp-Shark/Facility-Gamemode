-- Facility Gamemode table
FG = {}

-- Set up the mod's path
FG.path = table.pack(...)[1]

--[[
I'm using this pure lua json encoder/decoder Evil Factory suggested because it doesn't have an error the "pre-packaged" one has.
The bug consist of where if you set something from a table to nil (the way to remove a thing in lua), when you serialize said table, that thing will have a value of null.
When you later parse the json, you get an userdata there (which represents the null).
Example given below!

--|  THE CODE   |---
table = {a = {1,2,3}}
print(json.serialize
table.a = nil
print(json.serialize())
--| THE OUTPUT  |--
{"a":[1,2,3]}
{"a":null}
--| THE DESIRED |--
{"a":[1,2,3]}
{}

--]]
json = dofile(FG.path .. "/Lua/json.lua")
json.serialize = json.encode
json.parse = json.decode

-- Loaded files
FG.loadedFiles = {}

-- Adds file to FG.loadedFiles with value false if it isn't there
function expectFiles (...)
	local names = {...}
	for name in names do
		if FG.loadedFiles[name] == nil then
			FG.loadedFiles[name] = false
		end
	end
end

-- Localization variables
FG.localizations = {}
FG.language = 'English'
if CLIENT then FG.language = tostring(Game.Settings.CurrentConfig.language) end

-- Load default languages
expectFiles('english', 'ptbr', 'russian', 'schinese')
require 'localizations/english'
require 'localizations/ptbr'
require 'localizations/russian'
require 'localizations/schinese'

-- Just a lil' print statement for spacing
print('...')

-- Client only code
if CLIENT then
	print('[!] Running lua clientside code.')
	
	-- Load other files
	expectFiles('utilities', 'settings', 'gui')
	require 'utilities'
	require 'settings'
	require 'clientside/gui'
	
	-- If it's a client in multiplayer, don't execute the rest
	if Game.IsMultiplayer then
		-- Used for debugging other files
		FG.failedFiles = {}
		print('...')
		for name, value in pairs(FG.loadedFiles) do
			if value then
				print('[!] File ' .. name .. ' was loaded successfully.')
			else
				table.insert(FG.failedFiles, name)
			end
		end
		if table.size(FG.failedFiles) > 0 then
			print('...')
			for i, name in pairs(FG.failedFiles) do
				print('[!] File ' .. name .. ' failed to load!')
			end
		end
		print('...')
		
		print('[!] Will not run serverside code as client in multiplayer.')
		print('...')
		
		-- Sucess Message
		print('[!] Facility Gamemode by Sharp-Shark!')
		print('...')
		
		return
	end
else
	print('[!] Will not run lua clientside code as server.')
end

print('...')
print('[!] Running lua serverside code.')

-- Load other files
expectFiles('autoJob', 'commands', 'death', 'loadoutTables', 'lootTables', 'spawning', 'utilities', 'settings', 'items')
require 'json'
require 'autoJob'
require 'commands'
require 'death'
require 'loadoutTables'
require 'lootTables'
require 'spawning'
require 'utilities'
require 'settings'
require 'items'
if SERVER then
	expectFiles('discord')
	require 'discord'
end

-- Used for debugging other files
FG.failedFiles = {}
print('...')
for name, value in pairs(FG.loadedFiles) do
	if value then
		print('[!] File ' .. name .. ' was loaded successfully.')
	else
		table.insert(FG.failedFiles, name)
	end
end
if table.size(FG.failedFiles) > 0 then
	print('...')
	for i, name in pairs(FG.failedFiles) do
		print('[!] File ' .. name .. ' failed to load!')
	end
end
print('...')

-- Husk Control cuz WHY NOT?!
 Game.EnableControlHusk(true)
 
-- Clients that can receive net messages
FG.clientsNetReady = {}

-- Manual Spectator List
FG.spectators = {}

-- Option to disable the loot corpses (maybe for performance?)
FG.spawnCorpses = true

-- Last safe position - used to prevent players from ending up outside the map
FG.clientLastSafePos = {}

-- Tells you if the round is ending
FG.endGame = false

-- Decontamination starts at 12min15s
FG.decontaminationTimer = FG.settings.decontaminationTimer

-- Respawn timer isn't 90s (value is variable)
FG.respawnTimerMult = 1
FG.respawnTimer = 100
FG.respawnTimerSeconds = 0
FG.respawnETA = 'never for now.'
FG.respawnTimerUpdate = false
FG.respawnTimerLastUpdateSeconds = -1

-- Counts amounts the think hook has been called, might be reset, don't use it as a total call counter
FG.thinkCounter = 0

-- Variables for changing lights (check utilities.lua)
FG.lightColors = {}
FG.lightColorsLatest = {}

-- Player roles set at the start of the match
FG.playerRole = {}

-- Monster players and what monster they are
FG.monsterPlayers = {}

-- Respawn tickets for JET and MERCS
FG.terroristTickets = FG.settings.terroristTickets
FG.nexpharmaTickets = FG.settings.nexpharmaTickets

-- For the /vote command
FG.democracy = {
	options = {}, -- All the options one can vote on
	votes = {}, -- Keys are clients and items are what they voted
	voters = {}, -- Table sequence of all who voted
	started = false, -- If a voting is already ongoing
	gamemode = false, -- If the vote is for a gamemode
	gamemodeChosen = false -- If a gamemode has been voted for
}

-- Ends voting
FG.democracy.endVoting = function (clients)
	if not FG.democracy.started then return end
	-- Local vars
	local winners = {}
	local winnerVoteCount = -1
	local voteCount = {}
	-- Get all options
	for option in FG.democracy.options do
		voteCount[option] = 0
	end
	-- Count the votes
	for vote in FG.democracy.votes do
		voteCount[vote] = voteCount[vote] + 1
	end
	-- Register winners
	for option, count in pairs(voteCount) do
		if count >= winnerVoteCount then
			if count > winnerVoteCount then
				winnerVoteCount = count
				winners = {}
			end
			table.insert(winners, option)
		end
	end
	-- Warn all users
	for player in clients do	
		-- Text
		local text = ''
		if not Game.RoundStarted then text = text .. '\n' end
		-- Get winners and build text
		text = text .. string.localize('voteEndHeader', nil, player.Language) .. '\n'
		for option, count in pairs(voteCount) do
			text = text .. string.localize('voteEndItem', {option = option, votes = tostring(voteCount[option])}, player.Language) .. '\n'
		end
		-- Build winners text
		text = text .. string.localize('voteEndFooter', nil, player.Language)
		for winner in winners do
			text = text .. winner .. ', '
		end
		text = string.sub(text, 1, #text - 2) .. '.'
		-- Message clients
		messageClient(player, 'text-command', text)
	end
	-- Applies gamemode
	if FG.democracy.gamemode then
		local presetName = winners[math.random(#winners)]
		if FG.settingsPresets[presetName] ~= nil then
			FG.settings = table.copy(FG.settingsDefault)
			for settingName, settingValue in pairs(FG.settingsPresets[presetName]) do
				FG.settings[settingName] = settingValue
			end
			--text = text .. table.print(FG.settings, true, true)
			-- Sets the flag to true
			FG.democracy.gamemodeChosen = true
		end
	end
	-- Reset for next voting
	FG.democracy.options = {}
	FG.democracy.votes = {}
	FG.democracy.voters = {}
	FG.democracy.started = false
	FG.democracy.gamemode = false
end

-- Respawns escapee as militant and rewards team with 1 tickets
function promoteEscapee (client)

	-- Heal escapee incase he was hurt
	client.Character.Revive(true)

	-- Spawn escapee as militant
	if (isCharacterTerrorist(client.Character) and not client.Character.IsArrested) or (isCharacterNexpharma(client.Character) and client.Character.IsArrested) then
		-- Update ticket count
		if client.Character.IsArrested then
			FG.terroristTickets = FG.terroristTickets + 1.5
			messageAllClients('text-game', {'ticketsStaffCuffedEscape', {tickets = FG.terroristTickets}})
		else
			FG.terroristTickets = FG.terroristTickets + 2
			messageAllClients('text-game', {'ticketsInmateEscape', {tickets = FG.terroristTickets}})
		end
		-- Spawns JET
		spawnPlayerMilitant(client, 'JET', {free = true})
	elseif (isCharacterNexpharma(client.Character) and not client.Character.IsArrested) or (isCharacterTerrorist(client.Character) and client.Character.IsArrested) then
		-- Update ticket count
		if client.Character.IsArrested then
			FG.nexpharmaTickets = FG.nexpharmaTickets + 1.5
			messageAllClients('text-game', {'ticketsInmateCuffedEscape', {tickets = FG.terroristTickets}})
		else
			FG.nexpharmaTickets = FG.nexpharmaTickets + 1
			messageAllClients('text-game', {'ticketsStaffEscape', {tickets = FG.terroristTickets}})
		end
		-- Spawns MERCS
		spawnPlayerMilitant(client, 'MERCS', {free = true})
	end

end

-- Receive ping from client
if SERVER then
	Networking.Receive("pingClientToServer", function (message, client)
		print('[!] Answering ping from client.')
		FG.clientsNetReady[client] = true
		local message = Networking.Start("pingServerToClient", client.Connection)
		Networking.Send(message)
	end)
end

-- Execute when someone joins
Hook.Add("client.connected", "clientConnected", function (connectedClient)

	if SERVER and FG.loadedFiles['discord'] and Game.ServerSettings.IsPublic then
		local name = connectedClient.Name
		
		if string.has(name, 'http://') or string.has(name, 'https://') then
			name = '**[CENSORED]**'
		end
	
		if #Client.ClientList > 1 then
			discordChatMessage('01| ' .. name .. ' has joined! There are ' .. #Client.ClientList .. ' clients.')
		elseif #Client.ClientList > 0 then
			discordChatMessage('02| ' .. name .. ' has joined! There is ' .. #Client.ClientList .. ' client.')
		else
			discordChatMessage('03| ' .. name .. ' has joined! There are no clients.')
		end
	end

	messageClient(connectedClient, 'popup', string.localize('joinMessageText', nil, connectedClient.Language))
	
	if not FG.endGame or not Game.RoundStarted then return end

	FG.respawnTimerUpdate = true

end)

-- Execute when someone leaves
Hook.Add("client.disconnected", "clientDisconnected", function (disconnectedClient)

	if SERVER and FG.loadedFiles['discord'] and Game.ServerSettings.IsPublic then
		local name = disconnectedClient.Name
		
		if string.has(name, 'http://') or string.has(name, 'https://') then
			name = '**[CENSORED]**'
		end
		
		if (#Client.ClientList - 1) > 1 then
			discordChatMessage('04| ' .. name .. ' has left. There are ' .. (#Client.ClientList - 1) .. ' clients.')
		elseif (#Client.ClientList - 1) > 0 then
			discordChatMessage('05| ' .. name .. ' has left. There is ' .. (#Client.ClientList - 1) .. ' client.')
		else
			discordChatMessage('06| ' .. name .. ' has left. There are no clients.')
		end
	end
	
	-- Removes the client from net ready clients
	FG.clientsNetReady[disconnectedClient] = nil
	
	-- Deletes the user's submitted preset
	FG.settingsPresetsReceived[disconnectedClient.Name] = nil
	
	if not FG.endGame or not Game.RoundStarted then return end

	FG.respawnTimerUpdate = true

end)

-- Execute a client changes their name
Hook.Add("tryChangeClientName", "clientChangeName", function (client, newName, newJob, newTeam)

	-- Changes submission address
	FG.settingsPresetsReceived[newName] = FG.settingsPresetsReceived[client.Name]
	FG.settingsPresetsReceived[client.Name] = nil
	
end)

-- Executes constantly
Hook.Add("think", "thinkCheck", function ()
	FG.thinkCounter = FG.thinkCounter + 1
	local rect = 0
	
	--[[
	-- Stamina code (might remove later)
	if Game.RoundStarted then
		for char in Character.CharacterList do
			if char.SpeciesName == 'human' then
				if char.AnimController.IsMovingFast then
					giveAfflictionCharacter(char, 'fatigue', char.MaxHealth * 0.0005)
				else
					char.CharacterHealth.ReduceAfflictionOnAllLimbs(AfflictionPrefab.Prefabs['fatigue'].identifier,  char.MaxHealth * 0.001)
				end
			end
		end
	end
	--]]
	
	-- Only executes once every 1/10 a second for performance
	if FG.thinkCounter % 6 == 0 then
		-- Terror radius
		if SERVER and Game.RoundStarted and (not ((FG.settings.gamemode == 'greenskin') and (FG.settings.monsterSpawn == 'staff'))) then
			for client in Client.ClientList do
				if (client.Character ~= nil) and (not client.Character.IsDead) and (not client.UsingFreeCam) and (not isCharacterMonster(client.Character)) then
					local nearest = 999999
					for character in Character.CharacterList do
						if (not character.IsDead) and isCharacterMonster(character) then
							local dist = distance(client.Character.WorldPosition, character.WorldPosition)
							if dist < nearest then nearest = dist end
						end
					end
					if client.Character.CharacterHealth.GetAffliction('terrorradius', true) == nil then
						giveAfflictionCharacter(client.Character, 'terrorradius', 1)
					end
					local amount = math.min(100, math.max(0, 130 - math.sqrt(nearest)*2.5))
					client.Character.CharacterHealth.GetAffliction('terrorradius', true).SetStrength(amount)
				end
			end
		end
	end
	
	-- Only execute once every 1/2 a second for performance
	if FG.thinkCounter % 30 == 0 then
		if SERVER then
			Game.ServerSettings['AllowRespawn'] = FG.serverSettings['AllowRespawn']
	
			if string.sub(Game.ServerSettings.ServerMessageText, 1, #string.localize('serverMessageText')) ~= string.localize('serverMessageText') then
				Game.ServerSettings.ServerMessageText = string.localize('serverMessageText') .. Game.ServerSettings.ServerMessageText
			end
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
		if FG.respawnTimer > 0 then
			-- Count dead players
			local dead = 0
			local total = 0
			for player in Client.ClientList do
				if (player.Character == nil or player.Character.IsDead) and not FG.spectators[player.Name] and not player.UsingFreeCam then
					dead = dead + 1
				end
				if not FG.spectators[player.Name] then
					total = total + 1
				end
			end
			if total == 0 then total = 1 end
			local deadPercentage = dead/total
			-- Decrement timer
			local rate = (FG.settings.respawnSpeed) / #Client.ClientList * deadPercentage
			if table.size(Client.ClientList) == 0 then rate = 0 end
			FG.respawnTimer = FG.respawnTimer - rate
			-- Update Estimated Time of Arrival
			FG.respawnTimerSeconds = -1
			if rate > 0 then
				FG.respawnTimerSeconds = math.ceil(FG.respawnTimer / rate / 2)
			end
			if not ((rate / 2) > 0) then
				FG.respawnETA = 'never for now'
			else
				FG.respawnETA = 'in ' .. numberToTime(FG.respawnTimerSeconds, 1) .. ' for now'
			end
			-- Announce respawn timer to the dead every so often
			if FG.respawnTimerSeconds < (FG.respawnTimerLastUpdateSeconds - 30) then
				FG.respawnTimerUpdate = true
				FG.respawnTimerLastUpdateSeconds = -1
			end
			if FG.respawnTimerLastUpdateSeconds == -1 then
				FG.respawnTimerLastUpdateSeconds = FG.respawnTimerSeconds
			end
			-- Display respawn timer
			if FG.respawnTimerUpdate then
				for player in Client.ClientList do
					if (player.Character == nil or player.Character.IsDead) and not FG.spectators[player.Name] and not player.UsingFreeCam then
						respawnInfo(player)
					end
				end
				FG.respawnTimerUpdate = false
			end
		elseif not FG.endGame and not Game.ServerSettings['AllowRespawn'] then
			-- Default respawn system where everyone who respawns in the same team (the team is decided based on which team has more tickets)
			if FG.settings.respawnType == 'default' then
				-- Respawn dead players
				local balance = (FG.terroristTickets >= FG.nexpharmaTickets) and 1 or 0
				-- If it's a tie, decide it randomly
				if FG.terroristTickets == FG.nexpharmaTickets then balance = math.random(2) - 1 end
				-- Respawn/spawn dead/new players in a random order
				for player in shuffleArray(Client.ClientList) do
					if (player.Character == nil or player.Character.IsDead) and not FG.spectators[player.Name] and not player.UsingFreeCam then
						if balance == 1 then
							if FG.terroristTickets >= 1 then
								spawnPlayerMilitant(player, 'JET')
							else
								messageClient(player, 'text-game', text.localize('ticketsTerroristsOutOfTickets'), nil, player.Language)
							end
						elseif balance == 0 then
							if FG.nexpharmaTickets >= 1 then
								spawnPlayerMilitant(player, 'MERCS')
							else
								messageClient(player, 'text-game', text.localize('ticketsNexpharmaOutOfTickets'), nil, player.Language)
							end
						end
					end
				end
			-- Everyone respawns based on what was their team before
			elseif FG.settings.respawnType == 'split' then
				local balance = (FG.terroristTickets > FG.nexpharmaTickets) and 1 or 0
				for player in shuffleArray(Client.ClientList) do
					if (player.Character == nil or player.Character.IsDead) and not FG.spectators[player.Name] and not player.UsingFreeCam then
						if (FG.playerRole[player.Name] ==  'inmate' or FG.playerRole[player.Name] == 'jet' or FG.playerRole[player.Name] == 'monster') and FG.terroristTickets >= 1 then
							spawnPlayerMilitant(player, 'JET')
						elseif (FG.playerRole[player.Name] == 'overseer' or FG.playerRole[player.Name] == 'staff' or FG.playerRole[player.Name] == 'guard' or FG.playerRole[player.Name] == 'elite' or FG.playerRole[player.Name] == 'mercs') and FG.nexpharmaTickets >= 1 then
							spawnPlayerMilitant(player, 'MERCS')
						else
							if (balance > 0 or FG.nexpharmaTickets < 1) and FG.terroristTickets >= 1 then
								spawnPlayerMilitant(player, 'JET')
								balance = balance - 1
							elseif FG.nexpharmaTickets >= 1 then
								spawnPlayerMilitant(player, 'MERCS')
								balance = balance + 1
							else
								messageClient(player, 'text-game', text.localize('ticketsEveryoneOutOfTickets'), nil, player.Language)
							end
						end
					end
				end
			-- Everyone respawns as guard in a guard spawnpoint regardless of tickets
			elseif FG.settings.respawnType == 'infiniteguards' then
				for player in Client.ClientList do
					if (player.Character == nil or player.Character.IsDead) and not FG.spectators[player.Name] and not player.UsingFreeCam then
						spawnHuman(player, 'enforcerguard', findRandomWaypointByJob('enforcerguard').WorldPosition)
					end
				end
			end
			-- Reset
			FG.respawnTimerMult = FG.respawnTimerMult * FG.settings.respawnAccel
			FG.respawnTimer = 100 * FG.respawnTimerMult
			FG.respawnTimerLastUpdateSeconds = -1
		end
		
		-- Decontamination
		if FG.decontaminationTimer > 0 then
			FG.decontaminationTimer = FG.decontaminationTimer - 0.5
			-- Announce time until decontamination at certain time stamps
			if FG.decontaminationTimer == 0 then
				messageAllClients('text-game', {'deconTimeStart'})
				-- Make all non surface lights dark after 20s
				setNonSurfaceLightsSmooth(Color(), 300)
				-- Close all escape doors
				for item in findItemsByTag('fg_escapedoor') do setDoorState(item, false) end
			elseif FG.decontaminationTimer == 10 then
				messageAllClients('text-game', {'deconTimeTenSeconds'})
			elseif FG.decontaminationTimer == 60 then
				messageAllClients('text-game', {'deconTimeMinute'})
				-- Make all non surface lights red after 0.5s
				setNonSurfaceLightsSmooth(Color.DarkRed, 5)
				-- Open all escape doors
				for item in findItemsByTag('fg_escapedoor') do setDoorState(item, true) end
			elseif FG.decontaminationTimer % 120 == 0 then
				messageAllClients('text-game', {'deconTimeMinutes', {time = FG.decontaminationTimer / 60}})
			elseif FG.decontaminationTimer <= 10 and FG.decontaminationTimer % 1 == 0 then
				messageAllClients('text-game', {'deconTimeCountdown', {time = FG.decontaminationTimer}})
			end
		else
			-- Apply affliction to everyone outside of surface after decontamination started
			local chars = {}
			for item in findItemsByTag('fg_surface') do
				rect = item.WorldRect
				for char in Character.CharacterList do
					-- Item center is at its top left corner
					if math.abs(char.WorldPosition.X - rect.X - rect.Width/2) <= rect.Width/2 and math.abs(char.WorldPosition.Y - rect.Y + rect.Height/2) <= rect.Height/2 then
						chars[char] = true
					elseif not chars[char] then
						chars[char] = false
					end
				end
			end
			for char, value in pairs(chars) do
				if not value then giveAfflictionCharacter(char, 'intoxicated', char.MaxHealth * 0.01) end
			end
		end
		
		-- Check for escapees
		for item in findItemsByTag('fg_extractionpoint') do
			for player in Client.ClientList do
				if (player.Character ~= nil) and isCharacterCivilian(player.Character) and
				distance(item.WorldPosition, player.Character.WorldPosition) < 200 then
					promoteEscapee(player)
				end
			end
		end
		
		-- Prevents people from ending up outside the map
		for client in Client.ClientList do
			if (client.Character ~= nil) and (not client.Character.IsDead) then
				if (client.Character.Submarine == nil) and (FG.clientLastSafePos[client] ~= nil) then
					client.Character.TeleportTo(FG.clientLastSafePos[client])
					if (client.Character.Submarine == nil) then
						FG.clientLastSafePos[client] = nil
					end
				end
				if (client.Character.Submarine == Submarine.MainSub) then
					FG.clientLastSafePos[client] = client.Character.WorldPosition
				end
			end
		end
		
		-- Updates client GUI with server data
		if CLIENT then FG.clientsNetReady = {client = {language = FG.language}} end
		for client, value in pairs(FG.clientsNetReady) do
			local message = Networking.Start("updateGUI")
			local txtInMessage
			-- Add respawn timer text
			if (FG.respawnTimerSeconds ~= -1) and ((FG.terroristTickets >= 1) or (FG.nexpharmaTickets >= 1)) then
				txtInMessage = string.localize('GUIRespawnTime', {time = numberToTime(FG.respawnTimerSeconds, 1)}, client.Language)
				if FG.settings.respawnType == 'default' then
					if FG.terroristTickets > FG.nexpharmaTickets then
						txtInMessage = txtInMessage ..  string.localize('GUIRespawnTimeJet', nil, client.Language)
					elseif FG.terroristTickets < FG.nexpharmaTickets then
						txtInMessage = txtInMessage .. string.localize('GUIRespawnTimeMercs', nil, client.Language)
					else
						txtInMessage = txtInMessage .. string.localize('GUIRespawnTimeRandom', nil, client.Language)
					end
				elseif FG.settings.respawnType == 'split' then
					txtInMessage = ''
				elseif FG.settings.respawnType == 'infiniteguards' then
					txtInMessage = ''
				end
			else
				txtInMessage = ''
			end
			if (txtInMessage == nil) or (numberToTime(FG.respawnTimerSeconds, 1) == nil) then
				txtInMessage = ''
			end
			message.WriteString(txtInMessage)
			message.WriteDouble(FG.respawnTimerSeconds)
			-- If client, just write it, no networking needed
			if CLIENT then textBoxRespawnTimer.Text = txtInMessage end
			-- Add decon timer text
			local txtInMessage
			if FG.decontaminationTimer <= 0 then
				txtInMessage = string.localize('GUIDeconStart', nil, client.Language)
			else
				txtInMessage = string.localize('GUIDeconTime', {time = numberToTime(FG.decontaminationTimer, 1)}, client.Language)
			end
			message.WriteString(txtInMessage)
			message.WriteDouble(FG.decontaminationTimer)
			-- If client, just write it, no networking needed
			if CLIENT then textBoxDeconTimer.Text = txtInMessage end
			-- Send net message
			if SERVER then
				Networking.Send(message, client.Connection)
			else
				textBoxRespawnTimer.TextPos = Vector2(240, 40)
				textBoxDeconTimer.TextPos = Vector2(240, 20)
			end
		end
	end
	
	return true
end)

-- Execute at round start
Hook.Add("roundStart", "prepareMatch", function (createdCharacter)

	-- Print in console all players
	print('[!] Starting round with:')
	for client in Client.ClientList do
		print('    - ' .. client.Name)
	end
	-- Server only code
	if SERVER then
		-- Disables friendly fire
		Game.ServerSettings['AllowFriendlyFire'] = FG.settings.friendlyFire
	end
	-- Resets any voting
	FG.democracy.started = false
	-- Resets safe positions
	FG.clientLastSafePos = {}
	-- Resets round end
	FG.endGame = false
	-- Reset decon timer to 12m15s
	FG.decontaminationTimer = FG.settings.decontaminationTimer
	-- Resets respawn timer
	FG.respawnTimerMult = 1
	FG.respawnTimer = 100
	FG.respawnTimerUpdate = false
	FG.respawnTimerLastUpdate = -1
	-- Refresh think call counter
	FG.thinkCounter = 0
	-- Refresh light color keeping variables
	FG.lightColors = {}
	FG.lightColorsLatest = {}
	-- Refresh Tickets
	FG.terroristTickets = FG.settings.terroristTickets
	FG.nexpharmaTickets = FG.settings.nexpharmaTickets
	-- Enabling cheats is necessary for ExecuteCommand method
	Game.ExecuteCommand('enablecheats')
	-- Helps with trams not getting stuck
	Submarine.MainSub.LockX = false
	Submarine.MainSub.LockY = true
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
				for tag, content in pairs(FG.lootTables) do
					if item.HasTag(tag) then
						-- Iterate through all the items in the loot table and do spawning procedure
						for loot in shuffleArray(content) do
							for n = 1, loot[3] do
								if loot[2] > math.random() then
									for n = 1, loot[4] do
										if not item.OwnInventory.IsFull(true) then
											Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(loot[1]), item.OwnInventory, nil, nil, nil)
										end
									end
								end
							end
						end
					end
				end
			end
		end
		-- Spawn loot corpses
		if FG.spawnCorpses then
			for waypoint in findWaypointsByJob('corpsejob') do
				if math.random(100) <= 35 then
					local character = spawnHuman(nil, 'corpsejob', waypoint.WorldPosition + Vector2(0, math.random(100)))
					if math.random(2) == 1 then character.AnimController.Flip() end
					character.EnableDespawn = false
				end
			end
		end
		-- Fill all hulls tagged with "fg_flooded" with water
		for hull in Submarine.MainSub.GetHulls(false) do
			if hull.RoomName == 'Tunnels' then
				hull.WaterVolume = hull.Volume
			elseif hull.RoomName == 'Tunnel Access' then
				hull.WaterVolume = hull.Volume / 5
			end
		end
	end, 100)
	
	-- Infect
	Timer.Wait(function ()
		for playerName, value in pairs(FG.monsterPlayers) do
			if FG.monsterPlayers[playerName] == 'husk' then
				local char = findClientByUsername(playerName).Character
				if (char ~= nil) and (char.SpeciesName == 'human') then
					char.CharacterHealth.ApplyAffliction(char.AnimController.MainLimb, AfflictionPrefab.Prefabs["huskinfection"].Instantiate(100))
				end
			end
		end
	end, 5*1000)
	
	-- Goblin mode goblin mode goblin mode goblin mode goblin mode goblin mode
	if (FG.settings.gamemode == 'greenskin') and (FG.settings.monsterSpawn == 'staff') then
		setNonSurfaceLightsSmooth(Color(100, 250, 50, 10), 1)
	end
	
	-- Tell user of chosen gamemode
	for client in Client.ClientList do
		messageClient(client, 'popup', string.localize('gamemodeInfo', {text = FG.settings.info}, client.Language))
	end
	
	return true
end)

-- Executes when a human is transformed
Hook.Add("husk.clientControl", "humanTransformed", function (client, husk)

	Timer.Wait(function ()
		messageClient(client, 'info', string.localize('huskInfo', nil, client.Language))
	end, 5*1000)
	
	return true
end)

-- Execute when a human puts on a goblin mask
Hook.Add("goblinMask.wear", "turnHumanIntoGoblin", function (effect, deltaTime, item, targets, worldPosition)
	-- Guard clause
	local character = targets[1]
	if (character == nil) or (character.SpeciesName ~= 'human') then return end
	
	-- Is Troll
	local isTroll = math.random(100) <= FG.settings.conversionTrollPercentage
	
	-- For safety
	local client = findClientByCharacter(character)
	if client ~= nil then
		--client.SetClientCharacter(nil)
		messageClient(client, 'info', string.localize('greenskinInfo', nil, client.Language))
	end
	
	-- Find items to be regiven (clothing, ID Card, etc)
	local slotItems = {}
	for itemCount = 0, character.Inventory.Capacity do
		local item = character.Inventory.GetItemAt(itemCount)
		if (table.has({0, 1, 3, 4, 5, 6, 7}, itemCount) and (not isTroll)) or (table.has({0, 1, 3, 4, 7}, itemCount) and isTroll) then
			local conversion = {[0] = 0, [1] = 1, [3] = 2, [4] = 3, [5] = 4, [6] = 6, [7] = 6}
			slotItems[conversion[itemCount]] = item
		end
	end
	-- Find items to drop
	local dropItems = {}
	local hasRemovedMask = false
	for item in character.Inventory.AllItems do
		if not table.has(slotItems, item) then
			if (item.Prefab.identifier ~= 'goblinmask') or hasRemovedMask then
				table.insert(dropItems, item)
			else
				hasRemovedMask = true
			end
		end
	end
	
	-- Make goblin (or troll)
	local newCharacter = spawnHumangoblin(client, character.worldPosition, character.Name, isTroll)

	-- Give items back to player after a delay
	Timer.Wait(function ()
		-- Remove goblin card
		Entity.Spawner.AddEntityToRemoveQueue(newCharacter.Inventory.GetItemAt(0))
		-- Give clothing items to their correct slot
		for itemCount, item in pairs(slotItems) do
			--newCharacter.Inventory.ForceToSlot(item, itemCount)
			newCharacter.Inventory.TryPutItem(item, itemCount, true, true, newCharacter, true, true)
		end
		-- Give other items wherever they may fit (or put them in the floor by dropping them)
		for item in dropItems do
			local foundSlot = false
			for itemCount = 0, newCharacter.Inventory.Capacity do
				if newCharacter.Inventory.CanBePutInSlot(item, itemCount, false) and (itemCount ~= 4) and (itemCount ~= 5) then
					newCharacter.Inventory.TryPutItem(item, itemCount, true, true, newCharacter, true, true)
					foundSlot = true
				end
			end
			if not foundSlot then
				item.Drop()
			end
		end
		-- Delete old character
		Entity.Spawner.AddEntityToRemoveQueue(character)
		-- Check for game end
		checkForGameEnd()
	end, 100)
	
end)

-- Server settings to be applied
FG.serverSettings = {
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
    SelectedShuttle = 'FG Respawn',
    SelectedSubmarine = 'FG Facility',
    ServerDetailsChanged = true,
    ShowEnemyHealthBars = 0,
    SubSelectionMode = 0,--Manual
    TraitorsEnabled = 0,
    UseRespawnShuttle = true,
    VoiceChatEnabled = true
}

-- Applies settings to server
if SERVER then
	for setting, value in pairs(FG.serverSettings) do
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
end

-- Discord integration
if SERVER and FG.loadedFiles['discord'] and Game.ServerSettings.IsPublic then
	discordChatMessage('00| Server is up and running!')
end

-- Sucess Message
print('[!] Facility Gamemode by Sharp-Shark!')
print('...')

-- Pings clients again (incase, for example, the server did "reloadlua")
if SERVER then
	Timer.Wait(function ()
		print('[!] Sending ping to clients.')
		local message = Networking.Start("pingServerToClientAgain")
		Networking.Send(message)
	end, 1000)
end