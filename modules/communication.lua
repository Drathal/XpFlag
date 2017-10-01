local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local match = _G.string.match
local pairs = _G.pairs
local split = _G.strsplit
local UnitLevel = _G.UnitLevel

local MessagePrefix = "XPF1"
local MSG_TYPE_DATA = "DATA"
local MSG_TYPE_REQUEST = "RESQUEST"
local MSG_TYPE_DELETE = "DELETE"
local MSG_TYPE_PING = "PING"
local MSG_TYPE_PONG = "PONG"

local moduleName = "com"
local module = D:NewModule(moduleName, "AceEvent-3.0", "AceSerializer-3.0", "AceComm-3.0")

--@alpha@
-- mock communication
local After = _G.C_Timer.After
local assert = _G.assert
local select = _G.select
local random = _G.math.random
local vv = 0
local fakeData = {
    dataSource = "dataXp",
    name = select(1, split("-", D.fakeName)),
    realm = select(2, split("-", D.fakeName)),
    class = "MONK",
    disable = false,
    max = 5000
}

function module:FakeSendAddonMessage(prefix, msg, type, target)

    local _, data = self:Deserialize(msg)

    D.Debug(moduleName, "FakeSendAddonMessage", data.type, prefix, type, target)

    fakeData.level = random(UnitLevel("PLAYER") - 1, UnitLevel("PLAYER") + 1)
    fakeData.rested = random(100, 300)
    fakeData.gain = random(100, 300)

    vv = vv + fakeData.gain
    fakeData.value = vv

    if fakeData.value > 4999 then
        fakeData.value = 0
        vv = 0
    end

    if data.type == MSG_TYPE_PING then
        fakeData.type = MSG_TYPE_PONG
    end

    if data.type == MSG_TYPE_REQUEST or data.type == MSG_TYPE_DATA then
        fakeData.type = MSG_TYPE_DATA
        After(random(1, 5), function() self:SendUpdate(D.fakeName, fakeData) end)
    end

    if fakeData.type then
        self:OnCommReceived(MessagePrefix, self:Serialize(fakeData), "WHISPER", D.fakeName)
    end

end
--@end-alpha@

function module:Send(type, target, data)
    --@alpha@
    assert(type, 'com:Send - type is missing')
    assert(target, 'com:Send - target is missing')
    assert(match(target, "%-") == '-', 'com:Send - target has no relam ')
    --@end-alpha@

    if not match(target, "%-") then return end

    data = data or {}
    data.type = type

    --@alpha@
    if target ~= D.fakeName then
        D.Debug(moduleName, "Send", type, target)
        --@end-alpha@
        self:SendCommMessage(MessagePrefix, self:Serialize(data), "WHISPER", target)
        --@alpha@
    end

    if target == D.fakeName then
        self:FakeSendAddonMessage(MessagePrefix, self:Serialize(data), "WHISPER", target)
    end
    --@end-alpha@
end

function module:SendRequest(target, data)
    self:Send(MSG_TYPE_REQUEST, target, data)
end

function module:SendDelete(target, data)
    self:Send(MSG_TYPE_DELETE, target, data)
end

function module:SendPing(target, data)
    self:Send(MSG_TYPE_PING, target, data)
end

function module:SendPong(target, data)
    self:Send(MSG_TYPE_PONG, target, data)
end

function module:SendUpdate(target, data)
    self:Send(MSG_TYPE_DATA, target, data)
end

function module:SendUpdates(msg, id, data, source)
    if C.db.profile.mark.dataSource..":Update" ~= source then return end

    --@alpha@
    D.Debug(moduleName, "SendUpdates - incomming ", msg, id, data, source)
    --@end-alpha@

    for target, _ in pairs(D:GetModule("mark"):GetMarks()) do
        if target and target ~= D.nameRealm then
            --@alpha@
            D.Debug(moduleName, "SendUpdates", id, data)
            --@end-alpha@

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
    if pre ~= MessagePrefix then return end
    if sender == D.nameRealm then return end
    if not rawmsg or rawmsg == "" then return end

    if not match(sender, "%-") then
        sender = sender.."-"..D.realm
    end

    local success, data = self:Deserialize(rawmsg)

    --@alpha@
    assert(success, "OnCommReceived:Deserialize failed")
    D.Debug(moduleName, "OnCommReceived", data.type, pre, chan, sender, data)
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
