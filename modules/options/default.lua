local D, C, L = _G.unpack(_G.select(2, ...))

local HasArtifactEquipped = _G.HasArtifactEquipped
local UnitHasVehicleUI = _G.UnitHasVehicleUI

C["barpositions"] = {
    ["SCREENTOP"] = {"TOPLEFT", "UIParent", "TOPLEFT", 0, 0},
    ["SCREENBOTTOM"] = {"BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0}
}

C["player"] = {
    ["show"] = true,
    ["color"] = {0.25, 0.5, 1, 1},
    ["colorRested"] = {0.5, 0.25, 1, 1}
}

C["sparkXP"] = {
    ["max"] = 6,
    ["formats"] = {
        ["dataXp"] = L["XP_MARK_TT_1"],
        ["dataRep"] = L["REP_MARK_TT_1"],
        ["dataAp"] = L["AP_MARK_TT_1"]
    },
    ["font"] = {_G.GameFontNormal:GetFont(), 12, "OUTLINE", 0},
    ["fontColor"] = {1, .82, 0, 1},
    ["xSpread"] = {-15, 15},
    ["ySpread"] = {-120, -80},
    ["durationSpread"] = {2, 3}
}

C["sparkModel"] = {
    ["size"] = 3,
    ["model"] = "spells/7fx_mage_aegwynnsascendance_statehand.m2"
    -- spells/7fx_mage_aegwynnsascendance_statehand.m2
    -- spells/voljin_serpentward_missile.m2
    -- spells/7fx_druid_halfmoon_missile.m2
}

C["bar"] = {
    ["position"] = "SCREENTOP",
    ["dataSource"] = "dataXp",
    ["show"] = false,
    ["texture"] = "Interface\\AddOns\\" .. D.addonName .. "\\media\\bar.blp",
    ["backdrop"] = [[Interface\BUTTONS\WHITE8X8]],
    ["edge"] = [[Interface\BUTTONS\WHITE8X8]],
    ["height"] = 1,
    ["animationSpeed"] = 6
}

C["mark"] = {
    ["position"] = "SCREENTOP",
    ["size"] = 15,
    ["dataSource"] = "dataXp",
    ["showPlayer"] = true,
    ["animationSpeed"] = 6,
    ["texture"] = {
        ["default"] = "Interface\\AddOns\\" .. D.addonName .. "\\media\\circle.tga",
        ["below"] = "Interface\\AddOns\\" .. D.addonName .. "\\media\\circle-minus.tga",
        ["over"] = "Interface\\AddOns\\" .. D.addonName .. "\\media\\circle-plus.tga"
    }
}

local function GetMarkMenuPosition()
    local p = {}
    p["SCREENTOP"] = L["POS_SCREENTOP"]
    p["SCREENBOTTOM"] = L["POS_SCREENBOTTOM"]

    if _G["ArtifactWatchBar"]:IsVisible() then
        p["BLIZZEXPBAR"] = L["POS_BLIZZ_EXPBAR"]
    end

    if _G["MainMenuExpBar"]:IsVisible() then
        p["BLIZZEXPBAR"] = L["POS_BLIZZ_EXPBAR"]
    end

    if _G["ReputationWatchBar"]:IsVisible() then
        p["BLIZZEXPBAR"] = L["POS_BLIZZ_EXPBAR"]
    end

    return p
end

local function GetDataSourceOptions()
    local d = {}
    d["dataXp"] = L["dataXp"]
    d["dataRep"] = L["dataRep"]

    if HasArtifactEquipped() and not UnitHasVehicleUI("player") then
        d["dataAp"] = L["dataAp"]
    end

    return d
end

D.GetDataSourceOptions = GetDataSourceOptions
D.GetMarkMenuPosition = GetMarkMenuPosition
