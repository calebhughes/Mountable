local M = _G["Mountable"]

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

  local mountSpellId = M:GetRandomMountFromGroup(group)
  local mountId = C_MountJournal.GetMountFromSpell(mountSpellId)
  C_MountJournal.SummonByID(mountId)
end

-- Get random mount from the group
-- TODO: Implement flying/ground filter
function M:GetRandomMountFromGroup(group)
  local mountGroup = M:GetMountGroupTable(group)
  if not mountGroup then
    return
  end
  return mountGroup[math.random(#mountGroup)]
end

-- Check if group exists in our profile or not
function M:GetMountGroupTable(group)
  if M.db.profile.groups[group] then
    return M.db.profile.groups[group]
  end
  return nil
end

-- Expert Riding 34090
-- Master Riding 90265
function M:CanFly()
  if IsFlyableArea and (IsSpellKnown(34090) or IsSpellKnown(90265)) then
    return 1
  end
  return nil
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
