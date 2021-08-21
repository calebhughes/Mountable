local M = _G["Mountable"]
local tContains = tContains
local next = next

local mountTypes = {
  ground = 230,
  flying = 248,
  aquatic = 254,
  chauffer = 284
}

function M:SummonRandomMount(group)
  -- check if already mounted, should we dismount
  if M:ShouldDismount() then
    C_MountJournal.Dismiss()
    return
  elseif IsMounted() then
    return
  end

  if not M:CanMount() then
    return
  end

  local mountGroup = M:GetMountGroup(group)
  local mount = {}
  if M:CanMountSwimming() and M.db.profile.aquaticOverride then
    mount = M:GetAquaticMount(mountGroup)
  elseif M:CanFly() then
    mount = M:GetFlyingMount(mountGroup)
  elseif not M:CanFly() and M.db.profile.preferGroundMount then
    mount = M:GetGroundMount(mountGroup)
  end

  if not mount then M.Log:Warning("No valid mounts were found in group: "..group)
  else C_MountJournal.SummonByID(mount.mountID) end
end

-- Get random mount from the group
function M:GetRandomMountFromGroup(mounts)
  if not mounts or not next(mounts) then
    return nil
  end

  local keyset = { }
  for k,v in pairs(mounts) do
    keyset[#keyset+1] = k
  end
  return mounts[keyset[math.random(#keyset)]]
end

-- Check if group exists in our profile or not
function M:GetMountGroup(group)
  if M.db.profile.groups[group] then
    return M.db.profile.groups[group]
  end
  return nil
end

function M:GetFlyingMount(mountGroup)
  local validMounts = M:GetFilteredMountGroup(mountGroup, mountTypes.flying)
  local mount = M:GetRandomMountFromGroup(validMounts)
  if not mount then M.Log:Debug("Attempted flying mount summon - No valid mounts found") end
  return mount
end

function M:GetGroundMount(mountGroup)
  local validMounts = M:GetFilteredMountGroup(mountGroup, mountTypes.ground)
  local mount = M:GetRandomMountFromGroup(validMounts)
  if not mount then M.Log:Debug("Attempted ground mount summon - No valid mounts found") end
  return mount
end

function M:GetAquaticMount(mountGroup)
  local validMounts = M:GetAquaticMountFromGroup(mountGroup)
  -- if we don't have any water mounts in the specific group, check global collection
  if not next(validMounts) then
    validMounts = M:GetAquaticMountFromCollection()
  end

  local mount = M:GetRandomMountFromGroup(validMounts)
  if not mount then M.Log:Debug("Attempted aquatic mount summon - No valid mounts found") end
  return mount
end

function M:GetAquaticMountFromGroup(mountGroup)
  return M:GetFilteredMountGroup(mountGroup, mountTypes.aquatic)
end

function M:GetAquaticMountFromCollection()
  local validMounts = {}
  for k,v in ipairs(M.mountTable.global.mounts) do
    if v.mountType == mountTypes.aquatic then
      validMounts[v.spellID] = { mountID = v.mountID }
    end
  end
  return validMounts
end

function M:GetFilteredMountGroup(mounts, mountType)
  local filteredMounts = { }

  for k,v in pairs(mounts) do
    if v.type == mountType then
      filteredMounts[k] = v
    end
  end
  return filteredMounts
end

-- Expert Riding 34090
-- Master Riding 90265
function M:CanFly()
  if IsFlyableArea() and (IsSpellKnown(34090) or IsSpellKnown(90265)) then
    return 1
  end
  return nil
end

function M:CanMountSwimming()
  -- if true, need to check if we're at the surface or underwater
  return (IsSwimming() or IsSubmerged()) and not M:AtSurface()
end

-- Need to use this to check if we're underwater
-- Method for checking borrowed from Pets And Mounts Addon <3
function M:AtSurface()
  local timer, _, _, rate = GetMirrorTimerInfo(2);
  if(timer == "BREATH" and rate > -1) then
    M.Log:Debug("At surface")
    return 1
  end
  -- TODO: check for water breathing buffs
  if(timer == "UNKNOWN") then return nil end
end

-- Apprentice Riding 33388
-- Journeyman Riding 33391
-- Expert Riding 34090
-- Master Riding 90265
-- TODO: Add chauffer compatibility for low level characters
function M:CanMount()
  if IsSpellKnown(33391) or IsSpellKnown(33388) or IsSpellKnown(34090) or IsSpellKnown(90265) then
    return 1
  end
  return nil
end

function M:ShouldDismount()
  if (IsMounted() and not IsFlying()) or (IsFlying() and M.db.profile.dismountWhileFlying) then
    return 1
  end
  return nil
end
