local D, C, L = unpack(select(2, ...))

local _G = _G
local CreateFrame = _G.CreateFrame
local GetXPExhaustion = _G.GetXPExhaustion
local GameTooltip = _G.GameTooltip
local COLORS = _G.RAID_CLASS_COLORS
local format = _G.string.format
local pairs = _G.pairs
--@alpha@
local assert = _G.assert
--@end-alpha@

local moduleName = "markTooltip"
local module = D:NewModule(moduleName)
local delay = 2

local function UpdateTooltip(parent)
    local data = parent.data
    GameTooltip:ClearLines()
    GameTooltip:AddLine(format(L["XP_MARK_TT_1"], D.addonName))
    GameTooltip:AddLine(data.name, COLORS[data.class].r, COLORS[data.class].g, COLORS[data.class].b, 1)
    GameTooltip:AddLine(format(L["XP_MARK_TT_2"], data.level), 1, 1, 1, 1)
    GameTooltip:AddLine(format(L["XP_MARK_TT_3"], data.value, data.max, data.value / data.max * 100 ), 1, 1, 1, 1)
    if data.rested and data.rested > 0 then
        GameTooltip:AddLine(format(L["XP_MARK_TT_4"], data.rested, data.rested / data.max * 100 ), 1, 1, 1, 1)
    end
    GameTooltip:Show()
end

local function OnUpdate(parent, elapsed)
    parent.tooltip.delay = parent.tooltip.delay - elapsed;
    if parent.tooltip.delay > 0 then return end
    UpdateTooltip(parent)
    parent.tooltip.delay = delay
end

function module:SetTooltip(parent)
    --@alpha@
    D.Debug(moduleName, "SetTooltip")
    --@end-alpha@

    parent.tooltip = CreateFrame("Frame", nil, parent)
    parent.tooltip:Hide()

    parent:SetScript("OnEnter", function(self)
        parent.tooltip:SetScript("OnUpdate", function(self, elapsed) OnUpdate(parent, elapsed) end)
        parent.tooltip.delay = 0
        parent.tooltip:Show()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(format("%s XP", D.addonName))
        GameTooltip:Show()
    end)
    parent:SetScript("OnLeave", function(self)
        parent.tooltip:Hide()
        GameTooltip:Hide()
        parent.tooltip:SetScript("OnUpdate", nil)
    end)
end
