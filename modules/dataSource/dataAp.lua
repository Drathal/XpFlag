local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local GetRealmName = _G.GetRealmName
local HasArtifactEquipped = HasArtifactEquipped
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local GetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local GetNumArtifactTraitsPurchasableFromXP = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local COLORS = _G.RAID_CLASS_COLORS
local hooksecurefunc = _G.hooksecurefunc
local tonumber = _G.tonumber
local select = _G.select
local format = _G.string.format

local moduleName = "dataAp"
local module = D:NewModule(moduleName, "AceEvent-3.0")

local nameRealm = UnitName("player") .. "-" .. GetRealmName()
local data = nil

function module:getConfig(key)
    return C.db.profile.dataSource[moduleName][key]
end

function module:shouldActivate()
    return (UnitLevel("PLAYER") >= 100 and UnitLevel("PLAYER") <= 110)
           and (self:getConfig("enabled") and (self:getConfig("sendData") or self:getConfig("markShowOwn")))
end

function module:OnEnable()
    if not self:shouldActivate() then return self:Disable() end

    D.Debug(moduleName, "enabled")

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update")
    self:RegisterEvent("ARTIFACT_UPDATE", "Update")
end

function module:OnDisable()
    D.Debug(moduleName, "disabled")
    D:SendMessage(moduleName .. ":Update", nameRealm, data)

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("ARTIFACT_UPDATE")
end

function module:GetData(mix)
    local d = mix or {}

    if d.hash then
        d.prevHash = d.hash
    end

    d.prevValue = d.prevValue or {}

    if d.value and d.hashKey then
        d.prevValue[d.hashKey] = d.value
    end

    local canGetData = HasArtifactEquipped() and not UnitHasVehicleUI("player")
    local actifactName, totalPower, traitsLearned, tier, numTraitsLearnable, power, powerForNextTrait

    if canGetData then
        _, _, actifactName, _, totalPower, traitsLearned, _, _, _, _, _, _, tier = GetEquippedArtifactInfo()
        numTraitsLearnable, power, powerForNextTrait = GetNumArtifactTraitsPurchasableFromXP(traitsLearned, totalPower, tier)
    end

    if powerForNextTrait <= 0 then
        powerForNextTrait = power
    end

    actifactName = actifactName or "none"

    d.dataSource = moduleName
    d.name = d.name or UnitName("PLAYER")
    d.realm = d.realm or GetRealmName()
    d.class = d.class or select(2, UnitClass("PLAYER"))

    d.isMax = not self:shouldActivate()
    d.level = UnitLevel("PLAYER")
    d.value = power or 0
    d.max = powerForNextTrait or 0

    d.hashKey = actifactName
    d.hash = actifactName .. d.value

    d.gain = tonumber(d.value) - tonumber(d.prevValue[d.hashKey] or 0) or 0

    if d.gain < 1 or tonumber(d.prevValue[d.hashKey] or 0) == 0 then
        d.gain = 0
    end

    d.cR = .901
    d.cG = .8
    d.cB = .601

    d.traitsLearned = traitsLearned or 0
    d.totalPower = totalPower or 0
    d.actifactName = actifactName or "none"

    return d
end

function module:AddTooltip(tooltip, d)
    tooltip:AddLine(format(L["AP_MARK_TT_1"], D.addonName))
    tooltip:AddLine(format(L["AP_MARK_TT_2"], d.name, d.level), COLORS[d.class].r, COLORS[d.class].g, COLORS[d.class].b, 1)
    tooltip:AddLine(format(L["AP_MARK_TT_3"], d.actifactName, d.traitsLearned), 1, 1, 1, 1)
    tooltip:AddLine(format(L["AP_MARK_TT_4"], D.FormatNumber(d.value), D.FormatNumber(d.max), d.value / d.max * 100), 1, 1, 1, 1)
end

function module:Update(event, unit)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end

    data = self:GetData(data)

    if data.prevHash ~= data.hash then
        D:SendMessage(moduleName .. ":Update", nameRealm, data)
    end

    data.prevHash = data.hash

    if data.isMax then
        self:Disable()
    end
end
