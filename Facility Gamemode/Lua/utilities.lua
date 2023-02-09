-- Get the size of a table (for tables that aren't like an array, #t won't work)
table.size = function (t)
	local size = 0
	for item in t do size = size + 1 end
	return size
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

-- Gives the character of the client with the username an amount of an item
function giveItem (username, identifier, amount)
	giveItemCharacter(findClientByUsername(username).Character, identifier, amount, nil)
end

-- Checks wheter a character is part of Nexpharma Corporation
function isCharacterNexpharma (character)
	if character.SpeciesName ~= 'human' and (character.HasJob('mechanic') or character.HasJob('engineer') or character.HasJob('securityofficer')) then
		return true
	else
		return false
	end
end

-- Checks wheter a character is part of Terrorist Faction
function isCharacterTerrorist (character)
	if character.SpeciesName ~= 'human' and (character.HasJob('captain') or character.HasJob('medicaldoctor') or character.HasJob('assistant')) then
		return true
	else
		return false
	end
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
	if msgType == 'blue' then
		local chatMessage = ChatMessage.Create("@", text, ChatMessageType.Radio, nil, nil)
		chatMessage.Color = Color(155, 200, 255, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	elseif msgType == 'popup' then
		Game.SendDirectChatMessage("",text, nil, ChatMessageType.MessageBox, client)
	elseif msgType == 'info' then
		Game.SendDirectChatMessage("",text, nil, ChatMessageType.ServerMessageBoxInGame, client, 'WorkshopMenu.InfoButton')
	end
end

global_loadedFiles['utilities'] = true