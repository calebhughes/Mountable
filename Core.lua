local AddOnName, NS = ...
local LibStub = _G.LibStub

Mountable = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0")
local Mountable = Mountable
---------------------------------------------------------
-- Our db upvalue and db defaults
local db
local options
local dbDefaults = {
	profile = {
		enabled       = true,
    noFlyingMount = true,
    groups = { },
	},
}

local dbMountDefaults = {
  global = {
    [1] = { }, -- Ground,
    [2] = { }, -- Flying,
    [3] = { }, -- Hybrid,
    [4] = { }, -- Aquatic,
    lastMountCount = nil
  }
}

function Mountable:OnEnable()
  print(AddOnName.." enabled")
end

function Mountable:OnDisable()
  print(AddOnName.." disabled")
end

function Mountable:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("MountableDB", dbDefaults)
  self.dbMounts = LibStub("AceDB-3.0"):New("MountableMountsDB", dbMountDefaults)
  self:RegisterChatCommand("mountable", self.HandleSlashCmd)
end

function Mountable:HandleSlashCmd()
  LibStub("AceConfigDialog-3.0"):Open("Mountable")
end

_G["Mountable"] = Mountable