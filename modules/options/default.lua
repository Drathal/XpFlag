local D, C, L = _G.unpack(_G.select(2, ...))

C["positions"] = {
    ["SCREENTOP"] = {"TOPLEFT", "UIParent", "TOPLEFT", 0, 0},
    ["SCREENBOTTOM"] = {"BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0},
    ["BLIZZEXPBAR"] = {"TOPLEFT", "MainMenuBarOverlayFrame", "TOPLEFT", 0, -8}
    -- ["BLIZZEXPBAR"] = { "BOTTOMLEFT", _G['MainMenuExpBar'], "BOTTOMLEFT", 0, 2 },
}

C["markerpositions"] = {
    ["SCREENTOP"] = {"TOP", "UIParent", "TOPLEFT", 0, 0},
    ["SCREENBOTTOM"] = {"BOTTOM", "UIParent", "BOTTOMLEFT", 0, 0},
    ["BLIZZEXPBAR"] = {"TOP", "MainMenuBarOverlayFrame", "TOPLEFT", 0, -8}
    -- ["BLIZZEXPBAR"] = { "BOTTOMLEFT", _G['MainMenuExpBar'], "BOTTOMLEFT", 0, 2 },
}

C["datasourceshort"] = {
    ["dataXp"] = "XP",
    ["dataRep"] = "REP"
}

C["datasourceshort"] = {
    ["dataXp"] = "XP",
    ["dataRep"] = "REP"
}

C["player"] = {
    ["show"] = true,
    ["color"] = {0.25, 0.5, 1, 1},
    ["colorRested"] = {0.5, 0.25, 1, 1}
}

C["sparkXP"] = {
    ["max"] = 6,
    ["format"] = L["XP_MARK_TT_1"],
    ["formats"] = {
        ["dataXp"] = L["XP_MARK_TT_1"],
        ["dataRep"] = L["REP_MARK_TT_1"]
    },
    ["font"] = {_G.GameFontNormal:GetFont(), 12, "OUTLINE", 0},
    ["fontColor"] = {1, .82, 0, 1},
    ["xSpread"] = {-15, 15},
    ["ySpread"] = {-120, -80},
    ["durationSpread"] = {1.5, 2}
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
    ["show"] = true,
    ["texture"] = "Interface\\AddOns\\" .. D.addonName .. "\\media\\bar.blp",
    ["backdrop"] = [[Interface\BUTTONS\WHITE8X8]],
    ["edge"] = [[Interface\BUTTONS\WHITE8X8]],
    ["height"] = 1,
    ["animationSpeed"] = 6
}

-- todo: move funtions to dataSource
C["tooltip"] = {
    ["XP"] = {
        [2] = function(data)
            return data.name, data.level
        end,
        [3] = function(data)
            return data.value, data.max, data.value / data.max * 100
        end,
        [4] = function(data)
            return data.rested, data.rested / data.max * 100
        end
    },
    ["REP"] = {
        [2] = function(data)
            return data.name, data.level
        end,
        [3] = function(data)
            return data.faction, _G["FACTION_STANDING_LABEL" .. data.standingID]
        end,
        [4] = function(data)
            return data.value, data.max, data.value / data.max * 100
        end
    }
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
