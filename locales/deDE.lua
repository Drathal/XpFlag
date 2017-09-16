local D, C, L = unpack(select(2, ...))

local _G = _G

if _G.GetLocale() ~= "deDE" then return end

L["DESCRIPTION"] = "Erfahrungs Anzeige für dich und deine Freunde."

L["SECTION_BAR"] = "Balken"
L["SHOW_PLAYER_BAR_LABEL"] = "Zeige"
L["SHOW_PLAYER_BAR_DESC"] = "Zeige / Verberge Balken"
L["PLAYER_BAR_POS_LABEL"] = "Position"
L["PLAYER_BAR_POS_DESC"] = "Position des Balken"
L["PLAYER_BAR_HEIGHT_LABEL"] = "Höhe"
L["PLAYER_BAR_HEIGHT_DESC"] = "Höhe des Balken"

L["SECTION_MARK"] = "Markierung"
L["SHOW_PLAYER_MARK_LABEL"] = "Zeige"
L["SHOW_PLAYER_MARK_DESC"] = "Zeige Spieler Markierung"
L["MARK_POS_LABEL"] = "Position"
L["Mark_POS_DESC"] = "Position des Markers"
L["MARK_SIZE_LABEL"] = "Größe"
L["MARK_SIZE_DESC"] = "Größe aller Markierungen"

L["POS_SCREENTOP"] = "Am oberen Bildschirm"
L["POS_SCREENBOTTOM"] = "am unteren Bildschirm"
L["POS_BLIZZ_EXPBAR"] = "Blizzard Erfahrungsbalken"

L["CONNECT_BUTTON_TT"] = "Verbinde dich mit click auf diesen Button."

L["XP_MARK_TT_1"] = "%s XP"
L["XP_MARK_TT_2"] = "Level: %s"
L["XP_MARK_TT_3"] = "Erfahrung: %s/%s (%.2f %%)"
L["XP_MARK_TT_4"] = "Ausgeruht: %s (%.2f %%)"
