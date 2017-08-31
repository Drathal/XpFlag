local AddOnName, Engine = ...

-- speed up local calls
local _G = _G
local UnitName = _G.UnitName
local UnitGUID = _G.UnitGUID
local GetRealmName = _G.GetRealmName
local GetBuildInfo = _G.GetBuildInfo

-- init addon
local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceEvent-3.0")

-- export to Global
Engine[1] = AddOn
Engine[2] = {} -- C config default
Engine[3] = {} -- L locale
_G[AddOnName] = Engine

-- Addon API
AddOn.addonName = AddOnName
AddOn.title = GetAddOnMetadata(AddOnName, "Title")
AddOn.version = GetAddOnMetadata(AddOnName, "Version")
AddOn.name = UnitName("player")
AddOn.GUID = UnitGUID("player")
AddOn.class = select(2, UnitClass("player"))
AddOn.realm = GetRealmName()
AddOn.nameRealm = AddOn.name.."-"..AddOn.realm
AddOn.screenWidth = GetScreenWidth()
AddOn.screenHeight = GetScreenHeight()
AddOn.woWPatch, AddOn.woWBuild, AddOn.woWPatchReleaseDate, AddOn.tocVersion = GetBuildInfo()
AddOn.woWBuild = tonumber(AddOn.woWBuild)

--@alpha@
AddOn.fakeCom = true
AddOn.debug = {
    --@alpha@
    --mark = true,
    --dataXp = true,
    --markSpark = true,
    --markTooltip = true,
    com = true,
    --bar = true,
    friends = true
    --@end-alpha@
}
--@end-alpha@
