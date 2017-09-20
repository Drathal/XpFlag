local D, C, L = unpack(select(2, ...))

local _G = _G
local CreateFrame = _G.CreateFrame
local select = _G.select
local unpack = _G.unpack
local assert = _G.assert

local bars = {}

local moduleName = "bar"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:OnAnimation(bar, elapsed)
    D.AnimateWidth(bar)
end

function module:OnEnable()
    if not C.db.profile.bar.show then return end
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    self:RegisterMessage("dataSource:Update", "Update")
end

function module:OnDisable()
    --@alpha@
    D.Debug(moduleName, "OnDisable")
    --@end-alpha@

    self.DeleteBar(D.nameRealm)
    self:UnregisterMessage("dataSource:Update")
end

function module:CreateBar(id)
    --@alpha@
    D.Debug(moduleName, "CreateBar", id)
    assert(id, 'bar:CreateBar - id is missing')
    --@end-alpha@

    local parent = select(2, unpack(C.positions[C.db.profile.bar.position]))
    local bar = CreateFrame("Frame", nil, parent)
    bar.name = id
    bar:SetHeight(C.db.profile.bar.height)
    bar:SetWidth(0)
    bar:SetPoint(unpack(C.positions[C.db.profile.bar.position]))
    bar:SetFrameLevel(1)
    bar:SetFrameStrata("DIALOG");

    bar.texture = bar:CreateTexture(nil, "OVERLAY")
    bar.texture:SetTexture(C.bar.texture)
    bar.texture:SetAllPoints(bar)

    bar:SetBackdrop({
        bgFile = C.bar.backdrop,
        edgeFile = C.bar.edge,
        edgeSize = 1,
        tileSize = 8,
        tile = true,
        insets = { left = 0, right = 0, top = 0, bottom = -1 }
    })
    bar:SetBackdropColor(0, 0, 0, 0.5)
    bar:SetBackdropBorderColor(0, 0, 0, 0.5)
    bar:Show()

    if id == D.nameRealm then
        bar.isPlayer = true
    end

    bar.anim = D.CreateUpdateAnimation(bar, self.OnAnimation)

    bars[id] = bar

    return bar
end

function module:DeleteBar(id)
    --@alpha@
    D.Debug(moduleName, "DeleteBar", id)
    assert(id, 'bar:DeleteBar - id is missing')
    --@end-alpha@

    if not bars[id] then return end
    bars[id]:Hide()
    bars[id] = nil
end

function module:UpdateBar(id, data)
    local bar = bars[id] or self:CreateBar(id)

    bar.data = data

    bar:Show()

    bar.to = bar:GetParent():GetWidth() * data.value / data.max or 0
    bar.anim.Start()

    if data.cR then
        bar.texture:SetVertexColor(data.cR, data.cG, data.cB)
    end

    return bar
end

-- at the moment we only have one bar for the player
function module:Update(msg, id, data, source)
    id = id or D.nameRealm
    data = data or D:GetModule(C.db.profile.bar.dataSource):GetData()

    if not C.db.profile.bar.show or data.disable then
        self:DeleteBar(D.nameRealm)
        return
    end

    --@alpha@
    D.Debug(moduleName, "Update", id, data, source)
    --@end-alpha@

    local bar = self:UpdateBar(id, data)
    bar:SetHeight(C.db.profile.bar.height)
    bar:ClearAllPoints()
    bar:SetPoint(unpack(C.positions[C.db.profile.bar.position]))
end

function module:GetBar(id)
    --@alpha@
    D.Debug(moduleName, "GetBar", id)
    assert(id, 'bar:GetBar - id is missing')
    --@end-alpha@

    return bars[id]
end

function module:GetBars()
    --@alpha@
    D.Debug(moduleName, "GetBars")
    --@end-alpha@

    return bars
end
