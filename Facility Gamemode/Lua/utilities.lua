-- Get the size of a table (for tables that aren't like an array, #t won't work)
table.size = function (t)
	local size = 0
	for item in t do size = size + 1 end
	return size
end

-- Custom method for nicely printing tables
table.print = function(t, output)
	local out = '{ '
	local first = true
	for key, value in pairs(t) do
		if not first then
			out = out .. ', '
		else
			first = false
		end
		if type(key) == 'userdata' then
			if not pcall(function ()
				out = out .. key.Name
			end) then
				if not pcall(function ()
					out = out .. key.Info.Name
				end) then
					out = out .. 'USERDATA'
				end
			end
		elseif type(key) == 'table' then
			out = out .. table.print(key, true)
		else
			out = out .. key
		end
		out = out .. ' = '
		if type(value) == 'userdata' then
			if not pcall(function ()
				out = out .. value.Name
			end) then
				if not pcall(function ()
					out = out .. value.Info.Name
				end) then
					out = out .. 'USERDATA'
				end
			end
		elseif type(value) == 'table' then
			out = out .. table.print(value, true)
		else
			out = out .. value
		end
	end
	out = out .. ' }'
	if not output then print(out) end
	return out
end

-- Shuffles a table (assumes it has an array-like structure)
function shuffleArray (array)
	local shuffledArray = {}
	local originalArray = {}
	for key, value in pairs(array) do
		originalArray[key] = value
	end
	while #originalArray > 0 do
		table.insert(shuffledArray, table.remove(originalArray, math.random(#originalArray)))
	end
	return shuffledArray
end

-- Checks distance between two vectors
function distance (v2a, v2b)
	return ((v2a.x-v2b.x)^2 + (v2a.y-v2b.y)^2)^0.5
end

-- Gives a certain amount of an item to a character
function giveItemCharacter (character, identifier, amount, slot)
	-- Give Item
	for n=1,(amount or 1) do 
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), character.Inventory, nil, nil, function (spawnedItem)
			if slot == nil then return end
			character.Inventory.TryPutItem(spawnedItem, slot, true, true, character, true, true)
		end)
	end
end

function giveAfflictionCharacter (character, identifier, amount)
	character.CharacterHealth.ApplyAffliction(character.AnimController.MainLimb, AfflictionPrefab.Prefabs[identifier].Instantiate(amount))
end

-- Gives the character of the client with the username an amount of an item
function giveItem (username, identifier, amount)
	giveItemCharacter(findClientByUsername(username).Character, identifier, amount, nil)
end

-- Checks wheter a character is a monster
function isCharacterMonster (character)
	if character.SpeciesName == 'Mantisadmin' or character.SpeciesName == 'Crawleradmin' or character.SpeciesName == 'Humanhusk' then
		return true
	else
		return false
	end
end

-- Checks wheter a character is part of Terrorist Faction
function isCharacterTerrorist (character)
	if character.SpeciesName == 'human' and (character.HasJob('mutatedmantis') or character.HasJob('mutatedcrawler') or character.HasJob('inmate') or character.HasJob('jet')) then
		return true
	else
		return false
	end
end

-- Checks wheter a character is part of Nexpharma Corporation
function isCharacterNexpharma (character)
	if character.SpeciesName == 'human' and (character.HasJob('repairmen') or character.HasJob('researcher') or character.HasJob('enforcerguard') or character.HasJob('mercs')) then
		return true
	else
		return false
	end
end

-- Checks wheter a character is part of staff
function isCharacterStaff (character)
	if character.SpeciesName == 'human' and (character.HasJob('repairmen') or character.HasJob('researcher')) and not global_militantPlayers[findClientByCharacter(character).Name] then
		return true
	else
		return false
	end
end

-- Returns first item found with the tag
function findItemsByTag (tag, alsoFromConnectedSubs)
	items = {}
	for item in Submarine.MainSub.GetItems(alsoFromConnectedSubs or false) do
		if item.HasTag(tag) then
			table.insert(items, item)
		end
	end
	return items
end

-- Returns the client whose client matches
function findClientByCharacter (character)
	for player in Client.ClientList do
		if player.Character == character then
			return player
		end
	end
	return nil
end

-- Returns the client whose username matches
function findClientByUsername (username)
	for player in Client.ClientList do
		if player.Name == username then
			return player
		end
	end
	return nil
end

-- Returns the character whose username matches
function findCharacterByUsername (username)
	for character in Character.CharacterList do
		if character.Name == username then
			return character
		end
	end
	return nil
end

-- Messages a message to a client
function messageClient (client, msgType, text)
	-- For other stuff
	if msgType == 'text-general' then
		local chatMessage = ChatMessage.Create('[General Info]', text, ChatMessageType.Server, nil, nil)
		chatMessage.Color = Color(180, 180, 200, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	-- For warnings
	elseif msgType == 'text-warning' then
		local chatMessage = ChatMessage.Create('[Warning]', text, ChatMessageType.Server, nil, nil)
		chatMessage.Color = Color(255, 0, 0, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	-- For ingame info
	elseif msgType == 'text-game' then
		local chatMessage = ChatMessage.Create('[Important Intel]', text, ChatMessageType.Server, nil, nil)
		chatMessage.Color = Color(255, 125, 100, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	-- For console commands
	elseif msgType == 'text-command' then
		local chatMessage = ChatMessage.Create('[Chat Command]', text, ChatMessageType.Server, nil, nil)
		chatMessage.Color = Color(190, 215, 255, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	-- Big popup
	elseif msgType == 'popup' then
		Game.SendDirectChatMessage(msgType,text, nil, ChatMessageType.MessageBox, client)
		-- Also message user (like with text-general msgType)
		messageClient(client, 'text-general', text)
	-- Subtle popup
	elseif msgType == 'info' then
		Game.SendDirectChatMessage(msgType,text, nil, ChatMessageType.ServerMessageBoxInGame, client, 'WorkshopMenu.InfoButton')
		-- Also message user (like with text-general msgType)
		messageClient(client, 'text-general', text)
	end
end

-- Messages all clients using messageClient
function messageAllClients (msgType, text)
	for client in Client.ClientList do
		messageClient(client, msgType, text)
	end
end


-- Spawns a human with a job somewhere
function spawnHuman (client, job, pos)
	local info
	if client.CharacterInfo == nil then
		info = CharacterInfo("human", client.Name)
	else
		info = client.CharacterInfo
	end
	info.Job = Job(JobPrefab.Get(job))
	local character = Character.Create('human', pos, client.Name, info, 0, true, false)
	
	character.GiveJobItems()
	client.SetClientCharacter(character)
	
	return character
end

c = Client.ClientList[1]

global_loadedFiles['utilities'] = true
