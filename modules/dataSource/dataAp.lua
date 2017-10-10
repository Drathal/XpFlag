local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local GetRealmName = _G.GetRealmName
local GetNumFactions = _G.GetNumFactions
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetFactionInfo = _G.GetFactionInfo
local GetFactionInfoByID = _G.GetFactionInfoByID
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local hooksecurefunc = _G.hooksecurefunc
local tonumber = _G.tonumber
local select = _G.select

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

    hooksecurefunc(
        "SetWatchedFactionIndex",
        function(factionIndex)
            --@alpha@
            D.Debug(moduleName, "SetWatchedFactionIndex", factionIndex)
            --@end-alpha@
            self:Update()
        end
    )
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
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function module:UPDATE_FACTION(event, unit)
    if unit ~= "player" then
        return
    end
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

    d.dataSource = moduleName
    d.name = d.name or UnitName("PLAYER")
    d.realm = d.realm or GetRealmName()
    d.class = d.class or select(2, UnitClass("PLAYER"))
    d.isMax = d.isMax or false

    d.level = UnitLevel("PLAYER")
    d.min = min
    d.value = cur - min
    d.max = max - min
    d.gain = tonumber(d.value) - tonumber(prevValue or 0) or 0

    d.cR = FACTION_BAR_COLORS[5].r
    d.cG = FACTION_BAR_COLORS[5].g
    d.cB = FACTION_BAR_COLORS[5].b

    d.factionID = factionID
    d.faction = name
    d.standingID = standingID

    prevValue = d.value

    return d
end

function module:Update()
    data = self:GetData(data)

    if prevHash ~= data.factionID .. data.value then
        --@alpha@
        D.Debug(moduleName, "Update - SendMessage", moduleName .. ":Update", nameRealm)
        --@end-alpha@
        D:SendMessage(moduleName .. ":Update", nameRealm, data)
    end

    prevHash = data.factionID .. data.value

    if data.isMax then
        self:Disable()
    end
end
