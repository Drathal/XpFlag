local D, C, L = unpack(select(2, ...))

local _G = _G
local CreateFrame = _G.CreateFrame
local select = _G.select
local unpack = _G.unpack

local bars = {}

local module = D:NewModule("bar", "AceEvent-3.0")

function module:OnAnimation(bar, elapsed)
    D.AnimateWidth(bar)
end

function module:OnEnable()
    if not C.db.profile.bar.show then return end
    if not C.db.profile.bar.dataSource then return end
    self:RegisterMessage(C.db.profile.bar.dataSource..":Update", "UpdatePlayerBar")
end

function module:OnDisable()
    self.DeleteBar(D.nameRealm)
    self:UnregisterMessage(C.db.profile.bar.dataSource..":Update")
end

function module:CreateBar(id)
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
    if not id then return end
    if not bars[id] then return end
    bars[id]:Hide()
    bars[id] = nil
    D:SendMessage("DeleteBar", id)
end

function module:UpdateBar(id, data)
    if not data then return end
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
    self:UpdateBar(id, data)
end

function module:Update()
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
    return bars[id]
end

function module:GetBars()
    return bars
end
