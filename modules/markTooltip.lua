local D, C, L = unpack(select(2, ...))

local _G = _G
local CreateFrame = _G.CreateFrame
local GetXPExhaustion = _G.GetXPExhaustion
local GameTooltip = _G.GameTooltip
local COLORS = _G.RAID_CLASS_COLORS
local format = _G.string.format
local pairs = _G.pairs

local moduleName = "markTooltip"
local module = D:NewModule(moduleName)

function module:CreateMarkTooltip()
    --@alpha@
    D.Debug(moduleName, "CreateMarkTooltip")
    --@end-alpha@

    local t = CreateFrame("Frame")
    t:Hide()
    t.delay = 0.25
    t:SetScript("OnUpdate", function(self, elapsed)
        t.delay = t.delay - elapsed;
        if t.delay > 0 then return end

        local rested = GetXPExhaustion()

        for _, mark in pairs(D.GetMarks()) do
            if mark:IsMouseOver() and mark.data then
                local data = mark.data
                GameTooltip:ClearLines()
                GameTooltip:AddLine(format("%s XP", D.addonName))
                GameTooltip:AddLine(data.name, COLORS[data.class].r, COLORS[data.class].g, COLORS[data.class].b, 1)
                GameTooltip:AddLine(format("Level: %s", data.level), 1, 1, 1, 1)
                GameTooltip:AddLine(format("XP: %s/%s (%.2f %)", data.value, data.max, data.value / data.max * 100 ), 1, 1, 1, 1)
                if data.rested then
                    GameTooltip:AddLine(format("Rested: %s (%.2f %)", data.rested, data.rested / data.max * 100 ), 1, 1, 1, 1)
                end
                GameTooltip:Show()
            end
        end
        t.delay = 0.25
    end)

    return t
end

function module:OnMarkTooltipEnter(owner)
    --@alpha@
    D.Debug(moduleName, "CreateMarkTooltip")
    assert(owner, 'markTooltip:OnMarkTooltipEnter - owner is missing')
    --@end-alpha@

    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    module.t:Show();
end

function module:OnMarkTooltipLeave()
    --@alpha@
    D.Debug(moduleName, "OnMarkTooltipLeave")
    --@end-alpha@

    module.t:Hide();
    GameTooltip:Hide()
end

function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    module.t = self:CreateMarkTooltip()
end
