local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local GetRealmName = _G.GetRealmName
local HasArtifactEquipped = _G.HasArtifactEquipped
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local GetEquippedArtifactInfo = _G.C_ArtifactUI.GetEquippedArtifactInfo
local GetNumArtifactTraitsPurchasableFromXP = _G.MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local COLORS = _G.RAID_CLASS_COLORS
local hooksecurefunc = _G.hooksecurefunc
local tonumber = _G.tonumber
local select = _G.select
local format = _G.string.format

local moduleName = "dataAp"
local module = D:NewModule(moduleName, "AceEvent-3.0")

local nameRealm = UnitName("player") .. "-" .. GetRealmName()
local data = nil
local prevHash = ""
local prevValue = 0

function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ARTIFACT_XP_UPDATE")
end

function module:OnDisable()
    --@alpha@
    D.Debug(moduleName, "OnDisable")
    --@end-alpha@

    self:UnregisterEvent("ARTIFACT_XP_UPDATE")
end

function module:PLAYER_ENTERING_WORLD()
    --@alpha@
    D.Debug(moduleName, "PLAYER_ENTERING_WORLD")
    --@end-alpha@

    self:Update()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function module:ARTIFACT_XP_UPDATE(event, unit)
    if unit ~= "player" then
        return
    end
    --@alpha@
    D.Debug(moduleName, "ARTIFACT_XP_UPDATE", event, unit)
    --@end-alpha@

    self:Update()
end

function module:GetData(mix)
    local canGetData = HasArtifactEquipped() and not UnitHasVehicleUI("player")

    if not canGetData then
        return mix
    end

    local d = mix or {}

    local _, _, name, _, totalPower, traitsLearned, _, _, _, _, _, _, tier = GetEquippedArtifactInfo()
    local numTraitsLearnable, power, powerForNextTrait = GetNumArtifactTraitsPurchasableFromXP(traitsLearned, totalPower, tier)

    d.dataSource = moduleName
    d.name = d.name or UnitName("PLAYER")
    d.realm = d.realm or GetRealmName()
    d.class = d.class or select(2, UnitClass("PLAYER"))
    d.isMax = d.isMax or false

    d.level = UnitLevel("PLAYER")
    d.value = power
    d.max = powerForNextTrait
    d.gain = tonumber(d.value) - tonumber(prevValue or 0) or 0

    d.cR = .901
    d.cG = .8
    d.cB = .601

    d.traitsLearned = traitsLearned
    d.totalPower = totalPower
    d.actifactName = name

    prevValue = d.value

    return d
end

function module:AddTooltip(tooltip, d)
    tooltip:AddLine(format(L["AP_MARK_TT_1"], D.addonName))
    tooltip:AddLine(format(L["AP_MARK_TT_2"], d.name, d.level), COLORS[d.class].r, COLORS[d.class].g, COLORS[d.class].b, 1)
    tooltip:AddLine(format(L["AP_MARK_TT_3"], d.actifactName, d.traitsLearned), 1, 1, 1, 1)
    tooltip:AddLine(format(L["AP_MARK_TT_4"], D.FormatNumber(d.value), D.FormatNumber(d.max), d.value / d.max * 100), 1, 1, 1, 1)
end

function module:Update()
    data = self:GetData(data)

    if prevHash ~= data.name .. data.value then
        --@alpha@
        D.Debug(moduleName, "Update - SendMessage", moduleName .. ":Update", nameRealm)
        --@end-alpha@
        D:SendMessage(moduleName .. ":Update", nameRealm, data)
    end

    prevHash = data.name .. data.value

    if data.isMax then
        self:Disable()
    end
end
