require("hs.ipc")

local apps = {
  { key = "pad1", name = "ChatGPT", bundleID = "com.openai.codex" },
  { key = "pad2", name = "Finder", bundleID = "com.apple.finder" },
  { key = "pad3", name = "WeChat", bundleID = "com.tencent.xinWeChat" },
  { key = "pad4", name = "Chrome", bundleID = "com.google.Chrome" },
  { key = "pad5", name = "Telegram", bundleID = "ru.keepcoder.Telegram" },
  { key = "pad6", name = "Terminal", bundleID = "com.apple.Terminal" },
  { key = "pad7", name = "UU Remote", bundleID = "com.netease.uuremote" },
}

local function focusOrLaunch(item, showAlert)
  local app = hs.application.get(item.bundleID)
  if not app then
    hs.application.launchOrFocusByBundleID(item.bundleID)
    if showAlert ~= false then hs.alert.show("Opening " .. item.name, 0.7) end
    return nil
  end

  app:unhide()
  local window = app:mainWindow()
  if not window then
    local windows = app:allWindows()
    window = windows and windows[1] or nil
  end
  if window and window:isMinimized() then window:unminimize() end
  app:activate(true)
  if window then window:focus() end
  if showAlert ~= false then hs.alert.show(item.name, 0.45) end
  return window
end

for _, item in ipairs(apps) do
  hs.hotkey.bind({}, item.key, function() focusOrLaunch(item) end)
end

local function focusedWindow()
  local window = hs.window.focusedWindow()
  if not window then hs.alert.show("No active window", 0.7) end
  return window
end

local windowStates = {}
local lastAdjustedWindowID = nil

local function rememberWindow(window)
  if not window then return end
  local id = window:id()
  windowStates[id] = {
    frame = window:frame(),
    minimized = window:isMinimized(),
    fullScreen = window:isFullScreen(),
  }
  lastAdjustedWindowID = id
end

local function restorePreviousWindowState()
  local window = lastAdjustedWindowID and hs.window.get(lastAdjustedWindowID) or focusedWindow()
  if not window then return end
  local state = windowStates[window:id()]
  if not state then
    hs.alert.show("No previous window state", 0.8)
    return
  end
  if window:isMinimized() then window:unminimize() end
  if window:isFullScreen() ~= state.fullScreen then window:setFullScreen(state.fullScreen) end
  if not state.fullScreen then window:setFrame(state.frame) end
  if state.minimized then window:minimize() else window:focus() end
  windowStates[window:id()] = nil
  lastAdjustedWindowID = nil
end

hs.hotkey.bind({}, "f14", function()
  local window = focusedWindow()
  if window then rememberWindow(window); window:maximize() end
end)

hs.hotkey.bind({}, "f15", restorePreviousWindowState)

hs.hotkey.bind({}, "f16", function()
  local window = focusedWindow()
  if window then rememberWindow(window); window:moveToUnit({ 0, 0, 0.5, 1 }) end
end)

hs.hotkey.bind({}, "f17", function()
  local window = focusedWindow()
  if window then rememberWindow(window); window:minimize() end
end)

hs.hotkey.bind({}, "f18", function()
  local window = focusedWindow()
  if window then rememberWindow(window); window:moveToUnit({ 0.5, 0, 0.5, 1 }) end
end)

local chatGPT = { name = "ChatGPT", bundleID = "com.openai.codex" }

local function doubleTap(action, logName)
  local lastRelease = 0
  return function()
    local now = hs.timer.secondsSinceEpoch()
    if lastRelease > 0 and now - lastRelease <= 0.6 then
      lastRelease = 0
      hs.printf("mxkeys-vibe: %s double tap fired", logName)
      action()
    else
      lastRelease = now
    end
  end
end

hs.hotkey.bind({}, "pad.", function() end,
  doubleTap(function()
    hs.eventtap.keyStroke({ "ctrl", "alt", "shift" }, "d", 80000)
  end, "numpad delete"))

hs.hotkey.bind({}, "pad0", function() end,
  doubleTap(function()
    hs.eventtap.keyStroke({ "ctrl", "alt", "cmd" }, "d", 80000)
  end, "numpad 0"))

hs.hotkey.bind({}, "padenter", function()
  focusOrLaunch(chatGPT, false)
  hs.timer.doAfter(0.2, function()
    hs.eventtap.keyStroke({}, "return", 0)
  end)
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "r", hs.reload)
hs.alert.show("MX Keys Vibe Console enabled", 2)
