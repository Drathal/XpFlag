local D, C, L = unpack(select(2, ...))

local _G = _G
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local UnitLevel = _G.UnitLevel
local SendAddonMessage = _G.SendAddonMessage
local RegisterAddonMessagePrefix = _G.RegisterAddonMessagePrefix

local MessagePrefix = "XPF1b"
local MSG_TYPE_DATA = "DATA"
local MSG_TYPE_REQUEST = "RESQUEST"
local MSG_TYPE_DELETE = "DELETE"
local MSG_TYPE_PING = "PING"
local MSG_TYPE_PONG = "PONG"

local module = D:NewModule("Communication", "AceEvent-3.0")

local function CreateMessage(type, xp, max, level, class)
    local data = D.DataXpGet({
        xp = xp,
        max = max,
        level = level,
        class = class
    })
    return (type or MSG_TYPE_DATA)..":"..data.xp..":"..data.max..":"..data.level..":"..data.class
end

local function DecodeMessage(msg)
    local type, xp, max, level, class = msg:match("^(.-):(.-):(.-):(.-):(.-)$");

    return {
        type = type,
        xp = xp,
        max = max,
        level = level,
        class = class
    }
end

local function Send(type, target)
    -- print("COM: Send", type, target, CreateMessage(type))
    if not string.match(target, "%-") then return end
    SendAddonMessage(MessagePrefix, CreateMessage(type), "WHISPER", target)
end

local function SendRequest(target)
    Send(MSG_TYPE_REQUEST, target)
end

local function SendDelete(target)
    Send(MSG_TYPE_DELETE, target)
end

local function SendPing(target)
    Send(MSG_TYPE_PING, target)
end

local function SendPong(target)
    Send(MSG_TYPE_PONG, target)
end

local function SendUpdate(target)
    Send(MSG_TYPE_DATA, target)
end

local function SendUpdates()
    for target, _ in pairs(D.GetMarks()) do
        if target and target ~= D.nameRealm then
            SendUpdate(target)
        end
    end
end

function module:OnEnable()
    RegisterAddonMessagePrefix(MessagePrefix)
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterMessage("DataXpUpdate", SendUpdates)
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

    local data = DecodeMessage(rawmsg)

    if data.type == MSG_TYPE_DATA then
        D:SendMessage("ReceiveData", sender, data)
    end

    if data.type == MSG_TYPE_PING then
        SendPong(sender)
        D:SendMessage("ReceivePing", sender, data)
    end

    if data.type == MSG_TYPE_PONG then
        D:SendMessage("ReceivePong", sender, data)
    end

    if data.type == MSG_TYPE_REQUEST then
        SendUpdate(sender)
        D:SendMessage("ReceiveRequest", sender, data)
    end

    if data.type == MSG_TYPE_DELETE then
        D:SendMessage("ReceiveDelete", sender, data)
    end
end

-- API
D.SendRequest = SendRequest
D.SendDelete = SendDelete
D.SendPing = SendPing
D.SendPong = SendPong
D.SendUpdate = SendUpdate
D.SendUpdates = SendUpdates
