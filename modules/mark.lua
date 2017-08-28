local D, C, L = unpack(select(2, ...))

local _G = _G
local pairs = _G.pairs
local select = _G.select
local unpack = _G.unpack
local match = _G.string.match
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
    assert(id, 'mark:CreateMark - id is missing')
    assert(data, 'mark:CreateMark - data is missing')
    --@end-alpha@

    local rcolor = RAID_CLASS_COLORS[data.class]
    local parent = select(2, unpack(C.positions[C.db.profile.mark.position]))
    C.db.profile.mark.flip = match(C.db.profile.mark.position, "TOP") ~= nil

    local m = CreateFrame("Frame", nil, parent)
    m:SetHeight(C.db.profile.mark.size)
    m:SetWidth(C.db.profile.mark.size)
    m:SetPoint(unpack(C.positions[C.db.profile.mark.position]))
    m:SetFrameStrata("DIALOG")
    m:SetFrameLevel(2)
    m:SetAlpha(1)
    m:EnableMouse()
    m:SetScript("OnEnter", D:GetModule("markTooltip").OnMarkTooltipEnter )
    m:SetScript("OnLeave", D:GetModule("markTooltip").OnMarkTooltipLeave )
    m.texture = m:CreateTexture(nil, "OVERLAY")
    m.texture:SetAllPoints(m)
    m.texture:SetTexture(C.mark.texture.default)
    m.texture:SetTexCoord(unpack(C.db.profile.mark.flip and {0, 1, 1, 0} or {0, 1, 0, 1}))
    m.texture:SetVertexColor(rcolor.r, rcolor.g, rcolor.b, 1)
    m:Show()

    m.data = data
    m.anim = D.CreateUpdateAnimation(m, self.OnAnimation)

    --@alpha@
    D.Debug(moduleName, "CreateMark - SendMessage", moduleName..":Create", id )
    --@end-alpha@
    D:SendMessage(moduleName..":Create", id)

    marks[id] = m

    if id ~= D.nameRealm then return m end

    m.player = true;

    m.texture:SetVertexColor(data.cR, data.cG, data.cB)
    m:SetFrameLevel(5)
    m.model = D:GetModule("markModel"):Create(m)
    m.xpSparks = D:GetModule("markSpark"):Create(m)

    return m
end

function module:UpdateMark(id, data)
    --@alpha@
    D.Debug(moduleName, "UpdateMark", id)
    assert(id, 'mark:UpdateMark - id is missing')
    assert(data, 'mark:UpdateMark - data is missing')
    --@end-alpha@

    local rcolor = RAID_CLASS_COLORS[data.class]
    local m = marks[id] or self:CreateMark(id, data);
    m.data = data

    if data.disabled then
        m:Hide()
        return
    end

    m.to = m:GetParent():GetWidth() * data.value / data.max
    m.texture:SetTexture(D.GetMarkTexture(data.level, UnitLevel("player")))
    m.texture:SetVertexColor(rcolor.r, rcolor.g, rcolor.b)
    m:Show()

    m.anim.Start()

    --@alpha@
    D.Debug(moduleName, "UpdateMark - SendMessage", moduleName..":Update", id )
    --@end-alpha@
    D:SendMessage(moduleName..":Update", id, m)

    if not m.player then return end
    m.texture:SetVertexColor(data.cR, data.cG, data.cB)
end

function module:OnUpdateMark(event, id, data)
    --@alpha@
    D.Debug(moduleName, "OnUpdateMark", id)
    assert(id, 'mark:OnUpdateMark - id is missing')
    assert(data, 'mark:OnUpdateMark - data is missing')
    --@end-alpha@

    self:UpdateMark(id, data)
end

function module:OnDeleteMark(event, id)
    --@alpha@
    D.Debug(moduleName, "OnDeleteMark", id)
    --@end-alpha@

    self:DeleteMark(id)
end

function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    self:RegisterMessage("ReceiveData", "OnUpdateMark")
    self:RegisterMessage("ReceiveRequest", "OnUpdateMark")
    self:RegisterMessage("ReceiveDelete", "OnDeleteMark")
    self:RegisterMessage(C.db.profile.mark.dataSource..":Update", "OnUpdateMark")
end

function module:OnDisable()
    --@alpha@
    D.Debug(moduleName, "OnDisable")
    --@end-alpha@

    self:UnregisterMessage("ReceiveData")
    self:UnregisterMessage("ReceiveRequest")
    self:UnregisterMessage("ReceiveDelete")
    self:UnregisterMessage(C.db.profile.mark.dataSource..":Update")
end

function module:DeleteMark(id)
    --@alpha@
    D.Debug(moduleName, "DeleteMark", id)
    --@end-alpha@

    if not id then return end
    if not marks[id] then return end
    marks[id]:Hide()
    marks[id] = nil
    D:SendMessage("DeleteMark", id)
end

function module:Update()
    --@alpha@
    D.Debug(moduleName, "Update")
    --@end-alpha@

    if not C.db.profile.mark.showPlayer then
        self:DeleteMark(D.nameRealm)
    else
        self:UpdateMark(D.nameRealm, D:GetModule(C.db.profile.mark.dataSource):GetData())
    end

    C.db.profile.mark.flip = match(C.db.profile.mark.position, "TOP") ~= nil

    local newPos = C.positions[C.db.profile.mark.position]

    for id, mark in pairs(marks) do
        if not mark then return end

        local _, p, _, xOfs, _ = mark:GetPoint()
        newPos[4] = xOfs

        mark:ClearAllPoints()
        mark:SetParent(p)
        mark:SetPoint(unpack(newPos))
        mark:SetHeight(C.db.profile.mark.size)
        mark:SetWidth(C.db.profile.mark.size)
        mark.texture:SetTexCoord(unpack(C.db.profile.mark.flip and {0, 1, 1, 0} or {0, 1, 0, 1}))

        --@alpha@
        assert(mark.data, 'mark:Update - mark.data is missing for '..id)
        --@end-alpha@

        self:UpdateMark(id, mark.data)
    end
end

function module:GetMark(id)
    --@alpha@
    D.Debug(moduleName, "GetMark")
    --@end-alpha@

    return marks[id]
end

function module:GetMarks()
    --@alpha@
    D.Debug(moduleName, "GetMarks")
    --@end-alpha@

    return marks
end
