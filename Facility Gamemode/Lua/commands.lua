-- User Commands
-- Lists and explains user commands
Hook.Add("chatMessage", "helpCommand", function (message, client)
    if message ~= '/help' then return end
	
	local text = ''
	
	text = text .. '-USER COMMANDS-\n'
	text = text .. '/help - gives command list.\n'
	text = text .. '/admin - calls admin attention.\n'
	text = text .. '/admin <text> - sends text to admin.\n'
	text = text .. '/players - gives a list of players and their roles.\n'
	text = text .. '/tickets - tells JET and MERCS ticket count.\n'
	if client.HasPermission(ClientPermissions.ConsoleCommands) then
		text = text .. '-HOST COMMANDS-\n'
		text = text .. '/spectator - toggles yourself as spectator.\n'
		text = text .. '/spectator <player> - toggles player as spectator.\n'
		text = text .. '/spectators - list spectators.\n'
		text = text .. '/huskmode - toggles huskmode on or off.\n'
	end
	
	text = text .. '-END OF LIST-'
	
	messageClient(client, 'text-command', text)

    return true
end)

-- Communicate with admin
Hook.Add("chatMessage", "callAdmin", function (message, client)
    if string.sub(message, 1, 7) ~= "/admin " and message ~= '/admin' then return end
	
	local text = ''
	
	if #message < 8 then
		text = 'The player ' .. client.Name .. ' requires an admin/host.'
	else 
		text = 'The player ' .. client.Name .. ' has a message for admin/host: ' .. string.sub(message, 8)
	end
	
	for clientOther in Client.ClientList do
		if clientOther.HasPermission(ClientPermissions.ConsoleCommands) then
			messageClient(clientOther, 'text-command', text)
		end
	end

    return true
end)

-- Gives a list of players alive
Hook.Add("chatMessage", "livePlayerList", function (message, client)
    if message ~= '/players' then return end
	
	local text = ''
	
	text = text .. '-PLAYER LIST-\n'
	
	for player in Client.ClientList do
		if player.Character ~= nil and not player.Character.IsDead then
			if player.Character.SpeciesName == 'human' then
				if isCharacterTerrorist(player.Character)  then
					text = text .. player.Name .. ' is an armed member of the terrorist faction.\n'
				elseif isCharacterTerrorist(player.Character) then
					text = text .. player.Name .. ' is a civilian member of the terrorist faction.\n'
				elseif isCharacterNexpharma(player.Character) then
					text = text .. player.Name .. ' is an armed member of the nexpharma corp.\n'
				elseif isCharacterStaff(player.Character) then
					text = text .. player.Name .. ' is a civilian member of the nexpharma corp.\n'
				end
			elseif player.Character.SpeciesName == 'Mantisadmin' then
				text = text .. player.Name .. ' is mutated mantis.\n'
			elseif player.Character.SpeciesName == 'Crawleradmin' then
				text = text .. player.Name .. ' is mutated crawler.\n'
			elseif player.Character.SpeciesName == 'Humanhusk' then
				text = text .. player.Name .. ' is a husk.\n'
			end
		end
	end
	
	text = text .. '-END OF LIST-'
	
	messageClient(client, 'text-command', text)

    return true
end)

function respawnInfo(client, msgType)
	if (global_terroristTickets >= 1) or (global_nexpharmaTickets >= 1) then
		messageClient(client, msgType or 'text-game', 'Respawn is going to be ' .. global_respawnETA .. '.')
	else
		messageClient(client, msgType or 'text-game', 'No tickets, no respawns.')
	end
end

-- Tells the current amount of tickets and time to respawn
Hook.Add("chatMessage", "respawnInfo", function (message, client)
    if message ~= '/tickets' and message ~= '/respawn' then return end
	if not Game.RoundStarted then
		messageClient(client, 'text-command', 'Round has not started yet.')
		return true
	end
	
	local text = ''
	
	text = text .. 'Terrorists have ' .. global_terroristTickets .. ' tickets left.\n'
	text = text .. 'Nexpharma has ' .. global_nexpharmaTickets .. ' tickets left.\n'
	text = text .. "The team with more tickets respawns. In case of a tie, it's randomized."
	respawnInfo(client, 'text-command')
	
	messageClient(client, 'text-command', text)

    return true
end)

-- Declare self as Spectator (ADMIN ONLY)
Hook.Add("chatMessage", "toggleSpectator", function (message, client)
    if string.sub(message, 1, 11) ~= "/spectator " and message ~= '/spectator' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'text-warning', 'Admin only command!') return true end
	
	if message == '/spectator' then
		global_spectators[client.Name] = not global_spectators[client.Name]
		messageClient(client, 'text-command', 'Now you are ' .. string.rep('NOT ', global_spectators[client.Name] and 0 or 1) .. 'in the spectators list.')
	else
		if not findClientByUsername(string.sub(message, 12)) then 
			messageClient(client, 'text-command', 'There is no player with that username in the lobby.')
			return true
		end
		global_spectators[string.sub(message, 12)] = not global_spectators[string.sub(message, 12)]
		messageClient(client, 'text-command', 'Now ' .. string.sub(message, 12) .. ' is ' .. string.rep('NOT ', global_spectators[string.sub(message, 12)] and 0 or 1) .. 'in the spectators list.')
	end

    return true
end)

-- Declare self as Spectator (ADMIN ONLY)
Hook.Add("chatMessage", "listSpectator", function (message, client)
    if message ~= '/spectators' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'text-warning', 'Admin only command!') return true end
	
	local noSpectators = true
	local text = ''
	
	text = text .. '-SPECTATOR LIST-\n'
	
	for player, value in pairs(global_spectators) do 
		if value then
			text = text .. player .. ' is in the spectators list.\n'
			noSpectators = false
		end
	end
	
	text = text .. '-END OF LIST-'
	
	if noSpectators then
		messageClient(client, 'text-command', 'There are NO spectators.')
	else
		messageClient(client, 'text-command', text)
	end

    return true
end)

-- Toggle Husk Gamemode (ADMIN ONLY)
Hook.Add("chatMessage", "toggleHuskMode", function (message, client)
    if message ~= '/huskmode' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'text-warning', 'Admin only command!') return true end
	
	global_huskMode = not global_huskMode
	if global_huskMode then
		messageClient(client, 'text-command', 'Huskgamemode ENABLED.')
	else
		messageClient(client, 'text-command', 'Huskgamemode DISABLED.')
	end

    return true
end)

global_loadedFiles['commands'] = true