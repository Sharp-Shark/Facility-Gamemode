Hook.Add("chatMessage", "monsterChat", function (message, client)
	if CLIENT then return end
    if (string.sub(message, 1, 1) == '/') or (client.Character == nil) or (not isCharacterMonster(client.Character)) or (client.Character.IsDead) then return end
	
	for player in Client.ClientList do
		if (player == client) or (player.Character == nil) or (player.Character.IsDead) then
			messageClient(player, 'chat-regular', message, tostring(client.Character.SpeciesName) .. ' (' .. client.Name .. ')')
			--messageClient(player, 'chat-regular', message, client.Character.Name)
		elseif player.Character.CanHearCharacter(client.Character) then
			messageClient(player, 'chat-regular', message, tostring(client.Character.SpeciesName) .. ' (' .. client.Name .. ')')
		elseif isCharacterMonster(player.Character) then
			messageClient(player, 'chat-monster', message, tostring(client.Character.SpeciesName) .. ' (' .. client.Name .. ')')
		end
	end

    return true
end)

-- User Commands
-- Gets the credits for the mod
Hook.Add("chatMessage", "creditCommand", function (message, client)
    if message ~= '/credits' then return end
	
	local text = ''
	if not Game.RoundStarted then text = text .. '\n' end
	
	text = text .. File.Read(FG.path .. '/credits.txt')
	
	messageClient(client, 'text-command', text)

    return true
end)

-- Lists and explains user commands
Hook.Add("chatMessage", "helpCommand", function (message, client)
    if message ~= '/help' then return end
	
	local text = ''
	if not Game.RoundStarted then text = text .. '\n' end
	
	text = text .. string.localize('commandHelp', nil, client.Language)
	if client.HasPermission(ClientPermissions.ConsoleCommands) then
		text = text .. '-HOST COMMANDS-\n'
		text = text .. string.localize('commandHelpAdmin', nil, client.Language)
	end
	
	text = text .. '-END OF LIST-'
	
	messageClient(client, 'text-command', text)

    return true
end)

-- Communicate with admin
Hook.Add("chatMessage", "callAdmin", function (message, client)
    if string.sub(message, 1, 7) ~= '/admin ' and message ~= '/admin' then return end
	
	local text = ''
	if not Game.RoundStarted then text = text .. '\n' end
	
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
	if not Game.RoundStarted then text = text .. '\n' end
	
	text = text .. '-PLAYER LIST-\n'
	
	for player in Client.ClientList do
		if player.Character ~= nil and not player.Character.IsDead then
			if player.Character.SpeciesName == 'human' then
				if isCharacterTerrorist(player.Character) and isCharacterCivilian(player.Character) then
					text = text .. player.Name .. string.localize('commandPlayersTerroristCivilian', nil, client.Language) .. '\n'
				elseif isCharacterTerrorist(player.Character) then
					text = text .. player.Name .. string.localize('commandPlayersTerroristMilitant', nil, client.Language) .. '\n'
				elseif isCharacterNexpharma(player.Character) and isCharacterCivilian(player.Character) then
					text = text .. player.Name .. string.localize('commandPlayersNexpharmaCivilian', nil, client.Language) .. '\n'
				elseif isCharacterNexpharma(player.Character) then
					text = text .. player.Name .. string.localize('commandPlayersNexpharmaMilitant', nil, client.Language) .. '\n'
				end
			elseif (player.Character.SpeciesName == 'Mantisadmin') or (player.Character.SpeciesName == 'Mantisadmin_hatchling') then
				text = text .. player.Name .. string.localize('commandPlayersMutatedMantis', nil, client.Language) .. '\n'
			elseif (player.Character.SpeciesName == 'Crawleradmin') or (player.Character.SpeciesName == 'Crawleradmin_hatchling') then
				text = text .. player.Name .. string.localize('commandPlayersMutatedCrawler', nil, client.Language) .. '\n'
			elseif player.Character.SpeciesName == 'Humanhusk' then
				text = text .. player.Name .. string.localize('commandPlayersHusk', nil, client.Language) .. '\n'
			elseif player.Character.SpeciesName == 'Humangoblin' then
				text = text .. player.Name .. string.localize('commandPlayersGoblin', nil, client.Language) .. '\n'
			elseif player.Character.SpeciesName == 'Humantroll' then
				text = text .. player.Name .. string.localize('commandPlayersTroll', nil, client.Language) .. '\n'
			end
		end
	end
	
	text = text .. '-END OF LIST-'
	
	messageClient(client, 'text-command', text)

    return true
end)

