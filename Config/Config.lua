local M = _G["Mountable"]

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

function M:GetGroupOptions()
  local groups = {
    order = 0,
    name = "Mount Groups",
    type = "group",
    childGroups = "tab",
    args = {
      title = {
        name = "Mount Groups",
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
              M.db.profile.groups[v] = v
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
        name = v,
        type = "group",
        args = {
          deleteButton = {
            name = "Delete Group",
            type = "execute",
            func = function(info) M:DeleteGroup(info,k) end
          }
        }
      }
    end
  end

  return groups
end

function M:DeleteGroup(info, value)
  M.db.profile.groups[value] = nil
end

function M:GetAllOptions()
  local options = M:GetRootOptions()
  options.args.groups = M:GetGroupOptions()
  return options
end

LibStub("AceConfig-3.0"):RegisterOptionsTable("Mountable", M.GetAllOptions)