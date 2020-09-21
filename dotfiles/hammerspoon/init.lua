hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- LOAD / REQUIRE
hs.loadSpoon("MiroWindowsManager")
require("hs.ipc")
hs.ipc.cliInstall()

-- SETTINGS
-- solarized console
hs.console.windowBackgroundColor({hex="#073642"})
hs.console.outputBackgroundColor({hex="#002b36"})
hs.console.inputBackgroundColor({hex="#002b36"})
hs.console.consoleCommandColor({hex="#6c71c4"})
hs.console.consoleResultColor({hex="#839496"})
hs.console.consolePrintColor({hex="#657b83"})
hs.console.darkMode(true)
-- grid
hs.grid.ui.textSize = 50
hs.grid.ui.cellStrokeWidth = 5
hs.grid.ui.highlightStrokeWidth = 10
hs.grid.ui.textColor = {1,1,1}
hs.grid.ui.cellColor = {0,0,0,0.25}
hs.grid.ui.cellStrokeColor = {0,0,0}
hs.grid.ui.highlightColor = {0,0.8,0.8,0.5}
hs.grid.ui.highlightStrokeColor = {0,0.8,0.8,1}
-- animations
hs.window.animationDuration = 0
-- app search
hs.application.enableSpotlightForNameSearches(true)

-- ALIASES
local i = hs.inspect
local fw = hs.window.focusedWindow
-- local ms = hs.screen.mainScreen
local fmt = string.format
local bind = hs.hotkey.bind
local clear = hs.console.clearConsole
local reload = hs.reload
local pbcopy = hs.pasteboard.setContents
local std = hs.stdlib and require("hs.stdlib")

local laptopScreen = "Color LCD"
local bigScreen = "LED Cinema Display"

local loger = hs.logger.new('[LOG]','debug')
local log = loger.i

local hyper = {"cmd", "alt", "ctrl", "shift"}
local super = {"cmd", "alt", "ctrl"}

-- HELPERS

-- TODO enable cycling through apps/windows?
-- TODO enable launching with hold?
function appToggle(apps)
  return function() 
    for i, v in ipairs(apps) do
      local app, filename
      if type(v) == 'table' then
        app = hs.application.get(v.name)
        filename = v.filename
      else
        app = hs.application.get(v)
        filename = v
      end
      if app then
        if app:isFrontmost() then
          app:hide()
        else
          app:activate()
          -- hs.application.launchOrFocus(filename)
        end
      end
    end
    return false
  end
end

function changeWidth(amt)
  return function() 
    local s = fw():size() 
    s.w = s.w + amt
    fw():setSize(s)
  end
end

function defaultGrid()
  hs.grid.setGrid('24x24')
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0
end

function showGrid()
  hs.grid.setGrid('6x3')
  hs.grid.setMargins({-2, 0})
  hs.grid.show(defaultGrid, false)
end

local recentLayout, recentWindowInfo
local messageLayout = {
  {"Slack", nil, bigScreen, hs.layout.left50},
  {"Spark", nil, bigScreen, hs.layout.right50},
  {"Amazon Chime", nil, bigScreen, hs.layout.left50}
}
local togglWidth = 0.22
local secondaryLayout = {
  {"TogglDesktop", nil, laptopScreen, hs.geometry.unitrect(0, 0, togglWidth, 1)},
  {"Fantastical", nil, laptopScreen, hs.geometry.unitrect(togglWidth + .001, 0, .5 - togglWidth, 1)},
  {"Todoist", nil, laptopScreen, hs.layout.right50},
  {"iTerm2", nil, bigScreen, hs.layout.maximized},
}
function saveLayout()
  recentLayout = {}
  recentWindowInfo = {}
  for i, window in ipairs(hs.window.visibleWindows()) do
    table.insert(recentLayout, {window:application(), window, window:screen(), nil, window:frame(), nil})
    table.insert(recentWindowInfo, {
      app = window:application(),
      window = window,
      is_hidden = window:application():isHidden(),
      is_minimized = window:isMinimized(),
    })
  end
  log('Layot saved')
  log(to_string(recentLayout))
  log(to_string(recentWindowInfo))
end
function restoreLayout()
  _restoreLayout(recentLayout, recentWindowInfo)
