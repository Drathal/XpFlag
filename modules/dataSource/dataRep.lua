local D, C, L = unpack(select(2, ...))

local _G = _G
local GetXPExhaustion = _G.GetXPExhaustion
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local GetRealmName = _G.GetRealmName
local GetNumFactions = _G.GetNumFactions
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetFriendshipReputation = _G.GetFriendshipReputation
local GetFactionInfo = _G.GetFactionInfo
local GetFactionInfoByID = _G.GetFactionInfoByID
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local hooksecurefunc = _G.hooksecurefunc
local format = _G.format
local tonumber = _G.tonumber
local select = _G.select
local pairs = _G.pairs

local moduleName = "dataRep"
local module = D:NewModule(moduleName, "AceEvent-3.0")

local nameRealm = UnitName("player").."-"..GetRealmName()
local data = nil
local prevData = {}
local lastFactionID = nil

function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    hooksecurefunc('SetWatchedFactionIndex', function() self:Update() end)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UPDATE_FACTION")
end

function module:OnDisable()
    --@alpha@
    D.Debug(moduleName, "OnDisable")
    --@end-alpha@

    self:UnregisterEvent("UPDATE_FACTION")
end

function module:PLAYER_ENTERING_WORLD()
    --@alpha@
    D.Debug(moduleName, "PLAYER_ENTERING_WORLD")
    --@end-alpha@

    self:Update()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

function module:UPDATE_FACTION(event, unit)
    -- if unit ~= 'player' then return end
    --@alpha@
    D.Debug(moduleName, "UPDATE_FACTION", event, unit)
    --@end-alpha@

    self:Update()
end

function module:getSomeFactionID()
    for index = 1, GetNumFactions() do
        local name, _, standingID, min, max, cur, _, _, isHeader, _, _, _, _, factionID = GetFactionInfo(index)
        if not isHeader and cur > 3300 then
            return factionID
        end
    end
    return
end

function module:GetData(mix)
    local d = mix or {}

    local name, standingID, min, max, cur, factionID = GetWatchedFactionInfo()

    if not name then
        local _
        name, _, standingID, min, max, cur, _, _, _, _, _, _, _, factionID = GetFactionInfoByID(self:getSomeFactionID())
    end

    d.dataType = moduleName
    d.name = d.name or UnitName("PLAYER")
    d.realm = d.realm or GetRealmName()
    d.level = d.level or UnitLevel("PLAYER")
    d.class = d.class or select(2, UnitClass("PLAYER"))
    d.disable = d.disable or false

    d.min = d.min or min
    d.value = d.value or cur - min
    d.max = d.max or max - min
    d.gain = d.gain or tonumber(d.value) - tonumber(prevData.value or 0) or 0

    d.cR = d.cR or FACTION_BAR_COLORS[5].r
    d.cG = d.cG or FACTION_BAR_COLORS[5].g
    d.cB = d.cB or FACTION_BAR_COLORS[5].b

    d.factionID = d.factionID or factionID
    d.faction = d.faction or name
    d.standingID = d.standingID or standingID

    return d
end

function module:IsUpdated(data)
    if not prevData.dataType then
        return true
    end

    if prevData.dataType then
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
