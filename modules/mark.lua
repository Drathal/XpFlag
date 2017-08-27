local D, C, L = unpack(select(2, ...))

local _G = _G
local CreateFrame = _G.CreateFrame

local marks = {}

local module = D:NewModule("mark", "AceEvent-3.0")

function module:OnAnimation(mark, elapsed)
    D.AnimateX(mark)
end

function module:CreateMark(name, class)
    local rcolor = RAID_CLASS_COLORS[class]
    local parent = select(2, unpack(C.positions[C.db.profile.mark.position]))
    local m = CreateFrame("Frame", nil, parent)
    m:SetHeight(C.db.profile.mark.size)
    m:SetWidth(C.db.profile.mark.size)
    m:SetPoint(unpack(C.positions[C.db.profile.mark.position]))
    m:EnableMouse()
    m:SetScript("OnEnter", D.OnMarkTooltipEnter)
    m:SetScript("OnLeave", D.OnMarkTooltipLeave)
    m:SetFrameStrata("DIALOG")
    m:SetFrameLevel(2)
    m:SetAlpha(1)
    m:Show()

    marks[name] = m

    m.texture = m:CreateTexture(nil, "OVERLAY")
    m.texture:SetAllPoints(m)
    m.texture:SetTexture(C.mark.texture.default)
    m.texture:SetTexCoord(unpack(C.db.profile.mark.flip and {0, 1, 1, 0} or {0, 1, 0, 1}))
    m.texture:SetVertexColor(rcolor.r, rcolor.g, rcolor.b, 1)

    m.name = name
    m.class = class

    m.anim = D.CreateUpdateAnimation(m, self.OnAnimation)

    D:SendMessage("CreateMark", name)

    if name ~= D.nameRealm then return m end

    m.player = true;
    m.texture:SetVertexColor(unpack(D.GetXpColor()))
    m:SetFrameLevel(5)
    m.model = D.CreateSparkModel(m)
    m.xpSparks = D.CreateSparks(m)

    return m
end

function module:UpdateMark(name, value, maxvalue, level, class)
    if not marks then return end

    local name = name or D.nameRealm
    local value = value or UnitXP("PLAYER")
    local maxvalue = maxvalue or UnitXPMax("PLAYER")
    local level = level or UnitLevel("player")
    local class = class or D.class
    local m = marks[name] or self:CreateMark(name, class);

    if D.IsMaxLevel(level) then
        m:Hide()
        return
    end

    m.prev = m.value or value
    m.value = value
    m.maxvalue = maxvalue
    m.level = level
    m.gain = tonumber(value) - tonumber(m.prev) or 0
    m.to = D.screenWidth * value / maxvalue
    m.texture:SetTexture(D.GetMarkTexture(level, UnitLevel("player")))
    m.texture:SetVertexColor(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b)
    m:Show()

    m.anim.Start()

    D:SendMessage("UpdateMark", name, m)

    if not m.player then return end
    m.texture:SetVertexColor(unpack(D.GetXpColor()))

    D:SendMessage("UpdatePlayerMark", name, m)
end

function module:OnUpdateMark(event, friend, data )
    -- print("MARK: OnUpdateMark", event, friend, data)
    self:UpdateMark(friend, data.xp, data.max, data.level, data.class)
end

function module:OnDeleteMark(event, friend )
    -- print("MARK: OnDeleteMark", event, friend, data)
    self:DeleteMark(friend)
end

function module:OnEnable()
    self:RegisterMessage("ReceiveData", "OnUpdateMark")
    self:RegisterMessage("ReceiveRequest", "OnUpdateMark")
    self:RegisterMessage("ReceiveDelete", "OnDeleteMark")
    self:RegisterMessage(C.db.profile.mark.dataSource, "OnUpdateMark")
end

function module:OnDisable()
    self:UnregisterMessage("ReceiveData")
    self:UnregisterMessage("ReceiveRequest")
    self:UnregisterMessage("ReceiveDelete")
    self:UnregisterMessage(C.db.profile.mark.dataSource)
end

function module:DeleteMark(friend)
    if not friend then return end
    if not marks[friend] then return end
    marks[friend]:Hide()
    marks[friend] = nil
    D:SendMessage("DeleteMark", friend)
end

function module:Update()
    if not C.db.profile.mark.showPlayer then
        self:DeleteMark(D.nameRealm)
    else
        self:UpdateMark(D.nameRealm)
    end

    if string.match(C.db.profile.mark.position, "TOP") then
        C.db.profile.mark.flip = true
    else
        C.db.profile.mark.flip = nil
    end

    for name, mark in pairs(marks) do
        if not mark then return end

        mark:ClearAllPoints()
        mark:SetPoint(unpack(C.positions[C.db.profile.mark.position]))
        mark:SetHeight(C.db.profile.mark.size)
        mark:SetWidth(C.db.profile.mark.size)
        mark.texture:SetTexCoord(unpack(C.db.profile.mark.flip and {0, 1, 1, 0} or {0, 1, 0, 1}))

        self:UpdateMark(mark.name, mark.value, mark.maxvalue, mark.level, mark.class)
    end
end

local function GetMark(friend)
    return marks[friend]
end

local function GetMarks()
    return marks
end

-- API
D.DeleteMark = module.DeleteMark
D.GetMark = GetMark
D.GetMarks = GetMarks
