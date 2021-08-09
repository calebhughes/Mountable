local AddOnName = ...
local LibStub = _G.LibStub

Mountable = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0")
local Mountable = Mountable
local dbDefaults = {
  global = {
    useGlobalProfile = false,
    debugEnabled = false,
  },
	profile = {
		enabled       = true,
    noFlyingMount = true,
    groups = { },
	},
}

local mountTableDefaults = {
  lastMountCount = nil,
}

function Mountable:OnEnable()
  print(AddOnName.." enabled")
end

function Mountable:OnDisable()
  print(AddOnName.." disabled")
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