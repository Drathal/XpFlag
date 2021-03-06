local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local CreateFrame = _G.CreateFrame
local random = _G.math.random
local assert = _G.assert
local unpack = _G.unpack
local pairs = _G.pairs
local tostring = _G.tostring
local match = _G.string.match

local moduleName = "markSpark"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:PlaySpark(sparkList, parent)
    --@alpha@
    D.Debug(moduleName, "PlaySpark", sparkList, parent)
    assert(sparkList, "markSpark:PlaySpark - sparkList is missing")
    assert(parent, "markSpark:PlaySpark - parent is missing")
    --@end-alpha@

    for k, spark in pairs(sparkList) do
        if not spark.ag:IsPlaying() then
            local f1, p, f2, xOfs, yOfs = parent:GetPoint()

            spark:ClearAllPoints()
            spark:SetPoint(f1, p, f2, xOfs, yOfs)

            D.Debug(moduleName, "PlaySpark - POS", parent:GetPoint())

            local ySpread1, ySpread2 = unpack(C.sparkXP.ySpread)
            if match(C.db.profile.mark.position, "TOP") == nil then
                ySpread1 = C.sparkXP.ySpread[2] * -1
                ySpread2 = C.sparkXP.ySpread[1] * -1
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
    D.Debug(moduleName, "OnSparkPlay", f, f:GetParent().data.gain)
    assert(f, "markSparks:OnSparkPlay - f is missing")
    assert(f.text, "markSparks:OnSparkPlay - f.text is missing")
    assert(f:GetParent().data, "markSparks:OnSparkPlay - f:GetParent().data is missing")
    --@end-alpha@

    local gain = f:GetParent().data.gain
    if not gain or gain == "0" then
        D.Debug(moduleName, "OnSparkPlay STOPPED", gain)
        f.ag:Stop()
        return
    end

    f.text:SetFormattedText(C.sparkXP.formats[C.db.profile.mark.dataSource], tostring(gain))
end

function module:OnSparkFinished(f)
    --@alpha@
    D.Debug(moduleName, "OnSparkFinished", f)
    --@end-alpha@

    f.text:SetText("")
end

function module:AddSpark(parent, i)
    --@alpha@
    D.Debug(moduleName, "AddSpark", parent, i)
    --@end-alpha@

    local f = CreateFrame("Frame", parent:GetName() .. "_spark_" .. i, parent)
    f:SetPoint("CENTER", _G[parent:GetName()], "CENTER", 0, 0)
    f:SetHeight(C.db.profile.mark.size)
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
    f.ag.a3:SetToScale(1, 1)
    f.ag.a3:SetDuration(0)
    f.ag.a3:SetSmoothing("OUT")

    f.ag:HookScript(
        "OnPlay",
        function()
            self:OnSparkPlay(f)
        end
    )
    f.ag:HookScript(
        "OnFinished",
        function()
            self:OnSparkFinished(f)
        end
    )

    return f
end

function module:PlayXpSpark(msg, name, f)
    --@alpha@
    D.Debug(moduleName, "PlayXpSpark", msg, name)
    assert(name, "markSpark:PlayXpSpark - name is missing")
    assert(f, "markSpark:PlayXpSpark - f is missing")
    assert(f.data, "markSpark:PlayXpSpark - f.data is missing")
    --@end-alpha@

    if not f.sparks then
        return
    end
    if not f.data.gain or f.data.gain == 0 then
        return
    end
    f.sparks.Play(f.data.gain)
end

function module:Create(parent)
    --@alpha@
    D.Debug(moduleName, "Create", parent)
    assert(parent, "markSparks:Create - parent is missing")
    --@end-alpha@

    local f = {}
    f.sparkList = {}

    f.Play = function(xp)
        parent.data.gain = xp
        self:PlaySpark(f.sparkList, parent)
    end

    -- debug
    if parent.player then
        _G[D.addonName .. "PlaySpark"] = f.Play
    end

    for i = 1, parent.player and C.sparkXP.max or (C.sparkXP.max / 2), 1 do
        f.sparkList[i] = self:AddSpark(parent, i)
    end

    return f
end

function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@
    self:RegisterMessage("mark:Update", "PlayXpSpark")
end
