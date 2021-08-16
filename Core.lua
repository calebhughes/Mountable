local AddOnName = ...
local LibStub = _G.LibStub

Mountable = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0")
local Mountable = Mountable
Mountable.Log = { }

local dbDefaults = {
  global = {
    loggingLevel = 0
  },
	profile = {
		enabled = true,
    groups = { },
	},
}
local mountTableDefaults = {
  global = {
    lastMountCount = nil,
    mounts = { }
  }
}

function Mountable:OnEnable()
  Mountable.Log:Debug("Mountable was enabled")
end

function Mountable:OnDisable()
  Mountable.Log:Debug("Mountable was disabled")
end

function Mountable:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("MountableDB", dbDefaults)
  self.mountTable = LibStub("AceDB-3.0"):New("MountableMountsDB", mountTableDefaults)
  Mountable:RegisterChatCommand("mountable", "HandleSlashCmd")
  Mountable:RegisterChatCommand("mtb", "HandleSlashCmd")
end

-- if not given an argument we open the options
-- otherwise, we assume it's a group and check to summon one
function Mountable:HandleSlashCmd(input, editbox)
  if input == "" then
    LibStub("AceConfigDialog-3.0"):Open("Mountable")
    return
  end

  local groupName = Mountable:GetArgs(input, 1)
  if groupName then
    Mountable:SummonRandomMount(groupName)
  end
end

_G["Mountable"] = Mountable