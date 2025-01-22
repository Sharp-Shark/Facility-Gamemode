FG.analytics = {
	data = {},
	settings = {}
}

FG.analytics.publish = function ()
	if (table.size(FG.analytics.data) == 0) or CLIENT or (not Game.ServerSettings.IsPublic) then return end

	local text = '```'
	
	text = text .. 'settings = ' .. table.print(FG.analytics.settings, true, 1, nil, {space = '', line = ''})
	text = text .. '``````'
	text = text .. 'data = ' .. table.print(FG.analytics.data, true, 1, nil, {space = '| ', line = '``````'})
	text = text .. '```'
	
	discordChatMessage(text, FG.discordWebHookAnalytics)
	
	FG.analytics.data = {}
	
	print('[!] Analytics submitted to official discord server.')
end

-- Execute at round start
Hook.Add("roundStart", "startAnalytics", function (arg)

	FG.analytics.settings = table.copy(FG.settings)
	
	FG.analytics.valid = true
	
	FG.analytics.data.map = Submarine.MainSub.Info.Name
	FG.analytics.data.initialplayercount = #Client.ClientList - table.size(FG.spectators)
	FG.analytics.data.startTime = Timer.Time
	FG.analytics.data.inmateEscapes = 0
	FG.analytics.data.staffEscapes = 0
	FG.analytics.data.guardEscapes = 0
	FG.analytics.data.inmateArrested = 0
	FG.analytics.data.staffArrested = 0
	FG.analytics.data.respawnWaves = ''
	if FG.analytics.data.initialCharacters == nil then FG.analytics.data.initialCharacters = '' end
	FG.analytics.data.obituary = {}

	return true
end)

-- Execute at round end
Hook.Add("roundEnd", "sendAnalytics", function (arg)

	if not FG.analytics.valid then
		FG.analytics.data = {}
	else
		FG.analytics.valid = nil
	end
	
	if FG.analytics.data.winner == nil then
		FG.analytics.data.winner = 'undefined'
	end
	FG.analytics.data.finalplayercount = #Client.ClientList - table.size(FG.spectators)
	if FG.analytics.data.startTime ~= nil then
		FG.analytics.data.endTime = Timer.Time
		FG.analytics.data.roundDuration = numberToTime(FG.analytics.data.endTime - FG.analytics.data.startTime, 1)
		FG.analytics.data.startTime = nil
		FG.analytics.data.endTime = nil
	end
	if table.size(FG.analytics.data.obituary) == 0 then
		FG.analytics.data.obituary = 'make peace not war'
	end
	
	if FG.analytics.data.finalplayercount > 1 then
		FG.analytics.publish()
	end
	
	FG.analytics.data = {}
	
	return
end)

FG.loadedFiles['analytics'] = true