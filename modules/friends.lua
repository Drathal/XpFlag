local D, C, L = unpack(select(2, ...))

local _G = _G
local GetTime = _G.GetTime
local CanCooperateWithGameAccount = _G.CanCooperateWithGameAccount
local BNGetGameAccountInfo = _G.BNGetGameAccountInfo
local BNGetFriendInfo = _G.BNGetFriendInfo
local GetFriendInfo = _G.GetFriendInfo
local CreateFrame = _G.CreateFrame
local FriendsFrame = _G.FriendsFrame
local FriendsFrameFriendsScrollFrame = _G.FriendsFrameFriendsScrollFrame
local wipe = _G.wipe
local hooksecurefunc = _G.hooksecurefunc
local FRIENDS_BUTTON_TYPE_BNET = _G.FRIENDS_BUTTON_TYPE_BNET
local FRIENDS_BUTTON_TYPE_WOW = _G.FRIENDS_BUTTON_TYPE_WOW

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
    if button and not button.id then return end
    local data = nil
    if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        data = GetBNFriendName(button.id)
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        data = GetFriendName(button.id)
    end

    return data
end

local function OnStateButtonClick(self)
    local friend = self:GetParent().friend
    if not friend then return end
    if D.GetMark(friend) then
        D:DeleteMark(friend)
        D.SendDelete(friend)
    else
        D.SendRequest(friend)
    end
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
    local b = CreateFrame("Button", parent:GetName().."FriendButton", parent)
    b:SetFrameLevel(8)
    b:SetFrameStrata("DIALOG")
    b:SetSize(16, 16)
    b:SetPoint("LEFT", parent, "LEFT", 3, - 8)
    b:SetNormalTexture(buttonOff)
    b:SetPushedTexture(buttonOff)
    b:SetHighlightTexture(buttonOff)
    b:SetScript("OnClick", OnStateButtonClick)
    b:Hide()
    return b
end

local function RemoveOffineFriends()
    for friend, _ in pairs(D.GetMarks()) do
        if friend and friend ~= D.nameRealm and not online[friend] then
            D:DeleteMark(friend)
        end
    end
end

local function Ping(friend)
    if pinged[friend] and pinged[friend] > GetTime() - throttleTime then return end
    if hasAddon[friend] then return end
    D.SendPing(friend)
    pinged[friend] = GetTime()
end

local function OnFriendsFrameUpdate()
    if not FriendsFrame:IsShown() then return end

    wipe(online)
    local buttons = FriendsFrameFriendsScrollFrame.buttons

    for i = 1, #buttons do
        local friend = GetFriendNameByButton(buttons[i])
        buttons[i].friend = friend
        if buttons[i].statusButton then
            buttons[i].statusButton:Hide()
        end
        if friend then
            online[friend] = true
            Ping(friend)
            if buttons[i]:IsShown() then
                if not buttons[i].statusButton then
                    buttons[i].statusButton = CreateMiniButton(buttons[i])
                end
                SetButtonTexture(buttons[i].statusButton, D.GetMark(friend))
                if hasAddon[friend] then
                    buttons[i].statusButton:Show()
                end
            end
        end
    end

    RemoveOffineFriends()

end

local function OnPong(event, friend)
    -- print("FRIEND: OnPong", friend)
    hasAddon[friend] = true
    OnFriendsFrameUpdate()
end

local function OnNewMark(event, friend)
    -- print("FRIEND: OnNewMark", friend)
    OnFriendsFrameUpdate()
end

local function OnDeleteMark(event, friend)
    -- print("FRIEND: OnDeleteMark", friend)
    OnFriendsFrameUpdate()
end

function module:OnEnable()
    hooksecurefunc(_G['FriendsFrameFriendsScrollFrame'], 'update', OnFriendsFrameUpdate)
    hooksecurefunc('FriendsFrame_UpdateFriends', OnFriendsFrameUpdate)
    self:RegisterMessage("ReceivePong", OnPong)
    self:RegisterMessage("CreateMark", OnNewMark)
    self:RegisterMessage("DeleteMark", OnDeleteMark)
end
