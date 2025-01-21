local function escapeQuotes(str)
    return str:gsub("\"", "\\\"")
end

function discordChatMessage(message, hook)
	local discordWebHook = FG.discordWebHook
	if hook ~= nil then
		discordWebHook = hook
	end
    local escapedName = escapeQuotes(Game.ServerSettings.ServerName)
    local escapedMessage = escapeQuotes(message)

    Networking.RequestPostHTTP(discordWebHook, function(result) end, '{\"content\": \"'..escapedMessage..'\", \"username\": \"'..escapedName..'\"}')
end

FG.loadedFiles['discord'] = true