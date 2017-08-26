local D, C, L = unpack(select(2, ...))

local _G = _G
local GameFontNormal = _G.GameFontNormal

local options = nil

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
            local module = D:GetModule(moduleName)
            module:Update()
        else
            C.db.profile[key] = value
        end
    end
end

D.options = {
    name = D.addonName,
    type = 'group',
    args = {
        bar = {
            type = 'group',
            order = 1,
            name = L["SECTION_BAR"],
            get = Get('bar'),
            set = Set('bar'),
            args = {
                show = {
                    type = 'toggle',
                    order = 1,
                    width = 'full',
                    name = L["SHOW_PLAYER_XP_BAR_LABEL"],
                    desc = L["SHOW_PLAYER_XP_BAR_DESC"]
                },
                height = {
                    type = 'range',
                    order = 2,
                    width = 'full',
                    min = 1,
                    max = 15,
                    step = 1,
                    name = L["PLAYER_XP_BAR_HEIGHT_LABEL"],
                    desc = L["PLAYER_XP_BAR_HEIGHT_DESC"]
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
                showPlayer = {
                    type = 'toggle',
                    order = 1,
                    width = 'full',
                    name = L["SHOW_PLAYER_MARK_LABEL"],
                    desc = L["SHOW_PLAYER_MARK_DESC"]
                },
                size = {
                    type = 'range',
                    order = 2,
                    width = 'full',
                    min = 6,
                    max = 30,
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
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.addonName)
end

C["player"] = {
    ["show"] = true,
    ["color"] = { 0.25, 0.5, 1, 1 },
    ["colorRested"] = { 0.5, 0.25, 1, 1 }
}

C["sparkXP"] = {
    ["max"] = 10,
    ["format"] = "%s XP",
    ["font"] = { GameFontNormal:GetFont(), 12, "OUTLINE", 0 },
    ["fontColor"] = { 1, .82, 0, 1 },
    ["xSpread"] = { - 15, 15 },
    ["ySpread"] = { - 120, - 80 },
    ["durationSpread"] = { 1, 2 },
    ["y"] = -20
}

C["sparkModel"] = {
    ["size"] = 64,
    ["model"] = "spells/7fx_mage_aegwynnsascendance_statehand.m2"
    -- spells/7fx_mage_aegwynnsascendance_statehand.m2
    -- spells/voljin_serpentward_missile.m2
    -- spells/7fx_druid_halfmoon_missile.m2
}

C["bar"] = {
    ["position"] = { "TOPLEFT", _G['UIParent'], "TOPLEFT", 0, 0 },
    ["show"] = true,
    ["texture"] = "Interface\\AddOns\\"..D.addonName.."\\media\\bar.blp",
    ["backdrop"] = [[Interface\BUTTONS\WHITE8X8]],
	["edge"] = [[Interface\BUTTONS\WHITE8X8]],
	["height"] = 1,
	["animationSpeed"] = 6
}

C["mark"] = {
	["size"] = 15,
	["flip"] = true,
    ["showPlayer"] = true,
	["animationSpeed"] = 6,
	["texture"] = {
		["default"] = "Interface\\AddOns\\"..D.addonName.."\\media\\circle.tga",
		["below"] = "Interface\\AddOns\\"..D.addonName.."\\media\\circle-minus.tga",
		["over"] = "Interface\\AddOns\\"..D.addonName.."\\media\\circle-plus.tga",
	}
}
