local D, C, L = _G.unpack(_G.select(2, ...))

local moduleName = "dataSource"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:OnEnable()
    self:RegisterMessage("dataAp:Update", "Update")
    self:RegisterMessage("dataXp:Update", "Update")
    self:RegisterMessage("dataRep:Update", "Update")
end

function module:OnDisable()
end

function module:Update(event, id, data)
    D:SendMessage(moduleName .. ":Update", id, data, event)
end
