local D, C, L = unpack(select(2, ...))

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
    D:GetModule("markTooltip"):SetTooltip(m)

    m.texture = m:CreateTexture(nil, "OVERLAY")
    m.texture:SetAllPoints(m)
    m.texture:SetTexture(C.mark.texture.default)
    m.texture:SetTexCoord(unpack(C.db.profile.mark.flip and {0, 1, 1, 0} or {0, 1, 0, 1}))
    m.texture:SetVertexColor(rcolor.r, rcolor.g, rcolor.b, 1)
    m:Show()

    m.data = data
    m.player = id == D.nameRealm;
    m.anim = D.CreateUpdateAnimation(m, self.OnAnimation)
    m.model = D:GetModule("markModel"):Create(m)
    m.sparks = D:GetModule("markSpark"):Create(m)

    marks[id] = m

    --@alpha@
    D.Debug(moduleName, "CreateMark - SendMessage", moduleName..":Create", id )
    --@end-alpha@
    D:SendMessage(moduleName..":Create", id)

    if not m.player then return m end

    m.texture:SetVertexColor(data.cR, data.cG, data.cB)
    m:SetFrameLevel(5)

    return m
end

function module:UpdateMark(id, data)
    --@alpha@
    D.Debug(moduleName, "UpdateMark", id, data)
    assert(id, 'mark:UpdateMark - id is missing')
    assert(data, 'mark:UpdateMark - data is missing')
    --@end-alpha@

    local rcolor = RAID_CLASS_COLORS[data.class]
    local m = marks[id] or self:CreateMark(id, data);
    m.data = data

    m.to = m:GetParent():GetWidth() * data.value / data.max
    m.texture:SetTexture(D.GetMarkTexture(data.level, UnitLevel("player")))
    m.texture:SetVertexColor(rcolor.r, rcolor.g, rcolor.b)
    m:Show()

    m.anim.Start()

    D:SendMessage(moduleName..":Update", id, m)

    if not m.player then return m end
    m.texture:SetVertexColor(data.cR, data.cG, data.cB)

    return m
end

function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    self:RegisterMessage("ReceiveData", "Update")
    self:RegisterMessage("ReceiveRequest", "Update")
    self:RegisterMessage("ReceiveDelete", "DeleteMark")
    self:RegisterMessage("dataSource:Update", "Update")
end

function module:OnDisable()
    --@alpha@
    D.Debug(moduleName, "OnDisable")
    --@end-alpha@

    self:UnregisterMessage("ReceiveData")
    self:UnregisterMessage("ReceiveRequest")
    self:UnregisterMessage("ReceiveDelete")
    self:UnregisterMessage("dataSource:Update")
end

function module:DeleteMark(id)
    --@alpha@
    D.Debug(moduleName, "DeleteMark", id)
    --@end-alpha@

    if not id then return end
    if not marks[id] then return end
    marks[id]:Hide()
    marks[id] = nil

    --@alpha@
    D.Debug(moduleName, "DeleteMark - SendMessage", moduleName..":Delete", id )
    --@end-alpha@

    D:SendMessage("mark:Delete", id)
end

function module:Update(msg, id, data, source)
    --@alpha@
    D.Debug(moduleName, "Update", msg, id, data, source)
    --@end-alpha@

    id = id or D.nameRealm

    -- create player mark if we have to
    if not marks[id] and C.db.profile.mark.showPlayer then
        self:UpdateMark(id, data or D:GetModule(C.db.profile.mark.dataSource):GetData())
    end

    local flip = match(C.db.profile.mark.position, "TOP") == nil
    local newPos = C.positions[C.db.profile.mark.position]

    for mid, mark in pairs(marks) do
        if mid == id then
            if C.db.profile.mark.dataSource ~= mark.data.dataType then
                mark.data = D:GetModule(C.db.profile.mark.dataSource):GetData()
            end
            if not C.db.profile.mark.showPlayer then
                mark.data.disable = true
            end
        end

        newPos[4] = mark:GetParent():GetWidth() * mark.data.value / mark.data.max

        if flip then
            newPos[1] = gsub(newPos[1], "TOP", "BOTTOM")
        end

        mark:ClearAllPoints()
        mark:SetPoint(unpack(newPos))
        mark:SetParent(newPos[2])
        mark:SetHeight(C.db.profile.mark.size)
        mark:SetWidth(C.db.profile.mark.size)
        mark.texture:SetTexCoord(unpack(flip and {0, 1, 0, 1} or {0, 1, 1, 0}))

        if mark.data.disable then
            self:DeleteMark(mid)
        else
            self:UpdateMark(mid, mark.data)
        end
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