function respawnInfo(client, msgType)
	if (FG.terroristTickets >= 1) or (FG.nexpharmaTickets >= 1) or (FG.settings.respawnSpeed == 0) then
		messageClient(client, msgType or 'text-game', string.localize('commandRespawnTime', {text = FG.respawnETA}, client.Language))
	else
		messageClient(client, msgType or 'text-game', string.localize('commandRespawnNoTickets', nil, client.Language))
	end
end

-- Tells the current amount of tickets and time to respawn
Hook.Add("chatMessage", "respawnInfo", function (message, client)
    if message ~= '/tickets' and message ~= '/respawn' then return end
	if not Game.RoundStarted then
		messageClient(client, 'text-command', '\n' .. string.localize('commandRoundNotStarted', nil, client.Language))
		return true
	end
	
	local text = ''
	
	text = text .. string.localize('commandTickets', {terroristTickets = FG.terroristTickets, nexpharmaTickets = FG.nexpharmaTickets}, client.Language)
	respawnInfo(client, 'text-command')
	
	messageClient(client, 'text-command', text)

    return true
end)

-- Tells the user time until decontamination
Hook.Add("chatMessage", "deconInfo", function (message, client)
    if message ~= '/decon' then return end
	if not Game.RoundStarted then
		messageClient(client, 'text-command', '\n' .. string.localize('commandRoundNotStarted', nil, client.Language))
		return true
	end
	
	if FG.decontaminationTimer <= 0 then
		messageClient(client, 'text-command', string.localize('commandDeconStart', nil, client.Language))
	else
		messageClient(client, 'text-command', string.localize('commandDeconTime', {time = numberToTime(FG.decontaminationTimer, 1)}, client.Language))
	end

    return true
end)

