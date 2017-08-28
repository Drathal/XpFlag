local D, C, L = unpack(select(2, ...))

local _G = _G
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local UnitLevel = _G.UnitLevel
local SendAddonMessage = _G.SendAddonMessage
local RegisterAddonMessagePrefix = _G.RegisterAddonMessagePrefix
local LibStub = _G.LibStub

local MessagePrefix = "XPF1"
local MSG_TYPE_DATA = "DATA"
local MSG_TYPE_REQUEST = "RESQUEST"
local MSG_TYPE_DELETE = "DELETE"
local MSG_TYPE_PING = "PING"
local MSG_TYPE_PONG = "PONG"

local module = D:NewModule("com", "AceEvent-3.0", "AceSerializer-3.0")

function module:Send(type, target)
    -- print("COM: Send", type, target, CreateMessage(type))
    if not string.match(target, "%-") then return end
    SendAddonMessage(MessagePrefix, self:Serialize(D[C.db.profile.mark.dataSource].GetData({type = type})), "WHISPER", target)
end

function module:SendRequest(target)
    self:Send(MSG_TYPE_REQUEST, target)
end

function module:SendDelete(target)
    self:Send(MSG_TYPE_DELETE, target)
end

function module:SendPing(target)
    self:Send(MSG_TYPE_PING, target)
end

function module:SendPong(target)
    self:Send(MSG_TYPE_PONG, target)
end

function module:SendUpdate(target)
    self:Send(MSG_TYPE_DATA, target)
end

function module:SendUpdates()
    for target, _ in pairs(D.GetMarks()) do
        if target and target ~= D.nameRealm then
            self:SendUpdate(target)
        end
    end
end

function module:OnEnable()
    RegisterAddonMessagePrefix(MessagePrefix)
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterMessage("DataXpUpdate", "SendUpdates")
end

function module:OnDisable()
    self:UnregisterEvent("CHAT_MSG_ADDON")
    self:UnregisterMessage("DataXpUpdate")
end

function module:CHAT_MSG_ADDON(event, pre, rawmsg, chan, sender)
    if pre ~= MessagePrefix then return end
    if sender == D.nameRealm then return end
    if not rawmsg or rawmsg == "" then return end

    if not string.match(sender, "%-") then
        sender = sender.."-"..D.realm
    end

    local data = self:Deserialize(rawmsg)

    if data.type == MSG_TYPE_DATA then
        D:SendMessage("ReceiveData", sender, data)
    end

    if data.type == MSG_TYPE_PING then
        self:SendPong(sender)
        D:SendMessage("ReceivePing", sender, data)
    end

    if data.type == MSG_TYPE_PONG then
        self:SendMessage("ReceivePong", sender, data)
    end

    if data.type == MSG_TYPE_REQUEST then
        self:SendUpdate(sender)
        D:SendMessage("ReceiveRequest", sender, data)
    end

    if data.type == MSG_TYPE_DELETE then
        D:SendMessage("ReceiveDelete", sender, data)
    end
end
