local M = _G["Mountable"]
local tContains = tContains

function M:GetRootOptions()
  local options = {
    type = "group",
    name = "Mountable",
    desc = "Mountable",
    disabled = function() return not M.db.profile.enabled end,
    args = {
      enabled = {
        type = "toggle",
        name = "Enable Mountable",
        desc = "Enable or disable the addon",
        order = 1,
        get = function(info) return M.db.profile.enabled end,
        set = function(info, v)
          M.db.profile.enabled = v
          if v then M:Enable() else M:Disable() end
        end,
        disabled = false
      }
    }
  }
  options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(M.db)
  options.args.profile.disabled = false
  return options
end

function M:GetGeneralOptions()
  local general = {
    order = 1,
    name = "General",
    type = "group",
    childGroups = "tab",
    args = {
      title = {
        name = "General Options",
        type = "header",
        order = 0
      },
      loggingLevel = {
        name = "Logging Level",
        desc = "Determine the amount of messages to log to chat - probably doesn't need to be changed",
        type = "select",
        width = "full",
        values = M.Log.GetOptions,
        set = function(info,v) M.db.global.loggingLevel = v end,
        get = function(info) return M.db.global.loggingLevel end,
        order = 0
      },
      dismountWhileFlying = {
        name = "Flying Dismount",
        desc = "Whether to allow dismounting while flying or not",
        type = "toggle",
        width = "double",
        set = function(info, v) M.db.profile.dismountWhileFlying = v end,
        get = function(info) return M.db.profile.dismountWhileFlying end,
        order = 1
      },
      preferGroundMount = {
        name = "Prefer Ground Mount",
        desc = "When in a non-flying area, prefer mounts that are ground use only",
        type = "toggle",
        width = "double",
        set = function(info,v) M.db.profile.preferGroundMount = v end,
        get = function(info) return M.db.profile.preferGroundMount end,
        order = 1
      },
      aquaticOverride = {
        name = "Use Aquatic Mount",
        desc = "When swimming override any group options to mount on an aquatic mount",
        type = "toggle",
        width = "double",
        set = function(info,v) M.db.profile.aquaticOverride =  v end,
        get = function(info) return M.db.profile.aquaticOverride end,
        order = 1
      }
    }
  }
  return general
end

function M:GetGroupOptions()
  local groups = {
    order = 1,
    name = "Groups",
    type = "group",
    childGroups = "tab",
    args = {
      title = {
        name = "Groups",
        type = "header",
        order = 0
      },
      desc = {
        name = "These settings will allow you to create your own groups of mounts that can be summoned",
        type = "description",
        order = 1
      },
      newGroup = {
        name = "New Group",
        desc = "Add new group",
        type = "input",
        order = 2,
        set = function(info, v)
          if M.db.profile.groups then
            if not M.db.profile.groups[v] then
              M.db.profile.groups[v] = { }
            end
          end
        end
      },
      existingGroups = {
        name = "Groups",
        desc = "Existing groups",
        type = "group",
        childGroups = "tree",
        order = 3,
        args = {
        }
      }
    }
  }

  if M.db.profile.groups then 
    for k,v in pairs(M.db.profile.groups) do
      groups.args.existingGroups.args[k] = {
        name = k,
        type = "group",
        args = {
          searchBox = {
            order = 1,
            name  = "Search",
            desc  = "Search for a mount to add",
            type  = "input",
            width = "full",
            set  = function(info,val) M.searchText = val end,
            get  = function(info) return M.searchText end,
            func = function(info) M:SearchMounts(info) end,
          },
          deleteButton = {
            order = 10,
            name = "Delete Group",
            type = "execute",
            width = "full",
            confirm = function() return "Are you sure you want to delete this group?" end,
            func = function(info) M:DeleteGroup(info,k) end
          }
        }
      }

      --Loads a full list of mounts
      for kk,vv in ipairs(M:GetMountTable()) do
        groups.args.existingGroups.args[k].args[vv.name..vv.id] = {
          order = 2,
          name = vv.name,
          type = "toggle",
          image = vv.icon,
          get = function() return M:IsMountInGroup(v, vv) end,
          set = function() M:HandleMountGroupSet(v, vv) end
        }
      end
    end
  end

  return groups
end

function M:IsMountInGroup(group, mountInfo)
  if group[mountInfo.spellID] then
    return 1
  else
    return nil
  end
end

function M:AddMountToGroup(group, mountInfo)
  group[mountInfo.spellID] = {
    mountID = mountInfo.mountID,
    type = mountInfo.mountType
  }
end

function M:RemoveMountFromGroup(group, spellID)
  group[spellID] = nil
end

function M:HandleMountGroupSet(group, mountInfo)
  if group[mountInfo.spellID] then
    M:RemoveMountFromGroup(group, mountInfo.spellID)
  else
    M:AddMountToGroup(group, mountInfo)
  end
end

function M:DeleteGroup(info, value)
  M.db.profile.groups[value] = nil
end

function M:InitializeMountTable()
  local mountCount = C_MountJournal.GetNumMounts()
  if not mountCount or (mountCount == M.mountTable.global.lastMountCount) then return end

  M.mountTable.global.lastMountCount = mountCount
  M.mountTable.global.mounts = { }
  local _, creatureID, creatureName, spellID, icon, mountType, isUsable, hideOnChar, isCollected, mountID;
  for i=1, mountCount do
    creatureName, spellID, icon, _, isUsable, _, _, _, _, hideOnChar, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(i);
    if not hideOnChar and isCollected and mountID then
      creatureID, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID);
      M.mountTable.global.mounts[i] = {
        id = i,
        spellID = spellID,
        creatureID = creatureID,
        name = creatureName,
        icon = icon,
        mountType = mountType,
        mountID = mountID,
      }
    end
  end
end

function M:GetMountTable()
  if M.searchText then
    local mounts = { }
    for k,v in ipairs(M.mountTable.global.mounts) do
      if string.find(string.lower(v.name), string.lower(M.searchText)) then
        mounts[#mounts+1] = v
      end
    end
    return mounts
  else
    return { } -- don't return any options unless we're searching
  end
end

function M:GetAllOptions()
  M:InitializeMountTable()
  local options = M:GetRootOptions()
  options.args.general = M:GetGeneralOptions()
  options.args.groups = M:GetGroupOptions()
  return options
end

LibStub("AceConfig-3.0"):RegisterOptionsTable("Mountable", M.GetAllOptions)