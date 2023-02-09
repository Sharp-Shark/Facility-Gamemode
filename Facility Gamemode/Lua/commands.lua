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
	if global_admins[client.Name] then
		messageClient(client, 'blue', '-HOST COMMANDS-')
		messageClient(client, 'blue', '/am_spect - sets yourself as a spectator.')
		messageClient(client, 'blue', '/reset_spect - empties spectator list.')
		messageClient(client, 'blue', '/huskmode - toggles huskmode on or off.')
	end

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
Hook.Add("chatMessage", "declareSpectator", function (message, client)
    if message ~= '/am_spect' then return end
	if not global_admins[client.Name] then messageClient(client, 'blue', 'Admin only command!') return true end
	
	messageClient(client, 'blue', 'You are now in the spectators list.')
	global_spectators[client.Name] = true

    return true
end)

-- Reset Spectator list (ADMIN ONLY)
Hook.Add("chatMessage", "resetSpectator", function (message, client)
    if message ~= '/reset_spect' then return end
	if not global_admins[client.Name] then messageClient(client, 'blue', 'Admin only command!') return true end
	
	messageClient(client, 'blue', 'Spectator list reset.')
	global_spectators = {}

    return true
end)

-- Toggle Husk Gamemode (ADMIN ONLY)
Hook.Add("chatMessage", "toggleHuskMode", function (message, client)
    if message ~= '/huskmode' then return end
	if not global_admins[client.Name] then messageClient(client, 'blue', 'Admin only command!') return true end
	
	global_huskMode = not global_huskMode
	if global_huskMode then
		messageClient(client, 'blue', 'Huskgamemode ENABLED.')
	else
		messageClient(client, 'blue', 'Huskgamemode DISABLED.')
	end

    return true
end)

global_loadedFiles['commands'] = true