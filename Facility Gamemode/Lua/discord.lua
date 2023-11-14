local function escapeQuotes(str)
    return str:gsub("\"", "\\\"")
end

function discordChatMessage(message, hook)
	local discordWebHook = "https://discord.com/api/webhooks/1128508877458133113/PLmw236dj136aewlPnAEupWJbCxXb3gYCOAfZfC1kWQj9WhhPkN4tx-daucar-99lPQI"
	if hook ~= nil then
		discordWebHook = hook
	end
    local escapedName = escapeQuotes(Game.ServerSettings.ServerName)
    local escapedMessage = escapeQuotes(message)

    Networking.RequestPostHTTP(discordWebHook, function(result) end, '{\"content\": \"'..escapedMessage..'\", \"username\": \"'..escapedName..'\"}')
end

FG.loadedFiles['discord'] = true