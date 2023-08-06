-- Used for copy pasting presets
FG.settingsClipboard = {}
-- If client has connected to server
FG.clientConnectedToServer = false
FG.clientConnectingToServer = false

-- main frame
local frame = GUI.Frame(GUI.RectTransform(Vector2(1, 1)), nil)
frame.CanBeFocused = false

-- menu frame
local menu = GUI.Frame(GUI.RectTransform(Vector2(1, 1), frame.RectTransform, GUI.Anchor.Center), nil)
menu.CanBeFocused = false
menu.Visible = false

-- Make it so the GUI is updated in lobby, game and sub editor
Hook.Patch("Barotrauma.NetLobbyScreen", "AddToGUIUpdateList", function()
    frame.AddToGUIUpdateList()
end, Hook.HookMethodType.After)
Hook.Patch("Barotrauma.GameScreen", "AddToGUIUpdateList", function()
    frame.AddToGUIUpdateList()
end)
Hook.Patch("Barotrauma.SubEditorScreen", "AddToGUIUpdateList", function()
    frame.AddToGUIUpdateList()
end)

-- returns the children of a component
local function GetChildren(comp)
    local tbl = {}
    for value in comp.GetAllChildren() do
        table.insert(tbl, value)
    end
    return tbl
end

-- Setup config menu
local function setupConfigMenu()
	
	-- put a button that goes behind the menu content, so we can close it when we click outside
	local closeButton = GUI.Button(GUI.RectTransform(Vector2(1, 1), menu.RectTransform, GUI.Anchor.Center), "", GUI.Alignment.Center, nil)
	closeButton.OnClicked = function ()
		menu.Visible = not menu.Visible
        --GUI.GUI.TogglePauseMenu()
	end

	-- Menu frame and menu list
	local menuContent = GUI.Frame(GUI.RectTransform(Vector2(0.57, 0.83), menu.RectTransform, GUI.Anchor.Center))
	local menuList = GUI.ListBox(GUI.RectTransform(Vector2(0.95, 0.9), menuContent.RectTransform, GUI.Anchor.Center))
	
	-- Text
	local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuContent.RectTransform), "Facility Gamemode Config Editor", nil, nil, GUI.Alignment.Center)
	text.CanBeFocused = false
	text.textScale = 1.25
	
	-- Spacing
	local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.015), menuList.Content.RectTransform), '', nil, nil, GUI.Alignment.BottomLeft)
	text.CanBeFocused = false
	
	-- Text
	local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "Settings Preset Selector", nil, nil, GUI.Alignment.BottomLeft)
	text.CanBeFocused = false
	-- Dropdown for selecting prefab
	local presetsDropDown = GUI.DropDown(GUI.RectTransform(Vector2(1, 0.045), menuList.Content.RectTransform), "Settings Presets", 5, nil, false)
	presetsDropDown.ButtonTextColor = Color(169, 212, 187)
	for presetName, presetSettings in pairs(FG.settingsPresets) do
		presetsDropDown.AddItem(presetName, presetName)
	end
	-- Load a settings preset GUI
	local function loadPreset (presetName)
		configList.ClearChildren()
		-- If presetName isn't specified, load default instead
		if presetName == nil then
			loadPreset('default')
			presetsDropDown.SelectItem('default')
		end
		local presetSettings = FG.settingsPresets[presetName]
		
		-- Find all active settings in preset
		local activeSettings = {}
		for settingName, settingValue in pairs(presetSettings) do
			activeSettings[settingName] = true
		end
		
		local row = GUI.LayoutGroup(GUI.RectTransform(Vector2(1, 0.05), configList.Content.RectTransform), nil)
		row.isHorizontal = true
		local itemsInRow = 4
		
		-- Button for applying
		local button = GUI.Button(GUI.RectTransform(Vector2(1/itemsInRow, 0.05), row.RectTransform), "Apply this preset", GUI.Alignment.Center, "GUITextBox")
		button.OnClicked = function ()
			local preset = presetName
			FG.settings = table.copy(FG.settingsPresets[preset])
			if CLIENT and Game.IsMultiplayer then
				print('[!] Settings preset has been sent to the server.')
				local message = Networking.Start("loadClientPreset")
				message.WriteString(json.serialize(FG.settings))
				message.WriteString(preset)
				Networking.Send(message)
			end
			
			menuContent.Flash(Color(150, 200, 150))
		end

		-- Button for copying to clipboard
		local button = GUI.Button(GUI.RectTransform(Vector2(1/itemsInRow, 0.05), row.RectTransform), "Copy to clipboard", GUI.Alignment.Center, "GUITextBox")
		button.OnClicked = function ()
			local preset = presetName
			FG.settingsClipboard = table.copy(FG.settingsPresets[preset])
			
			menuContent.Flash(Color(50, 100, 50))
		end
		
		-- Button for pasting from clipboard
		local button = GUI.Button(GUI.RectTransform(Vector2(1/itemsInRow, 0.05), row.RectTransform), "Paste from clipboard", GUI.Alignment.Center, "GUITextBox")
		button.OnClicked = function ()
			local preset = presetName
			FG.settingsPresets[preset] = table.copy(FG.settingsClipboard)
				
			loadPreset(preset)
			
			saveSettingsPresets()
			
			menuContent.Flash(Color(50, 100, 50))
		end
		-- Disable this button for default settings
		if FG.settingsPresetsDefault[presetName] ~= nil then
			button.CanBeFocused = false
			button.OnClicked = function () end
			button.TextColor = Color(140, 155, 140)
			button.Color = Color(100, 100, 100)
		end
		
		-- Button for deleting preset
		local button = GUI.Button(GUI.RectTransform(Vector2(1/itemsInRow, 0.05), row.RectTransform), "Delete this preset", GUI.Alignment.Center, "GUITextBox")
		button.OnClicked = function ()
			local name = presetName
			FG.settingsPresets[name] = nil
			
			presetsDropDown.ClearChildren()
			for presetName, presetSettings in pairs(FG.settingsPresets) do
				presetsDropDown.AddItem(presetName, presetName)
			end
			loadPreset('default')
			presetsDropDown.SelectItem('default')
				
			saveSettingsPresets()
			
			menuContent.Flash(Color(150, 75, 75))
		end
		button.TextColor = Color(255, 100, 100)
		button.HoverTextColor = Color(255, 150, 150)
		button.SelectedTextColor = Color(200, 0, 0)
		button.Color = Color(255, 100, 100)
		button.HoverColor = Color(255, 150, 150)
		button.PressedColor = Color(200, 50, 50)
		-- Disable this button for default settings
		if FG.settingsPresetsDefault[presetName] ~= nil then
			button.CanBeFocused = false
			button.OnClicked = function () end
			button.TextColor = Color(200, 50, 50)
			button.Color = Color(150, 100, 100)
		end
			
		if (FG.settingsPresetsDefault[presetName] == nil) and (table.size(activeSettings) < table.size(FG.settingsDefault)) then
			-- Spacing
			local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.04), configList.Content.RectTransform), '', nil, nil, GUI.Alignment.BottomLeft)
			text.CanBeFocused = false
			-- Dropdown for adding new settings to preset
			local newSettingDropDown = GUI.DropDown(GUI.RectTransform(Vector2(1, 0.08), configList.Content.RectTransform), "Add Setting to Preset", math.min(5, table.size(FG.settingsDefault) - table.size(activeSettings)), nil, false)
			for settingName, settingValue in pairs(FG.settingsDefault) do
				if not activeSettings[settingName] then
					newSettingDropDown.AddItem(settingName, settingName)
				end
			end
			newSettingDropDown.OnSelected = function (guiComponent, object)
				FG.settingsPresets[presetName][object] = FG.settingsDefault[object]
				loadPreset(presetName)
					
				saveSettingsPresets()
			end
			-- Spacing
			local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.01), configList.Content.RectTransform), '', nil, nil, GUI.Alignment.BottomLeft)
			text.CanBeFocused = false
		else
			-- Spacing
			local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.04), configList.Content.RectTransform), '', nil, nil, GUI.Alignment.BottomLeft)
			text.CanBeFocused = false
		end
		
		-- Iterate through settings in the order they are in the settingsDefault
		for settingName, settingValueDefault in pairs(FG.settingsDefault) do
			if activeSettings[settingName] then
				local settingValue = FG.settingsPresets[presetName][settingName]
				-- Load setting description (if it has one)
				local settingDescription = 'no description.'
				if (FG.settingsDescription[settingName] ~= nil) and (FG.settingsDescription[settingName] ~= '') then
					settingDescription = FG.settingsDescription[settingName]
				end
				-- Text
				local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.06), configList.Content.RectTransform), settingName .. ' - ' .. settingDescription, nil, nil, GUI.Alignment.BottomLeft)
				text.CanBeFocused = false
				-- Add row for multiline
				local row = GUI.LayoutGroup(GUI.RectTransform(Vector2(1, 0.085), configList.Content.RectTransform), nil)
				row.isHorizontal = true
				local buttonSize = 0.13
				-- If it's a default setting preset, only add box as display
				if FG.settingsPresetsDefault[presetName] ~= nil then
					local input = GUI.TextBox(GUI.RectTransform(Vector2(1 - buttonSize, 0.05), row.RectTransform), settingValue, nil, nil, GUI.Alignment.CenterLeft)
					input.CanBeFocused = false
					input.TextColor = Color(140, 155, 140)
					button.Color = Color(100, 100, 100)
				else
					-- If dropdown has only 1 item, make it a unchangeable text box
					if (FG.settingsDropdown[settingName] ~= nil) and (table.size(FG.settingsDropdown[settingName]) == 1) then
						local input = GUI.TextBox(GUI.RectTransform(Vector2(1 - buttonSize, 0.05), row.RectTransform), FG.settingsDropdown[settingName][1], nil, nil, GUI.Alignment.CenterLeft)
						input.CanBeFocused = false
						input.TextColor = Color(140, 155, 140)
						button.Color = Color(100, 100, 100)
					-- Add dropdown with all valid options
					elseif FG.settingsDropdown[settingName] ~= nil then
						local dropdownItemsOnDisplay = 2
						if #FG.settingsDropdown[settingName] == 3 then
							dropdownItemsOnDisplay = #FG.settingsDropdown[settingName]
						end
						local dropdown = GUI.DropDown(GUI.RectTransform(Vector2(1 - buttonSize, 0.9), row.RectTransform), tostring(settingValue), dropdownItemsOnDisplay, nil, false)
						dropdown.ButtonTextColor = Color(169, 212, 187)
						for dropDownItem in FG.settingsDropdown[settingName] do
							dropdown.AddItem(tostring(dropDownItem), dropDownItem)
						end
						dropdown.OnSelected = function (guiComponent, object)
							local preset = presetName
							local name = settingName
							local value = object
							FG.settingsPresets[preset][name] = object
							
							saveSettingsPresets()
						end
					-- Add dropdown with true and false for booleans
					elseif type(FG.settingsDefault[settingName]) == 'boolean' then
						local dropdown = GUI.DropDown(GUI.RectTransform(Vector2(1 - buttonSize, 0.9), row.RectTransform), tostring(settingValue), 2, nil, false)
						if settingValue then
							dropdown.Text = 'True'
						else
							dropdown.Text = 'False'
						end
						dropdown.ButtonTextColor = Color(169, 212, 187)
						dropdown.AddItem('True', true)
						dropdown.AddItem('False', false)
						dropdown.OnSelected = function (guiComponent, object)
							local preset = presetName
							local name = settingName
							local value = object
							FG.settingsPresets[preset][name] = object
							
							saveSettingsPresets()
						end
					-- Add box for numbers and strings
					else
						local input = GUI.TextBox(GUI.RectTransform(Vector2(1 - buttonSize, 0.05), row.RectTransform), tostring(settingValue), nil, nil, GUI.Alignment.CenterLeft)
						input.OnTextChangedDelegate = function (guiComponent)
							local comp = input
							local preset = presetName
							local name = settingName
							local value = guiComponent.Text
							-- If value is a number, enforce a few safety features
							if type(FG.settingsDefault[name]) == 'number' then
								if tonumber(value) ~= nil then
									FG.settingsPresets[preset][name] = tonumber(value)
									
									saveSettingsPresets()
								else
									if (value ~= '') and (value ~= '-') then
										comp.Text = FG.settingsPresets[preset][name]
									end
								end
							-- If value is a string and has a defined legal character set, enforce it
							elseif (type(FG.settingsDefault[name]) == 'string') and (FG.settingsLegalChars[settingName] ~= nil) then
								local hasIllegalChar = false
								for charCount = 1, #value do
									local char = string.sub(value, charCount, charCount)
									if not string.has(FG.settingsLegalChars[settingName], char) then
										hasIllegalChar = true
										break
									end
								end
								if (not hasIllegalChar) and (value ~= '') then
									FG.settingsPresets[preset][name] = value
									
									saveSettingsPresets()
								else
									if value ~= '' then
										comp.Text = FG.settingsPresets[preset][name]
									end
								end
							-- If value is a string, no safety features
							elseif type(FG.settingsDefault[name]) == 'string' then
								FG.settingsPresets[preset][name] = value
									
								saveSettingsPresets()
							end
						end
					end
				end
				-- Button for deleting setting
				local button = GUI.Button(GUI.RectTransform(Vector2(buttonSize, 0.2), row.RectTransform), "Delete", GUI.Alignment.Center, "GUITextBox")
				button.OnClicked = function ()
					local preset = presetName
					local name = settingName
			
					FG.settingsPresets[preset][name] = nil
						
					loadPreset(preset)
						
					saveSettingsPresets()
				end
				button.TextColor = Color(255, 100, 100)
				button.HoverTextColor = Color(255, 150, 150)
				button.SelectedTextColor = Color(200, 0, 0)
				button.Color = Color(255, 100, 100)
				button.HoverColor = Color(255, 150, 150)
				button.PressedColor = Color(200, 50, 50)
				-- Disable this button for default settings
				if FG.settingsPresetsDefault[presetName] ~= nil then
					button.CanBeFocused = false
					button.OnClicked = function () end
					button.TextColor = Color(200, 50, 50)
					button.Color = Color(150, 100, 100)
				end
			end
		end
		-- Spacing
		local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.03), configList.Content.RectTransform), '', nil, nil, GUI.Alignment.BottomLeft)
		text.CanBeFocused = false
		
		return
	end
	-- Adds function to preset onselect
	presetsDropDown.OnSelected = function (guiComponent, object)
		loadPreset(object)
	end
	
	-- Text
	local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "New Settings Preset", nil, nil, GUI.Alignment.BottomLeft)
	text.CanBeFocused = false
	-- Add row for multiline
	local row = GUI.LayoutGroup(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), nil)
	row.isHorizontal = true
	local buttonSize = 0.16
	-- New prefab text box
	local newPrefabInput = GUI.TextBox(GUI.RectTransform(Vector2(1 - buttonSize, 0.05), row.RectTransform), "presetname", nil, nil, GUI.Alignment.CenterLeft)
	-- Create new prefab button
	local button = GUI.Button(GUI.RectTransform(Vector2(buttonSize, 0.05), row.RectTransform), "New preset", GUI.Alignment.Center, "GUITextBox")
	button.OnClicked = function ()
		local name = newPrefabInput.Text
		if FG.settingsPresetsDefault[name] == nil then
			FG.settingsPresets[name] = {}
			
			presetsDropDown.ClearChildren()
			for presetName, presetSettings in pairs(FG.settingsPresets) do
				presetsDropDown.AddItem(presetName, presetName)
			end
			
			loadPreset(name)
			presetsDropDown.SelectItem(name)
			
			saveSettingsPresets()
			
			menuContent.Flash(Color(50, 100, 50))
		end
	end
	
	-- Text
	local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "Current Preset Settings", nil, nil, GUI.Alignment.BottomLeft)
	text.CanBeFocused = false
	
	-- Containers for settings stuff
	configList = GUI.ListBox(GUI.RectTransform(Vector2(1, 0.65), menuList.Content.RectTransform))
	configList.ScrollBarVisible = true
	
	-- Spacing
	local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.015), menuList.Content.RectTransform), '', nil, nil, GUI.Alignment.BottomLeft)
	text.CanBeFocused = false
	
	-- inside close button
	local closeButton = GUI.Button(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "Close", GUI.Alignment.Center, "GUIButton")
	closeButton.OnClicked = function ()
		menu.Visible = not menu.Visible
        --GUI.GUI.TogglePauseMenu()
	end
	
	-- Spacing
	local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.015), menuList.Content.RectTransform), '', nil, nil, GUI.Alignment.BottomLeft)
	text.CanBeFocused = false
	
	-- Reset button
	local button = GUI.Button(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "Reset to default", GUI.Alignment.Center, "GUITextBox")
	button.OnClicked = function ()
		FG.settingsPresets = table.copy(FG.settingsPresetsDefault)
		
		presetsDropDown.ClearChildren()
		for presetName, presetSettings in pairs(FG.settingsPresets) do
			presetsDropDown.AddItem(presetName, presetName)
		end
			
		loadPreset('default')
		presetsDropDown.SelectItem('default')
		
		saveSettingsPresets()
		
		menuContent.Flash(Color(150, 75, 75))
	end
	button.TextColor = Color(255, 100, 100)
	button.HoverTextColor = Color(255, 150, 150)
	button.SelectedTextColor = Color(200, 0, 0)
	button.Color = Color(255, 100, 100)
	button.HoverColor = Color(255, 150, 150)
	button.PressedColor = Color(200, 50, 50)
	
	-- Text
	local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), 'Resets your config to the default permanently. Cannot be undone!', nil, nil, GUI.Alignment.Center)
	text.CanBeFocused = false
	
	-- Spacing
	local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.015), menuList.Content.RectTransform), '', nil, nil, GUI.Alignment.BottomLeft)
	text.CanBeFocused = false
	
	-- Loads the default preset when first opened
	loadPreset('default')
	presetsDropDown.SelectItem('default')
	
