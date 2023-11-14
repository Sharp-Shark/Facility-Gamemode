-- Get the size of a table (for tables that aren't like an array, #t won't work)
table.size = function (t)
	local size = 0
	for item in t do size = size + 1 end
	return size
end

-- Custom method for nicely printing tables
table.print = function(t, output, long, depth, chars)
	if t == nil then
		out = 'nil'
		if not output then print(out) end
		return out
	end
	
	local chars = chars or {}
	local quoteChar = chars['quote'] or '"'
	local lineChar = chars['line'] or '\n'
	local spaceChar = chars['space'] or '    '
	local depth = depth or 0
	local long = long or -1
	
	local out = '{'
	if long >= 0 then
		out = out .. lineChar
	else
		out = out .. ' '
	end
	local first = true
	for key, value in pairs(t) do
		if not first then
			if long >= 0 then
				out = out .. ',' .. lineChar
			else
				out = out .. ', '
			end
		else
			first = false
		end
		if long >= 0 then
			out = out .. string.rep(spaceChar, (depth + 1) * long)
		end
		if type(key) == 'function' then
			out = out .. 'FUNCTION'
		elseif type(key) == 'boolean' then
			if key then
				out = out .. 'true'
			else
				out = out .. 'false'
			end
		elseif type(key) == 'userdata' then
			if not pcall(function ()
				out = out .. 'UD:' ..key.Name
			end) then
				if not pcall(function ()
					out = out .. key.Info.Name
				end) then
					out = out .. 'USERDATA'
				end
			end
		elseif type(key) == 'table' then
			out = out .. table.print(key, true, long, depth + 1, chars)
		elseif type(key) == 'string' then
			out = out .. quoteChar .. key .. quoteChar
		else
			out = out .. key
		end
		out = out .. ' = '
		if type(value) == 'function' then
			out = out .. 'FUNCTION'
		elseif type(value) == 'boolean' then
			if value then
				out = out .. 'true'
			else
				out = out .. 'false'
			end
		elseif type(value) == 'userdata' then
			if not pcall(function ()
				out = out .. 'UD:' ..value.Name
			end) then
				if not pcall(function ()
					out = out .. value.Info.Name
				end) then
					out = out .. 'USERDATA'
				end
			end
		elseif type(value) == 'table' then
			out = out .. table.print(value, true, long, depth + 1, chars)
		elseif type(value) == 'string' then
			out = out .. quoteChar .. value .. quoteChar
		else
			out = out .. value
		end
	end
	if long >= 0 then
		out = out .. lineChar .. string.rep(spaceChar, depth * long) .. '}'
	else
		out = out .. ' }'
	end
	if not output then print(out) end
	return out
end

-- Copies a table (clones it)
table.copy = function(t)
  local u = { }
  for key, value in pairs(t) do u[key] = value end
  return setmetatable(u, getmetatable(t))
end

-- Returns a merge of two tables (values of tbl1 take preference)
table.merge = function(tbl1, tbl2)
	local tbl = {}
	for key, value in pairs(tbl2) do
		tbl[key] = value
	end
	for key, value in pairs(tbl1) do
		tbl[key] = value
	end
	return tbl
end

