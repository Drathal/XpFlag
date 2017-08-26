local D, C, L = unpack(select(2, ...))

local _G = _G
local CreateFrame = _G.CreateFrame

local bars = {}
local parent = select(2, unpack(C.bar.position))

local module = D:NewModule("bar", "AceEvent-3.0")

function module:OnAnimation(bar, elapsed)
    D.AnimateWidth(bar)
end

function module:OnEnable()
    if not C.db.profile.bar.show then return end
    if not C.db.profile.bar.dataSource then return end
    self:RegisterMessage(C.db.profile.bar.dataSource, "UpdatePlayerBar")
end

function module:OnDisable()
    self.DeleteBar(D.nameRealm)
    self:UnregisterMessage(C.db.profile.bar.dataSource)
end

function module:CreateBar(friend)
    local bar = CreateFrame("Frame", D.addonName..'-'..friend..'-XpBar', parent)
    bar.name = friend
    bar:SetHeight(C.db.profile.bar.height)
    bar:SetWidth(0)
    bar:SetPoint(unpack(C.bar.position))
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

    if friend == D.nameRealm then
        bar.isPlayer = true
    end

    bar.anim = D.CreateUpdateAnimation(bar, self.OnAnimation)

    bars[friend] = bar 

    return bar
end

function module:DeleteBar(friend)    
    if not friend then return end
    if not bars[friend] then return end
    bars[friend]:Hide()
    bars[friend] = nil
    D:SendMessage("DeleteBar", friend)
end

function module:UpdateBar(friend, data)
    if not data then return end    
    local bar = bars[friend] or self:CreateBar(friend)
    
    bar.data = data

    if data.isMaxLevel then
        self.DeleteBar(friend)
        return
    end

    bar:Show()

    bar.to = parent:GetWidth() * data.p or 0
    bar.anim.Start()

    if not bar.isPlayer then return end
    bar.texture:SetVertexColor(unpack(D.GetXpColor()))
end

function module:UpdatePlayerBar(msg, friend, data)
    self:UpdateBar(friend, data)
end

function module:Update()
    if not C.db.profile.bar.show then
        self:DeleteBar(D.nameRealm)
    else
        self:UpdateBar(D.nameRealm, D.DataXpGet())
    end

    if bars[D.nameRealm] then
        bars[D.nameRealm]:SetHeight(C.db.profile.bar.height)
    end

    if bars[D.nameRealm] and bars[D.nameRealm].data then
        self.UpdateBar(D.nameRealm, bars[D.nameRealm].data)
    end
end

local function GetBar(friend)
    return bars[friend]
end

local function GetBarks()
    return bars
end

-- API
D.DeleteBar = module.DeleteBar
D.GetBar = GetBar
D.GetBars = GeBars
