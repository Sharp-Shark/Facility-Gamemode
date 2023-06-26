-- Spawns a monster at a containment cell, gives a player control of it, tps their body to it and kills it too (free meal)
function spawnPlayerMonster (client, species)
	-- Guard clause
	local character = client.Character
	if character.IsBot then return end

	local items = findItemsByTag('fg_monsterspawn')

	-- Spawn monster at containment cell
	Entity.Spawner.AddCharacterToSpawnQueue(species .. 'admin', items[math.random(#items)].WorldPosition, function (characterMonster)
		-- Give player control of their monster (and bump monster counters)
		client.SetClientCharacter(characterMonster)
		global_monsterCount[species] = global_monsterCount[species] + 1
		-- Teleport and kill their human bodies
		character.Kill(CauseOfDeathType.Unknown)
		character.TeleportTo(items[math.random(#items)].WorldPosition)
	end)

	return true
end

-- General code for when respawning a player as militant
function spawnPlayerMilitant (client, team, OLD)
	global_militantPlayers[client.Name] = true
	if OLD then
		spawnPlayerMilitant_OLD(client, team)
	else
		spawnPlayerMilitant_NEW(client, team)
	end
	if team == 'JET' then
		global_playerRole[client.Name] = 'jet'
		messageClient(client, 'info', 'The Jovian Elite Troops or JET - a militant member of the Terrorist militia, equipped with heavy weaponry, meds, armor and a high-level card. Help inmates escape and kill the monsters and everyone working for Nexpharma.')
		global_terroristTickets = global_terroristTickets - 1
	elseif team == 'MERCS' then
		global_playerRole[client.Name] = 'mercs'
		messageClient(client, 'info', 'The Mobile Emergency Rescue and Combat Squad or MERCS - a militant member of the Nexpharma private army, equipped with heavy weaponry, meds, armor and a high-level card. Work together with guards to help staff escape and kill the inmates, JET and monsters.')
		global_nexpharmaTickets = global_nexpharmaTickets - 1
	end
end

-- Spawns a human who is a militant and sets it to the client's character, distinct from SpawnPlayerMilitant_OLD
function spawnPlayerMilitant_NEW (client, team)
	local items
	if team == 'JET' then
		items = findItemsByTag('fg_terroristspawn')
	elseif team == 'MERCS' then
		items = findItemsByTag('fg_nexpharmaspawn')
	end
	if (client.Character ~= nil) and not client.Character.IsDead then
		client.Character.Kill(CauseOfDeathType.Unknown)
		client.Character.TeleportTo(items[math.random(#items)].WorldPosition)
	end
	local character
	if team == 'JET' then
		character = spawnHuman(client, 'jet', items[math.random(#items)].WorldPosition)
		client.Character.SetOriginalTeam(CharacterTeamType.Team2)
		client.Character.UpdateTeam()
	elseif team == 'MERCS' then
		character = spawnHuman(client, 'mercs', items[math.random(#items)].WorldPosition)
		client.Character.SetOriginalTeam(CharacterTeamType.Team1)
		client.Character.UpdateTeam()
	end
	--[[
	Timer.Wait(function ()
		local idcard = character.Inventory.GetItemAt(0)
		idcard.GetComponentString('IdCard').TeamID = CharacterTeamType.Team1
		local property = idcard.SerializableProperties[Identifier(newProperty)]
		Networking.CreateEntityEvent(idcard, Item.ChangePropertyEventData(property, idcard))
	end, 1*1000)
	--]]
end

-- Removes the items of respawnees, gives them their proper loadout (be it JET or MERCS) and teleports them to their spawn area
function spawnPlayerMilitant_OLD (client, team)
	local character = client.Character
	-- Guard clause
	if character == nil or character.SpeciesName ~= 'human' or character.IsDead then return end
	
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
		local items = findItemsByTag('fg_terroristspawn')
		character.TeleportTo(items[math.random(#items)].WorldPosition)
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
		local items = findItemsByTag('fg_nexpharmaspawn')
		character.TeleportTo(items[math.random(#items)].WorldPosition)
	end

	return true
end

-- Execute when players job item are given - be it a respawn wave, or the start of the match
Hook.Add("character.giveJobItems", "monsterAndRespawns", function (character)
	local client = findClientByCharacter(character)
	-- Set TeamID to 2 if it's a terrorist
	if isCharacterTerrorist(character) then
		character.SetOriginalTeam(CharacterTeamType.Team2)
		character.UpdateTeam()
	end
	-- Spawn JET and MERCS card via LUA due to bug
	if character.HasJob('jet') then
		Timer.Wait(function ()
			giveItemCharacter(character, 'idcardjet', 1, 0)
		end, 1*1000)
	end
	if character.HasJob('mercs') then
		Timer.Wait(function ()
			giveItemCharacter(character, 'idcardmercs', 1, 0)
		end, 1*1000)
	end
	-- Guard clause
	if client == nil then return end

	-- Executed on match start to spawn in the monsters
	if character.Submarine.Info.Name == Submarine.MainSub.Info.Name then
		if character.HasJob('mutatedmantis') then
			spawnPlayerMonster(client, 'mantis')
			messageClient(client, 'info', 'You are a Mutated Mantis! A slow and weak monster with lots of HP. Work with your fellow monsters to kill all humans! You may eat corpses, use regular doors, use the trams and use local voicechat.')
		elseif character.HasJob('mutatedcrawler') then
			spawnPlayerMonster(client, 'crawler')
			messageClient(client, 'info', 'You are a Mutated Crawler! A fast and strong monster with decent HP. Work with your fellow monsters to kill all humans! You may eat corpses, use regular doors, use the trams and use local voicechat.')
		elseif isCharacterStaff(character) then
			messageClient(client, 'info', 'You are a civilian, part of Nexpharma staff, equipped with your low level keycard and a few supplies. Work with MERCS, guards and fellow staff to escape the facility!')
		elseif character.HasJob('enforcerguard') then
			messageClient(client, 'info', 'You are an armed member of Nexpharma security, equipped with a simple guard card and a sidearm. Work with MERCS and fellow guards to kill inmates, JET and monsters whilst helping staff escape.')
		elseif character.HasJob('inmate') then
			messageClient(client, 'info', 'You are a civilian member of the Terrorist faction, equipped with almost nothing. Work with your fellow inmates and JET to escape this wretched place!')
		end
		
	-- Executed at respawn waves to equip and teleport the JET and MERCS
	elseif character.Submarine.Info.Name == '_Respawn' then
		-- Inmate and Monsters respawn as JET
		if isCharacterTerrorist(character) then
			if global_terroristTickets >= 1 then
				spawnPlayerMilitant(client, 'JET', true)
			else
				messageAllClients('text-game', 'Terrorists are out of tickets - no more respawns!')
				character.Kill(CauseOfDeathType.Unknown)
			end
			
		-- Guards and Staff respawn as MERCS
		elseif isCharacterNexpharma(character) then
			if global_nexpharmaTickets >= 1 then
				spawnPlayerMilitant(client, 'MERCS', true)
			else
				messageAllClients('text-game', 'Nexpharma is out of tickets - no more respawns!')
				character.Kill(CauseOfDeathType.Unknown)
			end
		end
	end

    return true
end)

global_loadedFiles['spawning'] = true