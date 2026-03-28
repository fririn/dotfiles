local constants = require("constants")
local settings = require("config.settings")

local frontApps = {}
local currentFrontApp = nil

sbar.add("bracket", constants.items.FRONT_APPS, {}, { position = "left" })

local frontAppWatcher = sbar.add("item", {
  drawing = false,
  updates = true,
})

local function selectFocusedWindow(frontAppName)
  currentFrontApp = frontAppName
  for appName, app in pairs(frontApps) do
    local isSelected = appName == frontAppName
    local color = isSelected and settings.colors.orange or settings.colors.white
    app:set(
      {
        label = { color = color },
        icon = { color = color },
      }
    )
  end
end

local function updateWindows(windows)
  sbar.remove("/" .. constants.items.FRONT_APPS .. "\\.*/")

  frontApps = {}
  local foundWindows = string.gmatch(windows, "[^\n]+")
  for window in foundWindows do
    local parsedWindow = {}
    for key, value in string.gmatch(window, "(%w+)=([%w%s]+)") do
      parsedWindow[key] = value
    end

    local windowId = parsedWindow["id"]
    local windowName = parsedWindow["name"]
    local icon = settings.icons.apps[windowName] or settings.icons.apps["default"]

    frontApps[windowName] = sbar.add("item", constants.items.FRONT_APPS .. "." .. windowName, {
      label = {
        padding_left = 0,
        string = windowName,
      },
      icon = {
        string = icon,
        font = settings.fonts.icons(),
      },
      click_script = "aerospace focus --window-id " .. windowId,
    })

    frontApps[windowName]:subscribe(constants.events.FRONT_APP_SWITCHED, function(env)
      selectFocusedWindow(env.INFO)
    end)

    frontApps[windowName]:subscribe("mouse.entered", function(env)
      frontApps[windowName]:set({
        icon = { color = settings.colors.with_alpha(settings.colors.white, 0.5) },
        label = { color = settings.colors.with_alpha(settings.colors.white, 0.5) },
      })
    end)

    frontApps[windowName]:subscribe("mouse.exited", function(env)
      if currentFrontApp ~= nil then
        selectFocusedWindow(currentFrontApp)
      end
    end)
  end

  sbar.exec(constants.aerospace.GET_CURRENT_WINDOW, function(frontAppName)
    selectFocusedWindow(frontAppName:gsub("[\n\r]", ""))
  end)
end

local function getWindows()
  sbar.exec(constants.aerospace.LIST_WINDOWS, updateWindows)
end

frontAppWatcher:subscribe(constants.events.UPDATE_WINDOWS, function()
  getWindows()
end)

getWindows()
