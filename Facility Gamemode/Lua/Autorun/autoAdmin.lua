-- Game.EnableControlHusk(override)

-- Turn on for debugging and testing, disable when hosting
global_debug = false

-- Tells you if the round is ending
global_endGame = false

-- Counts amounts the think hook has been called, might be reset, don't use it as a total call counter
global_thinkCounter = 0

-- Waypoint used for spawnpoints for monsters, JET (Terrorists) and MERCS (Nexpharma) respectivelly
global_monsterSpawnWaypointIndex = 1014
global_terroristSpawnWaypointIndex = 582
global_nexpharmaSpawnWaypointIndex = 628
-- Waypoint used to detect escaped civilians
global_escapeWaypointIndex = 504

-- Whenever a player dies, add them to here (since if they are alive, they would have to be a JET or MERCS)
global_militantPlayers = {}

-- JET Loadout
global_terroristLoadout = {
	{'autoshotgun', 1},
	{'handcannon', 1},
	{'shotgunshell', 12},
	{'handcannonround', 12},
	{'crowbar', 1},
	{'antibleeding2', 2},--Plastiseal
	{'shotgunshell', 12},
	{'shotgunshell', 12},
	{'handcannonround', 6},
	{'combatstimulantsyringe', 1},
	{'oxygentank', 1},
	{'divingmask', 1},
	{'pirateclothes', 1},
	{'piratebodyarmor', 1},
	{'autoinjectorheadset', 1},
	{'idcardjet', 1},
}

-- MERCS Ladout
global_nexpharmaLoadout = {
	{'assaultrifle', 1},
	{'assaultriflemagazine', 2},
	{'assaultriflemagazine', 2},
	{'divingknife', 1},
	{'antibleeding2', 2},--Plastiseal
	{'assaultriflemagazine', 1},
	{'combatstimulantsyringe', 1},
	{'oxygentank', 1},
	{'piratebandana', 1},
	{'securityuniform2', 1},
	{'pucs', 1},
	{'headset', 1},
	{'idcardmercs', 1}
}

-- Give Item Queue
global_giveItemQueue = {
}

-- Respawn tickets for JET and MERCS
global_terroristTickets = 6
global_nexpharmaTickets = 6

-- Monster counter for setclientcharacter when multiple players pick the same monster
global_monsterCount = {}
global_monsterCount['mantis'] = 0
global_monsterCount['crawler'] = 0

-- Checks distance between two vectors
function distance (v2a, v2b)
	return ((v2a.x-v2b.x)^2 + (v2a.y-v2b.y)^2)^0.5
end

-- Gives a certain amount of an item to a character
function giveItemCharacter (character, identifier, amount)

	-- Give Item
	for n=1,amount do 
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), character.Inventory, nil, nil, nil)
	end
	
	return true
end

-- Spawns a monster at a containment cell, gives a player control of it, tps their body to it and kills it too (free meal)
function spawnPlayerMonster (character, species)
	-- Guard clause.
	if character.IsBot then return end

	-- Announce the player's team in chat
	Game.ExecuteCommand('say ' .. character.Info.Name .. ' is ' .. species .. 'admin!')
	-- Spawn monster at containment cell
	Entity.Spawner.AddCharacterToSpawnQueue(species .. 'admin', Submarine.MainSub.GetWaypoints(false)[global_monsterSpawnWaypointIndex].WorldPosition, function ()
		-- Give player control of their monster (and bump monster counters)
		Game.ExecuteCommand('setclientcharacter "' .. character.Info.Name .. '" ' .. species .. 'admin ' .. global_monsterCount[species])
		global_monsterCount[species] = global_monsterCount[species] + 1
		-- Teleport and kill their human bodies
		Game.ExecuteCommand('kill "' .. character.Info.Name .. '"')
		character.TeleportTo(Submarine.MainSub.GetWaypoints(false)[global_monsterSpawnWaypointIndex].WorldPosition)
	end)

	return true
end

