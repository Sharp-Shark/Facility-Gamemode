-- Husk Control cuz WHY NOT?!
 Game.EnableControlHusk(true)

-- Manual Spectator List
global_spectators = {}

-- Husk Gamemode
global_huskMode = false

-- Disables auto round end - turn to false for testing
global_allowEnd = true

-- Automatically give players a job - turn to false for testing
global_autoJob = true

-- Tells you if the round is ending
global_endGame = false

-- Counts amounts the think hook has been called, might be reset, don't use it as a total call counter
global_thinkCounter = 0

-- Player roles set at the start of the match
global_playerRole = {}

-- Indexes for Important Indexes (such as MERCS and JET spawn, monster spawn and escape area)
global_waypointIndexes = {monsterSpawn = 1014, terroristSpawn = 582, nexpharmaSpawn = 628, escape = 504}

-- Whenever a player dies, add them to here (since if they are alive, they would have to be a JET or MERCS)
global_militantPlayers = {}

-- Loot Tables
global_lootTables = {
--	Uses binomial distribution (p is %, n is tries)
--	fg_tag = {
--		{'identifier', p, n, amount}
--	}
	fg_trash = {
		{'antidama2', 0.35, 1, 1},
		{'batterycell', 0.3, 1, 1},
		{'revolverround', 0.25, 1, 3},
	},
	fg_office1 = {
		{'antidama2', 0.35, 1, 1},
		{'batterycell', 0.3, 1, 1},
		{'opium', 0.3, 2, 1},
		{'tonicliquid', 0.2, 3, 1},
		{'proteinbar', 0.3, 4, 1},
		{'idcardstaff', 0.2, 1, 1}
	},
	fg_office2 = {
		{'flashlight', 0.35, 1, 1},
		{'antibleeding2', 0.2, 1, 1},
		{'antibleeding1', 0.4, 2, 1},
		{'batterycell', 0.3, 2, 1},
		{'opium', 0.3, 2, 1},
		{'tonicliquid', 0.3, 3, 1},
		{'proteinbar', 0.3, 3, 1},
		{'revolver', 0.15, 1, 1},
		{'revolverround', 0.3, 3, 3},
		{'cigar', 0.65, 1, 1},
		{'clownmask', 0.01, 1, 1},
		{'idcardstaff', 0.3, 1, 1}
	},
	fg_office3 = {
		{'harmonica', 0.2, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'antibleeding2', 0.2, 2, 1},
		{'antibleeding1', 0.4, 3, 1},
		{'batterycell', 0.3, 2, 1},
		{'steroids', 0.2, 2, 1},
		{'antibiotics', 0.2, 2, 1},
		{'opium', 0.3, 2, 1},
		{'revolver', 0.3, 1, 1},
		{'revolverround', 0.5, 3, 3},
		{'cigar', 0.6, 2, 1},
		{'idcardstaff', 0.1, 1, 1},
		{'idcardenforcerguard', 0.2, 1, 1},
		{'idcardoverseer', 0.05, 1, 1}
	},
	fg_office4 = {
		{'headset', 0.3, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'antibleeding1', 0.4, 3, 1},
		{'antibiotics', 0.2, 2, 1},
		{'antidama1', 0.3, 3, 1},
		{'smg', 0.2, 1, 1},
		{'smgmagazine', 0.4, 2, 1},
		{'revolver', 0.6, 1, 1},
		{'revolverround', 0.6, 4, 3},
		{'oxygentank', 0.4, 4, 1},
		{'batterycell', 0.4, 4, 1},
		{'idcardenforcerguard', 0.3, 1, 1},
		{'idcardeliteguard', 0.1, 1, 1},
		{'idcardoverseer', 0.1, 1, 1}
	},
	fg_supplies1 = {
		{'antibleeding2', 0.3, 3, 1},
		{'handcannon', 0.3, 1, 1},
		{'handcannonround', 0.25, 3, 6},
		{'ironhelmet', 0.35, 1, 1},
		{'toolbelt', 0.35, 1, 1},
		{'crowbar', 0.35, 1, 1},
		{'wrench', 0.35, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'weldingfueltank', 0.4, 4, 1},
		{'batterycell', 0.4, 4, 1},
		{'idcardstaff', 0.3, 1, 1},
		{'idcardenforcerguard', 0.1, 1, 1}
	},
	fg_supplies2 = {
		{'antibleeding2', 0.4, 4, 1},
		{'shotgun', 0.6, 1, 1},
		{'shotgunshell', 0.5, 3, 6},
		{'ironhelmet', 0.45, 1, 1},
		{'toolbelt', 0.45, 1, 1},
		{'plasmacutter', 0.45, 1, 1},
		{'weldingtool', 0.45, 1, 1},
		{'crowbar', 0.45, 1, 1},
		{'wrench', 0.45, 1, 1},
		{'flashlight', 0.45, 1, 1},
		{'weldingfueltank', 0.4, 4, 1},
		{'oxygentank', 0.4, 4, 1},
		{'batterycell', 0.4, 4, 1},
		{'idcardstaff', 0.6, 1, 1},
		{'idcardenforcerguard', 0.2, 1, 1}
	},
	fg_med1 = {
		{'antibleeding2', 0.15, 2, 1},
		{'antibleeding1', 0.6, 4, 1},
		{'antidama1', 0.2, 2, 1},
		{'deusizine', 0.15, 2, 1},
		{'antibiotics', 0.15, 2, 1},
		{'opium', 0.5, 3, 1}
	},
	fg_med2 = {
		{'antibloodloss1', 0.3, 3, 1},
		{'antibleeding2', 0.3, 3, 1},
		{'antibleeding1', 0.6, 6, 1},
		{'antidama1', 0.4, 3, 1},
		{'chloralhydrate', 0.6, 3, 1},
		{'deusizine', 0.3, 3, 1},
		{'antibiotics', 0.3, 3, 1},
		{'calyxanide', 0.6, 1, 1},
		{'combatstimulantsyringe', 0.1, 1, 1}
	},
	fg_guns = {
		{'bodyarmor', 0.5, 1, 1},
		{'machinepistol', 0.25, 1, 1},
		{'smgmagazine', 0.75, 8, 1},
		{'revolver', 0.55, 2, 1},
		{'revolverround', 0.5, 6, 6},
		{'divingknife', 0.5, 2, 1}
	},
	fg_shelter = {
		{'extinguisher', 0.5, 1, 1},
		{'divingmask', 0.6, 2, 1},
		{'oxygentank', 0.55, 3, 1},
		{'antibleeding1', 0.5, 3, 1},
		{'antidama1', 0.2, 2, 1},
		{'bodyarmor', 0.2, 2, 1},
		{'revolver', 0.6, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'revolverround', 0.2, 2, 6},
		{'crowbar', 0.45, 1, 1},
		{'divingknife', 0.2, 2, 1},
		{'batterycell', 0.3, 3, 1},
		{'flare', 0.2, 2, 2},
		{'idcardoverseer', 0.4, 1, 1}
	},
	fg_armory = {
		{'extinguisher', 0.5, 1, 1},
		{'headset', 0.35, 2, 1},
		{'antibleeding1', 0.5, 3, 1},
		{'antidama1', 0.2, 2, 1},
		{'bodyarmor', 0.2, 2, 1},
		{'revolver', 0.6, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'smgmagazine', 0.2, 2, 1},
		{'revolverround', 0.2, 2, 6},
		{'crowbar', 0.45, 1, 1},
		{'divingknife', 0.2, 2, 1},
		{'batterycell', 0.3, 3, 1},
		{'idcardenforcerguard', 0.3, 1, 1},
		{'idcardeliteguard', 0.1, 1, 1}
	},
	fg_ammo = {
		{'assaultriflemagazine', 0.8, 10, 1},
		{'shotgunshell', 0.8, 8, 6},
		{'smgmagazine', 0.7, 6, 1},
		{'revolverround', 0.7, 6, 6}
	},
	fg_diving = {
		{'underwaterscooter', 0.35, 2, 1},
		{'flashlight', 0.75, 2, 1},
		{'divingmask', 0.6, 5, 1},
		{'oxygentank', 0.55, 5, 1},
		{'batterycell', 0.6, 3, 1},
		{'divingknife', 0.75, 1, 1}
	}
}

