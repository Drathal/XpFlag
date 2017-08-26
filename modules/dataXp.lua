local D, C, L = unpack(select(2, ...))

local _G = _G
local GetXPExhaustion = _G.GetXPExhaustion
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

local module = D:NewModule("dataXp", "AceEvent-3.0")

function module:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_UPDATE_RESTING")
    self:RegisterEvent("PLAYER_XP_UPDATE")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:Update()   
end

function module:OnDisable()
    self:UnregisterEvent("PLAYER_UPDATE_RESTING")
    self:UnregisterEvent("PLAYER_XP_UPDATE")
    self:UnregisterEvent("PLAYER_LEVEL_UP")
end

function module:PLAYER_ENTERING_WORLD()
    self:Update()    
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

function module:PLAYER_UPDATE_RESTING()
    self:Update()   
end

function module:PLAYER_LEVEL_UP()
    self:Update()   
end

function module:PLAYER_XP_UPDATE(event, unit)
    if unit ~= 'player' then return end
    self:Update()
end

function module:GetData(mix)
    return {
        level = mix and mix.level or UnitLevel("player"),
        xp = mix and mix.xp or UnitXP("PLAYER"),
        max = mix and mix.max or UnitXPMax("PLAYER"),
        p = mix and mix.p or UnitXP("PLAYER") / UnitXPMax("PLAYER"),
        rested = mix and mix.rested or GetXPExhaustion(),
        isMaxLevel = mix and mix.isMaxLevel or D.IsMaxLevel(UnitLevel("player")),
        class = mix and mix.class or D.class
    }
end

function module:Update() 
    local data = self:GetData()

    D:SendMessage("DataXpUpdate", D.nameRealm, data)

    if data.isMaxLevel then
        self:Disable()
    end
end

-- API
D.DataXpGet = module.GetData