-- Lists all the gamemodes (is like "/cfg plist" but for clients)
Hook.Add("chatMessage", "listgamemodes", function (message, client)
    if message ~= '/gamemodes' then return end
	
	text = ''
	if not Game.RoundStarted then text = text .. '\n' end
	
	for presetName, presetSettings in pairs(FG.settingsPresets) do
		local author = '[UNKNOWN]'
		if presetSettings.author ~= nil then
			author = presetSettings.author
		end
		local info = 'No information given.'
		if presetSettings.info ~= nil then
			info = presetSettings.info
		end
		text = text .. '"' .. presetName .. '"' .. ' by ' .. author .. ' - ' .. info ..'\n\n'
	end
	messageClient(client, 'text-command', string.sub(text, 1, #text - 2))

    return true
end)

-- Gives data on a specific gamemode (is like "/cfg pview" or "/cfg list" but for clients)
Hook.Add("chatMessage", "viewgamemode", function (message, client)
    if string.sub(message, 1, 10) ~= '/gamemode ' and message ~= '/gamemode' then return end
	
	text = ''
	if not Game.RoundStarted then text = text .. '\n' end
	
	if message == '/gamemode' then
		text = text .. table.print(FG.settings, true, true)
		messageClient(client, 'text-command', text)
	elseif not FG.settingsPresets[string.sub(message, 11, #message)] then
		text = text .. 'there is no gamemode named ' .. string.sub(message, 11, #message) .. '. Do /gamemodes for a list of gamemodes.'
		messageClient(client, 'text-command', text)
	else
		text = text .. table.print(FG.settingsPresets[string.sub(message, 11, #message)], true, true)
		messageClient(client, 'text-command', text)
	end

    return true
end)

-- SCP-079 & Paranormal Activity
Hook.Add("chatMessage", "ghostActivity", function (message, client)
    if (string.sub(message, 1, 4) ~= '/boo') or (FG.settings.ghosts == 'disabled') then return end
	if client.SpectatePos == nil then return end
	if not Game.RoundStarted then
		messageClient(client, 'text-command', '\n' .. string.localize('commandRoundNotStarted', nil, client.Language))
		return true
	end
	
	-- Breaks down message into words
	local msgTxt = message
	local words = {}
	local word = ''
	local letter = ''
	for count = 1, #msgTxt do
		letter = string.sub(msgTxt, count, count)
		if (letter ~= ' ') or (count == #msgTxt) then
			word = word .. letter
		end
		if ((letter == ' ') or (count == #msgTxt)) and (word ~= '') then
			table.insert(words, word)
			word = ''
		end
	end
	
	-- Remove the first word (which should be /boo)
	table.remove(words, 1)
	
	-- Joins all words after an index
	local function joinAllWordsAfterIndex (index, spacing)
		local joined = ''
		for n = index, #words do
			joined = joined .. table.remove(words, index) .. string.rep(' ', spacing or 0)
		end
		joined = string.sub(joined, 1, #joined - spacing)
		words[index] = joined
	end
	
	local level = 1
	if (FG.paranormal.clients[client] ~= nil) and (FG.paranormal.clients[client].level ~= nil) then level = FG.paranormal.clients[client].level end
	
	local actionSelected
	
	for actionName, action in pairs(FG.paranormal.actions) do
		if (action.name == words[1]) and (not action.hide) and ((not action.poltergeistOnly) or FG.settings.ghosts == 'poltergeist') and (level >= action.levelNeeded) then
			actionSelected = action
			break
		end
	end

	if actionSelected ~= nil then
		joinAllWordsAfterIndex(2, 1)
		FG.paranormal.doAction(client, actionSelected, {text = words[2]})
	else
		local text = ''
		for actionName, action in pairs(FG.paranormal.actions) do
			if (not action.hide) and ((not action.poltergeistOnly) or FG.settings.ghosts == 'poltergeist') and (level >= action.levelNeeded) then
				local cost = action.cost
				if action.free then cost = 0 end
				text = text .. '/boo: ' .. action.name .. ' (' .. tostring(cost) .. '), '
			end
		end
		text = string.sub(text, 1, #text - 2) .. '.'
		
		messageClient(client, 'text-command', text)
	end

	return true
end)

-- Enable poltergeist (ADMIN ONLY)
Hook.Add("chatMessage", "enablePoltergeist", function (message, client)
    if message ~= '/poltergeist' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'text-warning', string.localize('commandAdminOnly', nil, client.Language)) return true end
	
	FG.settings.ghosts = 'poltergeist'
	
	messageClient(client, 'text-command', 'Poltergeist has been enabled.')

    return true
end)

-- Toggle loot corpses (ADMIN ONLY)
Hook.Add("chatMessage", "toggleCorpses", function (message, client)
    if message ~= '/corpses' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'text-warning', string.localize('commandAdminOnly', nil, client.Language)) return true end
	
	FG.spawnCorpses = not FG.spawnCorpses
	
	messageClient(client, 'text-command', 'Corpse spawning has been set to: ' .. tostring(FG.spawnCorpses) .. '.')

    return true
end)

-- Declare self as Spectator (ADMIN ONLY)
Hook.Add("chatMessage", "toggleSpectator", function (message, client)
    if string.sub(message, 1, 11) ~= '/spectator ' and message ~= '/spectator' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'text-warning', string.localize('commandAdminOnly', nil, client.Language)) return true end
	
	local text = ''
	if not Game.RoundStarted then text = text .. '\n' end
	
	if message == '/spectator' then
		if FG.spectators[client.Name] then
			FG.spectators[client.Name] = nil
		else
			FG.spectators[client.Name] = true
		end
		text = text .. 'Now you are ' .. string.rep('NOT ', FG.spectators[client.Name] and 0 or 1) .. 'in the spectators list.'
	else
		if not findClientByUsername(string.sub(message, 12)) then 
			text = text .. 'There is no player with that username in the lobby.'
			return true
		end
		if FG.spectators[client.Name] then
			FG.spectators[client.Name] = nil
		else
			FG.spectators[client.Name] = true
		end
		FG.spectators[string.sub(message, 12)] = not FG.spectators[string.sub(message, 12)]
		text = text .. 'Now ' .. string.sub(message, 12) .. ' is ' .. string.rep('NOT ', FG.spectators[string.sub(message, 12)] and 0 or 1) .. 'in the spectators list.'
	end
	
	messageClient(client, 'text-command', text)

    return true
end)

-- Declare self as Spectator (ADMIN ONLY)
Hook.Add("chatMessage", "listSpectator", function (message, client)
    if message ~= '/spectators' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'text-warning', string.localize('commandAdminOnly', nil, client.Language)) return true end
	
	local noSpectators = true
	local text = ''
	if not Game.RoundStarted then text = text .. '\n' end
	
	text = text .. '-SPECTATOR LIST-\n'
	
	for player, value in pairs(FG.spectators) do 
		if value then
			text = text .. player .. ' is in the spectators list.\n'
			noSpectators = false
		end
	end
	
	text = text .. '-END OF LIST-'
	
	if noSpectators then
		messageClient(client, 'text-command', '\nThere are NO spectators.')
	else
		messageClient(client, 'text-command', text)
	end
	
    return true
end)

-- Cast a vote
Hook.Add("chatMessage", "democracyCastVote", function (message, client)
	if table.has(FG.democracy.voters, client) or (not table.has(FG.democracy.options, message)) or (not FG.democracy.started) then return end
	
	local text = ''
	if not Game.RoundStarted then text = text .. '\n' end
	
	FG.democracy.votes[client] = message
	table.insert(FG.democracy.voters, client)
	
	messageClient(client, 'text-general', string.localize('castVote', {option = message}, client.Language))
	
	for player in Client.ClientList do
		messageClient(player, 'text-general', string.localize('castVoteCount', {current = tostring(#FG.democracy.voters), total = tostring(#Client.ClientList)}, client.Language))
	end
	
	if (#Client.ClientList - #FG.democracy.voters) <= 0 then
		FG.democracy.endVoting(Client.ClientList)
	end
	
	return true
end)

-- Starts a vote (ADMIN ONLY)
Hook.Add("chatMessage", "democracyInterface", function (message, client)
	if string.sub(message, 1, 5) ~= '/vote' and message ~= '/vote' then return end
	if Game.RoundStarted then messageClient(client, 'text-warning', string.localize('voteMidMatch', nil, client.Language)) return true end
	
	local text = ''
	if not Game.RoundStarted then text = text .. '\n' end
	
	-- Vote command for clients who aren't admins
	if (not client.HasPermission(ClientPermissions.ConsoleCommands)) or (message == '/vote asclient') then
		-- Gamemode vote has already been done
		if FG.democracy.gamemodeChosen then
			messageClient(client, 'text-warning', string.localize('voteGamemodeAlreadyEnded', nil, client.Language))
		elseif FG.democracy.started then
		-- If voting has started, repeat announcement to client
			-- Do counting
			local voteCount = {}
			-- Get all options
			for option in FG.democracy.options do
				voteCount[option] = 0
			end
			-- Count the votes
			for vote in FG.democracy.votes do
				voteCount[vote] = voteCount[vote] + 1
			end
			-- Put text together
			text = text .. string.localize('voteRepeatHeader', nil, client.Language)
			for option in FG.democracy.options do
				text = text .. string.localize('voteRepeatItem', {option = option, votes = tostring(voteCount[option])}, client.Language)
			end
			text = string.sub(text, 1, #text - 2) .. '.'
			messageClient(client, 'text-command', text)
		-- Start poll and announce it to all
		else
			FG.democracy.options = {}
			FG.democracy.votes = {}
			FG.democracy.voters = {}
			FG.democracy.started = true
			FG.democracy.gamemode = true
			FG.democracy.gamemodeChosen = false
			text = text ..  string.localize('voteStartHeader', nil, client.Language)
			for presetName, presetSettings in pairs(FG.settingsPresets) do
				if not presetSettings.hide then
					text = text .. presetName .. ', '
					table.insert(FG.democracy.options, presetName)
				end
			end
			text = string.sub(text, 1, #text - 2) .. '.\n' ..  string.localize('voteStartFooter', nil, client.Language)
			for player in Client.ClientList do
				messageClient(player, 'text-command', text)
			end
		end
		return true
	end
	
	-- Breaks down message into words
	local msgTxt = message
	local words = {}
	local word = ''
	local letter = ''
	for count = 1, #msgTxt do
		letter = string.sub(msgTxt, count, count)
		if (letter ~= ' ') or (count == #msgTxt) then
			word = word .. letter
		end
		if ((letter == ' ') or (count == #msgTxt)) and (word ~= '') then
			table.insert(words, word)
			word = ''
		end
	end
	
	-- Remove the first word (which should be /democracy)
	table.remove(words, 1)
	
	-- Joins all words after an index
	local function joinAllWordsAfterIndex (index, spacing)
		local joined = ''
		for n = index, #words do
			joined = joined .. table.remove(words, index) .. string.rep(' ', spacing or 0)
		end
		joined = string.sub(joined, 1, #joined - spacing)
		words[index] = joined
	end
	
	-- Lists commands
	if words[1] == 'help' then
		text = text .. '-VOTE COMMANDS-\n'
		text = text .. '/vote help - gives command list and guides.\n'
		text = text .. '/vote asclient - the client /vote for admins.\n'
		text = text .. '/vote allgamemode <options> - starts a poll for all gamemodes.\n'
		text = text .. '/vote gamemodes <options> - starts a poll for some gamemodes.\n'
		text = text .. '/vote start <options> - starts and announces a poll.\n'
		text = text .. '/vote repeat - repeats the poll announcement.\n'
		text = text .. '/vote end - ends poll and counts the votes.\n'
		text = text .. '-END OF LIST-'
		messageClient(client, 'text-command', text)
	-- Starts a poll with the options being all the gamemodes
	elseif words[1] == 'allgamemodes' then
		if FG.democracy.started then messageClient(client, 'text-warning', string.localize('voteStarted', nil, client.Language)) return true end
		FG.democracy.options = {}
		FG.democracy.votes = {}
		FG.democracy.voters = {}
		FG.democracy.started = true
		FG.democracy.gamemode = true
		FG.democracy.gamemodeChosen = false
		table.remove(words, 1)
		text = text .. 'Democracy time! Please vote for one of these: '
		for presetName, presetSettings in pairs(FG.settingsPresets) do
			if not presetSettings.hide then
				text = text .. presetName .. ', '
				table.insert(FG.democracy.options, presetName)
			end
		end
		text = string.sub(text, 1, #text - 2) .. '.\nTo vote just type what you want in chat.'
		for player in Client.ClientList do
			messageClient(player, 'text-command', text)
		end
	-- Starts a poll with the options being some gamemodes
	elseif words[1] == 'gamemodes' then
		if FG.democracy.started then messageClient(client, 'text-warning', string.localize('voteStarted', nil, client.Language)) return true end
		FG.democracy.options = {}
		FG.democracy.votes = {}
		FG.democracy.voters = {}
		FG.democracy.started = true
		FG.democracy.gamemode = true
		FG.democracy.gamemodeChosen = false
		table.remove(words, 1)
		text = text .. 'Democracy time! Please vote for one of these: '
		for presetName, presetSettings in pairs(FG.settingsPresets) do
			if table.has(words, presetName) then
				text = text .. presetName .. ', '
				table.insert(FG.democracy.options, presetName)
			end
		end
		text = string.sub(text, 1, #text - 2) .. '.\nTo vote just type what you want in chat.'
		for player in Client.ClientList do
			messageClient(player, 'text-command', text)
		end
	-- Starts a poll and notifies clients of options
	elseif words[1] == 'start' then
		if FG.democracy.started then messageClient(client, 'text-warning', string.localize('voteStarted', nil, client.Language)) return true end
		FG.democracy.options = {}
		FG.democracy.votes = {}
		FG.democracy.voters = {}
		FG.democracy.started = true
		FG.democracy.gamemode = false
		table.remove(words, 1)
		text = text .. 'Democracy time! Please vote for one of these: '
		for word in words do
			text = text .. word .. ', '
			table.insert(FG.democracy.options, word)
		end
		text = string.sub(text, 1, #text - 2) .. '.\nTo vote just type what you want in chat.'
		for player in Client.ClientList do
			messageClient(player, 'text-command', text)
		end
	-- Repeats the warning
	elseif words[1] == 'repeat' then
		if not FG.democracy.started then messageClient(client, 'text-warning', string.localize('voteNotStarted', nil, client.Language)) return true end
		text = text .. 'Just type one of these in chat to vote: '
		for option in FG.democracy.options do
			text = text .. option .. ', '
		end
		text = string.sub(text, 1, #text - 2) .. '.\nTo vote just type what you want in chat.'
		for player in Client.ClientList do
			messageClient(player, 'text-command', text)
		end
	-- Ends a poll and shares poll results
	elseif words[1] == 'end' then
		if not FG.democracy.started then messageClient(client, 'text-warning', string.localize('voteNotStarted', nil, client.Language)) return true end
		FG.democracy.endVoting(Client.ClientList)
	-- Invalid command
	elseif (message == '/vote') or (message == '/vote ') then
		text = text .. 'Do "/vote help" for a list of commands.'
		messageClient(client, 'text-command', text)
	else
		text = text .. ' is not a command! Do "/vote help" for a list of commands.'
		messageClient(client, 'text-warning', text)
	end
	
	return true
end)

-- Settings interface (ADMIN ONLY)
Hook.Add("chatMessage", "settingsInterface", function (message, client)
    if string.sub(message, 1, 4) ~= '/cfg' then return end
	if not client.HasPermission(ClientPermissions.ConsoleCommands) then messageClient(client, 'text-warning', string.localize('commandAdminOnly', nil, client.Language)) return true end
	
	local text = ''
	if not Game.RoundStarted then text = text .. '\n' end
	
	-- Breaks down message into words
	local msgTxt = message
	local words = {}
	local word = ''
	local letter = ''
	for count = 1, #msgTxt do
		letter = string.sub(msgTxt, count, count)
		if (letter ~= ' ') or (count == #msgTxt) then
			word = word .. letter
		end
		if ((letter == ' ') or (count == #msgTxt)) and (word ~= '') then
			table.insert(words, word)
			word = ''
		end
	end
	
	-- Remove the first word (which should be /cfg)
	table.remove(words, 1)
	
	-- Joins all words after an index
	local function joinAllWordsAfterIndex (index, spacing)
		local joined = ''
		for n = index, #words do
			joined = joined .. table.remove(words, index) .. string.rep(' ', spacing or 0)
		end
		joined = string.sub(joined, 1, #joined - spacing)
		words[index] = joined
	end
	
	-- Lists commands
	if words[1] == 'help' then
		text = text .. '-CFG Simple COMMANDS-\n'
		text = text .. '/cfg help - gives command list and guides.\n'
		text = text .. '/cfg list - list the current settings and their values.\n'
		text = text .. '/cfg reset - resets the settings to default.\n'
		text = text .. '/cfg set <setting> <value> - changes the value of a setting.\n'
		text = text .. '-CFG P COMMANDS-\n'
		text = text .. '/cfg plist - lists all presets.\n'
		text = text .. '/cfg preset - resets settings presets to default.\n'
		text = text .. '/cfg pload <preset> - loads the settings from a preset.\n'
		text = text .. '/cfg psave <preset> - saves the current settings to a preset.\n'
		text = text .. '/cfg pdelete <preset> - deletes a preset. Can not be undone.\n'
		text = text .. '/cfg pview <preset> - previews the settings of a preset.\n'
		text = text .. '-CFG R COMMANDS-\n'
		text = text .. '/cfg rlist - lists all presets sent by non-admins.\n'
		text = text .. '/cfg rload <username> - loads a preset sent by a non-admin.\n'
		text = text .. '/cfg rview <username> - previews a preset sent by a non-admin.\n'
		text = text .. '-END OF LIST-'
		messageClient(client, 'text-command', text)
	-- Lists keys and values
	elseif words[1] == 'list' then
		text = text .. table.print(FG.settings, true, true)
		messageClient(client, 'text-command', text)
	-- Resets settings to default
	elseif words[1] == 'reset' then
		FG.settings = table.copy(FG.settingsDefault)
		text = text ..  'Settings have been reset to default.'
		messageClient(client, 'text-command', text)
	-- Sets the value of a key
	elseif words[1] == 'set' then
		joinAllWordsAfterIndex(3, 1)
		if FG.settings[words[2]] ~= nil then
			if type(FG.settingsDefault[words[2]]) == 'boolean' then
				if (words[3] == 'true') and not FG.settings[words[2]] then
					FG.settings[words[2]] = true
					text = text .. table.print({[words[2]] = FG.settings[words[2]]}, true)
					messageClient(client, 'text-command', text)
				elseif (words[3] == 'false') and FG.settings[words[2]] then
					FG.settings[words[2]] = false
					text = text .. table.print({[words[2]] = FG.settings[words[2]]}, true)
					messageClient(client, 'text-command', text)
				elseif (words[3] ~= 'true') and (words[3] ~= 'false') then
					text = text .. 'Error with user input!'
					messageClient(client, 'text-warning', text)
				end
			elseif type(FG.settingsDefault[words[2]]) == 'number' then
				if tonumber(words[3]) ~= nil then
					FG.settings[words[2]] = tonumber(words[3])
					text = text .. table.print({[words[2]] = FG.settings[words[2]]}, true)
					messageClient(client, 'text-command', text)
				else
					text = text .. 'Error with user input!'
					messageClient(client, 'text-warning', text)
				end
			elseif type(FG.settingsDefault[words[2]]) == 'string' then
				FG.settings[words[2]] = words[3]
				text = text .. table.print({[words[2]] = FG.settings[words[2]]}, true)
				messageClient(client, 'text-command', text)
			elseif type(FG.settingsDefault[words[2]]) == 'table' then
				text = text .. 'Settings of type table can only be changed by presets.'
				messageClient(client, 'text-warning', text)
			end
		else
			text = text .. 'Error with user input!'
			messageClient(client, 'text-warning', text)
		end
	-- List presets
	elseif words[1] == 'plist' then
		for presetName, presetSettings in pairs(FG.settingsPresets) do
			local author = '[UNKNOWN]'
			if presetSettings.author ~= nil then
				author = presetSettings.author
			end
			local info = 'No information given.'
			if presetSettings.info ~= nil then
				info = presetSettings.info
			end
			text = text .. '"' .. presetName .. '"' .. ' by ' .. author .. ' - ' .. info ..'\n\n'
		end
		messageClient(client, 'text-command', string.sub(text, 1, #text - 2))
	-- Resets settings presets
	elseif words[1] == 'preset' then
		joinAllWordsAfterIndex(2, 1)
		if (words[2] == 'yes i am sure') then
			FG.settingsPresets = table.copy(FG.settingsPresetsDefault)
			text = text ..  'Settings presets have been reset to default.'
			messageClient(client, 'text-command', text)
			-- Save changes to config file
			saveSettingsPresets()
		else
			text = text .. 'Please type "/cfg preset yes i am sure" to acknowlegde that you are aware you are about to reset your settings presets save to the default, thus removing any custom settings preset you may have made. This cannot be undone.' 
			messageClient(client, 'popup', text)
		end
	-- Load a preset
	elseif words[1] == 'pload' then
		if FG.settingsPresets[words[2]] == nil then messageClient(client, 'text-warning', 'Preset does not exist!') return true end
		joinAllWordsAfterIndex(2, 1)
		loadSettingsPreset(FG.settingsPresets[words[2]])
		text = text .. table.print(FG.settings, true, true)
		messageClient(client, 'text-general', text)
	-- Saves to an existing preset
	elseif words[1] == 'psave' then
		joinAllWordsAfterIndex(2, 1)
		local allowSave = true
		-- Only save all the settings that differ from the default
		local settingsPreset = {}
		for settingName, settingValue in pairs(FG.settings) do
			if FG.settingsDefault[settingName] ~= settingValue then
				settingsPreset[settingName] = settingValue
			end
		end
		-- Warn user if their preset doesn't change any settings
		if table.size(settingsPreset) == 0 then
			text = text .. 'Your settings preset is just the default settings!' 
			messageClient(client, 'text-warning', text)
			text = ''
			
			allowSave = false
		end
		-- Make sure the setting exists and isn't a default preset
		--if FG.settingsPresetsDefault[words[2]] then
		--	text = text .. words[2] .. ' is a default preset and must not be overwritten.' 
		--	messageClient(client, 'text-warning', text)
		--	
		--	allowSave = false
		--end
		-- Do the saving
		if allowSave then
			FG.settingsPresets[words[2]] = settingsPreset
			text = text .. 'Your settings have been saved successfully to ' .. words[2] .. '.'
			messageClient(client, 'text-command', text)
		end
		-- Save changes to config file
		saveSettingsPresets()
	-- Delete a preset
	elseif (words[1] == 'pdelete') or (words[1] == 'premove') then
		joinAllWordsAfterIndex(2, 1)
		-- Make sure the setting exists and isn't a default preset
		if FG.settingsPresetsDefault[words[2]] then
			text = text .. words[2] .. ' is a default preset and cannot be deleted.' 
			messageClient(client, 'text-warning', text)
		elseif FG.settingsPresets[words[2]] then
			FG.settingsPresets[words[2]] = nil
			text = text .. 'The preset ' .. words[2] .. ' has been deleted.'
			messageClient(client, 'text-command', text)
		else
			text = text .. 'There is no settings preset named ' .. words[2] .. '.' 
			messageClient(client, 'text-warning', text)
		end
		-- Save changes to config file
		saveSettingsPresets()
	-- View a preset
	elseif words[1] == 'pview' then
		joinAllWordsAfterIndex(2, 1)
		text = text .. table.print(FG.settingsPresets[words[2]], true, true)
		messageClient(client, 'text-command', text)
	-- Lists received presets
	elseif words[1] == 'rlist' then
		for sender, settingsPresets in pairs(FG.settingsPresetsReceived) do
			local author = '[UNKNOWN]'
			if table.getValues(settingsPresets)[1].author ~= nil then
				author = table.getValues(settingsPresets)[1].author
			end
			local info = 'No information given.'
			if table.getValues(settingsPresets)[1].info ~= nil then
				info = table.getValues(settingsPresets)[1].info
			end
			text = text .. '"' .. table.getKeys(settingsPresets)[1] .. '"' .. ' by ' .. author .. ' - ' .. info ..'\n\n'
		end
		if (text == '') or (text == '\n') then
			text = text .. 'No presets have been submitted yet.\n\n'
		end
		messageClient(client, 'text-command', string.sub(text, 1, #text - 2))
	-- Loads a received preset
	elseif words[1] == 'rload' then
		if table.getValues(FG.settingsPresetsReceived[words[2]])[1] == nil then messageClient(client, 'text-warning', 'Preset does not exist!') return true end
		joinAllWordsAfterIndex(2, 1)
		loadSettingsPreset(table.getValues(FG.settingsPresetsReceived[words[2]])[1])
		text = text .. table.print(FG.settings, true, true)
		messageClient(client, 'text-command', text)
		-- Notifies client who sent the preset that it has been loaded
		local sender = findClientByUsername(words[2])
		if sender ~= nil then
			messageClient(sender, 'text-command', 'Your settings preset has been loaded in by the server.')
		end
	-- Views a received preset
	elseif words[1] == 'rview' then
		joinAllWordsAfterIndex(2, 1)
		text = text .. table.print(table.getValues(FG.settingsPresetsReceived[words[2]])[1], true, true)
		messageClient(client, 'text-command', text)
	-- Invalid command
	elseif (message == '/cfg') or (message == '/cfg ') then
		text = text .. 'Do "/cfg help" for a list of commands.'
		messageClient(client, 'text-command', text)
	else
		text = text .. ' is not a command! Do "/cfg help" for a list of commands.'
		messageClient(client, 'text-warning', text)
	end

    return true
end)

FG.loadedFiles['commands'] = true