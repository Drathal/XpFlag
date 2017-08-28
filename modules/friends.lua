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
local match = _G.string.match
local pairs = _G.pairs
local hooksecurefunc = _G.hooksecurefunc
local FRIENDS_BUTTON_TYPE_BNET = _G.FRIENDS_BUTTON_TYPE_BNET
local FRIENDS_BUTTON_TYPE_WOW = _G.FRIENDS_BUTTON_TYPE_WOW

local buttonOff = "Interface\\COMMON\\Indicator-Gray"
local buttonOn = "Interface\\COMMON\\Indicator-Green"
local pinged = {}
local online = {}
local hasAddon = {}
local throttleTime = 10

local module = D:NewModule("friends", "AceEvent-3.0")

function module:GetBNFriendName(id)
    local bnetIDAccount, _, _, isBattleTagPresence, characterName, bnetIDGameAccount, client, isOnline, _, isAFK, isDND, _, _, isRIDFriend, _, _ = BNGetFriendInfo(id)
    if not bnetIDGameAccount then return end
    if not CanCooperateWithGameAccount(bnetIDGameAccount) then return end
    local _, characterName, client, realmName, realmID, faction, race, class, _, zoneName, _, _, _, _, _, _ = BNGetGameAccountInfo(bnetIDGameAccount)
    if not isOnline or not characterName or client ~= 'WoW' then return nil end
    return characterName..'-'..realmName
end

function module:GetFriendName(id)
    local name, level, class, area, connected, status, note, raf, id = GetFriendInfo(id)
    if not name or not connected then return nil end
    if not match(name, "-") then
        name = name.."-"..D.realm
    end
    return name
end

function module:GetFriendNameByButton(button)
    if button and not button.id then return end
    local data = nil
    if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        data = self:GetBNFriendName(button.id)
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        data = self:GetFriendName(button.id)
    end

    return data
end

function module:OnStateButtonClick(self)
    local friend = self:GetParent().friend
    if not friend then return end
    if D.GetMark(friend) then
        D:DeleteMark(friend)
        D:SendDelete(friend)
    else
        D:SendRequest(friend)
    end
end

function module:SetButtonTexture(button, state)
    if not button then return end

    local texture = buttonOff
    if state then
        texture = buttonOn
    end

    button:SetNormalTexture(texture)
    button:SetPushedTexture(texture)
    button:SetHighlightTexture(texture)
end

function module:CreateMiniButton(parent)
    local b = CreateFrame("Button", parent:GetName().."FriendButton", parent)
    b:SetFrameLevel(8)
    b:SetFrameStrata("DIALOG")
    b:SetSize(16, 16)
    b:SetPoint("LEFT", parent, "LEFT", 3, - 8)
    b:SetScript("OnClick", "OnStateButtonClick")
    self:SetButtonTexture(b)
    b:Hide()
    return b
end

function module:RemoveOffineFriends()
    for friend, _ in pairs(D.GetMarks()) do
        if friend and friend ~= D.nameRealm and not online[friend] then
            D:DeleteMark(friend)
        end
    end
end

function module:Ping(friend)
    if pinged[friend] and pinged[friend] > GetTime() - throttleTime then return end
    if hasAddon[friend] then return end
    D:SendPing(friend)
    pinged[friend] = GetTime()
end

function module:OnFriendsFrameUpdate()
    if not FriendsFrame:IsShown() then return end

    wipe(online)
    local buttons = FriendsFrameFriendsScrollFrame.buttons

    for i = 1, #buttons do
        local friend = self:GetFriendNameByButton(buttons[i])
        buttons[i].friend = friend
        if buttons[i].statusButton then
            buttons[i].statusButton:Hide()
        end
        if friend then
            online[friend] = true
            self:Ping(friend)
            if buttons[i]:IsShown() then
                if not buttons[i].statusButton then
                    buttons[i].statusButton = self:CreateMiniButton(buttons[i])
                end
                self:SetButtonTexture(buttons[i].statusButton, D:GetMark(friend))
                if hasAddon[friend] then
                    buttons[i].statusButton:Show()
                end
            end
        end
    end

    self:RemoveOffineFriends()

end

function module:OnPong(event, friend)
    hasAddon[friend] = true
    self:OnFriendsFrameUpdate()
end

function module:OnNewMark(event, friend)
    self:OnFriendsFrameUpdate()
end

function module:OnDeleteMark(event, friend)
    self:OnFriendsFrameUpdate()
end

function module:OnEnable()
    hooksecurefunc(_G['FriendsFrameFriendsScrollFrame'], 'update', self.OnFriendsFrameUpdate)
    hooksecurefunc('FriendsFrame_UpdateFriends', self.OnFriendsFrameUpdate)
    self:RegisterMessage("ReceivePong", "OnPong")
    self:RegisterMessage("CreateMark", "OnNewMark")
    self:RegisterMessage("DeleteMark", "OnDeleteMark")
end
