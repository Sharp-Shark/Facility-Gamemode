-- Data
FG.paranormal = {
	actions = {}
}

-- A reset function that is to be called at the start of a round
FG.paranormal.reset = function ()
	FG.paranormal.lights = {}
	FG.paranormal.doors = {}
	FG.paranormal.clients = {}
	FG.paranormal.noRespawn = {}
end

-- Adds client data
FG.paranormal.registerClient = function (client)
	if (client == nil) or (FG.paranormal.clients[client] ~= nil) then return end

	FG.paranormal.clients[client] = {}
	FG.paranormal.clients[client].power = 0
	FG.paranormal.clients[client].level = 0
	if (FG.playerRole[client.Name] == 'monster') or (FG.settings.ghosts == 'poltergeist') then FG.paranormal.clients[client].level = 1 end
	FG.paranormal.clients[client].xp = 0
	FG.paranormal.clients[client].reward = {pos = nil, range = nil, duration = 0, rewarded = 0}
	FG.paranormal.clients[client].getPowerCap = function () return FG.paranormal.getClientPowerCap(FG.paranormal.clients[client]) end
	FG.paranormal.clients[client].getXpNeeded = function () return FG.paranormal.getClientXpNeeded(FG.paranormal.clients[client]) end
end

-- Client getters
FG.paranormal.getClientPowerCap = function (clientData)
	return clientData.level * 18 + 10
end
FG.paranormal.getClientXpNeeded = function (clientData)
	local xpTable = {
		[1] = 400,
		[2] = 700,
		[3] = 900,
		[4] = 1000
	}
	local xpNeeded = xpTable[clientData.level]
	if xpNeeded == nil then
		return 0
	else
		return xpNeeded
	end
end

-- Setup a reward for an action
FG.paranormal.setupReward = function (client, pos, range, duration)
	if FG.paranormal.clients[client].level < 1 then return end
	FG.paranormal.clients[client].reward.pos = pos
	FG.paranormal.clients[client].reward.range = range
	FG.paranormal.clients[client].reward.duration = duration
end

-- An update function that is to be called every so often inside of a think hook
FG.paranormal.update = function ()
	for light, _ in pairs(FG.paranormal.lights) do
		FG.paranormal.lights[light] = FG.paranormal.lights[light] - 0.5
		if FG.paranormal.lights[light] <= 0 then
			light.GetComponentString('LightComponent').isOn = true
			FG.paranormal.lights[light] = nil
		end
	end
	for door, _ in pairs(FG.paranormal.doors) do
		FG.paranormal.doors[door] = FG.paranormal.doors[door] - 0.5
		if FG.paranormal.doors[door] <= 0 then
			door.GetComponentString('Door').IsJammed = false
			FG.paranormal.doors[door] = nil
		end
	end
	for client in Client.ClientList do
		if (FG.paranormal.clients[client] == nil) and (client.SpectatePos ~= nil) then
			FG.paranormal.registerClient(client)
		end
	end
	for client, _ in pairs(FG.paranormal.clients) do
		if client.SpectatePos ~= nil then
			if (FG.paranormal.clients[client].level < 1) and (FG.settings.ghosts == 'poltergeist') then
				FG.paranormal.clients[client].level = 1
			end
			-- Increase power
			FG.paranormal.clients[client].power = FG.paranormal.clients[client].power + (FG.paranormal.clients[client].level + 1) * 0.25
			if FG.paranormal.clients[client].power > FG.paranormal.clients[client].getPowerCap() then
				FG.paranormal.clients[client].power = FG.paranormal.clients[client].getPowerCap()
			end
			-- Update reward
			if FG.paranormal.clients[client].reward.duration > 0 then
				FG.paranormal.clients[client].reward.duration = FG.paranormal.clients[client].reward.duration - 0.5
				if FG.paranormal.clients[client].reward.duration <= 0 then
					if FG.paranormal.clients[client].reward.rewarded > 0 then
						messageClient (client, 'text-command', string.localize('booGainedXP', {xp = FG.paranormal.clients[client].reward.rewarded}, client.Language), nil)
					end
					FG.paranormal.clients[client].reward.duration = 0
					FG.paranormal.clients[client].reward.rewarded = 0
				end
			end
			-- Level up
			if (FG.paranormal.clients[client].level < 5) and (FG.paranormal.clients[client].level > 0) then
				FG.paranormal.clients[client].xp = FG.paranormal.clients[client].xp + 0.5
				if FG.paranormal.clients[client].xp >= FG.paranormal.clients[client].getXpNeeded() then
					FG.paranormal.clients[client].level = FG.paranormal.clients[client].level + 1
					FG.paranormal.clients[client].xp = 0
					FG.paranormal.clients[client].power = FG.paranormal.clients[client].getPowerCap()
					messageClient (client, 'text-command', string.localize('booLevelUp', {level = FG.paranormal.clients[client].level}, client.Language), nil)
				end
			else
				FG.paranormal.clients[client].xp = 0
			end
		else
			if (client.Character ~= nil) and (client.Character.SpeciesName ~= 'Humanghost') then
				FG.paranormal.clients[client].power = 0
			end
		end
	end
