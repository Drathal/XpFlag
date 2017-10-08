local AddOnName, Engine = ...

-- speed up local calls
local _G = _G
local UnitName = _G.UnitName
local UnitGUID = _G.UnitGUID
local GetRealmName = _G.GetRealmName
local GetBuildInfo = _G.GetBuildInfo
local LibStub = _G.LibStub

-- init addon
local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceEvent-3.0")

-- export to Global
Engine[1] = AddOn
Engine[2] = {} -- C config default
Engine[3] = {} -- L locale
_G[AddOnName] = Engine

-- Addon API
AddOn.addonName = AddOnName
AddOn.title = _G.GetAddOnMetadata(AddOnName, "Title")
AddOn.version = _G.GetAddOnMetadata(AddOnName, "Version")
AddOn.name = UnitName("player")
AddOn.GUID = UnitGUID("player")
AddOn.class = _G.select(2, _G.UnitClass("player"))
AddOn.realm = GetRealmName()
AddOn.nameRealm = AddOn.name .. "-" .. AddOn.realm
AddOn.screenWidth = _G.GetScreenWidth()
AddOn.screenHeight = _G.GetScreenHeight()
AddOn.woWPatch, AddOn.woWBuild, AddOn.woWPatchReleaseDate, AddOn.tocVersion = GetBuildInfo()
AddOn.woWBuild = _G.tonumber(AddOn.woWBuild)

--@alpha@
AddOn.fakeCom = true
AddOn.fakeName = "dummy-Madmortem"
AddOn.debug = {
    --mark = true,
    --markSpark = true,
    --markModel = true,
    --markTooltip = true,
    --dataSource = true,
    --dataXp = true,
    --dataRep = true,
    --com = true,
    --bar = true,
    friends = true
    --utils = true
}
--@end-alpha@
