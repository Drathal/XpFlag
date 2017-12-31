local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local pairs = _G.pairs
local select = _G.select
local unpack = _G.unpack
local match = _G.string.match
local gsub = _G.gsub
local assert = _G.assert
local CreateFrame = _G.CreateFrame
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local UnitLevel = _G.UnitLevel
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS

local marks = {}

local moduleName = "mark"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:OnAnimation(mark)
    D.AnimateX(mark, function() D:SendMessage("mark:AnimateXEnd", mark) end )    
end

function module:String2Position(posString, dataSource)
    local p = {}
    p["SCREENTOP"] = {"TOP", "UIParent", "TOPLEFT", 0, 0}
    p["SCREENBOTTOM"] = {"BOTTOM", "UIParent", "BOTTOMLEFT", 0, 0}

    if _G["ArtifactWatchBar"]:IsVisible() and dataSource == "dataAp" then
        p["BLIZZEXPBAR"] = {"TOP", "ArtifactWatchBar", "TOPLEFT", 0, -8}
    end

    if _G["MainMenuExpBar"]:IsVisible() and dataSource == "dataXp" then
        p["BLIZZEXPBAR"] = {"TOP", "MainMenuExpBar", "TOPLEFT", 0, -8}
    end

    if _G["ReputationWatchBar"]:IsVisible() and dataSource == "dataRep" then
        p["BLIZZEXPBAR"] = {"TOP", "ReputationWatchBar", "TOPLEFT", 0, -8}
    end

    return p[posString] or p["SCREENTOP"]
end

function module:CreateMark(id, data)
    --@alpha@
    D.Debug(moduleName, "CreateMark", id)
    assert(id, "mark:CreateMark - id is missing")
    assert(data, "mark:CreateMark - data is missing")
    --@end-alpha@

    local rcolor = RAID_CLASS_COLORS[data.class]
    local position = self:String2Position(C.db.profile.mark.position, data.dataSource)

    local m = CreateFrame("Frame", "XpFlagMark_" .. id:gsub("%W", ""), _G[select(2, unpack(position))])
    m:SetPoint(unpack(position))
    m:SetFrameStrata("DIALOG")
    m:SetFrameLevel(1)
    m:SetAlpha(1)
    m:SetHeight(C.db.profile.mark.size)
    m:SetWidth(C.db.profile.mark.size)
    m:EnableMouse()

    m.texture = m:CreateTexture(nil, "OVERLAY")
    m.texture:SetAllPoints(m)

    m.data = data
    m.player = id == D.nameRealm
    m.anim = D.CreateUpdateAnimation(m, self.OnAnimation)
    m.model = D:GetModule("markModel"):Create(m)
    m.sparks = D:GetModule("markSpark"):Create(m)
    m.tooltip = D:GetModule("markTooltip"):Create(m)

    marks[id] = m

    self:UpdateMark(id)

    --@alpha@
    D.Debug(moduleName, "CreateMark - SendMessage", moduleName .. ":Create", id)
    --@end-alpha@
    D:SendMessage(moduleName .. ":Create", id)

end

function module:UpdateMark(id, data)
    --@alpha@
    D.Debug(moduleName, "UpdateMark", id)
    assert(id, "mark:UpdateMark - id is missing")    
    --@end-alpha@

    local m = self:GetMark(id)

    if data then
        m.data = data
    end

    local rcolor = RAID_CLASS_COLORS[m.data.class]
    local flip = match(C.db.profile.mark.position, "TOP") == nil
    local newPos = self:String2Position(C.db.profile.mark.position, m.data.dataSource)
    newPos[1] = gsub(newPos[1], "TOP", flip and "BOTTOM" or "TOP")

    --@alpha@
    D.Debug(moduleName, "UpdateMark - SendMessage", moduleName .. ":Update", id, m)
    --@end-alpha@
    D:SendMessage(moduleName .. ":Update", id, m)

    m:ClearAllPoints()
    m:SetPoint(unpack(newPos))

    m.to = _G[newPos[2]]:GetWidth() * m.data.value / m.data.max
    m:SetHeight(C.db.profile.mark.size)
    m:SetWidth(C.db.profile.mark.size)
    m.texture:SetTexture(D.GetMarkTexture(m.data.level, UnitLevel("player")))
    m.texture:SetVertexColor(rcolor.r, rcolor.g, rcolor.b)
    m.texture:SetTexCoord(unpack(flip and {0, 1, 0, 1} or {0, 1, 1, 0}))
    m:Show()

    m.anim.Start()

    if not m.player then
        return m
    end

    m.texture:SetVertexColor(m.data.cR, m.data.cG, m.data.cB)

    return m
