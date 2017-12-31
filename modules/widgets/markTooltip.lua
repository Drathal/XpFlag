local D, C, L = _G.unpack(_G.select(2, ...))

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
    GameTooltip:ClearLines()
    D:GetModule(parent.data.dataSource):AddTooltip(GameTooltip, parent.data)
    GameTooltip:Show()
end

local function OnUpdate(parent, elapsed)
    parent.tooltip.delay = parent.tooltip.delay - elapsed
    if parent.tooltip.delay > 0 then
        return
    end
    UpdateTooltip(parent)
    parent.tooltip.delay = delay
end

function module:Create(parent)
    --@alpha@
    D.Debug(moduleName, "Create")
    --@end-alpha@

    local tooltip = CreateFrame("Frame", nil, parent)
    tooltip:Hide()

    parent:SetScript(
        "OnEnter",
        function(self)
            tooltip:SetScript(
                "OnUpdate",
                function(self, elapsed)
                    OnUpdate(parent, elapsed)
                end
            )
            tooltip.delay = 0
            tooltip:Show()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(format("%s XP", D.addonName))
            GameTooltip:Show()
        end
    )
    parent:SetScript(
        "OnLeave",
        function(self)
            tooltip:Hide()
            GameTooltip:Hide()
            tooltip:SetScript("OnUpdate", nil)
        end
    )

    return tooltip
end