-- JET Loadout
global_terroristLoadout = {
	{'autoshotgun', 1, 7},
	{'shotgunshell', 12, 7},
	{'shotgunshell', 12, 7},
	{'handcannon', 1, 8},
	{'handcannonround', 6, 8},
	{'shotgunshell', 12, 9},
	{'handcannonround', 12, 10},
	{'crowbar', 1, 11},
	{'antibleeding2', 2, 12},--Plastiseal
	{'oxygentank', 1, 13},
	{'flashlight', 1, 14},
	{'batterycell', 1, 14},
	{'divingmask', 1, 2},
	{'pirateclothes', 1, 3},
	{'piratebodyarmor', 1, 4},
	{'autoinjectorheadset', 1, 1},
	{'combatstimulantsyringe', 1, 1},
	{'idcardjet', 1, 0},
}

-- MERCS Ladout
global_nexpharmaLoadout = {
	{'assaultrifle', 1, 7},
	{'assaultriflemagazine', 1, 7},
	{'smg', 1, 8},
	{'smgmagazine', 1, 8},
	{'assaultriflemagazine', 2, 9},
	{'assaultriflemagazine', 2, 10},
	{'smgmagazine', 1, 11},
	{'divingknife', 1, 12},
	{'antibleeding2', 2, 13},--Plastiseal
	{'flashlight', 1, 14},
	{'batterycell', 1, 14},
	{'piratebandana', 1, 2},
	{'securityuniform2', 1, 3},
	{'pucs', 1, 4},
	{'combatstimulantsyringe', 1, 4},
	{'oxygentank', 1, 4},
	{'headset', 1, 1},
	{'idcardmercs', 1, 0}
}