end
function _restoreLayout(layout, window_info)
  window_info = window_info or {}
  window_info = {}
  for i, info in ipairs(window_info) do
    local window = info.window
    local app = info.app
    local is_hidden = app:isHidden()
    local is_minimized = window:isMinimized()
    if is_hidden ~= info.is_hidden then
      if is_hidden then 
        app:unhide()
      else
        app:hide()
      end
    end
    if is_minimized ~= info.is_minimized then
      if is_minimized then 
        window:unminimize()
      else
        window:minimize()
      end
    end
  end
  hs.layout.apply(layout)
  log('Layout restored')
  log(to_string(layout))
  log(to_string(window_info))
end

-- From http://lua-users.org/wiki/TableSerialization
function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end
function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end

bind(super, "R", restoreLayout)
bind(super, "S", saveLayout)
bind(super, "M", function() hs.layout.apply(secondaryLayout) end)

-- APPS

bind(hyper, "Q", appToggle({"Sequel Pro", "TablePlus"}))
bind(hyper, "W", appToggle({"Quip"}))
bind(hyper, "E", appToggle({"Sublime Text"}))
-- bind(hyper, "R", appToggle({"Toggl"}))
bind(hyper, "T", appToggle({"Messages"}))
 bind(hyper, "Y", appToggle({"Amazon Chime"}))
-- bind(hyper, "O", appToggle({"Todoist"}))
bind(hyper, "I", appToggle({"IntelliJ IDEA", "PhpStorm", "WebStorm"}))
-- bind(hyper, "U", appToggle({"FREE"}))
 bind(hyper, "P", appToggle({"PyCharm"}))

-- bind(hyper, "A", appToggle({"BeardedSpice Track"}))
bind(hyper, "S", appToggle({"Spotify"}))
bind(hyper, "D", appToggle({"Google Chrome Beta"}))
bind(hyper, "F", appToggle({"Firefox"}))
--bind(hyper, "G", appToggle({{name = "Fantastical", filename = "Fantastical 2"}, "Calendar"}))
bind(hyper, "H", appToggle({"Finder"}))
--bind(hyper, "J", appToggle({"FREE"}))
bind(hyper, "K", appToggle({"Microsoft PowerPoint"}))
-- bind(hyper, "L", appToggle({"LastPass Search"}))
-- bind(hyper, ";", appToggle({"iTerm2"}))