-- Messages a message to a client
function messageClient (client, r, g, b, text)
	local chatMessage = ChatMessage.Create("@", text, ChatMessageType.Radio, nil, nil)
	chatMessage.Color = Color(r, g, b, 255)
	Game.SendDirectChatMessage(chatMessage, client)
end

-- Removes the items of respawnees, gives them their proper loadout (be it JET or MERCS) and teleports them to their spawn area
function spawnPlayerMilitant (character, team)

	global_militantPlayers[character.Info.Name] = true
	
	-- Remove player items
	for item in character.Inventory.AllItems do
		Entity.Spawner.AddEntityToRemoveQueue(item)
	end
	-- Team Specific Actions
	if team == 'JET' then
		-- Give items
		for item in global_terroristLoadout do
			for n=1,item[2] do
				table.insert(global_giveItemQueue, {character, item[1]})
			end
		end
		-- Teleport player into battlefield
		character.TeleportTo(Submarine.MainSub.GetWaypoints(false)[global_terroristSpawnWaypointIndex].WorldPosition)
	elseif team == 'MERCS' then
		-- Give items
		for item in global_nexpharmaLoadout do
			for n=1,item[2] do
				table.insert(global_giveItemQueue, {character, item[1]})
			end
		end
		-- Teleport player into battlefield
		character.TeleportTo(Submarine.MainSub.GetWaypoints(false)[global_nexpharmaSpawnWaypointIndex].WorldPosition)
	end

	return true
end

-- Executes constantly
Hook.Add("think", "thinkCheck", function ()

	global_thinkCounter = global_thinkCounter + 1

	if global_giveItemQueue[1] ~= nil then
		giveItemCharacter(global_giveItemQueue[1][1], global_giveItemQueue[1][2], 1)
		table.remove(global_giveItemQueue, 1)
	end
	
	if global_thinkCounter % 30 == 0 then
		for player in Client.ClientList do
			if player.Character ~= nil and player.Character.SpeciesName == 'human' and (player.Character.HasJob('assistant') or player.Character.HasJob('mechanic') or player.Character.HasJob('engineer')) and
			distance(Submarine.MainSub.GetWaypoints(false)[global_escapeWaypointIndex].WorldPosition, player.Character.WorldPosition) < 200 and not global_militantPlayers[player.Name] then
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
	global_monsterCount = {}
	global_monsterCount['mantis'] = 0
	global_monsterCount['crawler'] = 0
	-- Refresh Tickets
	global_terroristTickets = 6
	global_nexpharmaTickets = 6
	-- Enabling cheats is necessary for ExecuteCommand method
	Game.ExecuteCommand('enablecheats')
	-- Stops the facility from being destroyed by players
	Game.ExecuteCommand('godmode_mainsub')
	for sub in Submarine.Loaded do
		sub.GodMode = true
	end
	-- Important info
	Game.ExecuteCommand('say Welcome to Facility Gamemode (by Sharp-Shark)!')

    return true
end)

