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
local MAX_PLAYER_LEVEL_TABLE = _G.MAX_PLAYER_LEVEL_TABLE
local ERR_EXHAUSTION_RESTED = _G.ERR_EXHAUSTION_RESTED
local ERR_EXHAUSTION_WELLRESTED = _G.ERR_EXHAUSTION_WELLRESTED
local ERR_EXHAUSTION_NORMAL = _G.ERR_EXHAUSTION_NORMAL
local ERR_EXHAUSTION_TIRED = _G.ERR_EXHAUSTION_TIRED
local GetExpansionLevel = _G.GetExpansionLevel
local format = _G.format
local tonumber = _G.tonumber
local select = _G.select
local pairs = _G.pairs

local moduleName = "dataXp"
local module = D:NewModule(moduleName, "AceEvent-3.0")

local nameRealm = UnitName("player").."-"..GetRealmName()
local data = nil
local prevData = {}


function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_UPDATE_RESTING")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("PLAYER_XP_UPDATE")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("CHAT_MSG_SYSTEM")

    self:Update()
end

function module:OnDisable()
    --@alpha@
    D.Debug(moduleName, "OnDisable")
    --@end-alpha@

    self:UnregisterEvent("PLAYER_UPDATE_RESTING")
    self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
    self:UnregisterEvent("PLAYER_XP_UPDATE")
    self:UnregisterEvent("PLAYER_LEVEL_UP")
    self:UnregisterEvent("CHAT_MSG_SYSTEM")
end

function module:CHAT_MSG_SYSTEM(event, msg)
    --@alpha@
    D.Debug(moduleName, "CHAT_MSG_SYSTEM", msg)
    --@end-alpha@

    if msg ~= ERR_EXHAUSTION_RESTED
    and msg ~= ERR_EXHAUSTION_WELLRESTED
    and msg ~= ERR_EXHAUSTION_NORMAL
    and msg ~= ERR_EXHAUSTION_TIRED then return end

    self:Update()
end

function module:PLAYER_ENTERING_WORLD()
    --@alpha@
    D.Debug(moduleName, "PLAYER_ENTERING_WORLD")
    --@end-alpha@

    self:Update()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

function module:ZONE_CHANGED_NEW_AREA()
    --@alpha@
    D.Debug(moduleName, "ZONE_CHANGED_NEW_AREA")
    --@end-alpha@

    self:Update()
end

function module:PLAYER_UPDATE_RESTING()
    --@alpha@
    D.Debug(moduleName, "PLAYER_UPDATE_RESTING")
    --@end-alpha@

    self:Update()
end

function module:PLAYER_LEVEL_UP()
    --@alpha@
    D.Debug(moduleName, "PLAYER_LEVEL_UP")
    --@end-alpha@

    self:Update()
end

function module:PLAYER_XP_UPDATE(event, unit)
    if unit ~= 'player' then return end
    --@alpha@
    D.Debug(moduleName, "PLAYER_XP_UPDATE")
    --@end-alpha@

    self:Update()
end

function module:GetData(mix)
    --@alpha@
    -- D.Debug(moduleName, "GetData")
    --@end-alpha@

    local d = mix or {}

    d.dataType = moduleName
    d.name = d.name or UnitName("PLAYER")
    d.realm = d.realm or GetRealmName()
    d.level = d.level or UnitLevel("PLAYER")
    d.class = d.class or select(2, UnitClass("PLAYER"))
    d.disable = d.disable or MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] == UnitLevel("PLAYER")

    d.value = d.value or UnitXP("PLAYER")
    d.max = d.max or UnitXPMax("PLAYER")
    d.gain = d.gain or tonumber(d.value) - tonumber(prevData.value or 0) or 0
    d.rested = d.rested or (GetXPExhaustion() or 0)

    d.cR = d.cR or d.rested > 0 and C.player.colorRested[1] or C.player.color[1]
    d.cG = d.cG or d.rested > 0 and C.player.colorRested[2] or C.player.color[2]
    d.cB = d.cB or d.rested > 0 and C.player.colorRested[3] or C.player.color[3]

    return d
end

function module:IsUpdated(data)
    if (prevData.dataType) then
        for k1, v1 in pairs(data) do
            if v1 ~= prevData[k1] then
                return true
            end
        end
    end
end

function module:Update()
    data = self:GetData()

    if self:IsUpdated(data) then
        --@alpha@
        D.Debug(moduleName, "Update - SendMessage", moduleName..":Update", nameRealm )
        --@end-alpha@
        D:SendMessage(moduleName..":Update", nameRealm, data)
    end

    prevData = data

    if data.disable then
        self:Disable()
    end
end