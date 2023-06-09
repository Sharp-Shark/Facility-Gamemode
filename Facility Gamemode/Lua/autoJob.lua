-- Get Team Distribution
function roleDistribution (amount)

	print('...')
	if table.size(global_spectators) > 0 then
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
	
	local roleSequence = 'msiigsmiigsimigsiimg'
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
				if (player.PreferredJob == 'mutatedmantis' or player.PreferredJob == 'mutatedcrawler') and teamCount['monster'] > 0 then
					selectedRole = 'monster'
				elseif (player.PreferredJob == 'repairmen' or player.PreferredJob == 'researcher') and teamCount['staff'] > 0 then
					selectedRole = 'staff'
				elseif (player.PreferredJob == 'enforcerguard') and teamCount['guard'] > 0 then
					selectedRole = 'guard'
				elseif (player.PreferredJob == 'inmate') and teamCount['inmate'] > 0 then
					selectedRole = 'inmate'
				else
					-- Couldn't give preferred role - move to unsolved player list
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
	global_playerRole = {}
	if not global_autoJob then return end
	if #Client.ClientList - table.size(global_spectators) <= 1 then print('[!] Only 1 player, will not assign jobs.') return end

	global_playerRole = assignPlayerRole()
	
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