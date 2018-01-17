local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local CopyTable = _G.CopyTable
local LibStub = _G.LibStub
local i18n = L.i18n
local HasArtifactEquipped = _G.HasArtifactEquipped
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local order = 0

local function String2Position(key, dataSource)
    if C.positions[key] and C.positions[key].enabled() then
        return C.positions[key].pos(dataSource)
    end

    return C.positions["SCREENTOP"].pos()
end

local function GetMarkMenuPosition()
    local out = {}
    for key, obj in pairs(C.positions) do
        if obj and obj.enabled() then
            out[key] = obj.name()
        end
    end

    return out
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

local function Get(section)
    return function(info)
        local key = info[#info]
        -- print("GET",section, key)
        return C.db.profile["dataSource"][section][key]
    end
end

local function Set(section)
    return function(info, value)
        local key = info[#info]
        C.db.profile["dataSource"][section][key] = value

        print("SET",section, key, value)
        D:GetModule("mark"):Config(key, value)
    end
end

local function generateTypeSection(type)

    typeUpper = string.upper(type)

    order = order + 1

    return {
        type = "group",
        order = order,
        name = i18n("SECTION_"..type),
        get = Get(type),
        set = Set(type),
        args = {
            header = {
                order = 10,
                type = "header",
                name = i18n("SECTION_"..typeUpper.."_HEADER"),
                width = "full"
            },
            description = {
                order = 20,
                type = "description",
                name = i18n("SECTION_"..typeUpper.."_DESCRIPTION"),
                width = "full"
            },
            sendData = {
                type = "toggle",
                order = 30,
                width = "full",
                name = i18n("SECTION_"..typeUpper.."_SEND"),
                desc = i18n("SECTION_"..typeUpper.."_SEND_DESCRIPTION") 
            },              
            markShowOwn = {
                type = "toggle",
                order = 40,
                width = "full",
                name = i18n("SECTION_"..typeUpper.."_SHOWOWN"),
                desc = i18n("SECTION_"..typeUpper.."_SHOWOWN_DESCRIPTION") 
            },
            markShowOther = {
                type = "toggle",
                order = 50,
                width = "full",
                name = i18n("SECTION_MARK_"..typeUpper.."_SHOWOTHER"),
                desc = i18n("SECTION_MARK_"..typeUpper.."_SHOWOTHER_DESCRIPTION") 
            },
            markPosition = {
                type = "select",
                order = 60,
                width = "full",
                values = D.GetMarkMenuPosition,
                name = i18n("MARK_POS_LABEL"),
                desc = i18n("MARK_POS_DESC")
            },
            markSize = {
                type = "range",
                order = 70,
                width = "full",
                min = 5,
                max = 50,
                step = 1,
                name = i18n("MARK_SIZE_LABEL"),
                desc = i18n("MARK_SIZE_DESC")
            },
            barShowOwn = {
                type = "toggle",
                order = 80,
                width = "full",
                name = i18n("SECTION_BAR_"..typeUpper.."_SHOWOWN"),
                desc = i18n("SECTION_BAR_"..typeUpper.."_SHOWOWN_DESCRIPTION") 
            },        
            barPosition = {
                type = "select",
                order = 90,
                width = "full",
                values = D.GetMarkMenuPosition,
                name = i18n("BAR_POS_LABEL"),
                desc = i18n("BAR_POS_DESC")
            },
            barSize = {
                type = "range",
                order = 100,
                width = "full",
                min = 5,
                max = 50,
                step = 1,
                name = i18n("BAR_SIZE_LABEL"),
                desc = i18n("BAR_SIZE_DESC")
            }                           
        }
    }
end

local function generateDataSourceOptions(destinationTable)
    for key in pairs(D.GetDataSourceOptions()) do
        destinationTable[key] = generateTypeSection(key)
    end
end

local function getOptions()
    local options = {
        name = D.addonName .. " " .. D.version,
        type = "group",
        args = {}
    }

    generateDataSourceOptions(options.args)

    return options
end

function D:OnInitialize()

    D.options = getOptions()

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

D.GetDataSourceOptions = GetDataSourceOptions
D.GetMarkMenuPosition = GetMarkMenuPosition
D.String2Position = String2Position