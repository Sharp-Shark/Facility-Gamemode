function checkForGameEnd ()

	if not Game.RoundStarted then return end
	-- Add a 5 second delay before checking for end conditions just to be sure
	Timer.Wait(function ()
		if not FG.settings.allowEnd then return end
		if #Client.ClientList - table.size(FG.spectators) < FG.settings.allowEndMinPlayers then return end --print('[!] Only ' .. (#Client.ClientList - table.size(FG.spectators)) .. ' player, will not end round.') return end
		
		-- Make sure the game isn't already ending
		if FG.endGame then return end
		-- Count live players
		local totalPlayersAlive = 0
		local terroristPlayersAlive = 0
		local nexpharmaPlayersAlive = 0
		local monsterPlayersAlive = 0
		for player in Client.ClientList do
			if player.Character ~= nil and not player.Character.IsDead then
				if isCharacterMonster(player.Character) and (player.Character.SpeciesName ~= 'Humanghost') then
					monsterPlayersAlive = monsterPlayersAlive + 1
				elseif isCharacterTerrorist(player.Character) then
					terroristPlayersAlive = terroristPlayersAlive + 1
				elseif isCharacterNexpharma(player.Character) then
					nexpharmaPlayersAlive = nexpharmaPlayersAlive + 1
				end
				if (player.Character.SpeciesName == 'human') and (player.Character.CharacterHealth.GetAffliction('huskinfection', true) ~= nil) then
					monsterPlayersAlive = monsterPlayersAlive + 1
				end
				totalPlayersAlive = totalPlayersAlive + 1
			end
		end
		-- End message
		local messageType = 'popup'
		if not FG.settings.allowEnd then
			messageType = 'ignore'
		end
		local endGame = false
		if FG.settings.endType == 'default' then
			if totalPlayersAlive == 0 then
				for player in Client.ClientList do
					messageClient(player, messageType, string.localize('endStalemate', nil, player.Language))
				end
				endGame = true
				FG.analytics.data.winner = 'stalemate'
			elseif terroristPlayersAlive > 0 and (nexpharmaPlayersAlive + monsterPlayersAlive) == 0 then
				for player in Client.ClientList do
					messageClient(player, messageType, string.localize('endTerrorist', nil, player.Language))
				end
				endGame = true
				FG.analytics.data.winner = 'terrorist'
			elseif nexpharmaPlayersAlive > 0 and (terroristPlayersAlive + monsterPlayersAlive) == 0 then
				for player in Client.ClientList do
					messageClient(player, messageType, string.localize('endNexpharma', nil, player.Language))
				end
				endGame = true
				FG.analytics.data.winner = 'nexpharma'
			elseif monsterPlayersAlive > 0 and (terroristPlayersAlive + nexpharmaPlayersAlive) == 0 then
				for player in Client.ClientList do
					messageClient(player, messageType, string.localize('endMonster', nil, player.Language))
				end
				endGame = true
				FG.analytics.data.winner = 'monster'
			end
		elseif FG.settings.endType == 'battleroyale' then
			if totalPlayersAlive == 0 then
				for player in Client.ClientList do
					messageClient(player, messageType, string.localize('endStalemate', nil, player.Language))
				end
				endGame = true
				FG.analytics.data.winner = 'br stalemate'
			elseif totalPlayersAlive == 1 then
				local lastPlayer
				for player in Client.ClientList do
					if player.Character ~= nil and not player.Character.IsDead then
						lastPlayer = player
					end
				end
				for player in Client.ClientList do
					messageClient(player, messageType, string.localize('endPlayer', {name = string.upper(lastPlayer.Name)}, player.Language))
				end
				endGame = true
				FG.analytics.data.winner = 'br player ' .. lastPlayer.Name
			end
		end
		-- The Final Countdown
		if endGame and FG.settings.allowEnd then
			FG.respawnTimer = -1
			FG.endGame = true
			for n=1,11 do
				Timer.Wait(function ()
					messageAllClients('text-game', {'ending', {time = (11-n)}})
				end, n*1000)
			end
			Timer.Wait(function ()
				Game.EndGame()
			end, 11.5*1000)
			-- Enable friendly fire for fun
			if FG.serverSettings['AllowFriendlyFire'] == false then
				messageAllClients('text-game', {'FFEnabled'})
				Game.ServerSettings['AllowFriendlyFire'] = true
			end
		end
	end, 5*1000)
