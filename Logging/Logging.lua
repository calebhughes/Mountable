local name, ns = ...
local M = _G["Mountable"]
local Log = M.Log

Log.Levels = {
  NONE    = 1,
  WARNING = 2,
  DEBUG   = 3,
}

Log.Colors = {
  NAME    = "|cff32e361",
  DEBUG   = "|cffff3333",
  WARNING = "|cfff2d022"
}

-- Get reverse table of log levels for AceConfig
function Log:GetOptions()
  local options = {}
  for k,v in pairs(Log.Levels) do
    options[v] = k
  end
  return options
end

-- Print messages meant for debugging purposes. Very noisy
function Log:Debug(message)
  if M.db.global.loggingLevel == Log.Levels.DEBUG then
    Log:PrintMessage(message, "DEBUG", Log.Colors.DEBUG)
  end
end

-- Print messages meant to alert user of an invalid combination or setting
-- in their groups e.g. no ground mounts in a no fly zone when prefer ground mounts is on
function Log:Warning(message)
  if M.db.global.loggingLevel >= Log.Levels.WARNING then
    Log:PrintMessage(message, "WARNING", Log.Colors.WARNING)
  end
end

function Log:PrintMessage(message, type, color)
  DEFAULT_CHAT_FRAME:AddMessage(Log.Colors.NAME..name.."|r "..color..type.."|r: "..message)
end