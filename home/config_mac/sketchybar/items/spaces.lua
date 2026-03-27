local constants = require("constants")
local settings = require("config.settings")

local spaces = {}
local focusedWorkspace = nil
local occupiedWorkspaces = {}

local swapWatcher = sbar.add("item", {
	drawing = false,
	updates = true,
})

local currentWorkspaceWatcher = sbar.add("item", {
	drawing = false,
	updates = true,
})

-- Modify this file with Visual Studio Code - at least vim does have problems with the icons
-- copy "Icons" from the nerd fonts cheat sheet and replace icon and name accordingly below
-- https://www.nerdfonts.com/cheat-sheet
local spaceConfigs <const> = {
	["1"] = { icon = "1", name = "Notes" },
	["2"] = { icon = "2", name = "Terminal" },
	["3"] = { icon = "3", name = "Browser" },
	["4"] = { icon = "4", name = "AltBrowser" },
	["5"] = { icon = "5", name = "Remote" },
	["6"] = { icon = "6", name = "Planner" },
	["7"] = { icon = "7", name = "Chat" },
	["8"] = { icon = "8", name = "Mail" },
	["9"] = { icon = "9", name = "Music" },
	["10"] = { icon = "0", name = "Secrets" },
	["t"] = { icon = "S", name = "Meeting" },
}

local function workspaceNameFromSid(sid)
	return sid:sub(#(constants.items.SPACES .. ".") + 1)
end

local function updateItemStyle(spaceName)
	local workspaceName = workspaceNameFromSid(spaceName)
	local isFocused = focusedWorkspace == workspaceName
	local isOccupied = occupiedWorkspaces[workspaceName] == true

	local iconColor
	if isFocused or isOccupied then
		iconColor = settings.colors.white
	else
		iconColor = settings.colors.grey
	end

	spaces[spaceName]:set({
		icon = { color = iconColor },
		background = {
			color = settings.colors.transparent,
			border_width = isFocused and 2 or 0,
			border_color = settings.colors.white,
			corner_radius = settings.dimens.graphics.background.corner_radius,
		},
	})
end

local function updateAllWorkspaceStyles()
	for spaceName, item in pairs(spaces) do
		if item ~= nil then
			updateItemStyle(spaceName)
		end
	end
end

local function refreshWorkspaceStates(newFocusedWorkspace)
	if newFocusedWorkspace then
		focusedWorkspace = newFocusedWorkspace
		sbar.exec(constants.aerospace.LIST_NONEMPTY_WORKSPACES, function(nonEmptyOutput)
			occupiedWorkspaces = {}
			for ws in nonEmptyOutput:gmatch("[^\r\n]+") do
				occupiedWorkspaces[ws] = true
			end
			updateAllWorkspaceStyles()
		end)
	else
		sbar.exec(constants.aerospace.GET_CURRENT_WORKSPACE, function(focusedOutput)
			focusedWorkspace = focusedOutput:match("[^\r\n]+")
			sbar.exec(constants.aerospace.LIST_NONEMPTY_WORKSPACES, function(nonEmptyOutput)
				occupiedWorkspaces = {}
				for ws in nonEmptyOutput:gmatch("[^\r\n]+") do
					occupiedWorkspaces[ws] = true
				end
				updateAllWorkspaceStyles()
			end)
		end)
	end
end

local function addWorkspaceItem(workspaceName)
	local spaceName = constants.items.SPACES .. "." .. workspaceName
	local spaceConfig = spaceConfigs[workspaceName]

	spaces[spaceName] = sbar.add("item", spaceName, {
		label = {
			width = 0,
			padding_left = 0,
			string = "",
		},
		icon = {
			string = spaceConfig.icon or settings.icons.apps["default"],
			color = settings.colors.grey,
		},
		background = {
			color = settings.colors.transparent,
			border_width = 0,
			corner_radius = settings.dimens.graphics.background.corner_radius,
		},
		click_script = "aerospace workspace " .. workspaceName,
	})

	spaces[spaceName]:subscribe("mouse.entered", function(env)
		spaces[spaceName]:set({ icon = { color = settings.colors.with_alpha(settings.colors.white, 0.5) } })
	end)

	spaces[spaceName]:subscribe("mouse.exited", function(env)
		updateItemStyle(spaceName)
	end)

	sbar.add("item", spaceName .. ".padding", {
		width = settings.dimens.padding.label,
	})
end

local function createWorkspaces()
	sbar.exec(constants.aerospace.LIST_ALL_WORKSPACES, function(workspacesOutput)
		for workspaceName in workspacesOutput:gmatch("[^\r\n]+") do
			addWorkspaceItem(workspaceName)
		end
		refreshWorkspaceStates()
	end)
end

swapWatcher:subscribe(constants.events.SWAP_MENU_AND_SPACES, function(env)
	local isShowingSpaces = env.isShowingMenu == "off" and true or false
	sbar.set("/" .. constants.items.SPACES .. "\\..*/", { drawing = isShowingSpaces })
end)

currentWorkspaceWatcher:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
	refreshWorkspaceStates(env.FOCUSED_WORKSPACE)
	sbar.trigger(constants.events.UPDATE_WINDOWS)
end)

createWorkspaces()
