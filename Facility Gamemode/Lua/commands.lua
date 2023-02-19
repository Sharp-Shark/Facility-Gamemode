-- User Commands
-- Lists and explains user commands
Hook.Add("chatMessage", "helpCommand", function (message, client)
    if message ~= '/help' then return end
	
	messageClient(client, 'blue', '-USER COMMANDS-')
	messageClient(client, 'blue', '/help - gives command list.')
	messageClient(client, 'blue', '/admin - calls admin attention.')
	messageClient(client, 'blue', '/admin <text> - sends text to admin.')
	messageClient(client, 'blue', '/players - gives a list of players and their roles.')
	messageClient(client, 'blue', '/tickets - tells JET and MERCS ticket count.')
	if client.HasPermission(ClientPermissions.ConsoleCommands) then
		messageClient(client, 'blue', '-HOST COMMANDS-')
		messageClient(client, 'blue', '/spectator - toggles yourself as spectator.')
		messageClient(client, 'blue', '/spectator <player> - toggles player as spectator.')
		messageClient(client, 'blue', '/spectators - list spectators.')
		messageClient(client, 'blue', '/huskmode - toggles huskmode on or off.')
	end

    return true
end)

-- Communicate with admin
Hook.Add("chatMessage", "callAdmin", function (message, client)
    if string.sub(message, 1, 7) ~= "/admin " and message ~= '/admin' then return end
	
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
				if isCharacterTerrorist(player.Character) and global_militantPlayers[player.Name]  then
					messageClient(client, 'blue', player.Name .. ' is an armed member of the terrorist faction.')
				elseif player.Character.HasJob('assistant') then
					messageClient(client, 'blue', player.Name .. ' is a civilian member of the terrorist faction.')
				elseif isCharacterNexpharma(player.Character) and global_militantPlayers[player.Name] then
					messageClient(client, 'blue', player.Name .. ' is an armed member of the nexpharma corp.')
				elseif isCharacterStaff(player.Character) then
					messageClient(client, 'blue', player.Name .. ' is a civilian member of the nexpharma corp.')
				end
			elseif player.Character.SpeciesName == 'Mantisadmin' then
				messageClient(client, 'blue', player.Name .. ' is mutated mantis.')
			elseif player.Character.SpeciesName == 'Crawleradmin' then
				messageClient(client, 'blue', player.Name .. ' is mutated crawler.')
			elseif player.Character.SpeciesName == 'Humanhusk' then
				messageClient(client, 'blue', player.Name .. ' is a husk.')
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

-- Declare self as Spectator (ADMIN ONLY)
Hook.Add("chatMessage", "toggleSpectator", function (message, client)
    if string.sub(message, 1, 11) ~= "/spectator " and message ~= '/spectator' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'blue', 'Admin only command!') return true end
	
	if message == '/spectator' then
		global_spectators[client.Name] = not global_spectators[client.Name]
		messageClient(client, 'blue', 'Now you are ' .. string.rep('not ', global_spectators[client.Name] and 0 or 1) .. 'in the spectators list.')
	else
		if not findClientByUsername(string.sub(message, 12)) then 
			messageClient(client, 'blue', 'There is no player with that username in the lobby.')
			return true
		end
		global_spectators[string.sub(message, 12)] = not global_spectators[string.sub(message, 12)]
		messageClient(client, 'blue', 'Now ' .. string.sub(message, 12) .. ' is ' .. string.rep('not ', global_spectators[string.sub(message, 12)] and 0 or 1) .. 'in the spectators list.')
	end

    return true
end)

-- Declare self as Spectator (ADMIN ONLY)
Hook.Add("chatMessage", "listSpectator", function (message, client)
    if message ~= '/spectators' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'blue', 'Admin only command!') return true end
	
	for player, value in pairs(global_spectators) do 
		if value then messageClient(client, 'blue', player .. ' is in the spectators list.') end
	end

    return true
end)

-- Toggle Husk Gamemode (ADMIN ONLY)
Hook.Add("chatMessage", "toggleHuskMode", function (message, client)
    if message ~= '/huskmode' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'blue', 'Admin only command!') return true end
	
	global_huskMode = not global_huskMode
	if global_huskMode then
		messageClient(client, 'blue', 'Huskgamemode ENABLED.')
	else
		messageClient(client, 'blue', 'Huskgamemode DISABLED.')
	end

    return true
end)

global_loadedFiles['commands'] = true