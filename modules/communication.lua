local D, C, L = unpack(select(2, ...))

local _G = _G
local match = _G.string.match
local pairs = _G.pairs
local split = _G.strsplit
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

local moduleName = "com"
local module = D:NewModule(moduleName, "AceEvent-3.0", "AceSerializer-3.0")

--@alpha@
-- mock communication
local assert = _G.assert
local select = _G.select
local random = _G.math.random
function module:FakeSendAddonMessage(prefix, msg, type, target)

    local _, data = self:Deserialize(msg)

    D.Debug(moduleName, "FakeSendAddonMessage", data.type, prefix, type, target)

    local fakeData = {
        dataType = "dataXp",
        name = select(1, split("-", D.fakeName)),
        realm = select(2, split("-", D.fakeName)),
        level = random(1, 110),
        class = "HUNTER",
        disable = false,
        value = 233,
        max = 5000,
        gain = 112,
        rested = 0
    }

    -- when we send a ping -- other player is sending pong back
    if data.type == MSG_TYPE_PING then
        fakeData.type = MSG_TYPE_PONG
        local dataString = self:Serialize(D:GetModule(C.db.profile.mark.dataSource):GetData(fakeData))
        self:CHAT_MSG_ADDON("CHAT_MSG_ADDON", MessagePrefix, dataString, "WHISPER", D.fakeName)
    end

    if data.type == MSG_TYPE_REQUEST then
        fakeData.type = MSG_TYPE_DATA
        local dataString = self:Serialize(D:GetModule(C.db.profile.mark.dataSource):GetData(fakeData))
        self:CHAT_MSG_ADDON("CHAT_MSG_ADDON", MessagePrefix, dataString, "WHISPER", D.fakeName)
    end
end
--@end-alpha@

function module:Send(type, target)
    --@alpha@
    D.Debug(moduleName, "Send", type, target)
    assert(type, 'com:Send - type is missing')
    assert(target, 'com:Send - target is missing')
    assert(match(target, "%-") == '-', 'com:Send - target has no relam ')
    --@end-alpha@

    if not match(target, "%-") then return end

    --@alpha@
    if target ~= D.fakeName then
        --@end-alpha@
        SendAddonMessage(MessagePrefix, self:Serialize(D:GetModule(C.db.profile.mark.dataSource):GetData({type = type})), "WHISPER", target)
        --@alpha@
    end

    if target == D.fakeName then
        self:FakeSendAddonMessage(MessagePrefix, self:Serialize(D:GetModule(C.db.profile.mark.dataSource):GetData({type = type})), "WHISPER", target)
    end
    --@end-alpha@
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
    for target, _ in pairs(D:GetModule("mark"):GetMarks()) do
        if target and target ~= D.nameRealm then
            self:SendUpdate(target)
        end
    end
end

function module:OnEnable()
    RegisterAddonMessagePrefix(MessagePrefix)
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterMessage(C.db.profile.mark.dataSource, "SendUpdates")
end

function module:OnDisable()
    self:UnregisterEvent("CHAT_MSG_ADDON")
    self:UnregisterMessage(C.db.profile.mark.dataSource)
end

function module:CHAT_MSG_ADDON(event, pre, rawmsg, chan, sender)
    if pre ~= MessagePrefix then return end
    if sender == D.nameRealm then return end
    if not rawmsg or rawmsg == "" then return end

    if not match(sender, "%-") then
        sender = sender.."-"..D.realm
    end

    local success, data = self:Deserialize(rawmsg)

    --@alpha@
    assert(success, "CHAT_MSG_ADDON:Deserialize failed")
    D.Debug(moduleName, "CHAT_MSG_ADDON", data.type, pre, chan, sender)
    --@end-alpha@

    if not success then return end

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