end

-- Execute when someone disconnects
Hook.Add("client.disconnected", "clientDisconnectedDied", function (disconnectedClient)

	checkForGameEnd()
	
	if not FG.endGame or not Game.RoundStarted then return end
	
	FG.respawnTimerUpdate = true
	
end)

-- Execute when a character dies
Hook.Add("character.death", "characterDied", function (character)
	if character == nil then return end
	
	-- Remove items from monster after it dies
	if isCharacterMonster(character) and (character.SpeciesName ~= 'Humanhusk') then
		for item in character.Inventory.AllItems do
			Entity.Spawner.AddEntityToRemoveQueue(item)
		end
	end

	-- This code only executes if it's a player's character
	if (findClientByCharacter(character) ~= nil) and (not FG.endGame) and character.IsPlayer then
		Timer.Wait(function ()
			-- This code only executes if it still is a player's character
			local client = findClientByCharacter(character)
			if (client == nil) or FG.endGame or not character.IsPlayer then return end
			-- Analytics
			if FG.analytics.valid then
				local obituaryName
				if character.SpeciesName == 'Human' then
					obituaryName = tostring(character.JobIdentifier) .. tostring(character.ID)
				else
					obituaryName = tostring(character.SpeciesName) .. tostring(character.ID)
				end
				local killerName
				if character.LastAttacker == nil then
					killerName = 'none'
				elseif character.LastAttacker.SpeciesName == 'Human' then
					killerName = tostring(character.LastAttacker.JobIdentifier) .. tostring(character.LastAttacker.ID)
				else
					killerName = tostring(character.LastAttacker.SpeciesName) .. tostring(character.LastAttacker.ID)
				end
				FG.analytics.data.obituary[obituaryName] = 'TOD:' .. numberToTime(math.floor(Timer.Time - FG.analytics.data.startTime), 1) .. 'BY:' .. killerName
			end
			-- Do death message to deceased
			messageClient(client, 'info', string.localize('dieMessageText', nil, client.Language))
			-- Increase kill count
			if character.LastAttacker ~= nil then
				giveAfflictionCharacter(character.LastAttacker, 'killcount', 1)
			end
			-- Reward a team for target elimination
			if character.LastAttacker ~= nil and character.LastAttacker.SpeciesName == 'human' then
				-- If dead is husk and...
				if character.SpeciesName == 'humanhusk' then
					-- and killer is terrorist then...
					if isCharacterTerrorist(character.LastAttacker) then
						FG.terroristTickets = FG.terroristTickets + 0.5
						messageAllClients('text-game', {'ticketsTerroristInfectedDown', {tickets = FG.terroristTickets}})
					-- and killer is nexpharma then...
					elseif isCharacterNexpharma(character.LastAttacker) then
						FG.nexpharmaTickets = FG.nexpharmaTickets + 0.5
						messageAllClients('text-game', {'ticketsNexpharmaInfectedDown', {tickets = FG.nexpharmaTickets}})
					end
				-- If dead is monster and...
				elseif character.SpeciesName ~= 'human' then
					-- and killer is terrorist then...
					if isCharacterTerrorist(character.LastAttacker) then
						FG.terroristTickets = FG.terroristTickets + 2
						messageAllClients('text-game', {'ticketsTerroristMonsterDown', {tickets = FG.terroristTickets}})
					-- and killer is nexpharma then...
					elseif isCharacterNexpharma(character.LastAttacker) then
						FG.nexpharmaTickets = FG.nexpharmaTickets + 2
						messageAllClients('text-game', {'ticketsNexpharmaMonsterDown', {tickets = FG.nexpharmaTickets}})
					end
				-- If dead is nexpharma and killer is terrorist then...
				elseif isCharacterNexpharma(character) and isCharacterTerrorist(character.LastAttacker) then
					-- Reward 0.5 extra tickts if it was by an inmate
					if findClientByCharacter(character.LastAttacker) and (character.LastAttacker.JobIdentifier == 'inmate') then
						FG.terroristTickets = FG.terroristTickets + 1.0
						messageAllClients('text-game', {'ticketsTerroristHumanDownByInmate', {tickets = FG.terroristTickets}})
					else
						FG.terroristTickets = FG.terroristTickets + 0.5
						messageAllClients('text-game', {'ticketsTerroristHumanDown', {tickets = FG.terroristTickets}})
					end
				-- If dead is terrorist and killer is nexpharma then...
				elseif isCharacterTerrorist(character) and isCharacterNexpharma(character.LastAttacker) then
					FG.nexpharmaTickets = FG.nexpharmaTickets + 0.5
					messageAllClients('text-game', {'ticketsNexpharmaHumanDown', {tickets = FG.nexpharmaTickets}})
				end
			end
		end, 0.1*1000)
	
		checkForGameEnd()
	end
	
	-- Special goblin and troll code
	if (character.SpeciesName == 'Humangoblin') or (character.SpeciesName == 'Humantroll') then
		-- Reward a team for target elimination
		if (findClientByCharacter(character) ~= nil) and (not FG.endGame) and character.IsPlayer and character.LastAttacker ~= nil and character.LastAttacker.SpeciesName == 'human' then
			-- If dead is goblin and...
			if character.SpeciesName == 'Humangoblin' then
				-- and killer is terrorist then...
				if isCharacterTerrorist(character.LastAttacker) then
					FG.terroristTickets = FG.terroristTickets + 0.5
					messageAllClients('text-game', {'ticketsTerroristGoblinDown', {tickets = FG.terroristTickets}})
				-- and killer is nexpharma then...
				elseif isCharacterNexpharma(character.LastAttacker) then
					FG.nexpharmaTickets = FG.nexpharmaTickets + 0.5
					messageAllClients('text-game', {'ticketsNexpharmaGoblinDown', {tickets = FG.nexpharmaTickets}})
				end
			-- If dead is troll and...
			elseif character.SpeciesName == 'Humantroll' then
				-- and killer is terrorist then...
				if isCharacterTerrorist(character.LastAttacker) then
					FG.terroristTickets = FG.terroristTickets + 1.5
					messageAllClients('text-game', {'ticketsTerroristTrollDown', {tickets = FG.terroristTickets}})
				-- and killer is nexpharma then...
				elseif isCharacterNexpharma(character.LastAttacker) then
					FG.nexpharmaTickets = FG.nexpharmaTickets + 1.5
					messageAllClients('text-game', {'ticketsNexpharmaTrollDown', {tickets = FG.nexpharmaTickets}})
				end
			end
		end
		-- Analytics
		if FG.analytics.valid then
			local obituaryName
			if character.SpeciesName == 'Human' then
				obituaryName = tostring(character.JobIdentifier) .. tostring(character.ID)
			else
				obituaryName = tostring(character.SpeciesName) .. tostring(character.ID)
			end
			local killerName
			if character.LastAttacker == nil then
				killerName = 'none'
			elseif character.LastAttacker.SpeciesName == 'Human' then
				killerName = tostring(character.LastAttacker.JobIdentifier) .. tostring(character.LastAttacker.ID)
			else
				killerName = tostring(character.LastAttacker.SpeciesName) .. tostring(character.LastAttacker.ID)
			end
			FG.analytics.data.obituary[obituaryName] = 'TOD:' .. numberToTime(math.floor(Timer.Time - FG.analytics.data.startTime), 1) .. 'BY:' .. killerName
		end
		-- Remove goblin/troll and spawn his mask on the floor
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('goblinmask'), character.WorldPosition)
		Entity.Spawner.AddEntityToRemoveQueue(character)
	end

	return true
end)

FG.loadedFiles['death'] = true