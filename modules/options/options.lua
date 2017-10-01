local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local CopyTable = _G.CopyTable
local LibStub = _G.LibStub

local function Get(section)
    return function(info)
        local key = info[#info]
        if section then
            return C.db.profile[section][key]
        end
        return C.db.profile[key]
    end
end

local function Set(moduleName)
    return function(info, value)
        local key = info[#info]
        if moduleName then
            C.db.profile[moduleName][key] = value
            D:GetModule(moduleName):Config(key, value)
        else
            C.db.profile[key] = value
        end
    end
end

D.options = {
    name = D.addonName.." "..D.version,
    type = 'group',
    args = {
        bar = {
            type = 'group',
            order = 1,
            name = L["SECTION_BAR"],
            get = Get('bar'),
            set = Set('bar'),
            args = {
                header = {
                    order = 1,
                    type = 'header',
                    name = L["SECTION_BAR_HEADER"],
                    width = 'full'
                },
                description = {
                    order = 2,
                    type = 'description',
                    name = L["SECTION_BAR_DESCRIPTION"],
                    width = 'full',
                },
                show = {
                    type = 'toggle',
                    order = 3,
                    width = 'full',
                    name = L["SHOW_PLAYER_BAR_LABEL"],
                    desc = L["SHOW_PLAYER_BAR_DESC"]
                },
                dataSource = {
                    type = 'select',
                    order = 4,
                    width = 'full',
                    values = {
                        ["dataXp"] = L["PLAYER_BAR_DATASOURCE_OPTION_XP"],
                        ["dataRep"] = L["PLAYER_BAR_DATASOURCE_OPTION_REP"],
                    },
                    name = L["PLAYER_BAR_DATASOURCE_LABEL"],
                    desc = L["PLAYER_BAR_DATASOURCE_DESC"]
                },
                position = {
                    type = 'select',
                    order = 5,
                    width = 'full',
                    values = {
                        ["SCREENTOP"] = L["POS_SCREENTOP"],
                        ["SCREENBOTTOM"] = L["POS_SCREENBOTTOM"],
                    },
                    name = L["PLAYER_BAR_POS_LABEL"],
                    desc = L["PLAYER_BAR_POS_DESC"]
                },
                height = {
                    type = 'range',
                    order = 6,
                    width = 'full',
                    min = 1,
                    max = 15,
                    step = 1,
                    name = L["PLAYER_BAR_HEIGHT_LABEL"],
                    desc = L["PLAYER_BAR_HEIGHT_DESC"]
                },
            }
        },
        mark = {
            type = 'group',
            order = 2,
            name = L["SECTION_MARK"],
            get = Get('mark'),
            set = Set('mark'),
            args = {
                header = {
                    order = 1,
                    type = 'header',
                    name = L["SECTION_MARK_HEADER"],
                    width = 'full'
                },
                description = {
                    order = 2,
                    type = 'description',
                    name = L["SECTION_MARK_DESCRIPTION"],
                    width = 'full',
                },
                showPlayer = {
                    type = 'toggle',
                    order = 3,
                    width = 'full',
                    name = L["SHOW_PLAYER_MARK_LABEL"],
                    desc = L["SHOW_PLAYER_MARK_DESC"]
                },
                dataSource = {
                    type = 'select',
                    order = 4,
                    width = 'full',
                    values = {
                        ["dataXp"] = L["PLAYER_BAR_DATASOURCE_OPTION_XP"],
                        ["dataRep"] = L["PLAYER_BAR_DATASOURCE_OPTION_REP"],
                    },
                    name = L["PLAYER_BAR_DATASOURCE_LABEL"],
                    desc = L["PLAYER_BAR_DATASOURCE_DESC"]
                },
                position = {
                    type = 'select',
                    order = 5,
                    width = 'full',
                    values = function()
                        local items = {}
                        items["SCREENTOP"] = L["POS_SCREENTOP"]
                        items["SCREENBOTTOM"] = L["POS_SCREENBOTTOM"]
                        if _G['MainMenuBarOverlayFrame']:IsVisible() then
                            items["BLIZZEXPBAR"] = L["POS_BLIZZ_EXPBAR"]
                        end
                        return items
                    end,
                    name = L["MARK_POS_LABEL"],
                    desc = L["Mark_POS_DESC"]
                },
                size = {
                    type = 'range',
                    order = 6,
                    width = 'full',
                    min = 5,
                    max = 50,
                    step = 1,
                    name = L["MARK_SIZE_LABEL"],
                    desc = L["MARK_SIZE_DESC"]
                },
            }
        },

    },
}

function D:OnInitialize()
    local default = {}
    default.profile = CopyTable(C)

    C.db = LibStub("AceDB-3.0"):New("XpFlagDB", default, "Default")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(self.addonName, self.options)
    self.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(C.db)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.addonName)

    C.db.RegisterCallback(self, "OnProfileChanged", "RefreshOptions")
    C.db.RegisterCallback(self, "OnProfileCopied", "RefreshOptions")
    C.db.RegisterCallback(self, "OnProfileReset", "RefreshOptions")
end

function D:RefreshOptions(event, database, newProfileKey)
    -- private.db = database.profile
end