end

-- Executes an action
FG.paranormal.doAction = function (client, action, data)
	-- Get position action will occur at
	local pos = client.SpectatePos

	-- Register client
	FG.paranormal.registerClient(client)

	-- Guard clauses
	if (not Game.RoundStarted) or (pos == nil) or (action.hide) or (action.poltergeistOnly and FG.settings.ghosts ~= 'poltergeist') or (FG.settings.ghosts == 'disabled') or (FG.paranormal.clients[client].level < action.levelNeeded) then return end
	
	if data.pos ~= nil then pos = data.pos end
	
	-- Execute action and if it returns true (was succesful) then deduct cost from client points
	if (FG.paranormal.clients[client].power < 0) and (not action.free) then
		messageClient (client, 'text-command', string.localize('booPowerNeeded', {power = (0 - FG.paranormal.clients[client].power)}, client.Language), nil)
	elseif action.script(client, pos, data) then
		local cost = action.cost
		if action.free then cost = 0 end
		FG.paranormal.clients[client].power = FG.paranormal.clients[client].power - cost
		if not action.noMessage then messageClient (client, 'text-command', string.localize('booPowerLeft', {power = FG.paranormal.clients[client].power}, client.Language), nil) end
	else
		if not action.noMessage then messageClient (client, 'text-command', string.localize('booActionFailed', nil, client.Language), nil) end
	end

	return true
end

-- Info - tells info to user
FG.paranormal.actions.info = {name = 'info', levelNeeded = 0, cost = 0, noMessage = true, free = true, script = function (client, pos, data)
	messageClient(client, 'text-command', '/boo: pwr:' .. tostring(FG.paranormal.clients[client].power) .. '/' .. tostring(FG.paranormal.clients[client].getPowerCap()) .. ', lvl:' .. tostring(FG.paranormal.clients[client].level) .. '/5, xp:' .. tostring(FG.paranormal.clients[client].xp) .. '/' .. tostring(FG.paranormal.clients[client].getXpNeeded()) .. '.', nil)
	
	return true
end}

-- Respawn - toggles whether client will respawn
FG.paranormal.actions.respawn = {name = 'respawn', levelNeeded = 1, cost = 0, noMessage = true, free = true, script = function (client, pos, data)
	if FG.paranormal.noRespawn[client] then
		FG.paranormal.noRespawn[client] = nil
		messageClient(client, 'text-command', string.localize('booRespawnEnabled', nil, client.Language), nil)
	else
		FG.paranormal.noRespawn[client] = true
		messageClient(client, 'text-command', string.localize('booRespawnDisabled', nil, client.Language), nil)
	end
	
	return true
end}

-- Blackout - turns off all lights in a radius
FG.paranormal.actions.blackout = {name = 'blackout', levelNeeded = 0, cost = 10, script = function (client, pos, data)
	findLights()
	-- Get targets of action
	local targets = {}
	local radius = 300 + 100 * FG.paranormal.clients[client].level
	for item in Item.ItemList do
		if FG.lightColors[item] ~= nil then
			local dist = distance(pos, item.WorldPosition)
			if dist < radius then 
				table.insert(targets, item)
			end
		end
	end
	
	if table.size(targets) == 0 then
		return false
	end
	
	for target in targets do
		FG.paranormal.lights[target] = 10 + 1 * FG.paranormal.clients[client].level
		setLightState(target, false)
	end
	
	FG.paranormal.setupReward(client, pos, radius * 2, 15 + 1 * FG.paranormal.clients[client].level)
	
	return true
end}

