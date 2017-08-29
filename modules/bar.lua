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
    if not C.db.profile.bar.dataSource then return end
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    self:RegisterMessage(C.db.profile.bar.dataSource..":Update", "UpdatePlayerBar")
end

function module:OnDisable()
    --@alpha@
    D.Debug(moduleName, "OnDisable")
    --@end-alpha@

    self.DeleteBar(D.nameRealm)
    self:UnregisterMessage(C.db.profile.bar.dataSource..":Update")
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
    --@alpha@
    D.Debug(moduleName, "UpdateBar", id)
    assert(id, 'bar:UpdateBar - id is missing')
    assert(data, 'bar:UpdateBar - data is missing')
    --@end-alpha@

    local bar = bars[id] or self:CreateBar(id)

    bar.data = data

    if data.isMaxLevel then
        self:DeleteBar(id)
        return
    end

    bar:Show()

    bar.to = bar:GetParent():GetWidth() * data.value / data.max or 0
    bar.anim.Start()

    if not bar.isPlayer then return end
    bar.texture:SetVertexColor(unpack(D.GetXpColor()))
end

function module:UpdatePlayerBar(msg, id, data)
    --@alpha@
    D.Debug(moduleName, "UpdatePlayerBar", id)
    assert(id, 'bar:UpdatePlayerBar - id is missing')
    assert(data, 'bar:UpdatePlayerBar - data is missing')
    --@end-alpha@

    self:UpdateBar(id, data)
end

function module:Update()
    --@alpha@
    D.Debug(moduleName, "Update")
    --@end-alpha@

    if not C.db.profile.bar.show then
        self:DeleteBar(D.nameRealm)
    else
        self:UpdateBar(D.nameRealm, D:GetModule(C.db.profile.bar.dataSource):GetData())
    end

    if bars[D.nameRealm] then
        bars[D.nameRealm]:SetHeight(C.db.profile.bar.height)
        bars[D.nameRealm]:ClearAllPoints()
        bars[D.nameRealm]:SetPoint(unpack(C.positions[C.db.profile.bar.position]))
    end

    if bars[D.nameRealm] and bars[D.nameRealm].data then
        self:UpdateBar(D.nameRealm, bars[D.nameRealm].data)
    end
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
