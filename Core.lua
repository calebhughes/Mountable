local AddOnName, NS = ...
local LibStub = _G.LibStub

local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName)
AddOn.defaults = { global = {}, profile = { modules = {["*"] = true} } }

NS[1] = AddOn
NS[2] = nil
NS[3] = AddOn.defaults.profile
NS[4] = AddOn.defaults.global

NS[1].Libs = {}
NS[1].Libs.ACD = LibStub("AceConfigDialog-3.0-Mountable")
NS[1].Libs.ACR = LibStub("AceConfigRegistry-3.0")

SLASH_Mountable1 = "/mountable"
SlashCmdList.Mountable = function(msg)
  print(AddOnName)
end

Mountable = NS