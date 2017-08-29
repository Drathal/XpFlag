local D, C, L = unpack(select(2, ...))

local _G = _G
local CreateFrame = _G.CreateFrame
local random = _G.math.random
local assert = _G.assert
local unpack = _G.unpack
local pairs = _G.pairs
local tostring = _G.tostring

local moduleName = "markSpark"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:PlaySpark(sparkList, parent)
    --@alpha@
    D.Debug(moduleName, "PlaySpark")
    assert(sparkList, 'markSpark:PlaySpark - sparkList is missing for ')
    --@end-alpha@

    for k, spark in pairs(sparkList) do
        if not spark.ag:IsPlaying() then
            local f1, p, f2, xOfs, yOfs = parent:GetPoint()
            local x = (xOfs + (C.db.profile.mark.size / 2)) --* UIParent:GetEffectiveScale()

            spark:ClearAllPoints()
            spark:SetPoint(f1, p, f2, x, yOfs);

            local ySpread1, ySpread2 = unpack(C.sparkXP.ySpread)
            if not C.db.profile.mark.flip then
                ySpread1 = C.sparkXP.ySpread[2] * - 1
                ySpread2 = C.sparkXP.ySpread[1] * - 1
            end

            spark.ag.a1:SetOffset(random(unpack(C.sparkXP.xSpread)), random(ySpread1, ySpread2))

            local d = random(unpack(C.sparkXP.durationSpread))
            spark.ag.a1:SetDuration(d)
            spark.ag.a2:SetDuration(d)
            spark.ag.a3:SetDuration(d)
            spark.ag:Play()
            break
        end
    end
end

function module:OnSparkPlay(f)
    --@alpha@
    D.Debug(moduleName, "OnSparkPlay", f)
    assert(f, 'markSparks:OnSparkPlay - f is missing')
    assert(f.text, 'markSparks:OnSparkPlay - f.text is missing')
    assert(f:GetParent().data, 'markSparks:OnSparkPlay - f:GetParent().data is missing')
    --@end-alpha@

    local value = f:GetParent().data.value
    if not value or value == "0" then
        f.ag:Stop()
        return
    end

    f.text:SetFormattedText(C.sparkXP.format, tostring(value))
end

function module:OnSparkFinished(f)
    --@alpha@
    D.Debug(moduleName, "OnSparkFinished", f)
    --@end-alpha@

    f.text:SetText("")
end

function module:AddSpark(parent)
    --@alpha@
    -- D.Debug(moduleName, "AddSpark")
    --@end-alpha@

    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(1)
    f:SetWidth(1)
    f:Show()

    f.text = f:CreateFontString(nil, "OVERLAY")
    f.text:SetPoint("CENTER")
    f.text:SetFont(unpack(C.sparkXP.font))
    f.text:SetShadowColor(0, 0, 0, 0)
    f.text:SetShadowOffset(0, 0)
    f.text:SetTextColor(unpack(C.sparkXP.fontColor))

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

    f.ag.a3 = f.ag:CreateAnimation("Scale")
    f.ag.a3:SetFromScale(1, 1)
    f.ag.a3:SetToScale(0.85, 0.85)
    f.ag.a3:SetDuration(0)
    f.ag.a3:SetSmoothing("OUT")

    f.ag:HookScript("OnPlay", function() self:OnSparkPlay(f) end)
    f.ag:HookScript("OnFinished", function() self:OnSparkFinished(f) end)

    return f
end

function module:PlayXpSpark(msg, name, f)
    --@alpha@
    D.Debug(moduleName, "PlayXpSpark", msg, name)
    --@end-alpha@

    if not f.sparks then return end
    if not f.gain or f.gain == 0 then return end
    f.sparks.Play(f.gain)
end

function module:Create(parent)
    --@alpha@
    D.Debug(moduleName, "Create")
    assert(parent, 'markSparks:Create - parent is missing')
    --@end-alpha@

    local f = {}
    f.sparkList = {}
    f.Play = function() self:PlaySpark(f.sparkList, parent) end

    -- debug
    _G[D.addonName.."PlaySpark"] = f.Play

    for i = 1, C.sparkXP.max, 1 do
        f.sparkList[i] = self:AddSpark(parent)
    end
    return f
end

function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@
    self:RegisterMessage("mark:Update", "PlayXpSpark")
end
