print('...')
print('[!] Loading Facility Gamemode...')

-- CUSTOMIZABLE VARIABLE
global_huskMode = false -- Husk Gamemode

-- CUSTOMIZABLE VARIABLE
global_allowEnd = true -- Disables auto round end - turn to false for testing

-- CUSTOMIZABLE VARIABLE
global_autoJob = true -- Automatically give players a job - turn to false for testing

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

-- Indexes for Important Indexes (such as MERCS and JET spawn, monster spawn and escape area)
-- lua n = nil d = 999999 for i,w in pairs(Submarine.MainSub.GetWaypoints(false)) do if distance(Character.CharacterList[1].WorldPosition, w.WorldPosition) < d then n = i d = distance(Character.CharacterList[1].WorldPosition, w.WorldPosition) end end print(n)
global_waypointIndexes = {monsterSpawn = 859, terroristSpawn = 1123, nexpharmaSpawn = 1134, escape = 1051}

-- Husk Control cuz WHY NOT?!
 Game.EnableControlHusk(true)

-- Manual Spectator List
global_spectators = {}

-- Tells you if the round is ending
global_endGame = false

-- Counts amounts the think hook has been called, might be reset, don't use it as a total call counter
global_thinkCounter = 0

-- Player roles set at the start of the match
global_playerRole = {}

-- Whenever a player dies, add them to here (since if they are alive, they would have to be a JET or MERCS)
global_militantPlayers = {}

-- Respawn tickets for JET and MERCS
global_terroristTickets = 2.5
global_nexpharmaTickets = 5

-- Monster counter for setclientcharacter when multiple players pick the same monster
global_monsterCount = {mantis = 0, crawler = 0}

-- Respawns escapee as militant and rewards team with 1 tickets
function promoteEscapee (client)

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

	messageClient(connectedClient, 'popup', [[_Welcome to the Facility Gamemode by Sharp-Shark. Please have fun and respect the rules. If you want, join our discord.
	
	_When the game starts, your objective is to be the last team standing.
	_If you are a civilian, try and escape to grant your team tickets. Tickets determine the amount of respawns your team has.
	_If you are a militant, kill the other teams and help the civilians from your team in their quest to escape.
	
	_Your preferred job may be overriden by the gamemode's autobalance script, but the script will try and give you your desired job if possible. ALso, only the 1st job in your preferred jobs list matters.]])

end)

-- Executes constantly
Hook.Add("think", "thinkCheck", function ()

	global_thinkCounter = global_thinkCounter + 1
	
	if global_thinkCounter % 30 == 0 then
		for player in Client.ClientList do
			if player.Character ~= nil and player.Character.SpeciesName == 'human' and (player.Character.HasJob('assistant') or player.Character.HasJob('mechanic') or player.Character.HasJob('engineer')) and
			distance(Submarine.MainSub.GetWaypoints(false)[global_waypointIndexes.escape].WorldPosition, player.Character.WorldPosition) < 200 and not global_militantPlayers[player.Name] then
				promoteEscapee(player)
			end
		end
	end
	
	return true
end)

-- Execute at round start
Hook.Add("roundStart", "prepareMatch", function (createdCharacter)

	-- Resets round end
	global_endGame = false
	-- Refresh think call counter
	global_thinkCounter = 0
	-- Refresh Militant Player List
	global_militantPlayers = {}
	-- Refresh Monster Count
	global_monsterCount = {mantis = 0, crawler = 0}
	-- Refresh Tickets
	global_terroristTickets = 2.5
	global_nexpharmaTickets = 5
	-- Enabling cheats is necessary for ExecuteCommand method
	Game.ExecuteCommand('enablecheats')
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
	
	-- Randomly infect someone
	if global_huskMode then
		Timer.Wait(function ()
			-- Infect a random prisoner
			local chars = {}
			local char = nil
			for player in Client.ClientList do
				if player.Character ~= nil and player.Character.HasJob('assistant') then
					table.insert(chars, player.Character)
				end
			end
			if table.size(chars) == 0 then
				-- If no valid characters, infect someone at random
				local tries = 0
				char = Client.ClientList[math.random(#Client.ClientList)].Character
				while char == nil and tries <= 999 do
					char = Client.ClientList[math.random(#Client.ClientList)].Character
					tries = tries + 1
				end
			else
				char = chars[math.random(#chars)]
			end
			char.CharacterHealth.ApplyAffliction(char.AnimController.MainLimb, AfflictionPrefab.Prefabs["huskinfection"].Instantiate(100))
		end, 10*1000)
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

-- Sucess Message
print('[!] Facility Gamemode by Sharp-Shark!')
print('...')