-- Execugte when a character dies
Hook.Add("character.death", "characterDied", function (character)

	if global_endGame then return end

	if character.SpeciesName == 'human' and global_militantPlayers[character.Info.Name] == nil then
		table.insert(global_militantPlayers, character.Info.Name)
	end
	
	terroristPlayersAlive = 0
	nexpharmaPlayersAlive = 0
	monsterPlayersAlive = 0
	for player in Client.ClientList do
		if  player.Character ~= nil and not player.Character.IsDead then
			if player.Character.SpeciesName == 'Mantisadmin' or player.Character.SpeciesName == 'Crawleradmin' then
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
	
	endGame = false
	if (terroristPlayersAlive + nexpharmaPlayersAlive + monsterPlayersAlive) == 0 then
		for n=1,5 do
			Game.ExecuteCommand('say ROUND HAS ENDED IN: STALEMATE')
		end
		endGame = true
	elseif terroristPlayersAlive > 0 and (nexpharmaPlayersAlive + monsterPlayersAlive) == 0 then
		for n=1,5 do
			Game.ExecuteCommand('say ROUND HAS ENDED IN: TERRORIST WIN')
		end
		endGame = true
	elseif nexpharmaPlayersAlive > 0 and (terroristPlayersAlive + monsterPlayersAlive) == 0 then
		for n=1,5 do
			Game.ExecuteCommand('say ROUND HAS ENDED IN: NEXPHARMA WIN')
		end
		endGame = true
	elseif monsterPlayersAlive > 0 and (terroristPlayersAlive + nexpharmaPlayersAlive) == 0 then
		for n=1,5 do
			Game.ExecuteCommand('say ROUND HAS ENDED IN: MONSTER WIN')
		end
		endGame = true
	end
	
	if endGame and not global_debug then
		global_endGame = true
		for n=1,11 do
			Timer.Wait(function ()
				Game.ExecuteCommand('say ENDING IN ' .. (11-n))
			end, n*1000)
		end
		Timer.Wait(function ()
			Game.ExecuteCommand('end')
		end, 10*1100+500)
	end

	return true
end)

-- Execute when players are spawned - be it a respawn wave, or the start of the match
Hook.Add("character.giveJobItems", "monsterAndRespawns", function (createdCharacter)

	-- Executed on match start to spawn in the monsters
	if createdCharacter.Submarine.Info.Name == '_Facility' then
		-- Captain is Mutated Mantis
		if createdCharacter.HasJob('captain') then
			spawnPlayerMonster(createdCharacter, 'mantis')
		-- Medic is Mutated Crawler
		elseif createdCharacter.HasJob('medicaldoctor') then
			spawnPlayerMonster(createdCharacter, 'crawler')
		end
	-- Executed at respawn waves to equip and teleport the JET and MERCS
	elseif createdCharacter.Submarine.Info.Name == '_Respawn' then
		-- Inmate and Monsters respawn as JET
		if createdCharacter.HasJob('assistant') or createdCharacter.HasJob('captain') or createdCharacter.HasJob('medicaldoctor') then
			if global_terroristTickets > 0 then
				-- Update Ticket Count
				global_terroristTickets = global_terroristTickets - 1
				Game.ExecuteCommand('say Terrorists have lost a ticket! ' .. global_terroristTickets .. ' tickets left!' )
				-- Spawns JET
				spawnPlayerMilitant(createdCharacter, 'JET')
			else
				Game.ExecuteCommand('say Terrorists are out of tickets - no more respawns!')
				Game.ExecuteCommand('kill ' .. createdCharacter.Info.Name)
			end
			
		-- Guards and Staff respawn as MERCS
		elseif createdCharacter.HasJob('securityofficer') or createdCharacter.HasJob('mechanic') or createdCharacter.HasJob('engineer') then
			if global_nexpharmaTickets > 0 then
				-- Update Ticket Count
				global_nexpharmaTickets = global_nexpharmaTickets - 1
				Game.ExecuteCommand('say Nexpharma has lost a ticket! ' .. global_nexpharmaTickets .. ' tickets left!' )
				-- Spawns MERCS
				spawnPlayerMilitant(createdCharacter, 'MERCS')
			else
				Game.ExecuteCommand('say Nexpharma is out of tickets - no more respawns!')
				Game.ExecuteCommand('kill ' .. createdCharacter.Info.Name)
			end
		end
	end

    return true
end)

