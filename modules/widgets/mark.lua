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

-- local debug = true
local marks = {}

local moduleName = "mark"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:OnAnimation(mark)
    D.AnimateX(mark)
end

function module:CreateMark(id, data)
    --@alpha@
    D.Debug(moduleName, "CreateMark", id)
    assert(id, "mark:CreateMark - id is missing")
    assert(data, "mark:CreateMark - data is missing")
    --@end-alpha@

    local rcolor = RAID_CLASS_COLORS[data.class]

    local position = D.GetMarkPosition(C.db.profile.mark.position, data.dataSource)

    local m = CreateFrame("Frame", "XpFlagMark_" .. id:gsub("%W", ""), _G[select(2, unpack(position))])
    m:SetHeight(C.db.profile.mark.size)
    m:SetWidth(C.db.profile.mark.size)
    m:SetPoint(unpack(position))
    m:SetFrameStrata("DIALOG")
    m:SetFrameLevel(1)
    m:SetAlpha(1)
    m:EnableMouse()
    D:GetModule("markTooltip"):SetTooltip(m)

    m.texture = m:CreateTexture(nil, "OVERLAY")
    m.texture:SetAllPoints(m)
    m.texture:SetTexture(C.mark.texture.default)
    m.texture:SetTexCoord(unpack(match(C.db.profile.mark.position, "TOP") ~= nil and {0, 1, 1, 0} or {0, 1, 0, 1}))
    m.texture:SetVertexColor(rcolor.r, rcolor.g, rcolor.b, 1)
    m:Show()

    m.data = data
    m.player = id == D.nameRealm
    m.anim = D.CreateUpdateAnimation(m, self.OnAnimation)
    m.model = D:GetModule("markModel"):Create(m)
    m.sparks = D:GetModule("markSpark"):Create(m)

    marks[id] = m

    --@alpha@
    D.Debug(moduleName, "CreateMark - SendMessage", moduleName .. ":Create", id)
    --@end-alpha@
    D:SendMessage(moduleName .. ":Create", id)

    if not m.player then
        return m
    end

    m.texture:SetVertexColor(data.cR, data.cG, data.cB)
    m:SetFrameLevel(5)

    return m
end

function module:UpdateMark(id, data)
    --@alpha@
    D.Debug(moduleName, "UpdateMark", id, data)
    assert(id, "mark:UpdateMark - id is missing")
    assert(data, "mark:UpdateMark - data is missing")
    --@end-alpha@

    -- if data.isMax then
    -- return self:DeleteMark(id)
    -- end

    local flip = match(C.db.profile.mark.position, "TOP") == nil
    local rcolor = RAID_CLASS_COLORS[data.class]
    local m = marks[id] or self:CreateMark(id, data)

    m.data = data

    local newPos = D.GetMarkPosition(C.db.profile.mark.position, data.dataSource)
    newPos[1] = gsub(newPos[1], "TOP", flip and "BOTTOM" or "TOP")

    --@alpha@
    D.Debug(moduleName, "UpdateMark - SendMessage", moduleName .. ":Update", id, m)
    --@end-alpha@
    D:SendMessage(moduleName .. ":Update", id, m)

    m:ClearAllPoints()
    m:SetPoint(unpack(newPos))

    m.to = _G[newPos[2]]:GetWidth() * data.value / data.max
    m:SetHeight(C.db.profile.mark.size)
    m:SetWidth(C.db.profile.mark.size)
    m.texture:SetTexture(D.GetMarkTexture(data.level, UnitLevel("player")))
    m.texture:SetVertexColor(rcolor.r, rcolor.g, rcolor.b)
    m.texture:SetTexCoord(unpack(flip and {0, 1, 0, 1} or {0, 1, 1, 0}))
    m:Show()

    m.anim.Start()

    if not m.player then
        return m
    end
    m.texture:SetVertexColor(data.cR, data.cG, data.cB)

    return m
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

function module:Config(key, value)
    --@alpha@
    D.Debug(moduleName, "Config", key, value)
    --@end-alpha@

    if key == "showPlayer" and value then
        self:UpdateMark(D.nameRealm, D:GetModule(C.db.profile.bar.dataSource):GetData())
    end

    for mid, mark in pairs(marks) do
        if mid == D.nameRealm and key == "dataSource" then
            mark.data = D:GetModule(C.db.profile.mark.dataSource):GetData()
        end

        if key == "size" then
            D:GetModule("markModel"):Config(mark.model)
        end

        if mid == D.nameRealm and not C.db.profile.mark.showPlayer then
            -- mark.data.isMax = true
            self:DeleteMark(mid)
        else
            self:UpdateMark(mid, mark.data)
        end
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

    --@alpha@
    D.Debug(moduleName, "Update", msg, id, data, data.dataSource)
    --@end-alpha@

    self:UpdateMark(id, data)
end

function module:HasMark(id)
    --@alpha@
    D.Debug(moduleName, "HasMark", id)
    assert(id, "bar:HasMark - id is missing")
    --@end-alpha@

    if not marks[id] then
        return
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
