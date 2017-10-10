local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local print = _G.print
local type = _G.type
local pairs = _G.pairs
local min = _G.math.min
local tonumber = _G.tonumber
local abs = _G.math.abs
local GetXPExhaustion = _G.GetXPExhaustion
local GetFramerate = _G.GetFramerate
local GetExpansionLevel = _G.GetExpansionLevel
local CreateFrame = _G.CreateFrame
local UnitLevel = _G.UnitLevel
local MAX_PLAYER_LEVEL_TABLE = _G.MAX_PLAYER_LEVEL_TABLE

--@alpha@
local select = _G.select
local tostring = _G.tostring
local PARAMETER_COLORS = {"|cff88ff88"}
local function Debug(module, ...)
    if D.debug and not D.debug[module] then
        return
    end

    local msg = "|cffffff78 " .. tostring(module) .. "|r : "
    for n = 1, select("#", ...) do
        msg = msg .. " " .. (PARAMETER_COLORS[n] or " |cffffffff") .. tostring(select(n, ...)) .. "|r"
        if _G.ViragDevTool_AddData and type(select(n, ...)) == "table" then
            _G.ViragDevTool_AddData(select(n, ...), tostring(module) .. ":" .. select(1, ...))
        end
    end

    print(msg)
end
--@end-alpha@

local function Throttle(self, elapsed)
    self.delay = min((self.delay or 0.01) - elapsed, 0.15)
    if self.delay > 0 then
        return true
    end
    self.delay = (1 / GetFramerate() / 2)

    return nil
end

local function CreateUpdateAnimation(f, cb)
    local anim = CreateFrame("Frame")

    anim.UpdateAnimation = function(self, elapsed)
        if Throttle(self, elapsed) then
            return
        end
        if not f.to then
            self:Stop()
            return
        end
        cb(self, f, elapsed)
    end

    anim.Start = function()
        if not f.to then
            return
        end
        anim:SetScript("OnUpdate", anim.UpdateAnimation)
    end

    anim.Stop = function()
        anim:SetScript("OnUpdate", nil)
    end

    return anim
end

-- refactor dont need it here
local function GetXpColor()
    return GetXPExhaustion() and C.player.colorRested or C.player.color
end

-- refactor dont need it here
local function GetMarkTexture(friend, player)
    local texture = C.mark.texture.default
    if tonumber(friend) < tonumber(player) then
        texture = C.mark.texture.below
    elseif tonumber(friend) > tonumber(player) then
        texture = C.mark.texture.over
    end
    return texture
end

local function AnimateWidth(f)
    local cur = f:GetWidth()
    local new = cur + (f.to - cur) / C.bar.animationSpeed

    if abs(new - f.to) < 1 then
        new = f.to
        f.to = nil
    end

    f:SetWidth(new)

    return f.to
end

local function AnimateX(f)
    local cur = f.cur or 0
    local new = cur + (f.to - cur) / C.mark.animationSpeed

    if abs(new - f.to) < 1 then
        new = f.to
        f.to = nil
        D:SendMessage("AnimateXEnd", f)
    end

    local p1, p, p2, _, yOfs = f:GetPoint()
    f:ClearAllPoints()
    f:SetPoint(p1, p, p2, new, yOfs)

    f.cur = new
    return f.to
end

local function IsMaxLevel(level)
    return MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] == (level or UnitLevel("player"))
end

-- API
--@alpha@
D.Debug = Debug
--@end-alpha@
D.Throttle = Throttle
D.GetXpColor = GetXpColor
D.GetMarkTexture = GetMarkTexture
D.AnimateWidth = AnimateWidth
D.AnimateX = AnimateX
D.IsMaxLevel = IsMaxLevel
D.CreateUpdateAnimation = CreateUpdateAnimation
