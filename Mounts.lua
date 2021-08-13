local M = _G["Mountable"]
local tContains = tContains

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

  local mounts = M:GetMountGroup(group)

  -- TODO: Add swimming mount compatibility
  -- if M:IsSwimming() and M.db.profile.aquaticOverride then
  --   mounts = M:GetFilteredMountGroup(mounts, mountTypes.aquatic)
  if M:CanFly() then
    mounts = M:GetFilteredMountGroup(mounts, mountTypes.flying)
  elseif not M:CanFly() and M.db.profile.preferGroundMount then
    mounts = M:GetFilteredMountGroup(mounts, mountTypes.ground)
  end

  local mount = M:GetRandomMountFromGroup(mounts)
  -- local mountId = C_MountJournal.GetMountFromSpell(mountSpellId)
  C_MountJournal.SummonByID(mount.mountID)
end

-- Get random mount from the group
-- TODO: Implement flying/ground filter
function M:GetRandomMountFromGroup(mounts)
  if not mounts then
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

function M:GetFilteredMountGroup(mounts, mountType)
  local filteredMounts = { }

  for k,v in pairs(mounts) do
    if v.type == mountType then
      filteredMounts[k] = v
    end
  end

  --if we have no valid mounts just return the whole group
  if not next(filteredMounts) then
    return mounts
  else
    return filteredMounts
  end
end

-- Expert Riding 34090
-- Master Riding 90265
function M:CanFly()
  if IsFlyableArea() and (IsSpellKnown(34090) or IsSpellKnown(90265)) then
    return 1
  end
  return nil
end

function M:IsSwimming()

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