end
setupConfigMenu()

-- respawn timer
textBoxRespawnTimer = GUI.TextBlock(GUI.RectTransform(Vector2(0.05, 0.05), frame.RectTransform, GUI.Anchor.TopLeft), '')
textBoxRespawnTimer.CanBeFocused = false
textBoxRespawnTimer.TextColor = Color(255, 255, 255)

-- decon timer
textBoxDeconTimer = GUI.TextBlock(GUI.RectTransform(Vector2(0.05, 0.05), frame.RectTransform, GUI.Anchor.TopLeft), '')
textBoxDeconTimer.CanBeFocused = false
textBoxDeconTimer.TextColor = Color(250, 125, 75)

-- Show button to open menu
Hook.Patch("Barotrauma.GUI", "TogglePauseMenu", {}, function ()
    if GUI.GUI.PauseMenuOpen then
		menu.Visible = false
        local frame = GUI.GUI.PauseMenu
        local list = GetChildren(GetChildren(frame)[2])[1]
		local button = GUI.Button(GUI.RectTransform(Vector2(1, 0.1), list.RectTransform), 'Config Editor', GUI.Alignment.Center, "GUIButton")
		button.OnClicked = function ()
			GUI.GUI.TogglePauseMenu()
			menu.Visible = true
		end
	end
end, Hook.HookMethodType.After)

