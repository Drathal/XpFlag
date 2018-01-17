local D, C, L = _G.unpack(_G.select(2, ...))

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

C["dataSource"] = {
    ["dataXp"] = {
        ["enabled"] = true,
        ["sendData"] = true,
        ["markShowOwn"] = true,
        ["markShowOther"] = true,
        ["markPosition"] = "SCREENTOP",
        ["markSize"] = 15,
        ["barShowOwn"] = true,
        ["barPosition"] = "SCREENTOP",
        ["barSize"] = 2,
    },
    ["dataRep"] = {
        ["enabled"] = true,
        ["sendData"] = true,
        ["markShowOwn"] = true,
        ["markShowOther"] = true,
        ["markPosition"] = "SCREENTOP",
        ["markSize"] = 15,
        ["barShowOwn"] = true,
        ["barPosition"] = "SCREENTOP",
        ["barSize"] = 2,
    },
    ["dataAp"] = {
        ["enabled"] = true,
        ["sendData"] = true,
        ["markShowOwn"] = true,
        ["markShowOther"] = true,
        ["markPosition"] = "SCREENTOP",
        ["markSize"] = 15,
        ["barShowOwn"] = true,
        ["barPosition"] = "SCREENTOP",
        ["barSize"] = 2,
    },
}

C["positions"] = {
    ["SCREENTOP"] = {
        ["name"] = function() return L["POS_SCREENTOP"] end,
        ["enabled"] = function() return true end,
        ["pos"] = function() return {"TOP", "UIParent", "TOPLEFT", 0, 0} end
    },
    ["SCREENBOTTOM"] = {
        ["name"] = function() return L["POS_SCREENBOTTOM"] end,
        ["enabled"] = function() return true end,
        ["pos"] = function() return {"BOTTOM", "UIParent", "BOTTOMLEFT", 0, 0} end
    },
    ["BLIZZEXPBAR"] = {
        ["name"] = function() return L["POS_BLIZZ_EXPBAR"] end,
        ["enabled"] = function()
            return _G["ArtifactWatchBar"]:IsVisible() or _G["MainMenuExpBar"]:IsVisible() or _G["ReputationWatchBar"]:IsVisible()
        end,
        ["pos"] = function(dataSource)
            if _G["ArtifactWatchBar"]:IsVisible() and dataSource == "dataAp" then
                return {"TOP", "ArtifactWatchBar", "TOPLEFT", 0, -8}
            end

            if _G["MainMenuExpBar"]:IsVisible() and dataSource == "dataXp" then
               return {"TOP", "MainMenuExpBar", "TOPLEFT", 0, -8}
            end

            if _G["ReputationWatchBar"]:IsVisible() and dataSource == "dataRep" then
                return {"TOP", "ReputationWatchBar", "TOPLEFT", 0, -8}
            end

            return {"TOP", "UIParent", "TOPLEFT", 0, 0}
        end
    },
 }