end

function module:DeleteMark(id)
    --@alpha@
    D.Debug(moduleName, "DeleteMark", id)
    --@end-alpha@

    if not id then
        return
    end
    if not marks[id] then
        return
    end
    marks[id]:Hide()
    marks[id] = nil

    --@alpha@
    D.Debug(moduleName, "DeleteMark - SendMessage", moduleName .. ":Delete", id)
    --@end-alpha@

    D:SendMessage("mark:Delete", id)
end

function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    self:RegisterMessage("com:Data", "Update")
    self:RegisterMessage("com:Request", "Update")
    self:RegisterMessage("com:Delete", "DeleteMark")
    self:RegisterMessage("dataSource:Update", "Update")
end

function module:OnDisable()
    --@alpha@
    D.Debug(moduleName, "OnDisable")
    --@end-alpha@

    self:UnregisterMessage("com:Data")
    self:UnregisterMessage("com:Request")
    self:UnregisterMessage("com:Delete")
    self:UnregisterMessage("dataSource:Update")
end

function module:Config(key, value)
    --@alpha@
    D.Debug(moduleName, "Config", key, value)
    --@end-alpha@

    if key == "showPlayer" and value and not self:GetMark(D.nameRealm) then
        self:CreateMark(D.nameRealm, D:GetModule(C.db.profile.mark.dataSource):GetData())
    end

    if key == "showPlayer" and not value and self:GetMark(D.nameRealm) then
        self:DeleteMark(D.nameRealm)
    end

    if key == "dataSource" then
        self:GetMark(D.nameRealm).data = D:GetModule(C.db.profile.mark.dataSource):GetData()        
    end

    for mid, mark in pairs(marks) do
        D:GetModule("markModel"):Config(mark.model)
        self:UpdateMark(mid)
    end
end

function module:Update(msg, id, data, source)
    --@alpha@
    assert(msg, "mark:Update - msg is missing")
    assert(id, "mark:Update - id is missing")
    assert(data, "mark:Update - data is missing")
    --@end-alpha@

    if C.db.profile.mark.dataSource .. ":Update" ~= source and id == D.nameRealm then
        return
    end

    if not C.db.profile.mark.showPlayer and id == D.nameRealm then
        return
    end

    if data.isMax then
        return self:DeleteMark(id)
    end

    --@alpha@
    D.Debug(moduleName, "Update", msg, id, data, data.dataSource)
    --@end-alpha@

    if not self:GetMark(id) then
       self:CreateMark(id, data)        
    end
    
    self:UpdateMark(id, data)
    
end

function module:HasMark(id)
    --@alpha@
    D.Debug(moduleName, "HasMark", id)
    assert(id, "bar:HasMark - id is missing")
    --@end-alpha@

    if not marks[id] then
        return false
    end
    return true
end

function module:GetMark(id)
    --@alpha@
    D.Debug(moduleName, "GetMark", id)
    assert(id, "bar:GetMark - id is missing")
    --@end-alpha@

    return marks[id]
end

function module:GetMarks()
    --@alpha@
    D.Debug(moduleName, "GetMarks")
    --@end-alpha@

    return marks
end
