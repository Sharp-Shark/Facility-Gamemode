-- Execugte when a character dies
Hook.Add("character.death", "characterDied", function (character)
	if character == nil or global_endGame or  not character.IsPlayer then return end
	
	-- Reward a team for target elimination
	if character.LastAttacker ~= nil and character.LastAttacker.SpeciesName == 'human' then
		-- If dead is husk and...
		if character.SpeciesName == 'humanhusk' then
			-- and killer is terrorist then...
			if isCharacterTerrorist(character.LastAttacker) then
				global_terroristTickets = global_terroristTickets + 2
				Game.ExecuteCommand('say Terrorists have gained 0.5 tickets - infected eliminated! ' .. global_terroristTickets .. ' tickets left!' )
			-- and killer is nexpharma then...
			elseif isCharacterNexpharma(character.LastAttacker) then
				global_nexpharmaTickets = global_nexpharmaTickets + 2
				Game.ExecuteCommand('say Nexpharma has gained 0.5 tickets - infected eliminated! ' .. global_nexpharmaTickets .. ' tickets left!' )
			end
		-- If dead is monster and...
		elseif character.SpeciesName ~= 'human' then
			-- and killer is terrorist then...
			if isCharacterTerrorist(character.LastAttacker) then
				global_terroristTickets = global_terroristTickets + 2
				Game.ExecuteCommand('say Terrorists have gained 2 tickets - monster target eliminated! ' .. global_terroristTickets .. ' tickets left!' )
			-- and killer is nexpharma then...
			elseif isCharacterNexpharma(character.LastAttacker) then
				global_nexpharmaTickets = global_nexpharmaTickets + 2
				Game.ExecuteCommand('say Nexpharma has gained 2 tickets - monster target eliminated! ' .. global_nexpharmaTickets .. ' tickets left!' )
			end
		-- If dead is nexpharma and killer is terrorist then...
		elseif isCharacterNexpharma(character) and isCharacterTerrorist(character.LastAttacker) then
			-- Reward 0.5 extra tickts if it was by an inmate
			if findClientByCharacter(character.LastAttacker).Name and not global_militantPlayers[findClientByCharacter(character.LastAttacker).Name] then
				global_terroristTickets = global_terroristTickets + 1.0
				Game.ExecuteCommand('say Terrorists have gained 1 ticket - human eliminated by inmate! ' .. global_terroristTickets .. ' tickets left!' )
			else
				global_terroristTickets = global_terroristTickets + 0.5
				Game.ExecuteCommand('say Terrorists have gained 0.5 tickets - human target eliminated! ' .. global_terroristTickets .. ' tickets left!' )
			end
		-- If dead is terrorist and killer is nexpharma then...
		elseif isCharacterTerrorist(character) and isCharacterNexpharma(character.LastAttacker) then
			global_nexpharmaTickets = global_nexpharmaTickets + 0.5
			Game.ExecuteCommand('say Nexpharma has gained 0.5 tickets - human target eliminated! ' .. global_nexpharmaTickets .. ' tickets left!' )
		end
	end

	if character.SpeciesName == 'human' and findClientByCharacter(character) ~= nil and global_militantPlayers[findClientByCharacter(character).Name] == nil then
		global_militantPlayers[findClientByCharacter(character).Name] = true
	end
	
	-- Add a 1 second delay before checking for end conditions just to be sure
	Timer.Wait(function ()
		if #Client.ClientList - table.size(global_spectators) <= 1 then print('[!] Only 1 player, will not end round.') return end
		
		-- Make sure the game isn't already ending
		if global_endGame then return end
		-- Count live players
		local terroristPlayersAlive = 0
		local nexpharmaPlayersAlive = 0
		local monsterPlayersAlive = 0
		for player in Client.ClientList do
			if  player.Character ~= nil and not player.Character.IsDead then
				if isCharacterMonster(player.Character) then
					monsterPlayersAlive = monsterPlayersAlive + 1
				elseif isCharacterTerrorist(player.Character) then
					terroristPlayersAlive = terroristPlayersAlive + 1
				elseif isCharacterNexpharma(player.Character) then
					nexpharmaPlayersAlive = nexpharmaPlayersAlive + 1
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
			end, 11.5*1000)
		end
	end, 5*1000)

	return true
end)

global_loadedFiles['death'] = true