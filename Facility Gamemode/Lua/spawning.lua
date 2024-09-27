-- Spawns a monster at a containment cell, gives a player control of it, tps their body to it and kills it too (free meal)
function spawnCharacterMonster (character, species, client, pos, delete)

	local characterReturn
	
	-- Spawn monster at containment cell
	Entity.Spawner.AddCharacterToSpawnQueue(species, pos, function (characterMonster)
		-- Give player control of their monster
		if client ~= nil then client.SetClientCharacter(characterMonster) end
		-- Teleport and kill their human bodies
		character.Kill(CauseOfDeathType.Unknown)
		character.TeleportTo(pos)
		-- Set return character
		characterReturn = characterMonster
	end)
	
	-- Delete old character
	if delete then Entity.Spawner.AddEntityToRemoveQueue(character) end
	
	return characterReturn

end

-- General code for when respawning a player as militant
function spawnPlayerMilitant (client, team, data)
	local character
	local subclass
	if (data ~= nil) and data['subclass'] then
		subclass = data['subclass']
	else
		if team == 'JET' then
			subclass = tonumber(string.sub(FG.settings.terroristSquadSequence, FG.terroristSubclassCount, FG.terroristSubclassCount))
			FG.terroristSubclassCount = FG.terroristSubclassCount + 1
			if FG.terroristSubclassCount > #FG.settings.terroristSquadSequence then FG.terroristSubclassCount = 1 end
		elseif team == 'MERCS' then
			subclass = tonumber(string.sub(FG.settings.nexpharmaSquadSequence, FG.nexpharmaSubclassCount, FG.nexpharmaSubclassCount))
			FG.nexpharmaSubclassCount = FG.nexpharmaSubclassCount + 1
			if FG.nexpharmaSubclassCount > #FG.settings.nexpharmaSquadSequence then FG.nexpharmaSubclassCount = 1 end
		end
	end
	if (data ~= nil) and data['old'] then
		character = spawnPlayerMilitant_OLD(client, team)
	else
		character = spawnPlayerMilitant_NEW(client, team, subclass)
	end
	if team == 'JET' then
		FG.playerRole[client.Name] = 'jet'
		messageClient(client, 'info', string.localize('jetInfo', nil, client.Language))
		if (data == nil) or (not data['free']) then
			FG.terroristTickets = FG.terroristTickets - 1
		end
	elseif team == 'MERCS' then
		FG.playerRole[client.Name] = 'mercs'
		messageClient(client, 'info', string.localize('mercsInfo', nil, client.Language))
		if (data == nil) or (not data['free']) then
			FG.nexpharmaTickets = FG.nexpharmaTickets - 1
		end
	end
	if (data == nil) or (not data['noprotection']) then
		giveAfflictionCharacter(character, 'spawnprotection', 9)
	end
	return character
end

-- Spawns a human who is a militant and sets it to the client's character, distinct from SpawnPlayerMilitant_OLD
function spawnPlayerMilitant_NEW (client, team, subclass)
	if (client.Character ~= nil) and not client.Character.IsDead then
		client.Character.Kill(CauseOfDeathType.Unknown)
		client.Character.TeleportTo(findRandomWaypointByJob(team).WorldPosition)
	end
	local character
	if team == 'JET' then
		local spawnPosition = findRandomWaypointByJob('jet')
		if spawnPosition == nil then spawnPosition = findRandomWaypointByJob('') end
		spawnPosition = spawnPosition.WorldPosition
		character = spawnHuman(client, 'jet', spawnPosition, nil, subclass)
		client.Character.SetOriginalTeam(CharacterTeamType.Team2)
		client.Character.UpdateTeam()
	elseif team == 'MERCS' then
		local spawnPosition = findRandomWaypointByJob('mercs')
		if spawnPosition == nil then spawnPosition = findRandomWaypointByJob('') end
		spawnPosition = spawnPosition.WorldPosition
		character = spawnHuman(client, 'mercs', spawnPosition, nil, subclass)
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
	return character
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
		for item in FG.terroristLoadout do
			Timer.Wait(function ()
				for n=1,item[2] do
					giveItemCharacter(character, item[1], 1, item[3])
				end
			end, itemCount*20+500)
			itemCount = itemCount + 1
		end
		-- Teleport player into battlefield
		local spawnPosition = findRandomWaypointByJob('jet')
		if spawnPosition == nil then spawnPosition = findRandomWaypointByJob('') end
		spawnPosition = spawnPosition.WorldPosition
		character.TeleportTo(spawnPosition)
	elseif team == 'MERCS' then
		-- Give items
		local itemCount = 1
		for item in FG.nexpharmaLoadout do
			Timer.Wait(function ()
				for n=1,item[2] do
					giveItemCharacter(character, item[1], 1, item[3])
				end
			end, itemCount*20+500)
			itemCount = itemCount + 1
		end
		-- Teleport player into battlefield
		local spawnPosition = findRandomWaypointByJob('mercs')
		if spawnPosition == nil then spawnPosition = findRandomWaypointByJob('') end
		spawnPosition = spawnPosition.WorldPosition
		character.TeleportTo(spawnPosition)
	end

	return character