-- Checks if a string has another string
string.has = function(strMain, strSub)
	local build = ''
	local letter = ''
	for letterCount = 1, #strMain do
		letter = string.sub(strMain, letterCount, letterCount)
		if letter == string.sub(strSub, #build + 1, #build + 1) then
			build = build .. letter
		else
			build = ''
		end
		if build == strSub then
			return true
		end
	end
	return false
end

-- Is like python's split
string.split = function(strMain, separator)
	local tbl = {}
	local build = ''
	local letter = ''
	local match = ''
	for letterCount = 1, #strMain do
		letter = string.sub(strMain, letterCount, letterCount)
		build = build .. letter
		if string.sub(separator, #match + 1, #match + 1) == letter then
			match = match .. letter
		else
			match = ''
		end
		if (match == separator) or (letter == separator) then
			table.insert(tbl, string.sub(build, 1, #build - #separator))
			build = ''
			match = ''
		end
	end
	table.insert(tbl, build)
	return tbl
end

-- My version of string.format
string.replace = function(str, tbl)
	local formatted = ''
	local build = ''
	local open = false
	for letterCount = 1, #str do
		local letter = string.sub(str, letterCount, letterCount)
		if (letter == '}') and open then
			open = false
			if tbl[build] == nil then
				formatted = formatted .. 'nil'
			elseif tbl[build] == true then
				formatted = formatted .. 'true'
			elseif tbl[build] == false then
				formatted = formatted .. 'false'
			elseif type(tbl[build]) == 'table' then
				formatted = formatted .. table.print(tbl[build], true)
			elseif type(tbl[build]) == 'string' then
				formatted = formatted .. tbl[build]
			else
				formatted = formatted .. tostring(tbl[build])
			end
			build = ''
		elseif open then
			build = build .. letter
		elseif (letter == '{') then
			open = true
		else
			formatted = formatted .. letter
		end
	end
	return formatted
end

-- Localizes a string
string.localize = function(key, tbl, language)
	local lang = tostring(language)
	if FG.localizations[lang] == nil then lang = FG.language end
	if FG.localizations[lang] == nil then lang = 'English' end
	local str = FG.localizations[lang][key]
	if (str == nil) then str = FG.localizations['English'][key] end
	if tbl == nil then
		return str
	else
		return string.replace(str, tbl)
	end
end

-- Checks if a table has an item that matches the one given
table.has = function(tbl, itemBeingSearched)
	for item in tbl do
		if item == itemBeingSearched then
			return true
		end
	end
	return false
end

-- Returns a table sequence of a table's keys
table.getKeys = function(tbl)
	if tbl == nil then return {} end
	local toReturn = {}
	for key, value in pairs(tbl) do
		table.insert(toReturn, key)
	end
	return toReturn
end

-- Returns a table sequence of a table's values
table.getValues = function(tbl)
	if tbl == nil then return {} end
	local toReturn = {}
	for key, value in pairs(tbl) do
		table.insert(toReturn, value)
	end
	return toReturn
end

-- Linear intepolation
function lerp (n, a, b)
	return a*(1-n) + b*n
end

-- Lerp colors
function lerpColor (n, a, b)
	return Color(Byte(lerp(n, a.R, b.R)), Byte(lerp(n, a.G, b.G)), Byte(lerp(n, a.B, b.B)), Byte(lerp(n, a.A, b.A)))
end

-- Takes number and returns string
function numberToTime (n, spacing, showH, showM, showS)
	local seconds = n
	if n < 0 then
		seconds = 0
	end
	local minutes = math.floor(seconds / 60)
	local hours = math.floor(minutes / 60)
	seconds = math.floor(seconds - minutes * 60 + 0.5)
	minutes = minutes - hours * 60
	
	local text = ''
	if ((hours > 0) or (showH == 1)) and (showH ~= -1) then
		text = text .. tostring(hours) .. string.rep(' ', spacing) .. 'h' .. string.rep(' ', spacing)
	end
	if ((minutes > 0) or ((hours > 0) and (seconds > 0)) or (showM == 1)) and (showM ~= -1) then
		text = text .. tostring(minutes) .. string.rep(' ', spacing) .. 'min' .. string.rep(' ', spacing)
	end
	if ((seconds > 0) or (showS == 1)) and (showS ~= -1) then
		text = text .. tostring(seconds) .. string.rep(' ', spacing) .. 's' .. string.rep(' ', spacing)
	end
	
	if text == '' then
		return '0' .. string.rep(' ', spacing) .. 's' .. string.rep(' ', spacing)
	end
	
	return text
end

-- Adds 0s in front of a number so it has the desired length
function numberAddZeroInFront (n, length)
	local str = tostring(n)
	
	if (length - #str) > 0 then
		if string.sub(str, 1, 1) == '-' then
			str = '-' .. string.rep('0', length - #str) .. string.sub(str, 2)
		else
			str = string.rep('0', length - #str) .. str
		end
	end
	
	return str
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

-- Checks distance between two vectors (circle collision check)
function distance (v2a, v2b)
	return ((v2a.x-v2b.x)^2 + (v2a.y-v2b.y)^2)^0.5
end

-- Checks distance between two vectors with horizontal and vertical multipliers (ellipse collision check)
function distanceEllipse (v2a, v2b, mult)
	return (( (v2a.x-v2b.x)*mult.x )^2 + ( (v2a.y-v2b.y)*mult.y )^2)^0.5
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

-- Gives an affliction to a character
function giveAfflictionCharacter (character, identifier, amount)
	character.CharacterHealth.ApplyAffliction(character.AnimController.MainLimb, AfflictionPrefab.Prefabs[identifier].Instantiate(amount))
end

-- Gives the character of the client with the username an amount of an item
function giveItem (username, identifier, amount)
	giveItemCharacter(findClientByUsername(username).Character, identifier, amount, nil)
end

-- Checks whether a character is a monster
function isCharacterMonster (character)
	--if character.SpeciesName == 'Mantisadmin' or character.SpeciesName == 'Crawleradmin' or character.SpeciesName == 'Mantisadmin_hatchling' or character.SpeciesName == 'Crawleradmin_hatchling' or character.SpeciesName == 'Humanhusk' or character.SpeciesName == 'Humangoblin' or character.SpeciesName == 'Humantroll' then
	if character.SpeciesName ~= 'human' then
		return true
	else
		return false
	end
end

-- Checks whether a character is part of Terrorist Faction
function isCharacterTerrorist (character)
	if character.SpeciesName == 'human' and (character.HasJob('inmate') or character.HasJob('jet')) then
		return true
	else
		return false
	end
end

-- Checks whether a character is part of Nexpharma Corporation
function isCharacterNexpharma (character)
	if character.SpeciesName == 'human' and (character.HasJob('overseer') or character.HasJob('repairmen') or character.HasJob('researcher') or character.HasJob('enforcerguard') or character.HasJob('eliteguard') or character.HasJob('mercs')) then
		return true
	else
		return false
	end
end

-- Checks whether a character is part of staff
function isCharacterStaff (character)
	if character.SpeciesName == 'human' and (character.HasJob('overseer') or character.HasJob('repairmen') or character.HasJob('researcher')) then
		return true
	else
		return false
	end
end

-- Checks whether a character is a guard
function isCharacterGuard (character)
	if character.SpeciesName == 'human' and (character.HasJob('enforcerguard') or character.HasJob('eliteguard')) then
		return true
	else
		return false
	end
end

-- Checks whether a character is a civilian
function isCharacterCivilian (character)
	if character.SpeciesName == 'human' and (isCharacterStaff(character) or character.HasJob('inmate')) then
		return true
	else
		return false
	end
end

-- Checks whether a client can or cannot respawn
function canClientRespawn (client)
	if (client.Character == nil or client.Character.IsDead) and (not FG.spectators[client.Name]) and (not client.UsingFreeCam) and (not FG.paranormal.noRespawn[client]) then
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

-- Find waypoints by job
function findWaypointsByJob (job)
	local waypoints = {}
	for waypoint in Submarine.MainSub.GetWaypoints(false) do
		if (waypoint.AssignedJob ~= nil) and (waypoint.AssignedJob.Identifier == job) then
			table.insert(waypoints, waypoint)
		end
	end
	if (job == '') and (table.size(waypoints) < 1) then
		for waypoint in Submarine.MainSub.GetWaypoints(false) do
			if waypoint.SpawnType == SpawnType.Human then
				table.insert(waypoints, waypoint)
			end
		end
		
	end
	return waypoints
end

-- Find one random waypoint of a job
function findRandomWaypointByJob (job)
	local waypoints = findWaypointsByJob(job)
	return waypoints[math.random(#waypoints)]
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
function messageClient (client, msgType, text, sender)
	if CLIENT then return end
	-- Ignore means don't say anything
	if msgType == 'ignore' then
		return
	-- For other stuff
	elseif msgType == 'text-general' then
		local chatMessage = ChatMessage.Create('[General Info]', text, ChatMessageType.Server, nil, nil)
		chatMessage.Color = Color(180, 180, 200, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	-- For warnings
	elseif msgType == 'text-warning' then
		local chatMessage = ChatMessage.Create('[Warning]', text, ChatMessageType.Server, nil, nil)
		chatMessage.Color = Color(255, 75, 75, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	-- For ingame info
	elseif msgType == 'text-game' then
		local chatMessage = ChatMessage.Create('[Important Intel]', text, ChatMessageType.Server, nil, nil)
		chatMessage.Color = Color(250, 125, 75, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	-- For console commands
	elseif msgType == 'text-command' then
		local chatMessage = ChatMessage.Create('[Chat Command]', text, ChatMessageType.Server, nil, nil)
		chatMessage.Color = Color(190, 215, 255, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	-- Ghost chat
	elseif msgType == 'chat-ghost' then
		local chatMessage = ChatMessage.Create(sender, text, ChatMessageType.Server, nil, nil)
		chatMessage.Color = Color(155, 200, 255, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	-- Monster chat
	elseif msgType == 'chat-monster' then
		local chatMessage = ChatMessage.Create(sender, text, ChatMessageType.Server, nil, nil)
		chatMessage.Color = Color(255, 200, 155, 255)
		Game.SendDirectChatMessage(chatMessage, client)
	-- Regular chat
	elseif msgType == 'chat-regular' then
		local chatMessage = ChatMessage.Create(sender, text, ChatMessageType.Default, nil, nil)
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

-- Messages a message to some clients using messageClient
function messageClients (clients, msgType, text, sender)
	for client in clients do
		if type(text) == 'table' then
			messageClient(client, msgType, string.localize(text[1], text[2], client.Language), sender)
		else
			messageClient(client, msgType, text, sender)
		end
	end
end

-- Messages all clients using messageClients
function messageAllClients (msgType, text, sender)
	messageClients(Client.ClientList, msgType, text, sender)
end


-- Spawns a human with a job somewhere
function spawnHuman (client, job, pos, name, subclass)
	local info
	if name ~= nil then
		info = CharacterInfo('human', name)
	elseif client == nil then
		info = CharacterInfo('human', CharacterInfo('human', 'John Doe').GetRandomName(1))
	elseif client.CharacterInfo == nil then
		info = CharacterInfo('human', client.Name)
	else
		info = client.CharacterInfo
	end
	
	local jobPrefab = JobPrefab.Get(job)
	if subclass == nil then
		info.Job = Job(jobPrefab)
		info.Job.Variant = math.random(jobPrefab.Variants) - 1
	else
		info.Job = Job(jobPrefab)
		info.Job.Variant = subclass
	end
	if info.Job.Variant > (jobPrefab.Variants - 1) then info.Job.Variant = (jobPrefab.Variants - 1) end
	
	local character
	if client == nil then
		character = Character.Create('human', pos, info.Name, info, 0, false, true)
	else
		character = Character.Create('human', pos, info.Name, info, 0, true, false)
	end
	
	character.GiveJobItems()
	if client ~= nil then
		client.SetClientCharacter(character)
	end
	
	return character
end

-- Spawns a goblin with a job somewhere
function spawnHumangoblin (client, pos, name, isTroll)
	-- Is a troll?
	local speciesName = 'Humangoblin'
	if isTroll then speciesName = 'Humantroll' end
	
	local info
	if name ~= nil then
		info = CharacterInfo(speciesName, name)
	elseif client == nil then
		info = CharacterInfo(speciesName, CharacterInfo(speciesName, 'John Doe').GetRandomName(1))
	elseif client.CharacterInfo == nil then
		info = CharacterInfo(speciesName, client.Name)
	else
		--info = client.CharacterInfo
		info = CharacterInfo(speciesName, client.Name)
	end
	info.Job = Job(JobPrefab.Get('greenskinjob'))
	
	local character
	if client == nil then
		character = Character.Create(speciesName, pos, info.Name, info, 0, false, true)
	else
		character = Character.Create(speciesName, pos, info.Name, info, 0, true, false)
	end
	
	--character.GiveJobItems()
	if client ~= nil then
		client.SetClientCharacter(character)
	end
	
	return character
end

-- Spawns a goblin with a job somewhere
function spawnHumanghost (client, pos, name)
	-- Is a troll?
	local speciesName = 'Humanghost'
	--if isTroll then speciesName = 'Humantroll' end
	
	local info
	if name ~= nil then
		info = CharacterInfo(speciesName, name)
	elseif client == nil then
		info = CharacterInfo(speciesName, CharacterInfo(speciesName, 'John Doe').GetRandomName(1))
	elseif client.CharacterInfo == nil then
		info = CharacterInfo(speciesName, client.Name)
	else
		--info = client.CharacterInfo
		info = CharacterInfo(speciesName, client.Name)
	end
	info.Job = Job(JobPrefab.Get('spiritjob'))
	
	local character
	if client == nil then
		character = Character.Create(speciesName, pos, info.Name, info, 0, false, true)
	else
		character = Character.Create(speciesName, pos, info.Name, info, 0, true, false)
	end
	
	--character.GiveJobItems()
	if client ~= nil then
		client.SetClientCharacter(character)
	end
	
	return character
end

-- Finds lights
function findLights ()
	if table.size(FG.lightColors) ~= 0 then return end
	local exemptItemIdentifiers = {'flare', 'alienflare', 'glowstick', 'flashlight', 'underwaterscooter', 'nexsuit', 'pucs'}
	FG.lightColors = {}
	FG.lightColorsLatest = {}
	for item in Item.ItemList do
		local component = item.GetComponentString('LightComponent')
		if (component ~= nil) and (component.lightColor ~= nil) and (not item.HasTag('fg_alwayson')) and (component.range > 100) and (not table.has(exemptItemIdentifiers, item.Prefab.Identifier)) and (not string.has(tostring(item.Prefab.Identifier), 'divingsuit')) then
			FG.lightColors[item] = component.lightColor
			FG.lightColorsLatest[item] = component.lightColor
		end
	end
	return FG.lightColors
end

-- Set lights to a specific color
function setLights (color)
	local color = color or Color()
	findLights()
	for item, lightColor in pairs(FG.lightColors) do
		item.GetComponentString('LightComponent').lightColor = color
		if SERVER then
			local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
		end
		FG.lightColorsLatest[item] = color
	end
end

-- Restore lights to original state
function resetLights ()
	findLights()
	for item, lightColor in pairs(FG.lightColors) do
		item.GetComponentString('LightComponent').lightColor = lightColor
		if SERVER then
			local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
		end
		FG.lightColorsLatest[item] = lightColor
	end
end

-- Set lights to a specific color (with linear interpolation)
function setLightsSmooth (color, time)
	local color = color or Color()
	local time = time or 50
	findLights()
	for n = 0, 100 do
		Timer.Wait(function ()
			local m = n/100
			for item, lightColor in pairs(FG.lightColors) do
				local lerpedColor = lerpColor(m, FG.lightColorsLatest[item], color)
				item.GetComponentString('LightComponent').lightColor = lerpedColor
				if SERVER then
					local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
					Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
				end
				if m == 1 then
					FG.lightColorsLatest[item] = lerpedColor
				end
			end
		end, time * n)
	end
end

-- Restore lights to original state (with linear interpolation)
function resetLightsSmooth (time)
	local time = time or 50
	findLights()
	for n = 0, 100 do
		Timer.Wait(function ()
			local m = n/100
			for item, lightColor in pairs(FG.lightColors) do
				local lerpedColor = lerpColor(m, FG.lightColorsLatest[item], lightColor)
				item.GetComponentString('LightComponent').lightColor = lerpedColor
				if SERVER then
					local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
					Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
				end
				if m == 1 then
					FG.lightColorsLatest[item] = lerpedColor
				end
			end
		end, time * n)
	end
end

-- Function currently crashes the game! Do not use!
function changeDescription(item, description)
	item.Description = description
	local prop = item.SerializableProperties[Identifier("Description")]
	Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item))
end

-- Set non-surface zone lights to a specific color
function setNonSurfaceLights (color)
	findLights()
	-- Find which items are in surface
	local items = {}
	for item in findItemsByTag('fg_surface') do
		rect = item.WorldRect
		for item, lightColor in pairs(FG.lightColors) do
			-- Item center is at its top left corner
			if math.abs(item.WorldPosition.X - rect.X - rect.Width/2) <= rect.Width/2 and math.abs(item.WorldPosition.Y - rect.Y + rect.Height/2) <= rect.Height/2 then
				items[item] = true
			elseif not items[item] then
				items[item] = false
			end
		end
	end
	
	local color = color or Color()
	for item, lightColor in pairs(FG.lightColors) do
		if (not items[item]) and (item.Submarine == Submarine.MainSub) then
			item.GetComponentString('LightComponent').lightColor = color
			if SERVER then
				local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
			end
			FG.lightColorsLatest[item] = color
		end
	end
end

-- Set non-surface zone lights to a specific color (with linear interpolation)
function setNonSurfaceLightsSmooth (color, time)
	findLights()
	-- Find which items are in surface
	local items = {}
	for item in findItemsByTag('fg_surface') do
		rect = item.WorldRect
		for item, lightColor in pairs(FG.lightColors) do
			-- Item center is at its top left corner
			if math.abs(item.WorldPosition.X - rect.X - rect.Width/2) <= rect.Width/2 and math.abs(item.WorldPosition.Y - rect.Y + rect.Height/2) <= rect.Height/2 then
				items[item] = true
			elseif not items[item] then
				items[item] = false
			end
		end
	end
	
	local color = color or Color()
	local time = time or 50
	for n = 0, 100 do
		Timer.Wait(function ()
			local items = items
			local m = n/100
			for item, lightColor in pairs(FG.lightColors) do
				if (not items[item]) and (item.Submarine == Submarine.MainSub) then
					local lerpedColor = lerpColor(m, FG.lightColorsLatest[item], color)
					item.GetComponentString('LightComponent').lightColor = lerpedColor
					if SERVER then
						local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
						Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
					end
					if m == 1 then
						FG.lightColorsLatest[item] = lerpedColor
					end
				end
			end
		end, time * n)
	end
end

-- Restore surface zone lights to original state (with linear interpolation)
function resetSurfaceLightsSmooth (time)
	findLights()
	-- Find which items are in surface
	local items = {}
	for item in findItemsByTag('fg_surface') do
		rect = item.WorldRect
		for item, lightColor in pairs(FG.lightColors) do
			-- Item center is at its top left corner
			if math.abs(item.WorldPosition.X - rect.X - rect.Width/2) <= rect.Width/2 and math.abs(item.WorldPosition.Y - rect.Y + rect.Height/2) <= rect.Height/2 then
				items[item] = true
			elseif not items[item] then
				items[item] = false
			end
		end
	end
	
	local time = time or 50
	for n = 0, 100 do
		Timer.Wait(function ()
			local items = items
			local m = n/100
			for item, lightColor in pairs(FG.lightColors) do
				if items[item] then
					local lerpedColor = lerpColor(m, FG.lightColorsLatest[item], lightColor)
					item.GetComponentString('LightComponent').lightColor = lerpedColor
					if SERVER then
						local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
						Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
					end
					if m == 1 then
						FG.lightColorsLatest[item] = lerpedColor
					end
				end
			end
		end, time * n)
	end
end

-- Enables or disables a light
function setLightState (item, state)
	item.GetComponentString('LightComponent').isOn = state
	if SERVER then
		local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("IsOn")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
	end
end

-- Opens or closes a door
function setDoorState (item, state)
	item.GetComponentString('Door').isOpen = state
	if SERVER then
		local prop = item.GetComponentString('Door').SerializableProperties[Identifier("IsOpen")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('Door')))
	end
end

-- Sets the water level of a hull
-- THIS FUNCTION IS STILL BEING WORKED ON!!!
function setHullWater (hull, amount)
	hull.WaterVolume = amount
	if SERVER and false then
		local prop = hull.SerializableProperties[Identifier("WaterVolume")]
		Networking.CreateEntityEvent(hull, Item.ChangePropertyEventData(prop))
	end
end

-- Wraps a function like in Python
function wrapFunction (func, prefix, suffix)
	local toWrap = func
	local prefix = prefix or (function () return end)
	local suffix = suffix or (function () return end)
	return function (...) prefix() toWrap(...) suffix() end
end

FG.loadedFiles['utilities'] = true