-- bind(hyper, "Z", appToggle({"FREE"}))
bind(hyper, "X", appToggle({"Microsoft Excel"}))
bind(hyper, "C", appToggle({"Slack"}))
bind(hyper, "V", appToggle({"Evernote"}))
bind(hyper, "B", appToggle({"Google Chrome"}))
-- bind(hyper, "N", appToggle({"Todoist Quick Task"}))
bind(hyper, "M", appToggle({"Mailplane", "Microsoft Outlook"}))
-- bind(hyper, ",", appToggle({"FREE"}))
-- bind(hyper, ".", appToggle({"FREE"})) (does sys diagnose by default)
-- bind(hyper, "/", appToggle({"FREE"})) (doesn't seem to work)

-- WINDOWS
-- todo: layout restoration
-- todo: specific layouts (i.e. for toggl/todoist/fantastical)

-- grid
bind(super, "space", showGrid)
bind(hyper, "space", showGrid)

-- window movement
spoon.MiroWindowsManager:bindHotkeys({
  up = {super, "up"},
  right = {super, "right"},
  down = {super, "down"},
  left = {super, "left"},
  fullscreen = {super, "return"}
})
-- spoon.MiroWindowsManager:bindHotkeys({
--   up = {super, "up"},
--   right = {super, "right"},
--   down = {super, "down"},
--   left = {super, "left"},
--   fullscreen = {super, "m"}
-- })
-- spoon.MiroWindowsManager:bindHotkeys({
--   up = {super, "up"},
--   right = {super, "right"},
--   down = {super, "down"},
--   left = {super, "left"},
--   fullscreen = {super, "c"}
-- })

-- APP SHORTCUTS
function bindAllAppHotkeys()
  appHotkeys = {}
  appHotkeys['Todoist'] = {
    hs.hotkey.new('cmd', '1', todoistGoTo('Home Do')),
    hs.hotkey.new('cmd', '2', todoistGoTo('Home Plan')),
    hs.hotkey.new('cmd', '3', todoistGoTo('Work Do')),
    hs.hotkey.new('cmd', '4', todoistGoTo('Work Plan')),
  }
  appHotkeys['Google Chrome'] = {
  }
  for appName, hotkeys in pairs(appHotkeys) do
    filter = hs.window.filter.new(appName)
    bindAppHotkeys(filter, hotkeys)
  end
end

function todoistGoTo(text)
  return function()
    hs.eventtap.keyStrokes('/')
    hs.eventtap.keyStrokes(text)
    hs.eventtap.event.newKeyEvent({}, "down", true):post()
    hs.eventtap.event.newKeyEvent({}, "down", false):post()
    hs.eventtap.event.newKeyEvent({}, "return", true):post()
    hs.eventtap.event.newKeyEvent({}, "return", false):post()
  end
end

function bindAppHotkeys(windowFilter, hotkeys)
  windowFilter:subscribe(hs.window.filter.windowFocused, function()
    for i, hotkey in pairs(hotkeys) do
      hotkey:enable()
    end
  end)
  windowFilter:subscribe(hs.window.filter.windowUnfocused, function()
    for i, hotkey in pairs(hotkeys) do
      hotkey:disable()
    end
  end)
end
bindAllAppHotkeys()

-- nudge wdith
bind(super, "=", changeWidth(50), nil, changeWidth(50))
bind(super, "-", changeWidth(-50), nil, changeWidth(-50))

-- push windows right/left/center
bind(super, "[", function() fw():setTopLeft({fw():screen():frame().x, fw():topLeft().y}) end)
bind(super, "]", function() fw():setTopLeft({fw():screen():frame().x + fw():screen():frame().w - fw():size().w + 4, fw():topLeft().y}) end)
bind(super, "\\", function() fw():centerOnScreen() end)

-- switch display
bind({"cmd", "ctrl"}, "Up", function() fw():moveOneScreenNorth() end)
bind({"cmd", "ctrl"}, "Down", function() fw():moveOneScreenSouth() end)
bind({"cmd", "ctrl"}, "Left", function() fw():moveOneScreenWest() end)
bind({"cmd", "ctrl"}, "Right", function() fw():moveOneScreenEast() end)

bind({"cmd", "ctrl", "shift"}, "Up", function() for i,win in ipairs(hs.window.allWindows()) do win:moveOneScreenNorth() end end)
bind({"cmd", "ctrl", "shift"}, "Up", function() for i,win in ipairs(hs.window.allWindows()) do win:moveOneScreenSouth() end end)
bind({"cmd", "ctrl", "shift"}, "Up", function() for i,win in ipairs(hs.window.allWindows()) do win:moveOneScreenWest() end end)
bind({"cmd", "ctrl", "shift"}, "Up", function() for i,win in ipairs(hs.window.allWindows()) do win:moveOneScreenEast() end end)

-- SWITCHER
-- set up your windowfilter
switcher = hs.window.switcher.new(hs.window.filter.new():setDefaultFilter{})
switcher_vis = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces
switcher_space = hs.window.switcher.new(hs.window.filter.new():setCurrentSpace(true):setDefaultFilter{}) -- include minimized/hidden windows, current Space only
switcher_browsers = hs.window.switcher.new{'Safari','Google Chrome', 'Google Chrome Beta', 'Firefox'} -- specialized switcher for your dozens of browser windows :)

-- bind to hotkeys; WARNING: at least one modifier key is required!
bind('alt','tab',nil,function()switcher_browsers:next()end)
bind('alt-shift','tab',nil,function()switcher_browsers:previous()end)

-- alternatively, call .nextWindow() or .previousWindow() directly (same as hs.window.switcher.new():next())
-- hs.hotkey.bind('alt','tab','Next window',hs.window.switcher.nextWindow)
-- you can also bind to `repeatFn` for faster traversing
-- hs.hotkey.bind('alt-shift','tab','Prev window',hs.window.switcher.previousWindow,nil,hs.window.switcher.previousWindow)

log('Initialized')
hs.alert.show("Hammerspoon Loaded")