-- Opens - Opens and locks the neearest door
FG.paranormal.actions.open = {name = 'open', levelNeeded = 0, cost = 15, script = function (client, pos, data)
	-- Get target of action
	local target = nil
	local radius = 400
	for item in Item.ItemList do
		if (not item.NonInteractable) and (item.GetComponentString('Door') ~= nil) then
			local dist = distance(pos, item.WorldPosition)
			if dist < radius then 
				target = item
				radius = dist
			end
		end
	end
	
	if target == nil then
		return false
	end
	
	FG.paranormal.doors[target] = 5 + 1 * FG.paranormal.clients[client].level
	target.GetComponentString('Door').IsJammed = true
	setDoorState(target, true)

	local pos = target.WorldPosition

	FG.paranormal.setupReward(client, pos, 1500, 10 + 1 * FG.paranormal.clients[client].level)
	
	return true
end}

-- Close - closes and locks the neearest door
FG.paranormal.actions.close = {name = 'close', levelNeeded = 0, cost = 20, script = function (client, pos, data)
	-- Get target of action
	local target = nil
	local radius = 400
	for item in Item.ItemList do
		if (not item.NonInteractable) and (item.GetComponentString('Door') ~= nil) then
			local dist = distance(pos, item.WorldPosition)
			if dist < radius then 
				target = item
				radius = dist
			end
		end
	end
	
	if target == nil then
		return false
	end
	
	FG.paranormal.doors[target] = 5 + 1 * FG.paranormal.clients[client].level
	target.GetComponentString('Door').IsJammed = true
	setDoorState(target, false)
	
	local pos = target.WorldPosition
	
	FG.paranormal.setupReward(client, pos, 1500, 10 + 1 * FG.paranormal.clients[client].level)
	
	return true
end}

-- Say - send a text message
FG.paranormal.actions.say = {name = 'say', levelNeeded = 4, cost = 45, script = function (client, pos, data)
	local speciesName = 'ghost'
	if FG.paranormal.poltergeist == client then speciesName = 'poltergeist' end
	for player in Client.ClientList do
		if (player == client) or (player.Character == nil) or (player.Character.IsDead) then
			messageClient(player, 'chat-regular', data.text, speciesName .. ' (' .. client.Name .. ')')
			--messageClient(player, 'chat-regular', message, client.Character.Name)
		else
			messageClient(player, 'chat-ghost', data.text, speciesName .. ' (' .. client.Name .. ')')
		end
	end
	
	return true
end}

-- Lockdown Blackout - causes the blackout from the lockdown
FG.paranormal.actions.lockdownBlackout = {hide = true, script = function (client, pos, data)
	findLights()
	-- Get targets of action
	local targets = {}
	local radius = 450 + 100 * FG.paranormal.clients[client].level
	for item in Item.ItemList do
		if FG.lightColors[item] ~= nil then
			local dist = distanceEllipse(pos, item.WorldPosition, Vector2(0.5, 1))
			if dist < radius then 
				table.insert(targets, item)
			end
		end
	end
	
	if table.size(targets) == 0 then
		return false
	end
	
	for target in targets do
		FG.paranormal.lights[target] = 9 + 2 * FG.paranormal.clients[client].level
		setLightState(target, false)
	end
	
	return true
end}

-- Lockdown - closes and locks all doors in a radius & triggers a blackout
FG.paranormal.actions.lockdown = {name = 'lockdown', levelNeeded = 3, cost = 60, script = function (client, pos, data)
	-- Get target of action
	local targets = {}
	local radius = 400 + 100 * FG.paranormal.clients[client].level
	for item in Item.ItemList do
		if (not item.NonInteractable) and (item.GetComponentString('Door') ~= nil) then
			local dist = distanceEllipse(pos, item.WorldPosition, Vector2(0.5, 1))
			if dist < radius then 
				table.insert(targets, item)
			end
		end
	end
	
	-- Blackout
	FG.paranormal.actions.lockdownBlackout.script(client, pos)
	
	if table.size(targets) == 0 then
		return false
	end
	
	for target in targets do
		FG.paranormal.doors[target] = 10 + 2 * FG.paranormal.clients[client].level
		target.GetComponentString('Door').IsJammed = true
		setDoorState(target, false)
	end
	
	FG.paranormal.setupReward(client, pos, radius * 2, 15 + 2 * FG.paranormal.clients[client].level)
	
	return true
end}

