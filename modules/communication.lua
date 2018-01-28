local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local match = _G.string.match
local pairs = _G.pairs
local split = _G.strsplit
local UnitLevel = _G.UnitLevel

local MessagePrefix = "XPF1"
local MSG_TYPE_UPDATE = "UPDATE"
local MSG_TYPE_DATA = "DATA"
local MSG_TYPE_REQUEST = "RESQUEST"
local MSG_TYPE_DELETE = "DELETE"
local MSG_TYPE_PING = "PING"
local MSG_TYPE_PONG = "PONG"

local moduleName = "com"
local module = D:NewModule(moduleName, "AceEvent-3.0", "AceSerializer-3.0", "AceComm-3.0")

function module:Send(type, target, data)
    if not match(target, "%-") then
        return
    end

    data = data or {}
    data.type = type

    self:SendCommMessage(MessagePrefix, self:Serialize(data), "WHISPER", target)
end

function module:SendUpdates(msg, id, data, source)
    if C.db.profile.mark.dataSource .. ":Update" ~= source then
        return
    end

    for target, _ in pairs(D:GetModule("mark"):GetMarks()) do
        if target and target ~= D.nameRealm then
            self:SendUpdate(id, data)
        end
    end
end

function module:OnEnable()
    self:RegisterComm(MessagePrefix)
    self:RegisterMessage("dataSource:Update", "SendUpdates")
end

function module:OnDisable()
    self:UnregisterMessage("dataSource:Update")
end

function module:OnCommReceived(pre, rawmsg, chan, sender)
    if pre ~= MessagePrefix then
        return
    end
    if sender == D.nameRealm then
        return
    end
    if not rawmsg or rawmsg == "" then
        return
    end

    if not match(sender, "%-") then
        sender = sender .. "-" .. D.realm
    end

    local success, data = self:Deserialize(rawmsg)

    if not success then
        return
    end

    D:SendMessage("com:Update", sender, data)

    if data.type == MSG_TYPE_REQUEST then
        self:Send(MSG_TYPE_DATA, sender, data)
    end

end