end

-- Execute when players job item are given - be it a respawn wave, or the start of the match
Hook.Add("character.giveJobItems", "monsterAndRespawns", function (character)
	-- Setup corpse
	if (character.Info.Job ~= nil) and (tostring(character.Info.Job.Prefab.Identifier) == 'corpsejob') then
		-- Kill character
		local afflictions = {'bleeding', 'gunshotwound', 'blunttrauma', 'explosiondamage', 'bitewounds'}
		for limb in character.AnimController.Limbs do
			for n = 1, math.random(0, 2) do
				character.CharacterHealth.ApplyAffliction(limb, AfflictionPrefab.Prefabs[afflictions[math.random(#afflictions)]].Instantiate(math.random(1, 20)))
			end
		end
		giveAfflictionCharacter(character, 'bloodloss', math.random(5, 25))
		giveAfflictionCharacter(character, 'oxygenlow', math.random(character.Health + 100))
		-- And just to be sure...
		character.Kill(CauseOfDeathType.Unknown)
		
		-- Defines possible loot
		local keys = {}
		local clothes = {
			-- Regular --
			{job = 'inmate', weight = 30, [0] = 'idcardinmate', [2] = 'piratebandana', [3] = 'prisonerclothes'},
			{job = 'repairmen', weight = 25, [0] = 'idcardstaff', [2] = 'ironhelmet', [3] = 'bluejumpsuit1', [8] = 'toolbelt'},
			{job = 'researcher', weight = 20, [0] = 'idcardstaff', [3] = 'medicalofficerclothes'},
			{job = 'enforcerguard', weight = 10, [0] = 'idcardenforcerguard', [2] = 'baseballcap', [3] = 'securityuniform2', [4] = 'bodyarmor'},
			-- Bagged --
			{job = 'inmate', weight = 30, [0] = 'idcardinmate', [2] = 'piratebandana', [3] = 'prisonerclothes', [4] = 'bodybag'},
			{job = 'repairmen', weight = 25, [0] = 'idcardstaff', [2] = 'ironhelmet', [3] = 'bluejumpsuit1', [4] = 'bodybag', [8] = 'toolbelt'},
			{job = 'researcher', weight = 20, [0] = 'idcardstaff', [3] = 'medicalofficerclothes', [4] = 'bodybag'},
			{job = 'enforcerguard', weight = 10, [0] = 'idcardenforcerguard', [2] = 'baseballcap', [3] = 'securityuniform2', [4] = 'bodybag'}
		}
		for key, value in pairs(clothes) do for n = 1, value.weight do table.insert(keys, key) end end
		
		-- Give corpse the correct clothing
		local clothing = clothes[keys[math.random(#keys)]]
		for slot, item in pairs(clothing) do
			if type(slot) == 'number' then
				giveItemCharacter(character, item, 1, slot)
			end
		end
		
		-- Spawn random loot
		for loot in shuffleArray(FG.lootTables['fg_dead' .. clothing.job]) do
			for n = 1, loot[3] do
				if loot[2] > math.random() then
					for n = 1, loot[4] do
						if not character.Inventory.IsFull(true) then
							Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(loot[1]), character.Inventory, nil, nil, nil)
						end
					end
				end
			end
		end
	end
	-- Find client
	local client = findClientByCharacter(character)
	-- Set up TeamID for player
	if isCharacterTerrorist(character) then
		character.SetOriginalTeam(CharacterTeamType.Team2)
		character.UpdateTeam()
	elseif isCharacterNexpharma(character) then
		character.SetOriginalTeam(CharacterTeamType.Team1)
		character.UpdateTeam()
	elseif (client ~= nil) and (FG.monsterPlayers[client.Name] ~= nil) then
		character.SetOriginalTeam(0)
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
	
	-- Spawn character monster and give info pop-up
	if (character.Submarine ~= nil) and (character.Submarine.Info.Name == Submarine.MainSub.Info.Name) then
		-- Get monster spawnpoint
		local jobs = {}
		if FG.settings.monsterSpawn == 'default' then
			--jobs = {'mutatedmantisjob', 'mutatedcrawlerjob', 'mutatedchimerajob'}
			jobs = {'mutatedmantisjob', 'mutatedcrawlerjob'}
		elseif FG.settings.monsterSpawn == 'staff' then
			jobs = {'researcher', 'repairmen'}
		elseif FG.settings.monsterSpawn == 'inmate' then
			jobs = {'inmate'}
		elseif FG.settings.monsterSpawn == 'corpse' then
			jobs = {'corpsejob'}
		end
		local spawnPosition = findRandomWaypointByJob(jobs[math.random(#jobs)])
		if spawnPosition == nil then spawnPosition = findRandomWaypointByJob('') end
		spawnPosition = spawnPosition.WorldPosition
		local monster = 'random'
		-- Player monster spawning
		if FG.monsterPlayers[client.Name] ~= nil then
			-- If monster is random then pick a random valid one
			monster = FG.monsterPlayers[client.Name]
			if (monster == 'random') or (monster == nil) then
				if FG.settings.gamemode == 'default' then
					if math.random(2) == 1 then
						monster = 'mutatedmantis'
					else
						--monster = 'mutatedcrawler'
						monster = 'mutatedchimera'
					end
				elseif FG.settings.gamemode == 'brood' then
					if math.random(2) == 1 then
						monster = 'mutatedmantishatchling'
					else
						monster = 'mutatedcrawlerhatchling'
					end
				elseif FG.settings.gamemode == 'husk' then
					monster = 'husk'
				elseif FG.settings.gamemode == 'greenskin' then
					monster = 'greenskin'
				end
			end
			-- Actual spawning
			if monster == 'mutatedmantis' then
				spawnCharacterMonster(character, 'mantisadmin', client, spawnPosition)
				
				messageClient(client, 'info', string.localize('mutatedMantisInfo', nil, client.Language))
			elseif monster == 'mutatedcrawler' then
				spawnCharacterMonster(character, 'crawleradmin', client, spawnPosition)
				
				messageClient(client, 'info', string.localize('mutatedCrawlerInfo', nil, client.Language))
			elseif monster == 'mutatedchimera' then
				spawnCharacterMonster(character, 'chimeraadmin', client, spawnPosition)
				
				messageClient(client, 'info', string.localize('mutatedChimeraInfo', nil, client.Language))
			elseif monster == 'mutatedmantishatchling' then
				spawnCharacterMonster(character, 'mantisadmin_hatchling', client, spawnPosition)
				
				messageClient(client, 'info', string.localize('mutatedMantisInfo', nil, client.Language))
			elseif monster == 'mutatedcrawlerhatchling' then
				spawnCharacterMonster(character, 'crawleradmin_hatchling', client, spawnPosition)
				
				messageClient(client, 'info', string.localize('mutatedCrawlerInfo', nil, client.Language))
			elseif monster == 'husk' then
				character.TeleportTo(spawnPosition)
				if FG.settings.monsterSpawn == 'corpse' then
					giveItemCharacter(character, 'bodybag', 1, 4)
					giveAfflictionCharacter(character, 'huskinfection', 1)
				end
			elseif monster == 'greenskin' then
				local isTroll = math.random(100) <= FG.settings.initialTrollPercentage
				local name = nil
				if client ~= nil then
					name = client.Name
				end
				spawnHumangoblin(client, spawnPosition, name, isTroll)
				Entity.Spawner.AddEntityToRemoveQueue(character)
				
				messageClient(client, 'info', string.localize('greenskinInfo', nil, client.Language))
			end
		else
			if character.SpeciesName == 'human' then
				messageClient(client, 'info', string.localize(tostring(character.Info.Job.Prefab.Identifier) .. 'Info', nil, client.Language))
			end
		end
	end
	
	--[[
	-- Executed at respawn waves to equip and teleport the JET and MERCS
	elseif (character.Submarine ~= nil) and (character.Submarine.Info.Name == 'FG Respawn') then
		-- Inmate and Monsters respawn as JET
		if isCharacterTerrorist(character) then
			if FG.terroristTickets >= 1 then
				spawnPlayerMilitant(client, 'JET', {old = true})
			else
				messageAllClients('text-game', 'Terrorists are out of tickets - no more respawns!')
				character.Kill(CauseOfDeathType.Unknown)
			end
			
		-- Guards and Staff respawn as MERCS
		elseif isCharacterNexpharma(character) then
			if FG.nexpharmaTickets >= 1 then
				spawnPlayerMilitant(client, 'MERCS', {old = true})
			else
				messageAllClients('text-game', 'Nexpharma is out of tickets - no more respawns!')
				character.Kill(CauseOfDeathType.Unknown)
			end
		end
	end
	--]]

    return true
end)

FG.loadedFiles['spawning'] = true