-- Hide respawn text if round hasn't started
Hook.Add("think", "thinkCheck", function ()
	textBoxRespawnTimer.TextPos = Vector2(240, 40)
	textBoxDeconTimer.TextPos = Vector2(240, 20)
	if Game.RoundStarted then
		textBoxRespawnTimer.Visible = true
		textBoxDeconTimer.Visible = true
	else
		textBoxRespawnTimer.Visible = false
		textBoxDeconTimer.Visible = false
	end
end)

if Game.IsMultiplayer then
	-- Send ping to server (after 1 second)
	Timer.Wait(function ()
		-- Send ping
		print('[!] Sending ping to server.')
		FG.clientConnectingToServer = true
		local message = Networking.Start("pingClientToServer")
		Networking.Send(message)
	end, 1000)
		
	-- Receive ping from server
	Networking.Receive("pingServerToClient", function (message, client)
		if FG.clientConnectingToServer and (not FG.clientConnectedToServer) then
			print('[!] Received ping from server.')
			FG.clientConnectingToServer = false
			FG.clientConnectedToServer = true
			-- Answer ping from server (incase, for example, the server did "reloadlua")
			Networking.Receive("pingServerToClientAgain", function (message, client)
				print('[!] Sending ping to server again.')
				FG.clientConnectingToServer = true
				FG.clientConnectedToServer = false
				local message = Networking.Start("pingClientToServer")
				Networking.Send(message)
			end)
		end
	end)
end
	
-- Update the respawn timer and decon timer GUI
Networking.Receive("updateGUI", function (message, client)
	if (FG.clientConnectedToServer) or (not Game.IsMultiplayer) then
		local respawnTimer = message.ReadString()
		FG.respawnTimerSeconds = message.ReadDouble()
		local deconTimer = message.ReadString()
		FG.decontaminationTimer = message.ReadDouble()
		textBoxRespawnTimer.Text = respawnTimer
		textBoxDeconTimer.Text = deconTimer
	end
end)

FG.loadedFiles['gui'] = true