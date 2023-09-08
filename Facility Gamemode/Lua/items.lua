Hook.Add("signalReceived.fgcomponent", "fgcomponent.receive", function(signal, connection)
    if connection.Name == "input" then
	
		local msgTxt = signal.value
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
		
		local output = FG
		while table.size(words) > 0 do
			local word = table.remove(words, 1)
			if string.sub(word, 1, 1) == '#' then word = tonumber(string.sub(word, 2, #word)) end
			output = output[word]
			if output == nil then break end
		end
		
        connection.Item.SendSignal(tostring(output), "output")
    end
end)

Hook.Add("wifiSignalTransmitted", "wifiModifyChannel", function (wifiComponent, signal, sentFromChat)
	local item = wifiComponent.Item
	local character
	if item.ParentInventory ~= nil then character = wifiComponent.Item.ParentInventory.Owner end
	
	if (not sentFromChat) or (item.ParentInventory == nil) or (character == nil) or (character.SpeciesName ~= 'Human') then return end
	
	if isCharacterTerrorist(character) then
		wifiComponent.Channel = 10
	elseif isCharacterNexpharma(character) then
		wifiComponent.Channel = 11
	else
		wifiComponent.Channel = 12
	end
	if SERVER then
		local prop = item.GetComponentString('WifiComponent').SerializableProperties[Identifier("Channel")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('WifiComponent')))
	end
end)

Hook.Add("handheldTrigger.use", "handheldTriggerUse", function (effect, deltaTime, item, targets, worldPosition)
	if (effect.user ~= nil) then
		local headset = effect.user.Inventory.GetItemAt(1)
		if headset == nil then
			headset = effect.user.Inventory.GetItemAt(8)
		end
		if (headset ~= nil) and (headset.GetComponentString('WifiComponent') ~= nil) then
			item.GetComponentString('WifiComponent').Channel = 0
			--item.GetComponentString('WifiComponent').Channel = headset.GetComponentString('WifiComponent').Channel
			if SERVER then
				local prop = item.GetComponentString('WifiComponent').SerializableProperties[Identifier("Channel")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('WifiComponent')))
			end
		else
			item.GetComponentString('WifiComponent').Channel = 0
			if SERVER then
				local prop = item.GetComponentString('WifiComponent').SerializableProperties[Identifier("Channel")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('WifiComponent')))
			end
		end
		--print('[!] Channel is ' .. tonumber(item.GetComponentString('WifiComponent').Channel))
		item.GetComponentString('WifiComponent').TransmitSignal(Signal('true'), false)
		-- Wifi explosion activation is done via lua
		for explosive in Item.ItemList do
			if (tostring(explosive.Prefab.Identifier) == 'wifiexplosive') and (explosive.ParentInventory == nil) and (not explosive.PhysicsBodyActive) and
			(explosive.GetComponentString('WifiComponent').Channel == item.GetComponentString('WifiComponent').Channel) and
			(distance(explosive.WorldPosition, item.WorldPosition) <= item.GetComponentString('WifiComponent').Range) then
				explosive.Condition = item.Condition - 101
			end
		end
	end
	
end)

--[[
Hook.Add("item.combine", "combineTime", function (item, deconstructor, characterUser, allowRemove)
	if characterUser == nil then return end
	
	if FG.lastGunReloaded == nil then FG.lastGunReloaded = {} end
	
	local combineTimes = {
		assaultriflemagazine = 1.6,
		smgmagazine = 0.85
	}
	
	local combineTime = combineTimes[item.Prefab.Identifier.Value]
	if (combineTime ~= nil) then
		print('[!] Combining ' .. tostring(item.Prefab.Identifier.Value))
		if FG.lastGunReloaded[characterUser] == nil then FG.lastGunReloaded[characterUser] = {} end
		FG.lastGunReloaded[characterUser][1] = {item}
		giveAfflictionCharacter(characterUser, 'reloading', combineTime)
	end
end)
--]]

Hook.Add("inventoryPutItem", "reloadTime", function (inventory, item, characterUser, index, removeItemBool)
	if characterUser == nil then return end
	
	if FG.lastGunReloaded == nil then FG.lastGunReloaded = {} end
	
	local reloadTimes = {
		jetlmg = 3.0 / 12,
		jetrifle = 2.5 / 12,
		jetsmgcompact = 1.5 / 1,
		jetsmg = 1.8 / 1,
		jetshotgun = 1.5 / 6,
		jetrevolver = 1.0 / 4,
		mercsrifle = 1.8 / 1,
		mercssniper = 1.8 / 4,
		mercssmg = 1.2 / 1,
		mercspistol = 0.6 / 1,
		stungun = 2.0 / 2
	}
	local ammoTypes = {
		riflebullet = 'round',
		shotgunshell = 'round',
		assaultriflemagazine = 'mag',
		smgmagazine = 'mag',
		stungundart = 'round'
	}
	local reloadTime = reloadTimes[inventory.Owner.Prefab.Identifier.Value]
	local ammoType = ammoTypes[item.Prefab.Identifier.Value]
	if (reloadTime ~= nil) and (ammoType ~= nil) and (
	(characterUser.CharacterHealth.GetAffliction('reloading', true) == nil) or 
	((FG.lastGunReloaded[characterUser][1] ~= item) and (ammoType == 'round')) or 
	(FG.lastGunReloaded[characterUser][2] ~= inventory.Owner)) then
		--print('[!] Reloading ' .. tostring(inventory.Owner.Prefab.Identifier.Value) .. ' with ' .. tostring(item.Prefab.Identifier.Value))
		FG.lastGunReloaded[characterUser] = {item, inventory.Owner}
		giveAfflictionCharacter(characterUser, 'reloading', reloadTime)
	end
	
end)

Hook.Add("item.use", "reloadTimeNoItemUsage", function (item, itemUser, targetLimb)
	if itemUser == nil then return end
	
	if itemUser.CharacterHealth.GetAffliction('reloading', true) ~= nil then
		return true
	end
end)

FG.loadedFiles['items'] = true