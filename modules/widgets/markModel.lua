local D, C, L = unpack(select(2, ...))

local _G = _G
local CreateFrame = _G.CreateFrame
local UIFrameFadeIn = _G.UIFrameFadeIn
local UIFrameFadeOut = _G.UIFrameFadeOut

local moduleName = "markModel"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:Create(parent)
    local m = CreateFrame('PlayerModel', D.addonName..'-SparkModel', parent)
    m:SetPoint('CENTER')
    m:SetSize(parent:GetWidth() * C.sparkModel.size, parent:GetWidth() * C.sparkModel.size)
    m:SetModel(C.sparkModel.model)
    m:SetAlpha(1)
    return m
end

function module:FadeInMarkModel(msg, name, f)
    --@alpha@
    D.Debug(moduleName, "FadeInMarkModel", name)
    --@end-alpha@
    if not f or not f.model then return end
    UIFrameFadeIn(f.model, 0.1, f.model:GetAlpha(), 0.5)
end

function module:FadeOutMarkModel(msg, f)
    --@alpha@
    D.Debug(moduleName, "FadeOutMarkModel")
    --@end-alpha@
    if not f or not f.model then return end
    UIFrameFadeOut(f.model, 1, f.model:GetAlpha(), 0)
end

function module:OnEnable()
    self:RegisterMessage("mark:Update", "FadeInMarkModel")
    self:RegisterMessage("AnimateXEnd", "FadeOutMarkModel")
end
