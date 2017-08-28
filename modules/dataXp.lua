local D, C, L = unpack(select(2, ...))

local _G = _G
local GetXPExhaustion = _G.GetXPExhaustion
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local UnitName = _G.UnitName
local GameTooltip = _G.GameTooltip
local UnitClass = _G.UnitClass
local GetRealmName = _G.GetRealmName
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local MAX_PLAYER_LEVEL_TABLE = _G.MAX_PLAYER_LEVEL_TABLE
local GetExpansionLevel = _G.GetExpansionLevel
local format = _G.format
local tonumber = _G.tonumber

local module = D:NewModule("dataXp", "AceEvent-3.0")
local prevData = {}

function module:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_UPDATE_RESTING")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("PLAYER_XP_UPDATE")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:Update()
end

function module:OnDisable()
    self:UnregisterEvent("PLAYER_UPDATE_RESTING")
    self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
    self:UnregisterEvent("PLAYER_XP_UPDATE")
    self:UnregisterEvent("PLAYER_LEVEL_UP")
end

function module:PLAYER_ENTERING_WORLD()
    self:Update()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

function module:ZONE_CHANGED_NEW_AREA()
    self:Update()
end

function module:PLAYER_UPDATE_RESTING()
    self:Update()
end

function module:PLAYER_LEVEL_UP()
    self:Update()
end

function module:PLAYER_XP_UPDATE(event, unit)
    if unit ~= 'player' then return end
    self:Update()
end

function module:GetData(mix)

    print("mix", mix)

    local d = mix or {}

    d.dataType = "XP"
    d.name = d.name or UnitName("PLAYER")
    d.realm = d.realm or GetRealmName()
    d.level = d.level or UnitLevel("PLAYER")
    d.class = d.class or select(2, UnitClass("PLAYER"))
    d.disable = d.disable or MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] == UnitLevel("PLAYER")

    d.value = d.value or UnitXP("PLAYER")
    d.max = d.max or UnitXPMax("PLAYER")
    d.gain = tonumber(d.value) - tonumber(prevData.value or 0) or 0
    d.rested = d.rested or GetXPExhaustion() or 0

    d.cR = d.cR or d.rested and C.player.colorRested.r or C.player.color.r
    d.cG = d.cG or d.rested and C.player.colorRested.g or C.player.color.g
    d.cB = d.cB or d.rested and C.player.colorRested.b or C.player.color.b

    prevData = d

    return d
end

function module:Tooltip(data)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(D.addonName)
    GameTooltip:AddLine(data.name, data.color.r, data.color.g, data.color.b, 1)
    GameTooltip:AddLine("Level: "..data.level, 1, 1, 1, 1)
    GameTooltip:AddLine("XP: "..data.xp.." / "..data.max.." ("..format("%.2f", data.p * 100).."%)", 1, 1, 1, 1)
    if data.rested then
        GameTooltip:AddLine("Rested: "..data.rested.." ("..format("%.2f", data.rp * 100).."%)", 1, 1, 1, 1)
    end
    GameTooltip:Show()
end

function module:Update()
    local data = self:GetData()

    D:SendMessage("DataXpUpdate", D.nameRealm, data)

    if data.isMaxLevel then
        self:Disable()
    end
end
