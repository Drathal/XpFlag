local D, C, L = unpack(select(2, ...))

local _G = _G
local random = math.random
local module = D:NewModule("Spark", "AceEvent-3.0")

local function PlaySpark(xp, sparks, parent)
    for k, spark in pairs(sparks) do
        if not spark.ag:IsPlaying() then
            local _, _, _, xOfs, yOfs = parent:GetPoint()
            local x = (xOfs + (C.db.profile.mark.size / 2)) --* UIParent:GetEffectiveScale()

            spark:ClearAllPoints()
            spark:SetPoint("TOP", _G[UIParent], "TOPLEFT", x, C.sparkXP.y);

            local d = random(unpack(C.sparkXP.durationSpread))
            spark.ag.a1:SetOffset(random(unpack(C.sparkXP.xSpread)), random(unpack(C.sparkXP.ySpread)))
            spark.ag.a1:SetDuration(d)
            spark.ag.a2:SetDuration(d)

            spark.xp = xp
            spark.ag:Play()
            break
        end
    end
end

local function OnSparkPlay(self)
    local xp = self:GetParent().xp
    if not xp or xp == "0" then
        self:GetParent().text:SetText("")
        self.ag:Stop()
        return
    end

    self:GetParent().text:SetFormattedText(C.sparkXP.format, tostring(xp))
end

local function OnSparkFinished(self)
    self:GetParent().text:SetText("")
end

local function AddSpark(parent, num)
    local f = CreateFrame("Frame", nil, _G['UIParent'])
    f:SetHeight(1)
    f:SetWidth(1)
    f:Show()

    f.text = f:CreateFontString(nil, "OVERLAY")
    f.text:SetPoint("CENTER")
    f.text:SetFont(unpack(C.sparkXP.font))
    f.text:SetShadowColor(0, 0, 0, 0)
    f.text:SetShadowOffset(0, 0)
    f.text:SetTextColor(unpack(C.sparkXP.fontColor))
    --f.text:SetText("DEBUG")

    f.ag = f:CreateAnimationGroup()

    f.ag.a1 = f.ag:CreateAnimation("Translation")
    f.ag.a1:SetParent(f.ag)
    f.ag.a1:SetOffset(0, 0)
    f.ag.a1:SetDuration(0)
    f.ag.a1:SetSmoothing("IN_OUT")

    f.ag.a2 = f.ag:CreateAnimation("Alpha")
    f.ag.a2:SetParent(f.ag)
    f.ag.a2:SetFromAlpha(1)
    f.ag.a2:SetToAlpha(0)
    f.ag.a2:SetDuration(0)
    f.ag.a2:SetSmoothing("IN_OUT")

    f.ag:HookScript("OnPlay", OnSparkPlay)
    f.ag:HookScript("OnFinished", OnSparkFinished)

    return f
end

local function PlayXpSpark(msg, name, f)
    if not f.xpSparks then return end
    if not f.gain or f.gain == 0 then return end
    f.xpSparks.Play(f.gain)
end

local function CreateSparks(parent)
    local f = {}
    f.sparks = {}
    f.Play = function(xp) PlaySpark(xp, f.sparks, parent) end

    -- debug
    _G[D.addonName.."PlaySpark"] = f.Play

    for i = 1, C.sparkXP.max, 1 do
        f.sparks[i] = AddSpark(f, i)
    end
    return f
end

function module:OnEnable()
    self:RegisterMessage("UpdatePlayerMark", PlayXpSpark)
end

-- API
D.CreateSparks = CreateSparks
