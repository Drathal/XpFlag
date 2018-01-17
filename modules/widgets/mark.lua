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

function module:OnEnable()
    self:RegisterMessage("com:Data", "Update")
    self:RegisterMessage("com:Request", "Update")
    self:RegisterMessage("com:Delete", "DeleteMark")
    self:RegisterMessage("dataSource:Disable", "DeleteMark")
    self:RegisterMessage("dataSource:Update", "Update")
end

function module:OnDisable()
    self:UnregisterMessage("com:Data")
    self:UnregisterMessage("com:Request")
    self:UnregisterMessage("com:Delete")
    self:UnregisterMessage("dataSource:Disable")
    self:UnregisterMessage("dataSource:Update")
end

function module:getConfig(data, key)
    --D.Debug(moduleName, "getConfig", data.dataSource, key)
    return C.db.profile.dataSource[data.dataSource][key]
end

function module:OnAnimation(mark)
    D.AnimateX(mark, function() D:SendMessage("mark:AnimateXEnd", mark) end )
end

function module:CreateMark(id, data)
    D.Debug(moduleName, "CreateMark", id, data)

    local position = D.String2Position(self:getConfig(data, "markPosition"), data.dataSource)

    local m = CreateFrame("Frame", "XpFlagMark_" .. id, _G[select(2, unpack(position))])
    m:SetPoint(unpack(position))
    m:SetFrameStrata("DIALOG")
    m:SetFrameLevel(1)
    m:SetAlpha(1)
    m:SetHeight(self:getConfig(data, "markSize"))
    m:SetWidth(self:getConfig(data, "markSize"))
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

    D:SendMessage(moduleName .. ":Create", id)

    self:UpdateMark(id)
end

function module:UpdateMark(id, data)

    D.Debug(moduleName, "UpdateMark", id)

    local m = self:GetMark(id)

    if data then
        m.data = data
        D.Debug(moduleName, "UpdateMark", id, m)
    end

    local flip = match(self:getConfig(m.data, "markPosition"), "TOP") == nil
    local newPos = D.String2Position(self:getConfig(m.data, "markPosition"), m.data.dataSource)
    newPos[1] = gsub(newPos[1], "TOP", flip and "BOTTOM" or "TOP")

    m:ClearAllPoints()
    m:SetPoint(unpack(newPos))

    m.to = _G[newPos[2]]:GetWidth() * m.data.value / m.data.max
    m:SetHeight(self:getConfig(m.data, "markSize"))
    m:SetWidth(self:getConfig(m.data, "markSize"))
    m.texture:SetTexture(D.GetMarkTexture(m.data.level, UnitLevel("player")))
    m.texture:SetVertexColor(m.data.cR, m.data.cG, m.data.cB)
    m.texture:SetTexCoord(unpack(flip and {0, 1, 0, 1} or {0, 1, 1, 0}))
    m:Show()

    m.anim.Start()

    if data then
        D:SendMessage(moduleName .. ":Update", id, m)
    end

    return m
end

function module:DeleteMark(id)

    D.Debug(moduleName, "DeleteMark x", id)

    if not id then return end

    if not marks[id] then
        return
    end

    marks[id]:Hide()
    marks[id] = nil

    D:SendMessage("mark:Delete", id)
end

function module:Config(key, value)
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

function module:Update(msg, id, data, sourceEvent)

    D.Debug(moduleName, "Update", msg, id, data, sourceEvent)



--[[
    if C.db.profile.mark.dataSource .. ":Update" ~= source and id == D.nameRealm then
        return
    end

    if not C.db.profile.mark.showPlayer and id == D.nameRealm then
        return
    end

    if data.isMax then
        return self:DeleteMark(id)
    end
]]
    local markID = id .. "-" .. data.dataSource


    if not self:GetMark(markID) then
       self:CreateMark(markID, data)
    end

    self:UpdateMark(markID, data)

end

function module:HasMark(id)
    if not marks[id] then
        return false
    end
    return true
end

function module:GetMark(id)
    return marks[id]
end

function module:GetMarks()
    return marks
end
