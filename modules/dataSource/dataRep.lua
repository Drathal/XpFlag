local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local GetRealmName = _G.GetRealmName
local GetNumFactions = _G.GetNumFactions
local GetFactionInfo = _G.GetFactionInfo
local IsFactionParagon = _G.IsFactionParagon
local GetFactionInfoByID = _G.GetFactionInfoByID
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local COLORS = _G.RAID_CLASS_COLORS
local MAX_REPUTATION_REACTION = _G.MAX_REPUTATION_REACTION
local hooksecurefunc = _G.hooksecurefunc
local tonumber = _G.tonumber
local select = _G.select
local format = _G.string.format
local CopyTable = _G.CopyTable

local moduleName = "dataRep"
local module = D:NewModule(moduleName, "AceEvent-3.0")

local nameRealm = UnitName("player") .. "-" .. GetRealmName()
local data = nil
local setByAddon = false

_G["FACTION_STANDING_LABEL" .. (MAX_REPUTATION_REACTION + 1)] = L["Paragon"]
--COLORS[MAX_REPUTATION_REACTION + 1] = {0, 0.5, 0.9} -- paragon color

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


            if not setByAddon then
                self:Update()
            else
                setByAddon = false
            end
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
            setByAddon = true
            SetWatchedFactionIndex(index)
            return factionID
        end
    end
    return
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

    local faction, standingID, min, max, cur, factionID = GetWatchedFactionInfo()

    if not faction then
        local _
        faction, _, standingID, min, max, cur, _, _, _, _, _, _, _, factionID = GetFactionInfoByID(self:getSomeFactionID())        
    end

    if standingID == 8 and C_Reputation.IsFactionParagon(factionID) then
        cur, _, _, _ = C_Reputation.GetFactionParagonInfo(factionID) 
        min = 10000
        max = 20000
        standingID = 9
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

    d.hashKey = faction .. standingID  
    d.hash = faction .. d.value .. standingID  

    d.gain = tonumber(d.value) - tonumber(d.prevValue[d.hashKey] or 0) or 0

    if d.gain < 1 then
        d.gain = 0
    end

    d.cR = FACTION_BAR_COLORS[5].r
    d.cG = FACTION_BAR_COLORS[5].g
    d.cB = FACTION_BAR_COLORS[5].b

    d.factionID = factionID
    d.faction = faction
    d.standingID = standingID

    return d
end

function module:AddTooltip(tooltip, d)
    tooltip:AddLine(format(L["REP_MARK_TT_1"], D.addonName))
    tooltip:AddLine(format(L["REP_MARK_TT_2"], d.name, d.level), COLORS[d.class].r, COLORS[d.class].g, COLORS[d.class].b, 1)
    tooltip:AddLine(format(L["REP_MARK_TT_3"], d.faction, _G["FACTION_STANDING_LABEL" .. d.standingID]), 1, 1, 1, 1)
    tooltip:AddLine(format(L["REP_MARK_TT_4"], D.FormatNumber(d.value), D.FormatNumber(d.max), d.value / d.max * 100), 1, 1, 1, 1)
end

function module:Update()
    data = self:GetData(data)

    if data.prevHash ~= data.hash then
        --@alpha@
        D.Debug(moduleName, "Update - SendMessage", moduleName .. ":Update", nameRealm)
        --@end-alpha@
        D:SendMessage(moduleName .. ":Update", nameRealm, data)
    end

    data.prevHash = data.hash

    if data.isMax then
        self:Disable()
    end
end
