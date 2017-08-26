local D, C, L = unpack(select(2, ...))

local _G = _G
local buttonOff = "Interface\\COMMON\\Indicator-Gray"
local buttonOn = "Interface\\COMMON\\Indicator-Green"
local pinged = {}
local online = {}
local hasAddon = {}
local throttleTime = 10

local module = D:NewModule("Friends", "AceEvent-3.0")

local function GetBNFriendName(id)
    local bnetIDAccount, _, _, isBattleTagPresence, characterName, bnetIDGameAccount, client, isOnline, _, isAFK, isDND, _, _, isRIDFriend, _, _ = BNGetFriendInfo(id)
    if not bnetIDGameAccount then return end
    if not CanCooperateWithGameAccount(bnetIDGameAccount) then return end
    local _, characterName, client, realmName, realmID, faction, race, class, _, zoneName, _, _, _, _, _, _ = BNGetGameAccountInfo(bnetIDGameAccount)

    if not isOnline or not characterName or client ~= 'WoW' then return nil end

    return characterName..'-'..realmName
end

local function GetFriendName(id)
    local name, level, class, area, connected, status, note, raf, id = GetFriendInfo(id)

    if not name or not connected then return nil end

    if not string.match(name, "-") then
        name = name.."-"..D.realm
    end

    return name
end

local function GetFriendNameByButton(button)
    if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        return GetBNFriendName(button.id)
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        return GetFriendName(button.id)
    end

    return nil
end

local function SetButtonTexture(button, state)
    if not button then return end

    if state then
        button:SetNormalTexture(buttonOn)
        button:SetPushedTexture(buttonOn)
        button:SetHighlightTexture(buttonOn)
        return
    end

    button:SetNormalTexture(buttonOff)
    button:SetPushedTexture(buttonOff)
    button:SetHighlightTexture(buttonOff)
end

local function CreateMiniButton(parent)
    local b = CreateFrame("Button", nil, parent)
    b:SetFrameLevel(8)
    b:SetFrameStrata("DIALOG")
    b:SetSize(16, 16)
    b:SetPoint("LEFT", parent, "LEFT", 3, - 8)
    b:SetNormalTexture(buttonOff)
    b:SetPushedTexture(buttonOff)
    b:SetHighlightTexture(buttonOff)
    b:Show()
    return b
end

local function RemoveOffineFriends()
    for friend, _ in pairs(D.GetMarks()) do
        if friend and friend ~= D.nameRealm and not online[friend] then
            D.DeleteMark(friend)
        end
    end
end

local function Ping(friend)
    if pinged[friend] and pinged[friend] > GetTime() - throttleTime then return end
    if hasAddon[friends] then return end
    D.SendPing(friend)
    pinged[friend] = GetTime()
end

local function OnStateButtonClick(button, friend)
    if D.GetMark(friend) then
        D.DeleteMark(friend)
        D.SendDelete(friend)
    else
        D.SendRequest(friend)
    end
end

local function OnFriendsFrameUpdate()
    local buttons = FriendsFrameFriendsScrollFrame.buttons
    wipe(online)

    for i = 1, #buttons do
        local friend = GetFriendNameByButton(buttons[i])
        if friend then
            online[friend] = buttons[i]
        end
    end

    for friend, button in pairs(online) do
        RemoveOffineFriends()
        Ping(friend)

        if hasAddon[friend] and button:IsShown() then
            if not button.statusbutton then
                button.statusbutton = CreateMiniButton(button)
                button.statusbutton:SetScript("OnClick", function(self) OnStateButtonClick(self, friend) end)
            end

            SetButtonTexture(button.statusbutton, D.GetMark(friend))
        end

    end
end

local function OnPong(event, friend)
    hasAddon[friend] = true
    OnFriendsFrameUpdate()
end

local function OnNewMark(event, friend)
    OnFriendsFrameUpdate()
end

local function OnDeleteMark(event, friend)
    OnFriendsFrameUpdate()
end

function module:OnEnable()
    hooksecurefunc(_G['FriendsFrameFriendsScrollFrame'], 'update', OnFriendsFrameUpdate)
    hooksecurefunc('FriendsFrame_UpdateFriends', OnFriendsFrameUpdate)
    self:RegisterMessage("ReceivePong", OnPong)
    self:RegisterMessage("CreateMark", OnNewMark)
    self:RegisterMessage("DeleteMark", OnDeleteMark)
end