-- User Commands
-- Lists and explains user commands
Hook.Add("chatMessage", "helpCommand", function (message, client)
    if message ~= '/help' then return end
	
	messageClient(client, 0, 200, 255, '/help - gives command list.')
	messageClient(client, 0, 200, 255, '/admin - calls admin attention.')
	messageClient(client, 0, 200, 255, '/admin <text> - sends text to admin.')
	messageClient(client, 0, 200, 255, '/players - gives a list of players and their roles.')
	messageClient(client, 0, 200, 255, '/tickets - tells JET and MERCS ticket count.')

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
					messageClient(client, 0, 200, 255, player.Name .. ' is a armed member of the terrorist faction.')
				elseif player.Character.HasJob('assistant') then
					messageClient(client, 0, 200, 255, player.Name .. ' is a civilian member of the terrorist faction.')
				elseif player.Character.HasJob('securityofficer') or ((player.Character.HasJob('mechanic') or player.Character.HasJob('engineer')) and global_militantPlayers[player.Name]) then
					messageClient(client, 0, 200, 255, player.Name .. ' is an armed member of the nexpharma corp.')
				elseif player.Character.HasJob('mechanic') or player.Character.HasJob('engineer') then
					messageClient(client, 0, 200, 255, player.Name .. ' is a civilian member of the nexpharma corp.')
				end
			elseif player.Character.SpeciesName == 'mantisadmin' then
				messageClient(client, 0, 200, 255, player.Name .. ' is mutated mantis.')
			elseif player.Character.SpeciesName == 'crawleradmin' then
				messageClient(client, 0, 200, 255, player.Name .. ' is mutated crawler.')
			end
		end
	end

    return true
end)

-- Tells the current amount of tickets
Hook.Add("chatMessage", "ticketCount", function (message, client)
    if message ~= '/tickets' then return end
	
	messageClient(client, 0, 200, 255, 'Terrorists have ' .. global_terroristTickets .. ' tickets left.')
	messageClient(client, 0, 200, 255, 'Nexpharma has ' .. global_nexpharmaTickets .. ' tickets left.')

    return true
end)

-- Admin Commands
-- Lists important variables and commands
function help ()
	print('-|FUNCTIONS|-')
	print('promoteEscapee(username)')
	print('giveItem(username, identifier, amount)')
	print('-|VARIABLES|-')
	print('global_debug')
	print('global_militantPlayers')
	print('global_terroristTickets')
	print('global_nexpharmaTickets')
	print('global_monsterCount')
end

-- Respawns escapee as militant and rewards team with 1 tickets
function promoteEscapee (username)

	-- Search for client
	clientIndex = -1
	counter = 1
	for player in Client.ClientList do
		if player.Name == username then
			clientIndex = counter
			break
		end
		counter = counter + 1
	end
	if clientIndex == -1 then return end
	-- Spawn escapee as militant
	Game.ExecuteCommand('say ' .. Client.ClientList[clientIndex].Character.Info.Name .. ' has escaped!')
	global_militantPlayers[Client.ClientList[clientIndex].Name] = true
	clientCharacter = Client.ClientList[clientIndex].Character
	if clientCharacter.HasJob('assistant') or clientCharacter.HasJob('captain') or clientCharacter.HasJob('medicaldoctor') then
		-- Update Ticket Count
		global_terroristTickets = global_terroristTickets + 1
		Game.ExecuteCommand('say Terrorists have gained a ticket! ' .. global_terroristTickets .. ' tickets left!' )
		-- Spawns JET
		spawnPlayerMilitant(clientCharacter, 'JET')
	elseif clientCharacter.HasJob('securityofficer') or clientCharacter.HasJob('mechanic') or clientCharacter.HasJob('engineer') then
		-- Update Ticket Count
		global_nexpharmaTickets = global_nexpharmaTickets + 1
		Game.ExecuteCommand('say Nexpharma has gained a ticket! ' .. global_nexpharmaTickets .. ' tickets left!' )
		-- Spawns MERCS
		spawnPlayerMilitant(clientCharacter, 'MERCS')
	end

end

-- Gives a certain amount of an item to a client's character
function giveItem (username, identifier, amount)

	-- Search for client
	clientIndex = -1
	counter = 1
	for player in Client.ClientList do
		if player.Name == username then
			clientIndex = counter
			break
		end
		counter = counter + 1
	end
	if clientIndex == -1 then return end
	-- Give Item
	for n=1,amount do 
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), Client.ClientList[clientIndex].Character.Inventory, nil, nil, nil)
	end
	
	return true
end