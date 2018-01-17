local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local CreateFrame = _G.CreateFrame
local select = _G.select
local unpack = _G.unpack
local assert = _G.assert
local pairs = _G.pairs

local bars = {}

local moduleName = "markBar"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:OnAnimation(bar, elapsed)
    D.AnimateWidth(bar)
end

function module:OnEnable()
    if not C.db.profile.bar.show then
        return
    end

    self:RegisterMessage("dataSource:Update", "Update")
end

function module:OnDisable()
    self.DeleteBar(D.nameRealm)
    self:UnregisterMessage("dataSource:Update")
end

function module:CreateBar(id)
    local bar = CreateFrame("Frame", nil, _G[select(2, unpack(C.barpositions[C.db.profile.bar.position]))])
    bar.name = id
    bar:SetHeight(C.db.profile.bar.height)
    bar:SetWidth(0)
    bar:SetPoint(unpack(C.barpositions[C.db.profile.bar.position]))
    bar:SetFrameLevel(1)
    bar:SetFrameStrata("DIALOG")

    bar.texture = bar:CreateTexture(nil, "OVERLAY")
    bar.texture:SetTexture(C.bar.texture)
    bar.texture:SetAllPoints(bar)

    bar:SetBackdrop(
        {
            bgFile = C.bar.backdrop,
            edgeFile = C.bar.edge,
            edgeSize = 1,
            tileSize = 8,
            tile = true,
            insets = {left = 0, right = 0, top = 0, bottom = -1}
        }
    )
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
    if not bars[id] then
        return
    end
    bars[id]:Hide()
    bars[id] = nil
end

function module:UpdateBar(id, data)
    local bar = bars[id] or self:CreateBar(id)

    -- if data.isMax then
    -- return self:DeleteBar(id)
    -- end

    bar.data = data

    bar:Show()

    bar.to = bar:GetParent():GetWidth() * data.value / data.max or 0
    bar.anim.Start()

    if data.cR then
        bar.texture:SetVertexColor(data.cR, data.cG, data.cB)
    end

    bar:SetHeight(C.db.profile.bar.height)
    bar:ClearAllPoints()
    bar:SetPoint(unpack(C.barpositions[C.db.profile.bar.position]))

    return bar
end

function module:Config(key, value)
    if key == "show" and value then
        self:UpdateBar(D.nameRealm, D:GetModule(C.db.profile.bar.dataSource):GetData())
    end

    for bid, bar in pairs(bars) do
        if key == "dataSource" then
            bar.data = D:GetModule(C.db.profile.bar.dataSource):GetData()
        end

        if bid == D.nameRealm and not C.db.profile.bar.show then
            -- bar.data.isMax = true
            self:DeleteBar(bid)
        else
            self:UpdateBar(bid, bar.data)
        end
    end
end

function module:Update(msg, id, data, source)
    if C.db.profile.bar.dataSource .. ":Update" ~= source then
        return
    end
    if not C.db.profile.bar.show then
        return
    end

    self:UpdateBar(id, data)
end

function module:GetBar(id)
    return bars[id]
end

function module:GetBars()
    return bars
end