-- Respawn tickets for JET and MERCS
global_terroristTickets = 0
global_nexpharmaTickets = 0

-- Monster counter for setclientcharacter when multiple players pick the same monster
global_monsterCount = {mantis = 0, crawler = 0}

-- Checks distance between two vectors
function distance (v2a, v2b)
	return ((v2a.x-v2b.x)^2 + (v2a.y-v2b.y)^2)^0.5
end

-- Gives a certain amount of an item to a character
function giveItemCharacter (character, identifier, amount, slot)

	-- Give Item
	for n=1,amount do 
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), character.Inventory, nil, nil, function (spawnedItem)
			if slot == nil then return end
			character.Inventory.TryPutItem(spawnedItem, slot, true, true, character, true, true)
		end)
	end
	
	return true
end

-- Spawns a monster at a containment cell, gives a player control of it, tps their body to it and kills it too (free meal)
function spawnPlayerMonster (character, species)
	-- Guard clause.
	if character.IsBot then return end

	-- Spawn monster at containment cell
	Entity.Spawner.AddCharacterToSpawnQueue(species .. 'admin', Submarine.MainSub.GetWaypoints(false)[global_waypointIndexes.monsterSpawn].WorldPosition, function ()
		-- Give player control of their monster (and bump monster counters)
		Game.ExecuteCommand('setclientcharacter "' .. character.Info.Name .. '" ' .. species .. 'admin ' .. global_monsterCount[species])
		global_monsterCount[species] = global_monsterCount[species] + 1
		-- Teleport and kill their human bodies
		Game.ExecuteCommand('kill "' .. character.Info.Name .. '"')
		character.TeleportTo(Submarine.MainSub.GetWaypoints(false)[global_waypointIndexes.monsterSpawn].WorldPosition)
	end)

	return true
end

