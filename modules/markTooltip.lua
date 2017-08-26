local D, C, L = unpack(select(2, ...))

local _G = _G
local GetXPExhaustion = _G.GetXPExhaustion
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local format = string.format

local module = D:NewModule("MarkTooltip")

local function CreateMarkTooltip()
    local t = CreateFrame("Frame")

    t:Hide()
    t.delay = 0.25

    t:SetScript("OnUpdate", function(self, elapsed)

        t.delay = t.delay - elapsed;
        if t.delay > 0 then return end

        local rested = GetXPExhaustion()

        for k, v in pairs(D.GetMarks()) do
            if v:IsMouseOver() and v.class and v.name and v.level then
                GameTooltip:ClearLines()
                GameTooltip:AddLine(D.addonName)
                GameTooltip:AddLine(k, RAID_CLASS_COLORS[v.class].r, RAID_CLASS_COLORS[v.class].g, RAID_CLASS_COLORS[v.class].b, 1)
                GameTooltip:AddLine("Level: "..v.level, 1, 1, 1, 1)
                GameTooltip:AddLine("XP: "..v.value.." / "..v.maxvalue.." ("..format("%.2f", v.value / v.maxvalue * 100).."%)", 1, 1, 1, 1)
                if rested and v.player then
                    GameTooltip:AddLine("Rested: "..rested.." ("..format("%.2f", rested / v.maxvalue * 100).."%)", 1, 1, 1, 1)
                end
                GameTooltip:Show()
            end
        end
        t.delay = 0.25

    end)

    return t
end

local function OnMarkTooltipEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    module.t:Show();
end

local function OnMarkTooltipLeave(self)
    module.t:Hide();
    GameTooltip:Hide()
end

function module:OnEnable()
    module.t = CreateMarkTooltip()
end

-- API
D.CreateMarkTooltip = CreateMarkTooltip
D.OnMarkTooltipEnter = OnMarkTooltipEnter
D.OnMarkTooltipLeave = OnMarkTooltipLeave