-- Use - interacts with a button
FG.paranormal.actions.use = {name = 'use', levelNeeded = 2, cost = 60, script = function (client, pos, data)
	-- Get target of action
	local target = nil
	local radius = 400
	for item in Item.ItemList do
		if (not item.NonInteractable) and (item.Connections ~= nil) and (item.GetComponentString('Controller') ~= nil) then
			local dist = distance(pos, item.WorldPosition)
			if dist < radius then 
				target = item
				radius = dist
			end
		end
	end
	
	if target == nil then
		return false
	end
	
	if target.Connections ~= nil then
		for connection in target.Connections do
			if connection.IsOutput then
				target.SendSignal(tostring(true), connection.Name)
			end
		end
	end
	
	local pos = target.WorldPosition
	
	FG.paranormal.setupReward(client, pos, 1500, 15)
	
	return true
end}

-- Tram - same as "use"
FG.paranormal.actions.tram = table.copy(FG.paranormal.actions.use)
FG.paranormal.actions.tram.name = 'tram'

-- Manifest - manifest yourself in a physical form
FG.paranormal.actions.manifest = {name = 'manifest', levelNeeded = 1, cost = 75, script = function (client, pos, data)
	local character = spawnHumanghost(client, pos, nil)
	--giveAfflictionCharacter(character, 'spawnprotection', 3)
	giveAfflictionCharacter(character, 'stun', 4.5)
	giveAfflictionCharacter(character, 'stunimmune', 1)
	
	return true
end}

-- Call reset function to do initial set
FG.paranormal.reset()

-- Rewards ghost for dealing damage or assisting in dealing damage
Hook.Add("character.applyDamage", "FG.ghostRewardHumanDamaged", function (characterHealth, attackResult, hitLimb, allowStacking)
	local character = characterHealth.Character
	if (character.SpeciesName == 'Humanghost') or (character.IsDead) or (findClientByCharacter(character) == nil) then return end
	
	local getDamageFromAfflictions = function (afflictions)
		local damage = 0
		
		for affliction in afflictions do
			if affliction.GetVitalityDecrease(characterHealth) ~= nil then
				damage = damage + affliction.GetVitalityDecrease(characterHealth)
			end
		end
		
		return damage
	end
	
	local damage = (getDamageFromAfflictions(attackResult.Afflictions) / character.MaxHealth) * 100
	
	-- Reward ghosts who assisted the attack (like by locking a nearby door)
	if character.WorldPosition ~= nil then
		for client, clientData in pairs(FG.paranormal.clients) do
			if (clientData.reward.duration > 0) and (distance(character.WorldPosition, clientData.reward.pos) < clientData.reward.range) and (clientData.level < 5) then
				FG.paranormal.clients[client].xp = FG.paranormal.clients[client].xp + math.ceil(damage * 1.0)
				FG.paranormal.clients[client].reward.rewarded = FG.paranormal.clients[client].reward.rewarded + math.ceil(damage * 1.0)
				if FG.paranormal.clients[client].reward.duration < 5 then
					FG.paranormal.clients[client].reward.duration = 5
				end
				--print('[!] Ghost awarded for assisted damage.')
			end
		end
	end
	
	-- Currently does NOT work because the Humanghost is removed after exploding making it not traceable
	--[[
	-- Reward ghost who manifested and attacked
	if (character.LastAttacker ~= nil) and (character.LastAttacker.SpeciesName == 'Humanghost') and (FG.paranormal.clients[findClientByCharacter(character.LastAttacker)] ~= nil) then
		local client = findClientByCharacter(character.LastAttacker)
		if FG.paranormal.clients[client].level < 5 then
			FG.paranormal.clients[client].xp = FG.paranormal.clients[client].xp + math.ceil(damage * 0.35)
			FG.paranormal.clients[client].reward.rewarded = FG.paranormal.clients[client].reward.rewarded + math.ceil(damage * 0.35)
			if FG.paranormal.clients[client].reward.duration < 1 then
				FG.paranormal.clients[client].reward.duration = 1
			end
			print('[!] Ghost awarded for direct damage.')
		end
	end
	-]]

	return
end)

-- Generate a bar for the ghost power
FG.paranormal.powerTextBar = function(power, powerCap)
	local total = math.ceil(powerCap/2)
	local available = math.floor(power/2)
	local unavailable = total - available
	local text = '<'
	
	if power < 0 then
		text = text .. text.rep('-', total)
	else
		text = text .. text.rep('=', available)
		text = text .. text.rep('-', unavailable)
	end
	
	text = text .. '>'
	return text
end

FG.loadedFiles['ghost'] = true