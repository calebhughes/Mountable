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
  self:RegisterChatCommand("mountable", self.HandleSlashCmd)
  self:RegisterChatCommand("mtb", self.HandleSlashCmd)
end

function Mountable:HandleSlashCmd()
  LibStub("AceConfigDialog-3.0"):Open("Mountable")
end

_G["Mountable"] = Mountable