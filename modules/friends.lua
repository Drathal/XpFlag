local D, C, L = _G.unpack(_G.select(2, ...))

local _G = _G
local GetTime = _G.GetTime
local CanCooperateWithGameAccount = _G.CanCooperateWithGameAccount
local BNGetGameAccountInfo = _G.BNGetGameAccountInfo
local BNGetFriendInfo = _G.BNGetFriendInfo
local GetFriendInfo = _G.GetFriendInfo
local CreateFrame = _G.CreateFrame
local FriendsFrame = _G.FriendsFrame
local FriendsFrameBattlenetFrame = _G.FriendsFrameBattlenetFrame
local FriendsFrameFriendsScrollFrame = _G.FriendsFrameFriendsScrollFrame
local wipe = _G.wipe
local format = _G.string.format
local match = _G.string.match
local pairs = _G.pairs
local hooksecurefunc = _G.hooksecurefunc
local FRIENDS_BUTTON_TYPE_BNET = _G.FRIENDS_BUTTON_TYPE_BNET
local FRIENDS_BUTTON_TYPE_WOW = _G.FRIENDS_BUTTON_TYPE_WOW
local GameTooltip = _G.GameTooltip

local buttonOff = "Interface\\COMMON\\Indicator-Gray"
local buttonInfo = "Interface\\COMMON\\Indicator-Yellow"
local buttonOn = "Interface\\COMMON\\Indicator-Green"
local pinged = {}
local online = {}
local hasAddonCache = {}
local throttleTime = 10

local moduleName = "friends"
local module = D:NewModule(moduleName, "AceEvent-3.0")

function module:GetBNFriendName(id)
    local characterName, bnetIDGameAccount, client
    local isOnline, isAFK, isDND, realmName, faction, class

    _, _, _, _, characterName, bnetIDGameAccount, client, isOnline, _, isAFK, isDND, _, _, _, _, _ = BNGetFriendInfo(id)
    if not bnetIDGameAccount then
        return
    end
    if not CanCooperateWithGameAccount(bnetIDGameAccount) then
        return
    end

    _, characterName, client, realmName, _, faction, _, class, _, _, _, _, _, _, _, _ = BNGetGameAccountInfo(bnetIDGameAccount)
    if not isOnline or not characterName or client ~= "WoW" then
        return nil
    end

    return characterName .. "-" .. realmName
end

function module:GetFriendName(id)
    local name, level, class, area, connected, status, note, raf, fid = GetFriendInfo(id)

    if not name or not connected then
        return nil
    end

    if not match(name, "-") then
        name = name .. "-" .. D.realm
    end

    return name
end

function module:GetFriendNameByButton(button)
    if not button then
        return
    end

    local data = nil
    if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        data = self:GetBNFriendName(button.id)
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        data = self:GetFriendName(button.id)
    end

    return data
end

function module:OnButtonClick(f)
    if not f.friend then
        return
    end

    if D:GetModule("mark"):GetMark(f.friend) then
        D:GetModule("mark"):DeleteMark(f.friend)
        -- D:GetModule("com"):SendDelete(f.friend)
    else
        -- D:GetModule("com"):SendRequest(f.friend)
    end

    GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(format(L["XP_MARK_TT_1"], D.addonName))

    self:OnFriendsFrameUpdate()
end

function module:SetButtonTexture(button, friendHasMark, friendhasAddon)
    if not button then
        return
    end

    local texture = buttonOff

    if friendHasMark and friendhasAddon then
        texture = buttonOn
    end

    button:SetNormalTexture(texture)
    button:SetPushedTexture(texture)
    button:SetHighlightTexture(texture)
end

function module:CreateMiniButton(parent)
    local b = CreateFrame("Button", parent:GetName() .. "FriendButton", parent)
    self:SetButtonTexture(b)
    b:SetFrameLevel(8)
    b:SetFrameStrata("DIALOG")
    b:SetSize(16, 16)
    b:SetPoint("LEFT", parent, "LEFT", 3, -8)
    b:SetScript(
        "OnClick",
        function()
            self:OnButtonClick(parent)
        end
    )
    b:SetScript(
        "OnEnter",
        function()
            GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(D.addonName)
            if hasAddonCache[parent.friend] then
                GameTooltip:AddLine(format(L["CONNECT_BUTTON_DATA"], L[self:getFriendProp(parent.friend, "dataSource") or "dataXP"]), 1, 1, 1, 1)
            end
            GameTooltip:AddLine(format(L["CONNECT_BUTTON_TT"], parent.friend), 1, 1, 1, 1)
            GameTooltip:Show()
        end
    )
    b:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )
    b:Hide()
    return b
end

function module:RemoveOffineFriends()
    for friend, _ in pairs(D:GetModule("mark"):GetMarks()) do
        if friend and friend ~= D.nameRealm and not online[friend] then
            D:GetModule("mark"):DeleteMark(friend)
        end
    end
end

function module:Ping(friend)
    if pinged[friend] and pinged[friend] > GetTime() - throttleTime then
        return
    end

    if self:hasAddon(friend) then
        return
    end

    -- D:GetModule("com"):SendPing(friend)

    pinged[friend] = GetTime()
end

function module:UpdateFriendButton(button)
    local friend = module:GetFriendNameByButton(button)

    if button.statusButton then
        button.statusButton:Hide()
    end

    if friend then
        button.friend = friend
        online[friend] = true
        self:Ping(friend)
        if button:IsShown() and self:hasAddon(friend) then
            if not button.statusButton then
                button.statusButton = self:CreateMiniButton(button)
            end
            self:SetButtonTexture(button.statusButton, D:GetModule("mark"):HasMark(friend), self:hasAddon(friend))
            button.statusButton:Show()
        end
    end
end

function module:OnFriendsFrameUpdate()
    if not FriendsFrame:IsShown() then
        return
    end

    wipe(online)
    local buttons = FriendsFrameFriendsScrollFrame.buttons

    for i = 1, #buttons do
        if (buttons[i].buttonType == FRIENDS_BUTTON_TYPE_WOW
            or buttons[i].buttonType == FRIENDS_BUTTON_TYPE_BNET)
            and buttons[i].gameIcon:IsVisible() then
            self:UpdateFriendButton(buttons[i])
        end
    end

    self:RemoveOffineFriends()
end

function module:hasAddon(friend)
    if not hasAddonCache[friend] then
        return
    end

    return true
end

function module:getFriendProp(friend, propName)
    if not hasAddonCache[friend] then
        return
    end
    if not hasAddonCache[friend][propName] then
        return
    end

    return hasAddonCache[friend][propName]
end

function module:OnUpdate(event, friend, data)
    if friend == D.nameRealm then
        return
    end

    hasAddonCache[friend] = data

    self:OnFriendsFrameUpdate()
end

function module:OnEnable()
    hooksecurefunc(
        _G["FriendsFrameFriendsScrollFrame"],
        "update",
        function()
            self:OnFriendsFrameUpdate(self)
        end
    )
    hooksecurefunc(
        "FriendsFrame_UpdateFriends",
        function()
            self:OnFriendsFrameUpdate(self)
        end
    )

    self:RegisterMessage("com:Update", "OnUpdate")
end
