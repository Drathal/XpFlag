local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local GetXPExhaustion = _G.GetXPExhaustion
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local GetRealmName = _G.GetRealmName
local MAX_PLAYER_LEVEL_TABLE = _G.MAX_PLAYER_LEVEL_TABLE
local ERR_EXHAUSTION_RESTED = _G.ERR_EXHAUSTION_RESTED
local ERR_EXHAUSTION_WELLRESTED = _G.ERR_EXHAUSTION_WELLRESTED
local ERR_EXHAUSTION_NORMAL = _G.ERR_EXHAUSTION_NORMAL
local ERR_EXHAUSTION_TIRED = _G.ERR_EXHAUSTION_TIRED
local COLORS = _G.RAID_CLASS_COLORS
local GetExpansionLevel = _G.GetExpansionLevel
local tonumber = _G.tonumber
local select = _G.select
local format = _G.string.format

local moduleName = "dataXp"
local module = D:NewModule(moduleName, "AceEvent-3.0")

local nameRealm = UnitName("player") .. "-" .. GetRealmName()
local data = nil

function module:getConfig(key)
    return C.db.profile.dataSource[moduleName][key]
end

function module:shouldActivate()
    return not (MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] == UnitLevel("PLAYER"))
           and (self:getConfig("enabled") and (self:getConfig("sendData") or self:getConfig("markShowOwn")))
end

function module:OnEnable()
    if not self:shouldActivate() then return self:Disable() end

    D.Debug(moduleName, "enabled")

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update")
    self:RegisterEvent("PLAYER_UPDATE_RESTING", "Update")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update")
    self:RegisterEvent("PLAYER_XP_UPDATE", "Update")
    self:RegisterEvent("PLAYER_LEVEL_UP", "Update")
    self:RegisterEvent("CHAT_MSG_SYSTEM", "Update")
end

function module:OnDisable(d)
    D.Debug(moduleName, "disabled")

    D:SendMessage(moduleName .. ":Update", nameRealm, d)

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("PLAYER_UPDATE_RESTING")
    self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
    self:UnregisterEvent("PLAYER_XP_UPDATE")
    self:UnregisterEvent("PLAYER_LEVEL_UP")
    self:UnregisterEvent("CHAT_MSG_SYSTEM")
end

function module:GetData(mix)
    local d = mix or {}

    if d.hash then
        d.prev = d.hash
    end

    if d.value then
        d.prevValue = d.value
    end

    d.dataSource = d.dataSource or moduleName
    d.name = d.name or UnitName("PLAYER")
    d.realm = d.realm or GetRealmName()
    d.class = d.class or select(2, UnitClass("PLAYER"))

    d.level = UnitLevel("PLAYER")
    d.isMax = not self:shouldActivate()
    d.value = UnitXP("PLAYER")
    d.max = UnitXPMax("PLAYER")
    d.gain = tonumber(d.value) - tonumber(d.prevValue or 0) or 0
    d.rested = (GetXPExhaustion() or 0)

    d.cR = d.rested > 0 and C.player.colorRested[1] or C.player.color[1]
    d.cG = d.rested > 0 and C.player.colorRested[2] or C.player.color[2]
    d.cB = d.rested > 0 and C.player.colorRested[3] or C.player.color[3]

    d.hashKey = d.dataSource
    d.hash = d.level .. d.value .. d.rested

    return d
end

function module:AddTooltip(tooltip, d)
    tooltip:AddLine(format(L["XP_MARK_TT_1"], D.addonName))
    tooltip:AddLine(format(L["XP_MARK_TT_2"], d.name, d.level), COLORS[d.class].r, COLORS[d.class].g, COLORS[d.class].b, 1)
    tooltip:AddLine(format(L["XP_MARK_TT_3"], D.FormatNumber(d.value), D.FormatNumber(d.max), d.value / d.max * 100), 1, 1, 1, 1)
    tooltip:AddLine(format(L["XP_MARK_TT_4"], D.FormatNumber(d.rested), d.rested / d.max * 100), 1, 1, 1, 1)
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
        self:Disable(data)
    end
end
