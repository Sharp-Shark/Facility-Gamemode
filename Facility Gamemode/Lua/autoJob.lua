-- Get Team Distribution
function roleDistribution ()

	print('...')
	if table.size(global_spectators) > 0 then
		for player, value in pairs(global_spectators) do
			print('[!] ' .. player .. ' is a spectator.')
		end
		print('...')
	end
	
	local unassigned = #Client.ClientList - table.size(global_spectators)
	local teamCount = {}
	teamCount['monster'] = 0
	teamCount['staff'] = 0
	teamCount['guard'] = 0
	teamCount['inmate'] = 0
	
	teamCount['monster'] = math.ceil(unassigned/5)
	unassigned = unassigned - teamCount['monster']
	
	teamCount['staff'] = math.ceil(unassigned/4)
	unassigned = unassigned - teamCount['staff']
	teamCount['guard'] = math.floor(unassigned/3)
	unassigned = unassigned - teamCount['guard']
	
	teamCount['inmate'] = unassigned
	
	if global_huskMode then
		teamCount['inmate'] = teamCount['inmate'] + teamCount['monster']
		teamCount['monster'] = 0
	end
	
	return teamCount
end

-- Assign players a Role
function assignPlayerRole ()

	local teamCount = roleDistribution()
	local unassignedPlayers = {}
	for player in Client.ClientList do
		if not global_spectators[player.Name] then
			table.insert(unassignedPlayers, player.Name)
		end
	end
	local playerRole = {}
	local selectedRole = ''
	local unsolvedPlayers = {}
	local index = 0
	
	-- Give players their preferred role if possible
	while ((teamCount['monster'] + teamCount['staff'] + teamCount['guard'] + teamCount['inmate']) > 0) and #unassignedPlayers > 0 do
		index = math.random(#unassignedPlayers)
		
		selectedRole = ''
		for player in Client.ClientList do
			if unassignedPlayers[index] == player.Name then
				if (player.PreferredJob == 'captain' or player.PreferredJob == 'medicaldoctor') and teamCount['monster'] > 0 then
					selectedRole = 'monster'
				elseif (player.PreferredJob == 'mechanic' or player.PreferredJob == 'engineer') and teamCount['staff'] > 0 then
					selectedRole = 'staff'
				elseif (player.PreferredJob == 'securityofficer') and teamCount['guard'] > 0 then
					selectedRole = 'guard'
				elseif (player.PreferredJob == 'assistant') and teamCount['inmate'] > 0 then
					selectedRole = 'inmate'
				else
					-- Couldn't give preferred role - move to unsolved player lit
					table.insert(unsolvedPlayers, table.remove(unassignedPlayers, index))
				end
			end
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

-- Overrides the jobs the players chose, assuming auto jobs is activated
Hook.Add("jobsAssigned", "automaticJobAssignment", function ()
	if CLIENT and Game.IsMultiplayer then return end
	if not global_autoJob then return end

	global_playerRole = assignPlayerRole()
	
	local roleJob = {}
	roleJob['monster'] = {'medicaldoctor', 'captain'}
	roleJob['staff'] = {'mechanic', 'engineer'}
	roleJob['guard'] = {'securityofficer'}
	roleJob['inmate'] = {'assistant'}

	for playerName, role in pairs(global_playerRole) do
		for player in Client.ClientList do
			if playerName == player.Name then
				if role == 'monster' then
					if player.preferredJob == 'captain' then
						player.AssignedJob = JobVariant(JobPrefab.Get('captain'), 0)
					elseif player.preferredJob == 'medicaldoctor' then
						player.AssignedJob = JobVariant(JobPrefab.Get('medicaldoctor'), 0)
					else
						player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
					end
				elseif role == 'staff' then
					if player.preferredJob == 'mechanic' then
						player.AssignedJob = JobVariant(JobPrefab.Get('mechanic'), 0)
					elseif player.preferredJob == 'engineer' then
						player.AssignedJob = JobVariant(JobPrefab.Get('engineer'), 0)
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