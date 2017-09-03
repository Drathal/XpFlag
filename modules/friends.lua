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
local GameTooltip = _G.GameTooltip
--@alpha@
local assert = _G.assert
--@end-alpha@

local buttonOff = "Interface\\COMMON\\Indicator-Gray"
local buttonOn = "Interface\\COMMON\\Indicator-Green"
local pinged = {}
local online = {}
local hasAddon = {}
local throttleTime = 10

local moduleName = "friends"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:GetBNFriendName(id)
    --@alpha@
    -- D.Debug(moduleName, "GetBNFriendName", id)
    assert(id, 'friends:GetBNFriendName - id is missing')
    --@end-alpha@

    local bnetIDAccount, _, _, isBattleTagPresence, characterName, bnetIDGameAccount, client, isOnline, _, isAFK, isDND, _, _, isRIDFriend, _, _ = BNGetFriendInfo(id)
    if not bnetIDGameAccount then return end
    if not CanCooperateWithGameAccount(bnetIDGameAccount) then return end
    local _, characterName, client, realmName, realmID, faction, race, class, _, zoneName, _, _, _, _, _, _ = BNGetGameAccountInfo(bnetIDGameAccount)
    if not isOnline or not characterName or client ~= 'WoW' then return nil end
    return characterName..'-'..realmName
end

function module:GetFriendName(id)
    --@alpha@
    -- D.Debug(moduleName, "GetFriendName", id)
    assert(id, 'friends:GetFriendName - id is missing')
    --@end-alpha@

    local name, level, class, area, connected, status, note, raf, id = GetFriendInfo(id)
    if not name or not connected then return nil end
    if not match(name, "-") then
        name = name.."-"..D.realm
    end
    return name
end

function module:GetFriendNameByButton(button)
    --@alpha@
    -- D.Debug(moduleName, "GetFriendNameByButton", button)
    assert(button, 'friends:GetFriendNameByButton - button is missing')
    --@end-alpha@

    if not button then return end

    local data = nil
    if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        data = self:GetBNFriendName(button.id)
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        data = self:GetFriendName(button.id)
    end

    --@alpha@
    if button == _G.FriendsFrameBattlenetFrame then
        data = D.fakeName
        button:GetParent().friend = data
        D.Debug(moduleName, "GetFriendNameByButton:fake", data)
    end
    --@end-alpha@

    return data
end

function module:OnStateButtonClick(f)
    --@alpha@
    D.Debug(moduleName, "OnStateButtonClick", f)
    assert(f, 'friends:OnStateButtonClick - f is missing')
    --@end-alpha@

    local friend = f:GetParent().friend
    if not friend then return end

    --@alpha@
    D.Debug(moduleName, "OnStateButtonClick friend:", friend)
    --@end-alpha@

    if D:GetModule("mark"):GetMark(friend) then
        D:GetModule("mark"):DeleteMark(friend)
        D:GetModule("com"):SendDelete(friend)
    else
        D:GetModule("com"):SendRequest(friend)
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
    --@alpha@
    D.Debug(moduleName, "CreateMiniButton", parent)
    assert(parent, 'friends:CreateMiniButton - parent is missing')
    --@end-alpha@

    local b = CreateFrame("Button", parent:GetName().."FriendButton", parent)
    b:SetFrameLevel(8)
    b:SetFrameStrata("DIALOG")
    b:SetSize(16, 16)
    b:SetPoint("LEFT", parent, "LEFT", 3, - 8)
    b:SetScript("OnClick", function() self:OnStateButtonClick(parent) end )
    self:SetButtonTexture(b)
    b:SetScript("OnEnter", function(self)
        parent.tooltip:Show()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(format("%s XP", D.addonName))
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function(self)
        parent.tooltip:Hide()
        GameTooltip:Hide()
        parent.tooltip:SetScript("OnUpdate", nil)
    end)
    b:Hide()
    return b
end