-- Messages a message to a client
function messageClient (client, msgType, text)
	if msgType == 'blue' then
		local chatMessage = ChatMessage.Create("@", text, ChatMessageType.Radio, nil, nil)
		chatMessage.Color = Color(155, 200, 255, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	elseif msgType == 'popup' then
		Game.SendDirectChatMessage("",text, nil, ChatMessageType.MessageBox, client)
	elseif msgType == 'info' then
		Game.SendDirectChatMessage("",text, nil, ChatMessageType.ServerMessageBoxInGame, client, 'WorkshopMenu.InfoButton')
	end
end

-- Removes the items of respawnees, gives them their proper loadout (be it JET or MERCS) and teleports them to their spawn area
function spawnPlayerMilitant (character, team)
	if character == nil or character.SpeciesName ~= 'human' or character.IsDead then return end

	global_militantPlayers[character.Info.Name] = true
	
	-- Heal incase player was hurt
	Game.ExecuteCommand('heal ' .. character.Info.Name)
	
	-- Remove player items
	Timer.Wait(function ()
		for item in character.Inventory.AllItems do
			Entity.Spawner.AddEntityToRemoveQueue(item)
		end
	end, 250)
	-- Team Specific Actions
	if team == 'JET' then
		-- Give items
		local itemCount = 1
		for item in global_terroristLoadout do
			Timer.Wait(function ()
				for n=1,item[2] do
					giveItemCharacter(character, item[1], 1, item[3])
				end
			end, itemCount*20+500)
			itemCount = itemCount + 1
		end
		-- Teleport player into battlefield
		character.TeleportTo(Submarine.MainSub.GetWaypoints(false)[global_waypointIndexes.terroristSpawn].WorldPosition)
	elseif team == 'MERCS' then
		-- Give items
		local itemCount = 1
		for item in global_nexpharmaLoadout do
			Timer.Wait(function ()
				for n=1,item[2] do
					giveItemCharacter(character, item[1], 1, item[3])
				end
			end, itemCount*20+500)
			itemCount = itemCount + 1
		end
		-- Teleport player into battlefield
		character.TeleportTo(Submarine.MainSub.GetWaypoints(false)[global_waypointIndexes.nexpharmaSpawn].WorldPosition)
	end

	return true
end

-- Executes constantly
Hook.Add("think", "thinkCheck", function ()

	global_thinkCounter = global_thinkCounter + 1
	
	if global_thinkCounter % 30 == 0 then
		for player in Client.ClientList do
			if player.Character ~= nil and player.Character.SpeciesName == 'human' and (player.Character.HasJob('assistant') or player.Character.HasJob('mechanic') or player.Character.HasJob('engineer')) and
			distance(Submarine.MainSub.GetWaypoints(false)[global_waypointIndexes.escape].WorldPosition, player.Character.WorldPosition) < 200 and not global_militantPlayers[player.Name] then
				promoteEscapee(player.Name)
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
			local char = Client.ClientList[math.random(#Client.ClientList)].Character
			char.CharacterHealth.ApplyAffliction(char.AnimController.MainLimb, AfflictionPrefab.Prefabs["huskinfection"].Instantiate(100))
		end, 10*1000)
	end

    return true
end)

-- Execute when someone joins
Hook.Add("client.connected", "characterDied", function (connectedClient)

	messageClient(connectedClient, 'popup', [[_Welcome to the Facility Gamemode by Sharp-Shark. Please have fun and respect the rules. If you want, join our discord.
	
	_When the game starts, your objective is to be the last team standing.
	_If you are a civilian, try and escape to grant your team tickets. Tickets determine the amount of respawns your team has.
	_If you are a militant, kill the other teams and help the civilians from your team in their quest to escape.
	
	_Your preferred job may be overriden by the gamemode's autobalance script, but the script will try and give you your desired job if possible. ALso, only the 1st job in your preferred jobs list matters.]])

end)

-- Execugte when a character dies
Hook.Add("character.death", "characterDied", function (character)
	if character == nil or global_endGame then return end
	
	-- Reward a team for target elimination
	if character.LastAttacker ~= nil and character.LastAttacker.SpeciesName == 'human' then
		-- If dead is monster and...
		if character.SpeciesName ~= 'human' then
			-- and killer is terrorist then...
			if character.LastAttacker.HasJob('assistant') or character.LastAttacker.HasJob('captain') or character.LastAttacker.HasJob('medicaldoctor') then
				global_terroristTickets = global_terroristTickets + 2
				Game.ExecuteCommand('say Terrorists have gained 2 tickets - monster target eliminated! ' .. global_terroristTickets .. ' tickets left!' )
			-- and killer is nexpharma then...
			elseif character.LastAttacker.HasJob('securityofficer') or character.LastAttacker.HasJob('mechanic') or character.LastAttacker.HasJob('engineer') then
				global_nexpharmaTickets = global_nexpharmaTickets + 2
				Game.ExecuteCommand('say Nexpharma has gained 2 tickets - monster target eliminated! ' .. global_nexpharmaTickets .. ' tickets left!' )
			end
		-- If dead is nexpharma and killer is terrorist then...
		elseif (character.HasJob('securityofficer') or character.HasJob('mechanic') or character.HasJob('engineer')) and
		(character.LastAttacker.HasJob('assistant') or character.LastAttacker.HasJob('captain') or character.LastAttacker.HasJob('medicaldoctor')) then
			-- Reward 0.5 extra tickts if it was by an inmate
			if not global_militantPlayers[character.LastAttacker.Info.Name] then
				global_terroristTickets = global_terroristTickets + 1.0
				Game.ExecuteCommand('say Terrorists have gained 1 ticket - human eliminated by inmate! ' .. global_terroristTickets .. ' tickets left!' )
			else
				global_terroristTickets = global_terroristTickets + 0.5
				Game.ExecuteCommand('say Terrorists have gained 0.5 tickets - human target eliminated! ' .. global_terroristTickets .. ' tickets left!' )
			end
		-- If dead is terrorist and killer is nexpharma then...
		elseif (character.HasJob('assistant') or character.HasJob('captain') or character.HasJob('medicaldoctor')) and
		(character.LastAttacker.HasJob('securityofficer') or character.LastAttacker.HasJob('mechanic') or character.LastAttacker.HasJob('engineer')) then
			global_nexpharmaTickets = global_nexpharmaTickets + 0.5
			Game.ExecuteCommand('say Nexpharma has gained a 0.5 tickets - human target eliminated! ' .. global_nexpharmaTickets .. ' tickets left!' )
		end
	end

	if character.SpeciesName == 'human' and global_militantPlayers[character.Info.Name] == nil then
		global_militantPlayers[character.Info.Name] = true
	end
	
	-- Add a 1 second delay before checking for end conditions just to be sure
	Timer.Wait(function ()
		-- Make sure the game isn't already ending
		if global_endGame then return end
		-- Count live players
		local terroristPlayersAlive = 0
		local nexpharmaPlayersAlive = 0
		local monsterPlayersAlive = 0
		for player in Client.ClientList do
			if  player.Character ~= nil and not player.Character.IsDead then
				if player.Character.SpeciesName == 'Mantisadmin' or player.Character.SpeciesName == 'Crawleradmin' or player.Character.SpeciesName == 'Humanhusk' then
					monsterPlayersAlive = monsterPlayersAlive + 1
				elseif player.Character.SpeciesName == 'human' then
					if player.Character.HasJob('assistant') or player.Character.HasJob('captain') or player.Character.HasJob('medicaldoctor') then
						terroristPlayersAlive = terroristPlayersAlive + 1
					elseif player.Character.HasJob('securityofficer') or player.Character.HasJob('mechanic') or player.Character.HasJob('engineer') then
						nexpharmaPlayersAlive = nexpharmaPlayersAlive + 1
					end
				end
			end
		end
		-- End message
		local endGame = false
		if (terroristPlayersAlive + nexpharmaPlayersAlive + monsterPlayersAlive) == 0 then
			for player in Client.ClientList do
				messageClient(player, 'popup', 'The match has ended in a STALEMATE - there are no living players.')
			end
			endGame = true
		elseif terroristPlayersAlive > 0 and (nexpharmaPlayersAlive + monsterPlayersAlive) == 0 then
			for player in Client.ClientList do
				messageClient(player, 'popup', 'The match has ended in a TERRORIST WIN - all other teams have been eliminated.')
			end
			endGame = true
		elseif nexpharmaPlayersAlive > 0 and (terroristPlayersAlive + monsterPlayersAlive) == 0 then
			for player in Client.ClientList do
				messageClient(player, 'popup', 'The match has ended in a NEXPHARMA WIN - all other teams have been eliminated.')
			end
			endGame = true
		elseif monsterPlayersAlive > 0 and (terroristPlayersAlive + nexpharmaPlayersAlive) == 0 then
			for player in Client.ClientList do
				messageClient(player, 'popup', 'The match has ended in a MONSTER WIN - all other teams have been eliminated.')
			end
			endGame = true
		end
		-- The Final Countdown
		if endGame and global_allowEnd then
			global_endGame = true
			for n=1,11 do
				Timer.Wait(function ()
					Game.ExecuteCommand('say ENDING IN ' .. (11-n))
				end, n*1000)
			end
			Timer.Wait(function ()
				Game.EndGame()
			end, 11*1000+500)
		end
	end, 5000)

	return true
end)

-- Execute when players are spawned - be it a respawn wave, or the start of the match
Hook.Add("character.giveJobItems", "monsterAndRespawns", function (createdCharacter)

	local characterClient = ''
	for player in Client.ClientList do
		if createdCharacter.Info.Name == player.Name then
			characterClient = player
		end
	end
	
	if characterClient == '' then return end

	-- Executed on match start to spawn in the monsters
	if createdCharacter.Submarine.Info.Name == '_Facility' then
		-- Captain is Mutated Mantis
		if createdCharacter.HasJob('captain') then
			spawnPlayerMonster(createdCharacter, 'mantis')
			messageClient(characterClient, 'info', 'You are a Mutated Mantis! A slow and weak monster with lots of HP. Work with your fellow monsters to kill all humans! You may eat corpses, use regular doors, use the trams and use local voicechat.')
		-- Medic is Mutated Crawler
		elseif createdCharacter.HasJob('medicaldoctor') then
			spawnPlayerMonster(createdCharacter, 'crawler')
			messageClient(characterClient, 'info', 'You are a Mutated Crawler! A fast and strong monster with decent HP. Work with your fellow monsters to kill all humans! You may eat corpses, use regular doors, use the trams and use local voicechat.')
		-- Mechanic and Engineer (Researcher) are Nexpharma Staff
		elseif createdCharacter.HasJob('mechanic') or createdCharacter.HasJob('engineer') then
			messageClient(characterClient, 'info', 'You are a civilian, part of Nexpharma staff, equipped with your low level keycard and a few supplies. Work with MERCS, guards and fellow staff to escape the facility!')
		-- Security Officer is Nexpharma Security
		elseif createdCharacter.HasJob('securityofficer') then
			messageClient(characterClient, 'info', 'You are an armed member of Nexpharma security, equipped with a simple guard card and a sidearm. Work with MERCS and fellow guards to kill inmates, JET and monsters whilst helping staff escape.')
		-- Assistant is Inmate
		elseif createdCharacter.HasJob('assistant') then
			messageClient(characterClient, 'info', 'You are a civilian member of the Terrorist faction, equipped with almost nothing. Work with your fellow inmates and JET to escape this wretched place!')
		end
		
	-- Executed at respawn waves to equip and teleport the JET and MERCS
	elseif createdCharacter.Submarine.Info.Name == '_Respawn' then
		-- Inmate and Monsters respawn as JET
		if createdCharacter.HasJob('assistant') or createdCharacter.HasJob('captain') or createdCharacter.HasJob('medicaldoctor') then
			if global_terroristTickets >= 1 then
				-- Update Ticket Count
				global_terroristTickets = global_terroristTickets - 1
				Game.ExecuteCommand('say Terrorists have lost 1 ticket - an unit has respawn! ' .. global_terroristTickets .. ' tickets left!' )
				-- Spawns JET
				spawnPlayerMilitant(createdCharacter, 'JET')
				messageClient(characterClient, 'info', 'The Jovian Elite Troops or JET - a militant member of the Terrorist militia, equipped with heavy weaponry, meds, armor and a high-level card. Help inmates escape and kill the monsters and everyone working for Nexpharma.')
			else
				Game.ExecuteCommand('say Terrorists are out of tickets - no more respawns!')
				Game.ExecuteCommand('kill ' .. createdCharacter.Info.Name)
			end
			
		-- Guards and Staff respawn as MERCS
		elseif createdCharacter.HasJob('securityofficer') or createdCharacter.HasJob('mechanic') or createdCharacter.HasJob('engineer') then
			if global_nexpharmaTickets >= 1 then
				-- Update Ticket Count
				global_nexpharmaTickets = global_nexpharmaTickets - 1
				Game.ExecuteCommand('say Nexpharma has lost 1 ticket - an unit has respawn! ' .. global_nexpharmaTickets .. ' tickets left!' )
				-- Spawns MERCS
				spawnPlayerMilitant(createdCharacter, 'MERCS')
				messageClient(characterClient, 'info', 'The Mobile Emergency Rescue and Combat Squad or MERCS - a militant member of the Nexpharma private army, equipped with heavy weaponry, meds, armor and a high-level card. Work together with guards to help staff escape and kill the inmates, JET and monsters.')
			else
				Game.ExecuteCommand('say Nexpharma is out of tickets - no more respawns!')
				Game.ExecuteCommand('kill ' .. createdCharacter.Info.Name)
			end
		end
	end

    return true
end)

-- Overrides the jobs the players chose, assuming auto jobs is activated
Hook.Add("jobsAssigned", "automaticJobAssignment", function ()
	if CLIENT and Game.IsMultiplayer then return end
	if not global_autoJob then return end

	global_playerRole = assignPlayerRole()
	
	local roleJob = {}
	roleJob['monster'] = {'medicaldoctor', 'captain'}
	roleJob['staff'] = {'mechanic', 'engineer'}
	roleJob['guard'] = {'securityofficer'}
	roleJob['inmate'] = {'assistant'}

	for playerName, role in pairs(global_playerRole) do
		for player in Client.ClientList do
			if playerName == player.Name then
				if role == 'monster' then
					if player.preferredJob == 'captain' then
						player.AssignedJob = JobVariant(JobPrefab.Get('captain'), 0)
					elseif player.preferredJob == 'medicaldoctor' then
						player.AssignedJob = JobVariant(JobPrefab.Get('medicaldoctor'), 0)
					else
						player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
					end
				elseif role == 'staff' then
					if player.preferredJob == 'mechanic' then
						player.AssignedJob = JobVariant(JobPrefab.Get('mechanic'), 0)
					elseif player.preferredJob == 'engineer' then
						player.AssignedJob = JobVariant(JobPrefab.Get('engineer'), 0)
					else
						player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
					end
				else
					player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
				end
				break
			end
		end
	end
	
	return true
end)

-- Get Team Distribution
function roleDistribution ()

	if #global_spectators > 0 then
		print('[!] List of spectators ahead.')
		for player in global_spectators do
			print('[!] ' .. player .. ' is a spectator.')
		end
		print()
	end
	
	local unassigned = #Client.ClientList - #global_spectators
	local teamCount = {}
	teamCount['monster'] = 0
	teamCount['staff'] = 0
	teamCount['guard'] = 0
	teamCount['inmate'] = 0
	
	teamCount['monster'] = math.ceil(unassigned/5)
	unassigned = unassigned - teamCount['monster']
	
	teamCount['staff'] = math.ceil(unassigned/4)
	unassigned = unassigned - teamCount['staff']
	teamCount['guard'] = math.floor(unassigned/3)
	unassigned = unassigned - teamCount['guard']
	
	teamCount['inmate'] = unassigned
	
	if global_huskMode then
		teamCount['inmate'] = teamCount['inmate'] + teamCount['monster']
		teamCount['monster'] = 0
	end
	
	return teamCount
end

-- Assign players a Role
function assignPlayerRole ()

	local teamCount = roleDistribution()
	local unassignedPlayers = {}
	for player in Client.ClientList do
		if not global_spectators[player.Name] then
			table.insert(unassignedPlayers, player.Name)
		end
	end
	local playerRole = {}
	local selectedRole = ''
	local unsolvedPlayers = {}
	local index = 0
	
	-- Give players their preferred role if possible
	while ((teamCount['monster'] + teamCount['staff'] + teamCount['guard'] + teamCount['inmate']) > 0) and #unassignedPlayers > 0 do
		index = math.random(#unassignedPlayers)
		
		selectedRole = ''
		for player in Client.ClientList do
			if unassignedPlayers[index] == player.Name then
				if (player.PreferredJob == 'captain' or player.PreferredJob == 'medicaldoctor') and teamCount['monster'] > 0 then
					selectedRole = 'monster'
				elseif (player.PreferredJob == 'mechanic' or player.PreferredJob == 'engineer') and teamCount['staff'] > 0 then
					selectedRole = 'staff'
				elseif (player.PreferredJob == 'securityofficer') and teamCount['guard'] > 0 then
					selectedRole = 'guard'
				elseif (player.PreferredJob == 'assistant') and teamCount['inmate'] > 0 then
					selectedRole = 'inmate'
				else
					-- Couldn't give preferred role - move to unsolved player lit
					table.insert(unsolvedPlayers, table.remove(unassignedPlayers, index))
				end
			end
		end
		
		if selectedRole ~= '' then
			playerRole[table.remove(unassignedPlayers, index)] = selectedRole
			teamCount[selectedRole] = teamCount[selectedRole] - 1
		end
	end
	
	-- Give roleless players a random role
	while ((teamCount['monster'] + teamCount['staff'] + teamCount['guard'] + teamCount['inmate']) > 0) and #unsolvedPlayers > 0 do
		index = math.random(#unsolvedPlayers)
		
		selectedRole = ''
		if teamCount['monster'] > 0 then
			selectedRole = 'monster'
		elseif teamCount['staff'] > 0 then
			selectedRole = 'staff'
		elseif teamCount['guard'] > 0 then
			selectedRole = 'guard'
		elseif teamCount['inmate'] > 0 then
			selectedRole = 'inmate'
		end
		
		if selectedRole ~= '' then
			playerRole[table.remove(unsolvedPlayers, index)] = selectedRole
			teamCount[selectedRole] = teamCount[selectedRole] - 1
		end
	end
	
	return playerRole
end

-- Respawns escapee as militant and rewards team with 1 tickets
function promoteEscapee (username)

	-- Search for client
	local clientIndex = -1
	local counter = 1
	for player in Client.ClientList do
		if player.Name == username then
			clientIndex = counter
			break
		end
		counter = counter + 1
	end
	if clientIndex == -1 then return end
	-- Spawn escapee as militant
	global_militantPlayers[Client.ClientList[clientIndex].Name] = true
	clientCharacter = Client.ClientList[clientIndex].Character
	if clientCharacter.HasJob('assistant') or clientCharacter.HasJob('captain') or clientCharacter.HasJob('medicaldoctor') then
		-- Update Ticket Count
		global_terroristTickets = global_terroristTickets + 2
		Game.ExecuteCommand('say Terrorists have gained 2 tickets - civilian has escaped! ' .. global_terroristTickets .. ' tickets left!' )
		-- Spawns JET
		spawnPlayerMilitant(clientCharacter, 'JET')
	elseif clientCharacter.HasJob('securityofficer') or clientCharacter.HasJob('mechanic') or clientCharacter.HasJob('engineer') then
		-- Update Ticket Count
		global_nexpharmaTickets = global_nexpharmaTickets + 1
		Game.ExecuteCommand('say Nexpharma has gained 1 ticket - civilian has escaped! ' .. global_nexpharmaTickets .. ' tickets left!' )
		-- Spawns MERCS
		spawnPlayerMilitant(clientCharacter, 'MERCS')
	end

end

-- User Commands
-- Lists and explains user commands
Hook.Add("chatMessage", "helpCommand", function (message, client)
    if message ~= '/help' then return end
	
	messageClient(client, 'blue', '/help - gives command list.')
	messageClient(client, 'blue', '/admin - calls admin attention.')
	messageClient(client, 'blue', '/admin <text> - sends text to admin.')
	messageClient(client, 'blue', '/players - gives a list of players and their roles.')
	messageClient(client, 'blue', '/tickets - tells JET and MERCS ticket count.')

    return true
end)

-- Communicate with admin
Hook.Add("chatMessage", "callAdmin", function (message, client)
    if message.sub(message, 1, 7) ~= "/admin " and message ~= '/admin' then return end
	
	if #message < 8 then
		Game.ExecuteCommand('say ' .. client.Name .. ' requires an admin/host.')
	else 
		Game.ExecuteCommand('say ' .. client.Name .. ' has a message for admin/host: ' .. string.sub(message, 8))
	end

    return true
end)

-- Gives a list of players alive
Hook.Add("chatMessage", "livePlayerList", function (message, client)
    if message ~= '/players' then return end
	
	for player in Client.ClientList do
		if player.Character ~= nil and not player.Character.IsDead then
			if player.Character.SpeciesName == 'human' then
				if (player.Character.HasJob('assistant') or player.Character.HasJob('captain') or player.Character.HasJob('medicaldoctor')) and global_militantPlayers[player.Name]  then
					messageClient(client, 'blue', player.Name .. ' is an armed member of the terrorist faction.')
				elseif player.Character.HasJob('assistant') then
					messageClient(client, 'blue', player.Name .. ' is a civilian member of the terrorist faction.')
				elseif player.Character.HasJob('securityofficer') or ((player.Character.HasJob('mechanic') or player.Character.HasJob('engineer')) and global_militantPlayers[player.Name]) then
					messageClient(client, 'blue', player.Name .. ' is an armed member of the nexpharma corp.')
				elseif player.Character.HasJob('mechanic') or player.Character.HasJob('engineer') then
					messageClient(client, 'blue', player.Name .. ' is a civilian member of the nexpharma corp.')
				end
			elseif player.Character.SpeciesName == 'mantisadmin' then
				messageClient(client, 'blue', player.Name .. ' is mutated mantis.')
			elseif player.Character.SpeciesName == 'crawleradmin' then
				messageClient(client, 'blue', player.Name .. ' is mutated crawler.')
			end
		end
	end

    return true
end)

-- Tells the current amount of tickets
Hook.Add("chatMessage", "ticketCount", function (message, client)
    if message ~= '/tickets' then return end
	
	messageClient(client, 'blue', 'Terrorists have ' .. global_terroristTickets .. ' tickets left.')
	messageClient(client, 'blue', 'Nexpharma has ' .. global_nexpharmaTickets .. ' tickets left.')

    return true
end)

-- Declare self as Spectator
Hook.Add("chatMessage", "declareSpectator", function (message, client)
    if message ~= '/am_spect' then return end
	
	messageClient(client, 'blue', 'You are now in the spectators list.')
	global_spectators[client.Name] = true

    return true
end)

-- Reset Spectator list
Hook.Add("chatMessage", "resetSpectator", function (message, client)
    if message ~= '/reset_spect' then return end
	
	messageClient(client, 'blue', 'Spectator list reset.')
	global_spectators = {}

    return true
end)

-- Sucess Message
print('[!] Facility Gamemode by Sharp-Shark!')