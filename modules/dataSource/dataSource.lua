local D, C, L = _G.unpack(_G.select(2, ...))

local moduleName = "dataSource"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    self:RegisterMessage("dataXp:Update", "Update")
    self:RegisterMessage("dataRep:Update", "Update")
end

function module:OnDisable()
    --@alpha@
    D.Debug(moduleName, "OnDisable")
    --@end-alpha@
end


function module:Update(event, id, data)
    --@alpha@
    D.Debug(moduleName, "Update", event, id, data)
    --@end-alpha@

    D:SendMessage(moduleName..":Update", id, data, event)
end