function module:RemoveOffineFriends()
    for friend, _ in pairs(D:GetModule("mark"):GetMarks()) do
        if friend and friend ~= D.nameRealm and not online[friend] then
            --@alpha@
            D.Debug(moduleName, "RemoveOffineFriends", friend)
            --@end-alpha@
            D:GetModule("mark"):DeleteMark(friend)
        end
    end
end

function module:Ping(friend)
    --@alpha@
    assert(friend, 'friends:Ping - friend is missing')
    --@end-alpha@

    if pinged[friend] and pinged[friend] > GetTime() - throttleTime then return end
    if hasAddon[friend] then return end

    --@alpha@
    D.Debug(moduleName, "Ping", friend)
    --@end-alpha@

    D:GetModule("com"):SendPing(friend)
    pinged[friend] = GetTime()
end

function module:UpdateFriendButton(button)
    local friend = module:GetFriendNameByButton(button)
    button.friend = friend

    if button.statusButton then
        button.statusButton:Hide()
    end

    if friend then
        online[friend] = true
        self:Ping(friend)
        if button:IsShown() and hasAddon[friend] then
            if not button.statusButton then
                button.statusButton = self:CreateMiniButton(button)
            end
            self:SetButtonTexture(button.statusButton, D:GetModule("mark"):GetMark(friend))
            button.statusButton:Show()
        end
    end
end

function module:OnFriendsFrameUpdate(self)
    if not FriendsFrame:IsShown() then return end

    --@alpha@
    D.Debug(moduleName, "OnFriendsFrameUpdate", self)
    assert(self, 'friends:OnFriendsFrameUpdate - self is missing')
    --@end-alpha@

    wipe(online)
    local buttons = FriendsFrameFriendsScrollFrame.buttons

    --@alpha@
    if D.fakeCom then
        self:UpdateFriendButton(_G.FriendsFrameBattlenetFrame)
    end
    --@end-alpha@

    for i = 1, #buttons do
        if (buttons[i].buttonType == FRIENDS_BUTTON_TYPE_WOW or buttons[i].buttonType == FRIENDS_BUTTON_TYPE_BNET) and buttons[i].gameIcon:IsVisible() then
            self:UpdateFriendButton(buttons[i])
        end
    end

    self:RemoveOffineFriends()
end

function module:OnPong(event, friend)
    --@alpha@
    D.Debug(moduleName, "OnPong", event, friend)
    assert(event, 'friends:OnPong - event is missing')
    assert(friend, 'friends:OnPong - friend is missing')
    --@end-alpha@
    hasAddon[friend] = true

    self:OnFriendsFrameUpdate(self)
end

function module:OnNewMark(event, friend)
    --@alpha@
    D.Debug(moduleName, "OnNewMark", event, friend)
    assert(event, 'friends:OnNewMark - event is missing')
    assert(friend, 'friends:OnNewMark - friend is missing')
    --@end-alpha@

    if friend == D.nameRealm then return end

    self:OnFriendsFrameUpdate(self)
end

function module:OnDeleteMark(event, friend)
    --@alpha@
    D.Debug(moduleName, "OnDeleteMark", event, friend)
    assert(event, 'friends:OnDeleteMark - event is missing')
    assert(friend, 'friends:OnDeleteMark - friend is missing')
    --@end-alpha@

    self:OnFriendsFrameUpdate(self)
end

function module:OnEnable()
    --@alpha@
    D.Debug(moduleName, "OnEnable")
    --@end-alpha@

    local this = self
    hooksecurefunc(_G['FriendsFrameFriendsScrollFrame'], 'update', function() module.OnFriendsFrameUpdate(self, this) end)
    hooksecurefunc('FriendsFrame_UpdateFriends', function() module.OnFriendsFrameUpdate(self, this) end)
    self:RegisterMessage("ReceivePong", "OnPong")
    self:RegisterMessage("mark:Create", "OnNewMark")
    self:RegisterMessage("mark:Delete", "OnDeleteMark")
end
