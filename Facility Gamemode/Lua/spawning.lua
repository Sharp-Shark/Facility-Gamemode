-- Spawns a monster at a containment cell, gives a player control of it, tps their body to it and kills it too (free meal)
function spawnPlayerMonster (client, species)
	-- Guard clause
	local character = client.character
	if character.IsBot then return end

	-- Spawn monster at containment cell
	Entity.Spawner.AddCharacterToSpawnQueue(species .. 'admin', Submarine.MainSub.GetWaypoints(false)[global_waypointIndexes.monsterSpawn].WorldPosition, function ()
		-- Give player control of their monster (and bump monster counters)
		Game.ExecuteCommand('setclientcharacter "' .. client.Name .. '" ' .. species .. 'admin ' .. global_monsterCount[species])
		global_monsterCount[species] = global_monsterCount[species] + 1
		-- Teleport and kill their human bodies
		Game.ExecuteCommand('kill "' .. character.Info.Name .. '"')
		character.TeleportTo(Submarine.MainSub.GetWaypoints(false)[global_waypointIndexes.monsterSpawn].WorldPosition)
	end)

	return true
end

-- Removes the items of respawnees, gives them their proper loadout (be it JET or MERCS) and teleports them to their spawn area
function spawnPlayerMilitant (client, team)
	local character = client.character
	-- Guard clause
	if character == nil or character.SpeciesName ~= 'human' or character.IsDead then return end

	global_militantPlayers[client.Name] = true
	
	-- Heal incase player was hurt
	Game.ExecuteCommand('heal ' .. character.Info.Name)
	Game.ExecuteCommand('revive ' .. character.Info.Name)
	
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

-- Execute when players job item are given - be it a respawn wave, or the start of the match
Hook.Add("character.giveJobItems", "monsterAndRespawns", function (character)
	local client = findClientByCharacter(character)
	if not client then return end

	-- Executed on match start to spawn in the monsters
	if character.Submarine.Info.Name == '_Facility' then
		-- Captain is Mutated Mantis
		if character.HasJob('captain') then
			spawnPlayerMonster(client, 'mantis')
			messageClient(client, 'info', 'You are a Mutated Mantis! A slow and weak monster with lots of HP. Work with your fellow monsters to kill all humans! You may eat corpses, use regular doors, use the trams and use local voicechat.')
		-- Medic is Mutated Crawler
		elseif character.HasJob('medicaldoctor') then
			spawnPlayerMonster(client, 'crawler')
			messageClient(client, 'info', 'You are a Mutated Crawler! A fast and strong monster with decent HP. Work with your fellow monsters to kill all humans! You may eat corpses, use regular doors, use the trams and use local voicechat.')
		-- Mechanic and Engineer (Researcher) are Nexpharma Staff
		elseif isCharacterStaff(character) then
			messageClient(client, 'info', 'You are a civilian, part of Nexpharma staff, equipped with your low level keycard and a few supplies. Work with MERCS, guards and fellow staff to escape the facility!')
		-- Security Officer is Nexpharma Security
		elseif character.HasJob('securityofficer') then
			messageClient(client, 'info', 'You are an armed member of Nexpharma security, equipped with a simple guard card and a sidearm. Work with MERCS and fellow guards to kill inmates, JET and monsters whilst helping staff escape.')
		-- Assistant is Inmate
		elseif character.HasJob('assistant') then
			messageClient(client, 'info', 'You are a civilian member of the Terrorist faction, equipped with almost nothing. Work with your fellow inmates and JET to escape this wretched place!')
		end
		
	-- Executed at respawn waves to equip and teleport the JET and MERCS
	elseif character.Submarine.Info.Name == '_Respawn' then
		-- Inmate and Monsters respawn as JET
		if isCharacterTerrorist(character) then
			if global_terroristTickets >= 1 then
				-- Update Ticket Count
				global_terroristTickets = global_terroristTickets - 1
				Game.ExecuteCommand('say Terrorists have lost 1 ticket - an unit has respawned! ' .. global_terroristTickets .. ' tickets left!' )
				-- Spawns JET
				spawnPlayerMilitant(client, 'JET')
				messageClient(client, 'info', 'The Jovian Elite Troops or JET - a militant member of the Terrorist militia, equipped with heavy weaponry, meds, armor and a high-level card. Help inmates escape and kill the monsters and everyone working for Nexpharma.')
			else
				Game.ExecuteCommand('say Terrorists are out of tickets - no more respawns!')
				Game.ExecuteCommand('kill ' .. character.Info.Name)
			end
			
		-- Guards and Staff respawn as MERCS
		elseif isCharacterNexpharma(character) then
			if global_nexpharmaTickets >= 1 then
				-- Update Ticket Count
				global_nexpharmaTickets = global_nexpharmaTickets - 1
				Game.ExecuteCommand('say Nexpharma has lost 1 ticket - an unit has respawned! ' .. global_nexpharmaTickets .. ' tickets left!' )
				-- Spawns MERCS
				spawnPlayerMilitant(client, 'MERCS')
				messageClient(client, 'info', 'The Mobile Emergency Rescue and Combat Squad or MERCS - a militant member of the Nexpharma private army, equipped with heavy weaponry, meds, armor and a high-level card. Work together with guards to help staff escape and kill the inmates, JET and monsters.')
			else
				Game.ExecuteCommand('say Nexpharma is out of tickets - no more respawns!')
				Game.ExecuteCommand('kill ' .. character.Info.Name)
			end
		end
	end

    return true
end)

-- Executes when players spawn
Hook.Add("character.created", "monsterAndRespawns", function (createdCharacter)
	if createdCharacter == nil or createdCharacter.SpeciesName ~= 'human' then return end
	
	-- Set Player TeamID to 2 if he's a terrorist
	if isCharacterTerrorist(createdCharacter) then
		createdCharacter.SetOriginalTeam(CharacterTeamType.Team2)
		createdCharacter.UpdateTeam()
	end

	return true
end)

global_loadedFiles['spawning'] = true