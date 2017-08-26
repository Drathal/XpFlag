local D, C, L = unpack(select(2, ...))

local _G = _G
local min = math.min;
local max = math.max;
local floor = math.floor
local GetXPExhaustion = _G.GetXPExhaustion
local GetFramerate = _G.GetFramerate
local GetExpansionLevel = _G.GetExpansionLevel
local UnitLevel = _G.UnitLevel

local function CopyTable(src, dest)
    if type(dest) ~= "table" then
        dest = {}
    end

    for k, v in next, src do
        if type(v) == "table" then
            dest[k] = CopyTable(v, dest[k])
        else
            dest[k] = v
        end
    end

    return dest
end

-- TODO: refactor
local function Throttle(self, elapsed)
    self.delay = min((self.delay or 0.01) - elapsed, 0.15);
    if self.delay > 0 then return true end
    self.delay = 12 / GetFramerate();

    return nil
end

local function CreateUpdateAnimation(f, cb)
    local anim = CreateFrame('Frame')

    anim.UpdateAnimation = function(self, elapsed)
        if Throttle(self, elapsed) then return end
        if not f.to or f.to == 0 then
            self:Stop()
            return
        end
        cb(self, f, elapsed)
    end

    anim.Start = function()
        if not f.to or f.to == 0 then return end
        anim:SetScript("OnUpdate", anim.UpdateAnimation)
    end

    anim.Stop = function()
        anim:SetScript("OnUpdate", nil)
    end

    return anim
end

local function GetXpColor()
    return GetXPExhaustion() and C.player.colorRested or C.player.color
end

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
    if not f then return end
    if not f.to then return end

    local cur = f:GetWidth()
    local new = cur + min((f.to - cur) / C.bar.animationSpeed, f.to - cur)

    if cur == f.to or abs(new - f.to) < 2 then
        new = f.to
        f.to = nil
    end

    f:SetWidth(new)

    return f.to
end

local function AnimateX(f)
    if not f then return end
    if not f.to then return end

    local cur = f.cur or 0
    local new = cur + min((f.to - cur) / C.mark.animationSpeed, f.to - cur)

    if cur == f.to or abs(new - f.to) < 2 then
        new = f.to
        f.to = nil
        D:SendMessage("AnimateXEnd", f)
    end

    local p1, p, p2, xOfs, yOfs = f:GetPoint()
    f:ClearAllPoints();
    f:SetPoint(p1, p, p2, new - f:GetWidth() / 2, 0);

    f.cur = new
    return f.to
end

local function IsMaxLevel(level)
    return MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] == (level or UnitLevel("player"));
end

-- API
D.FormatNumber = FormatNumber
D.Throttle = Throttle
D.GetXpColor = GetXpColor
D.GetMarkTexture = GetMarkTexture
D.AnimateWidth = AnimateWidth
D.AnimateX = AnimateX
D.IsMaxLevel = IsMaxLevel
D.CopyTable = CopyTable
D.CreateUpdateAnimation = CreateUpdateAnimation
