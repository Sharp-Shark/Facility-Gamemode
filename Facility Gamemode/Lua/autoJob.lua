-- Get Team Distribution
function roleDistribution (amount)

	if table.size(FG.spectators) > 0 then
		print('...')
		for player, value in pairs(FG.spectators) do
			print('[!] ' .. player .. ' is a spectator.')
		end
		print('...')
	end
	
	local unassigned = amount or (#Client.ClientList - table.size(FG.spectators))
	local teamCount = {}
	teamCount['monster'] = 0
	teamCount['overseer'] = 0
	teamCount['staff'] = 0
	teamCount['elite'] = 0
	teamCount['guard'] = 0
	teamCount['inmate'] = 0
	teamCount['jet'] = 0
	teamCount['mercs'] = 0
	
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
	
	local roleSequence = FG.settings.autoJobRoleSequence
	local letterCount = 1
	while unassigned > 0 do
		local letter = string.sub(roleSequence, letterCount, letterCount)
		unassigned = unassigned - 1
		if letter == 'x' then
			teamCount['monster'] = teamCount['monster'] + 1
		elseif letter == 'o' then
			teamCount['overseer'] = teamCount['overseer'] + 1
		elseif letter == 's' then
			teamCount['staff'] = teamCount['staff'] + 1
		elseif letter == 'e' then
			teamCount['elite'] = teamCount['elite'] + 1
		elseif letter == 'g' then
			teamCount['guard'] = teamCount['guard'] + 1
		elseif letter == 'i' then
			teamCount['inmate'] = teamCount['inmate'] + 1
		elseif letter == 'j' then
			teamCount['jet'] = teamCount['jet'] + 1
		elseif letter == 'm' then
			teamCount['mercs'] = teamCount['mercs'] + 1
		-- Undo decrement if no role was assigned
		else
			unassigned = unassigned + 1
		end
		letterCount = letterCount + 1
		if letterCount > #roleSequence then
			local validLetters = {x = true, s = true, g = true, i = true, j = true, m = true}
			local canBreak = false
			while letterCount > 1 do
				letter = string.sub(roleSequence, letterCount, letterCount)
				if validLetters[letter] then canBreak = true end
				if (letter == '-') and canBreak then break end
				letterCount = letterCount - 1
			end
		end
	end
	
	return teamCount
end

-- Assign players a Role
function assignPlayerRole (amount, preferredRole, disableAutoJob)

	function jobToRole (job)
		if FG.settings.autoJobIgnorePreference then
			return ''
		end
		if job == 'monsterjob' or job == 'mutatedmantisjob' or job == 'mutatedcrawlerjob' or job == 'greenskinjob' then
			return 'monster'
		elseif job == 'overseer' then
			return 'overseer'
		elseif job == 'repairmen' or job == 'researcher' then
			return 'staff'
		elseif job == 'eliteguard' then
			return 'elite'
		elseif job == 'enforcerguard' then
			return 'guard'
		elseif job == 'inmate' then
			return 'inmate'
		elseif job == 'jet' then
			return 'jet'
		elseif job == 'mercs' then
			return 'mercs'
		else
			return ''
		end
	end

	local roles = {'monster', 'overseer', 'staff', 'elite', 'guard', 'inmate', 'jet', 'mercs'}

	local teamCount = {}
	local unassignedPlayers = {}
	local playerPreferredRole = {}
	
	-- regular usage
	if amount == nil then
		teamCount = roleDistribution()
		unassignedPlayers = {}
		for player in Client.ClientList do
			if not FG.spectators[player.Name] then
				if jobToRole(player.PreferredJob) == '' then
					playerPreferredRole[player.Name] = roles[math.random(#roles)]
				else
					playerPreferredRole[player.Name] = jobToRole(player.PreferredJob)
				end
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
	
	-- If autoJob is disabled, just assign the player whatever role he picked!	
	if disableAutoJob then
		for player in Client.ClientList do
			playerRole[player.Name] = playerPreferredRole[player.Name]
		end
		return playerRole
	end
	
	-- Give players their preferred role if possible
	while ((teamCount['monster'] + teamCount['overseer'] + teamCount['staff'] + teamCount['elite'] + teamCount['guard'] + teamCount['inmate']  + teamCount['jet'] + teamCount['mercs']) > 0) and #unassignedPlayers > 0 do
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
	while ((teamCount['monster'] + teamCount['overseer'] + teamCount['staff'] + teamCount['elite'] + teamCount['guard'] + teamCount['inmate']  + teamCount['jet'] + teamCount['mercs']) > 0) and #unsolvedPlayers > 0 do
		index = math.random(#unsolvedPlayers)
		
		selectedRole = ''
		if teamCount['monster'] > 0 then
			selectedRole = 'monster'
		elseif teamCount['overseer'] > 0 then
			selectedRole = 'overseer'
		elseif teamCount['staff'] > 0 then
			selectedRole = 'staff'
		elseif teamCount['elite'] > 0 then
			selectedRole = 'elite'
		elseif teamCount['guard'] > 0 then
			selectedRole = 'guard'
		elseif teamCount['inmate'] > 0 then
			selectedRole = 'inmate'
		elseif teamCount['jet'] > 0 then
			selectedRole = 'jet'
		elseif teamCount['mercs'] > 0 then
			selectedRole = 'mercs'
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
	teamCount['overseer'] = 0
	teamCount['staff'] = 0
	teamCount['elite'] = 0
	teamCount['guard'] = 0
	teamCount['inmate'] = 0
	teamCount['jet'] = 0
	teamCount['mercs'] = 0
	
	
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
	-- Apply vote resutls if it started
	FG.democracy.endVoting(Client.ClientList)
	-- Reset the gamemodeChosen flag
	FG.democracy.gamemodeChosen = false
	
	-- Autojob start
	FG.playerRole = {}
	
	-- Disable autoJob means give players the role they picked
	local disableAutoJob = false
	if not FG.settings.autoJob then disableAutoJob = true end
	if #Client.ClientList - table.size(FG.spectators) < FG.settings.autoJobMinPlayers then print('[!] Only ' .. (#Client.ClientList - table.size(FG.spectators)) ..' player, will not assign jobs.') disableAutoJob = true end
	
	-- Get the roles of each player
	FG.playerRole = assignPlayerRole(nil, nil, disableAutoJob)
	
	-- Reset special monster table
	FG.monsterPlayers = {}
	
	local roleJob = {}
	roleJob['monster'] = {'mutatedcrawlerjob', 'mutatedmantisjob'}
	roleJob['overseer'] = {'overseer'}
	roleJob['staff'] = {'repairmen', 'researcher'}
	roleJob['elite'] = {'eliteguard'}
	roleJob['guard'] = {'enforcerguard'}
	roleJob['inmate'] = {'inmate'}
	roleJob['jet'] = {'jet'}
	roleJob['mercs'] = {'mercs'}
	
	-- Reset subclass setter for initial wave
	FG.terroristSubclassCount = 1
	FG.nexpharmaSubclassCount = 1
	
	-- Analytics
	FG.analytics.data.initialCharacters = ''

	for playerName, role in pairs(FG.playerRole) do
		for player in Client.ClientList do
			if playerName == player.Name then
				if role == 'monster' then
					-- Husk
					if FG.settings.gamemode == 'husk' then
						player.AssignedJob = JobVariant(JobPrefab.Get('inmate'), 0)
						FG.monsterPlayers[playerName] = 'husk'
						
						FG.analytics.data.initialCharacters = FG.analytics.data.initialCharacters .. 'husk '
					-- Greenskin
					elseif FG.settings.gamemode == 'greenskin' then
						player.AssignedJob = JobVariant(JobPrefab.Get('monsterjob'), 0)
						FG.monsterPlayers[playerName] = 'greenskin'
						
						FG.analytics.data.initialCharacters = FG.analytics.data.initialCharacters .. 'greenskin '
					-- Brood
					elseif FG.settings.gamemode == 'brood' then
						if player.PreferredJob == 'mutatedmantisjob' then
							player.AssignedJob = JobVariant(JobPrefab.Get('monsterjob'), 0)
							FG.monsterPlayers[playerName] = 'mutatedmantishatchling'
						elseif player.PreferredJob == 'mutatedcrawlerjob' then
							--player.AssignedJob = JobVariant(JobPrefab.Get('monsterjob'), 0)
							--FG.monsterPlayers[playerName] = 'mutatedcrawlerhatchling'
							player.AssignedJob = JobVariant(JobPrefab.Get('monsterjob'), 0)
							FG.monsterPlayers[playerName] = 'mutatedmantishatchling'
						else
							--player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
							--FG.monsterPlayers[playerName] = 'random'
							player.AssignedJob = JobVariant(JobPrefab.Get('monsterjob'), 0)
							FG.monsterPlayers[playerName] = 'mutatedmantishatchling'
						end
						
						FG.analytics.data.initialCharacters = FG.analytics.data.initialCharacters .. 'brood '
					-- Default
					elseif FG.settings.gamemode == 'default' then
						if player.PreferredJob == 'mutatedmantisjob' then
							player.AssignedJob = JobVariant(JobPrefab.Get('monsterjob'), 0)
							FG.monsterPlayers[playerName] = 'mutatedmantis'
						elseif player.PreferredJob == 'mutatedcrawlerjob' then
							--player.AssignedJob = JobVariant(JobPrefab.Get('monsterjob'), 0)
							--FG.monsterPlayers[playerName] = 'mutatedcrawler'
							player.AssignedJob = JobVariant(JobPrefab.Get('monsterjob'), 0)
							FG.monsterPlayers[playerName] = 'mutatedmantis'
						else
							--player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
							--FG.monsterPlayers[playerName] = 'random'
							player.AssignedJob = JobVariant(JobPrefab.Get('monsterjob'), 0)
							FG.monsterPlayers[playerName] = 'mutatedmantis'
						end
						
						FG.analytics.data.initialCharacters = FG.analytics.data.initialCharacters .. 'monster '
					end
				elseif role == 'staff' then
					if player.PreferredJob == 'repairmen' then
						player.AssignedJob = JobVariant(JobPrefab.Get('repairmen'), 0)
						
						FG.analytics.data.initialCharacters = FG.analytics.data.initialCharacters .. 'repairmen '
					elseif player.PreferredJob == 'researcher' then
						player.AssignedJob = JobVariant(JobPrefab.Get('researcher'), 0)
						
						FG.analytics.data.initialCharacters = FG.analytics.data.initialCharacters .. 'repairmen '
					else
						player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
						
						FG.analytics.data.initialCharacters = FG.analytics.data.initialCharacters .. 'staff '
					end
				elseif role == 'jet' then
					player.AssignedJob = JobVariant(JobPrefab.Get('jet'), tonumber(string.sub(FG.settings.terroristSquadSequence, FG.terroristSubclassCount, FG.terroristSubclassCount)))
					FG.terroristSubclassCount = FG.terroristSubclassCount + 1
					if FG.terroristSubclassCount > #FG.settings.terroristSquadSequence then FG.terroristSubclassCount = 1 end
					
					FG.analytics.data.initialCharacters = FG.analytics.data.initialCharacters .. 'jet '
				elseif role == 'mercs' then
					player.AssignedJob = JobVariant(JobPrefab.Get('mercs'), tonumber(string.sub(FG.settings.nexpharmaSquadSequence, FG.nexpharmaSubclassCount, FG.nexpharmaSubclassCount)))
					FG.nexpharmaSubclassCount = FG.nexpharmaSubclassCount + 1
					if FG.nexpharmaSubclassCount > #FG.settings.nexpharmaSquadSequence then FG.nexpharmaSubclassCount = 1 end
					
					FG.analytics.data.initialCharacters = FG.analytics.data.initialCharacters .. 'mercs '
				else
					player.AssignedJob = JobVariant(JobPrefab.Get(roleJob[role][math.random(#roleJob[role])]), 0)
					
					FG.analytics.data.initialCharacters = FG.analytics.data.initialCharacters .. roleJob[role][math.random(#roleJob[role])] .. ' '
				end
				break
			end
		end
	end
	
	return true
end)

FG.loadedFiles['autoJob'] = true