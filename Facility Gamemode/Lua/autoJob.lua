-- Get Team Distribution
function roleDistribution (amount)

	if table.size(global_spectators) > 0 then
		print('...')
		for player, value in pairs(global_spectators) do
			print('[!] ' .. player .. ' is a spectator.')
		end
		print('...')
	end
	
	local unassigned = amount or (#Client.ClientList - table.size(global_spectators))
	local teamCount = {}
	teamCount['monster'] = 0
	teamCount['staff'] = 0
	teamCount['guard'] = 0
	teamCount['inmate'] = 0
	
	-- OLD role distribution code
	--[[
	teamCount['monster'] = math.ceil(unassigned/6)
	unassigned = unassigned - teamCount['monster']
	
	teamCount['staff'] = math.ceil(unassigned/4)
	unassigned = unassigned - teamCount['staff']
	teamCount['guard'] = math.floor(unassigned/3)
	unassigned = unassigned - teamCount['guard']
	
	teamCount['inmate'] = unassigned
	--]]
	
	local roleSequence = 'msiigmisigmisigmisigmisig'
	for count = 0, unassigned - 1 do
		local letter = string.sub(roleSequence, count % #roleSequence + 1, count % #roleSequence + 1)
		if letter == 'm' then
			teamCount['monster'] = teamCount['monster'] + 1
		elseif letter == 's' then
			teamCount['staff'] = teamCount['staff'] + 1
		elseif letter == 'g' then
			teamCount['guard'] = teamCount['guard'] + 1
		elseif letter == 'i' then
			teamCount['inmate'] = teamCount['inmate'] + 1
		end
	end
	
	return teamCount
end

-- Assign players a Role
function assignPlayerRole (amount, preferredRole)

	function jobToRole (job)
		if job == 'mutatedmantis' or job == 'mutatedcrawler' then
			return 'monster'
		elseif job == 'repairmen' or job == 'researcher' then
			return 'staff'
		elseif job == 'enforcerguard' then
			return 'guard'
		elseif job == 'inmate' then
			return 'inmate'
		else
			return ''
		end
	end

	local roles = {'monster', 'staff', 'guard', 'inmate'}

	local teamCount = {}
	local unassignedPlayers = {}
	local playerPreferredRole = {}
	
	-- regular usage
	if amount == nil then
		teamCount = roleDistribution()
		unassignedPlayers = {}
		for player in Client.ClientList do
			if not global_spectators[player.Name] then
				playerPreferredRole[player.Name] = jobToRole(player.PreferredJob)
				table.insert(unassignedPlayers, player.Name)
			end
		end
	-- for debugging
	else
		teamCount = roleDistribution(amount)
		unassignedPlayers = {'Alpha', 'Beta', 'Charlie', 'Delta', 'Echo', 'Foxtrot', 'Golf', 'Hotel', 'India', 'Juliett', 'Kilo', 'Lima', 'Mike', 'November', 'Oscar', 'Papa', 'Quebec', 'Romeo', 'Sierra', 'Tango', 'Uniform', 'Victor', 'Whiskey', 'Xray', 'Yankee', 'Zuku'}
		for n=1, #unassignedPlayers - amount do
			table.remove(unassignedPlayers, #unassignedPlayers)
		end
		for player in unassignedPlayers do
			if preferredRole == 'random' then
				playerPreferredRole[player] = roles[math.random(#roles)]
			elseif preferredRole == nil then
				playerPreferredRole[player] = ''
			else
				playerPreferredRole[player] = preferredRole
			end
		end
		-- print the player preferred roles
		table.print(playerPreferredRole)
	end
	
	local playerRole = {}
	local selectedRole = ''
	local unsolvedPlayers = {}
	local player = ''
	local index = 0
	
	-- Give players their preferred role if possible
	while ((teamCount['monster'] + teamCount['staff'] + teamCount['guard'] + teamCount['inmate']) > 0) and #unassignedPlayers > 0 do
		index = math.random(#unassignedPlayers)
		player = unassignedPlayers[index]
		
		selectedRole = ''
		if playerPreferredRole[player] ~= '' and teamCount[playerPreferredRole[player]] > 0 then
			selectedRole = playerPreferredRole[player]
		else
			table.insert(unsolvedPlayers, table.remove(unassignedPlayers, index))
		end
		
		if selectedRole ~= '' then
			playerRole[table.remove(unassignedPlayers, index)] = selectedRole
			teamCount[selectedRole] = teamCount[selectedRole] - 1
		end
	end
	
	-- Give roleless players a random role
	while ((teamCount['monster'] + teamCount['staff'] + teamCount['guard'] + teamCount['inmate']) > 0) and #unsolvedPlayers > 0 do
		index = math.random(#unsolvedPlayers)
		
		selectedRole = ''
		if teamCount['monster'] > 0 then
			selectedRole = 'monster'
		elseif teamCount['staff'] > 0 then
			selectedRole = 'staff'
		elseif teamCount['guard'] > 0 then
			selectedRole = 'guard'
		elseif teamCount['inmate'] > 0 then
			selectedRole = 'inmate'
		end
		
		if selectedRole ~= '' then
			playerRole[table.remove(unsolvedPlayers, index)] = selectedRole
			teamCount[selectedRole] = teamCount[selectedRole] - 1
		end
	end
	
	return playerRole
end

-- Debug function that counts the amount of each role
function countRoleAmount (playerRole, extra)

	local teamCount = {}
	teamCount['total'] = 0
	teamCount['monster'] = 0
	teamCount['staff'] = 0
	teamCount['guard'] = 0
	teamCount['inmate'] = 0
	
	
	for playerName, role in pairs(playerRole) do
		teamCount['total'] = teamCount['total'] + 1
		teamCount[role] = teamCount[role] + 1
	end
	
	if extra then
		table.print(countRoleAmount(assignPlayerRole(teamCount['total'])))
	end
	
	return teamCount
end

-- Overrides the jobs the players chose, assuming auto jobs is activated
Hook.Add("jobsAssigned", "automaticJobAssignment", function ()
	global_playerRole = {}
	if not global_autoJob then return end
	if #Client.ClientList - table.size(global_spectators) <= 1 then print('[!] Only 1 player, will not assign jobs.') return end

	global_playerRole = assignPlayerRole()
	
	global_huskPlayers = {}
	
	local roleJob = {}
	roleJob['monster'] = {'mutatedcrawler', 'mutatedmantis'}
	roleJob['staff'] = {'repairmen', 'researcher'}
	roleJob['guard'] = {'enforcerguard'}
	roleJob['inmate'] = {'inmate'}

	for playerName, role in pairs(global_playerRole) do
		for player in Client.ClientList do
			if playerName == player.Name then
				if role == 'monster' then
					if global_huskMode then
						player.AssignedJob = JobVariant(JobPrefab.Get('inmate'), 0)
						global_huskPlayers[playerName] = true
					elseif player.PreferredJob == 'mutatedmantis' then
						player.AssignedJob = JobVariant(JobPrefab.Get('mutatedmantis'), 0)
					elseif player.PreferredJob == 'mutatedcrawler' then
						player.AssignedJob = JobVariant(JobPrefab.Get('mutatedcrawler'), 0)
					else
						player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
					end
				elseif role == 'staff' then
					if player.PreferredJob == 'repairmen' then
						player.AssignedJob = JobVariant(JobPrefab.Get('repairmen'), 0)
					elseif player.PreferredJob == 'researcher' then
						player.AssignedJob = JobVariant(JobPrefab.Get('researcher'), 0)
					else
						player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
					end
				else
					player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
				end
				break
			end
		end
	end
	
	return true
end)

global_loadedFiles['autoJob'] = true