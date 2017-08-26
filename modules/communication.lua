local D, C, L = unpack(select(2, ...))

local _G = _G
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local UnitLevel = _G.UnitLevel
local SendAddonMessage = _G.SendAddonMessage

local MessagePrefix = D.addonName
local MSG_TYPE_DATA = "DATA"
local MSG_TYPE_REQUEST = "RESQUEST"
local MSG_TYPE_DELETE = "DELETE"
local MSG_TYPE_PING = "PING"
local MSG_TYPE_PONG = "PONG"

local module = D:NewModule("Communication", "AceEvent-3.0")

function module:OnEnable()
    module:RegisterEvent("CHAT_MSG_ADDON")
    module:RegisterEvent("PLAYER_XP_UPDATE")
    RegisterAddonMessagePrefix(MessagePrefix)
end

local function CreateMessage(type, xp, max, level, class)
    return (type or MSG_TYPE_DATA)..":"..(xp or UnitXP("PLAYER"))..":"..(max or UnitXPMax("PLAYER"))..":"..(level or UnitLevel("player"))..":"..(class or D.class)
end

local function DecodeMessage(msg)
    local type, xp, maxxp, level, class = msg:match("^(.-):(.-):(.-):(.-):(.-)$");

    return {
        type = type,
        xp = xp,
        maxxp = maxxp,
        level = level,
        class = class
    }
end

local function SendRequest(target)
    if not string.match(target, "%-") then return end
    SendAddonMessage(MessagePrefix, CreateMessage(MSG_TYPE_REQUEST), "WHISPER", target)
end

local function SendDelete(target)
    if not string.match(target, "%-") then return end
    SendAddonMessage(MessagePrefix, CreateMessage(MSG_TYPE_DELETE), "WHISPER", target)
end

local function SendPing(target)
    if not string.match(target, "%-") then return end
    SendAddonMessage(MessagePrefix, CreateMessage(MSG_TYPE_PING), "WHISPER", target)
end

local function SendPong(target)
    if not string.match(target, "%-") then return end
    SendAddonMessage(MessagePrefix, CreateMessage(MSG_TYPE_PONG), "WHISPER", target)
end

local function SendUpdate(target)
    if not string.match(target, "%-") then return end
    SendAddonMessage(MessagePrefix, CreateMessage(MSG_TYPE_DATA), "WHISPER", target)
    D:SendMessage("SendData", sender)
end

local function SendUpdates()
    for target, _ in pairs(D.GetMarks()) do
        if target and target ~= D.nameRealm then
            SendUpdate(target)
        end
    end
end

function module:CHAT_MSG_ADDON(event, pre, rawmsg, chan, sender)
    if pre ~= MessagePrefix then return end
    if sender == D.nameRealm then return end
    if not rawmsg or rawmsg == "" then return end

    if not string.match(sender, "%-") then
        sender = sender.."-"..D.realm
    end

    local msg = DecodeMessage(rawmsg)

    if msg.type == MSG_TYPE_DATA then
        D:SendMessage("ReceiveData", sender, msg)
    end

    if msg.type == MSG_TYPE_PING then
        SendPong(sender)
        D:SendMessage("ReceivePing", sender, msg)
    end

    if msg.type == MSG_TYPE_PONG then
        D:SendMessage("ReceivePong", sender, msg)
    end

    if msg.type == MSG_TYPE_REQUEST then
        SendUpdate(sender)
        D:SendMessage("ReceiveRequest", sender, msg)
    end

    if msg.type == MSG_TYPE_DELETE then
        D:SendMessage("ReceiveDelete", sender, msg)
    end
end

function module:PLAYER_XP_UPDATE(event, unit)
    if unit ~= "player" then return end
    if D.IsMaxLevel() then
        module:UnregisterEvent("PLAYER_XP_UPDATE")
        return
    end
    SendUpdates()
end

-- API
D.SendRequest = SendRequest
D.SendDelete = SendDelete
D.SendPing = SendPing
D.SendPong = SendPong
D.SendUpdate = SendUpdate
D.SendUpdates = SendUpdates
