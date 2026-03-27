local constants = require("constants")
local settings = require("config.settings")

sbar.add("event", constants.events.SWAP_MENU_AND_SPACES)

local function switchToggle(menuToggle)
  local isShowingMenu = menuToggle:query().icon.value == settings.icons.text.switch.on

  menuToggle:set({
    icon = { string = isShowingMenu and settings.icons.text.switch.off or settings.icons.text.switch.on },
  })

  sbar.trigger(constants.events.SWAP_MENU_AND_SPACES, { isShowingMenu = isShowingMenu })
end

local function addToggle()
  local menuToggle = sbar.add("item", constants.items.MENU_TOGGLE, {
    icon = {
      string = settings.icons.text.switch.on,
      color = settings.colors.white,
    },
    label = { width = 0 },
  })

  sbar.add("item", constants.items.MENU_TOGGLE .. ".padding", {
    width = settings.dimens.padding.label,
  })

  menuToggle:subscribe("mouse.entered", function(env)
    menuToggle:set({ icon = { color = settings.colors.with_alpha(settings.colors.white, 0.5) } })
  end)

  menuToggle:subscribe("mouse.exited", function(env)
    menuToggle:set({ icon = { color = settings.colors.white } })
  end)

  menuToggle:subscribe("mouse.clicked", function(env)
    switchToggle(menuToggle)
  end)

  menuToggle:subscribe(constants.events.AEROSPACE_SWITCH, function(env)
    switchToggle(menuToggle)
  end)
end

addToggle()
