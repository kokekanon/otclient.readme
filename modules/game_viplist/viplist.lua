vipWindow = nil
vipButton = nil
addVipWindow = nil
editVipWindow = nil
vipInfo = {}
local groups = {
    groupsAmountLeft = 5,
    groupsName = {}
}
local viewMode = "default" -- default or groups

function init()
    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline,
        onAddVip = onAddVip,
        onVipStateChange = onVipStateChange,
        onVipGroupChange = onVipGroupChange
    })

    g_keyboard.bindKeyDown('Ctrl+P', toggle)

    vipButton = modules.game_mainpanel.addToggleButton('vipListButton', tr('VIP List') .. ' (Ctrl+P)',
                                                                '/images/options/button_vip', toggle, false, 3)
    vipButton:setOn(true)
    vipWindow = g_ui.loadUI('viplist')

    if not g_game.getFeature(GameAdditionalVipInfo) then
        loadVipInfo()
    end
    refresh()
    vipWindow:setup()
    if g_game.isOnline() then
        vipWindow:setupOnStart()
    end
end

function terminate()
    g_keyboard.unbindKeyDown('Ctrl+P')
    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline,
        onAddVip = onAddVip,
        onVipStateChange = onVipStateChange,
        onVipGroupChange = onVipGroupChange
    })

    if not g_game.getFeature(GameAdditionalVipInfo) then
        saveVipInfo()
    end

    if addVipWindow then
        addVipWindow:destroy()
    end

    if editVipWindow then
        editVipWindow:destroy()
    end

    vipWindow:destroy()
    vipButton:destroy()

    vipWindow = nil
    vipButton = nil
end

function loadVipInfo()
    local settings = g_settings.getNode('VipList')
    if not settings then
        vipInfo = {}
        return
    end
    vipInfo = settings['VipInfo'] or {}
end

function saveVipInfo()
    settings = {}
    settings['VipInfo'] = vipInfo
    g_settings.mergeNode('VipList', settings)
end

function online()
    vipWindow:setupOnStart() -- load character window configuration
    refresh()
end

function offline()
    vipWindow:setParent(nil, true)
    clear()
end

function refresh()
    clear()
    for id, vip in pairs(g_game.getVips()) do
        onAddVip(id, unpack(vip))
    end

    vipWindow:setContentMinimumHeight(38)
end

function clear()
    local vipList = vipWindow:getChildById('contentsPanel')
    vipList:destroyChildren()
end

function toggle()
    if vipButton:isOn() then
        vipWindow:close()
        vipButton:setOn(false)
    else
        if not vipWindow:getParent() then
            local panel = modules.game_interface.findContentPanelAvailable(vipWindow, vipWindow:getMinimumHeight())
            if not panel then
                return
            end

            panel:addChild(vipWindow)
        end
        vipWindow:open()
        vipButton:setOn(true)
    end
end

function onMiniWindowOpen()
    vipButton:setOn(true)
end

function onMiniWindowClose()
    vipButton:setOn(false)
end

function createAddWindow()
    if not addVipWindow then
        addVipWindow = g_ui.displayUI('addvip')
    end
end

function createEditWindow(widget)
    if editVipWindow then
        return
    end

    editVipWindow = g_ui.displayUI('editvip')

    local name = widget:getText()
    local id = widget:getId():sub(4)

    local okButton = editVipWindow:getChildById('buttonOK')
    local cancelButton = editVipWindow:getChildById('buttonCancel')

    local nameLabel = editVipWindow:getChildById('nameLabel')
    nameLabel:setText(name)

    local descriptionText = editVipWindow:getChildById('descriptionText')
    descriptionText:appendText(widget:getTooltip())

    local notifyCheckBox = editVipWindow:getChildById('checkBoxNotify')
    notifyCheckBox:setChecked(widget.notifyLogin)

    local iconRadioGroup = UIRadioGroup.create()
    for i = VipIconFirst, VipIconLast do
        iconRadioGroup:addWidget(editVipWindow:recursiveGetChildById('icon' .. i))
    end
    iconRadioGroup:selectWidget(editVipWindow:recursiveGetChildById('icon' .. widget.iconId))

    local panelGroupName = editVipWindow:getChildById('panelGroupName')
    table.sort(groups.groupsName, function(a, b)
        return a[2]:lower() < b[2]:lower()
    end)
    for i, group in ipairs(groups.groupsName) do
        local label = g_ui.createWidget("ScreenshotType", panelGroupName)
        label:setId(group[1])
        label:setText(group[2])

        if getPlayerGroups(name)[group[1]] then
            label.enabled:setChecked(true)
        end
    end
    
    local cancelFunction = function()
        editVipWindow:destroy()
        iconRadioGroup:destroy()
        editVipWindow = nil
    end

    local saveFunction = function()
        local vipList = vipWindow:getChildById('contentsPanel')
        if not widget or not vipList:hasChild(widget) then
            cancelFunction()
            return
        end

        local name = widget:getText()
        local state = widget.vipState
        local description = descriptionText:getText()
        local iconId = tonumber(iconRadioGroup:getSelectedWidget():getId():sub(5))
        local notify = notifyCheckBox:isChecked()
        local groupIds = {}
        for i, group in ipairs(panelGroupName:getChildren()) do
            if group.enabled:isChecked() then
                table.insert(groupIds, tonumber(group:getId()))
            end
        end


        if g_game.getFeature(GameAdditionalVipInfo) then
            if g_game.getFeature(GameVipGroups) then
                g_game.editVip(id, description, iconId, notify, groupIds)
            else
                g_game.editVip(id, description, iconId, notify)
            end
        else
            if notify ~= false or #description > 0 or iconId > 0 then
                vipInfo[name] = {
                    description = description,
                    iconId = iconId,
                    notifyLogin = notify
                }
            else
                vipInfo[name] = nil
            end
        end

        widget:destroy()
        onAddVip(id, name, state, description, iconId, notify)

        editVipWindow:destroy()
        iconRadioGroup:destroy()
        editVipWindow = nil
    end

    cancelButton.onClick = cancelFunction
    okButton.onClick = saveFunction

    editVipWindow.onEscape = cancelFunction
    editVipWindow.onEnter = saveFunction
end

function destroyAddWindow()
    addVipWindow:destroy()
    addVipWindow = nil
end

function addVip()
    g_game.addVip(addVipWindow:getChildById('name'):getText())
    destroyAddWindow()
end

function removeVip(widgetOrName)
    if not widgetOrName then
        return
    end

    local widget
    local vipList = vipWindow:getChildById('contentsPanel')
    if type(widgetOrName) == 'string' then
        local entries = vipList:getChildren()
        for i = 1, #entries do
            if entries[i]:getText():lower() == widgetOrName:lower() then
                widget = entries[i]
                break
            end
        end
        if not widget then
            return
        end
    else
        widget = widgetOrName
    end

    if widget then
        local id = widget:getId():sub(4)
        local name = widget:getText()
        g_game.removeVip(id)
        vipList:removeChild(widget)
        if vipInfo[name] and g_game.getFeature(GameAdditionalVipInfo) then
            vipInfo[name] = nil
        end
    end
end

function hideOffline(state)
    settings = {}
    settings['hideOffline'] = state
    g_settings.mergeNode('VipList', settings)

    refresh()
end

function isHiddingOffline()
    local settings = g_settings.getNode('VipList')
    if not settings then
        return false
    end
    return settings['hideOffline']
end

function getSortedBy()
    local settings = g_settings.getNode('VipList')
    if not settings or not settings['sortedBy'] then
        return 'status'
    end
    return settings['sortedBy']
end

function sortBy(state)
    settings = {}
    settings['sortedBy'] = state
    g_settings.mergeNode('VipList', settings)

    refresh()
end

function onAddVip(id, name, state, description, iconId, notify, groupID)
    local vipList = vipWindow:getChildById('contentsPanel')

    local label = g_ui.createWidget('VipListLabel')
    label.onMousePress = onVipListLabelMousePress
    label:setId('vip' .. id)
    label:setText(name)

    if not g_game.getFeature(GameAdditionalVipInfo) then
        local tmpVipInfo = vipInfo[name]
        label.iconId = 0
        label.notifyLogin = false
        if tmpVipInfo then
            if tmpVipInfo.iconId then
                label:setImageClip(torect((tmpVipInfo.iconId * 12) .. ' 0 12 12'))
                label.iconId = tmpVipInfo.iconId
            end
            if tmpVipInfo.description then
                label:setTooltip(tmpVipInfo.description)
            end
            label.notifyLogin = tmpVipInfo.notifyLogin or false
        end
    else
        label:setTooltip(description)
        label:setImageClip(torect((iconId * 12) .. ' 0 12 12'))
        label.iconId = iconId
        label.notifyLogin = notify
    end

    if state == VipState.Online then
        label:setColor('#00ff00')
    elseif state == VipState.Pending then
        label:setColor('#ffca38')
    else
        label:setColor('#ff0000')
    end

    label.vipState = state

    label:setPhantom(false)
    connect(label, {
        onDoubleClick = function()
            g_game.openPrivateChannel(label:getText())
            return true
        end
    })

    if state == VipState.Offline and isHiddingOffline() then
        label:setVisible(false)
    end
    if viewMode == "default" then
        insertVipDefault(vipList, label, name, state)
    else
     --   insertVipGroup(vipList, label, name, state, groupID)
    end
end

function insertVipDefault(vipList, label, name, state)
    local nameLower = name:lower()
    local childrenCount = vipList:getChildCount()

    for i = 1, childrenCount do
        local child = vipList:getChildByIndex(i)
        if (state == VipState.Online and child.vipState ~= VipState.Online and getSortedBy() == 'status') or
            (label.iconId > child.iconId and getSortedBy() == 'type') then
            vipList:insertChild(i, label)
            return
        end

        if (((state ~= VipState.Online and child.vipState ~= VipState.Online) or
            (state == VipState.Online and child.vipState == VipState.Online)) and getSortedBy() == 'status') or
            (label.iconId == child.iconId and getSortedBy() == 'type') or getSortedBy() == 'name' then

            local childText = child:getText():lower()
            local length = math.min(childText:len(), nameLower:len())

            for j = 1, length do
                if nameLower:byte(j) < childText:byte(j) then
                    vipList:insertChild(i, label)
                    return
                elseif nameLower:byte(j) > childText:byte(j) then
                    break
                elseif j == nameLower:len() then -- We are at the end of nameLower, and its shorter than childText, thus insert before
                    vipList:insertChild(i, label)
                    return
                end
            end
        end
    end

    vipList:insertChild(childrenCount + 1, label)
end

function onVipStateChange(id, state)
    local vipList = vipWindow:getChildById('contentsPanel')
    local label = vipList:getChildById('vip' .. id)
    local name = label:getText()
    local description = label:getTooltip()
    local iconId = label.iconId
    local notify = label.notifyLogin
    label:destroy()

    onAddVip(id, name, state, description, iconId, notify)

    if notify and state ~= VipState.Pending then
        modules.game_textmessage.displayFailureMessage(state == VipState.Online and tr('%s has logged in.', name) or
                                                           tr('%s has logged out.', name))
    end
end

function onVipListMousePress(widget, mousePos, mouseButton)
    if mouseButton ~= MouseRightButton then
        return
    end

    local vipList = vipWindow:getChildById('contentsPanel')

    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addOption(tr('Add new VIP'), function()
        createAddWindow()
    end)
    menu:addOption(tr('Add Group'), function()
        createAddGroupWindow()
    end)

    menu:addSeparator()
    if not isHiddingOffline() then
        menu:addOption(tr('Hide Offline'), function()
            hideOffline(true)
        end)
    else
        menu:addOption(tr('Show Offline'), function()
            hideOffline(false)
        end)
    end

    if not (getSortedBy() == 'name') then
        menu:addOption(tr('Sort by name'), function()
            sortBy('name')
        end)
    end

    if not (getSortedBy() == 'status') then
        menu:addOption(tr('Sort by status'), function()
            sortBy('status')
        end)
    end

    if not (getSortedBy() == 'type') then
        menu:addOption(tr('Sort by type'), function()
            sortBy('type')
        end)
    end
--[[ menu:addSeparator()
    menu:addOption(tr('Sort by type'), function()
        toggleViewMode()
    end) ]]
    menu:display(mousePos)

    return true
end

function onVipListLabelMousePress(widget, mousePos, mouseButton)
    if mouseButton ~= MouseRightButton then
        return
    end

    local vipList = vipWindow:getChildById('contentsPanel')

    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addOption(tr('Send Message'), function()
        g_game.openPrivateChannel(widget:getText())
    end)
    menu:addOption(tr('Add new VIP'), function()
        createAddWindow()
    end)
    menu:addOption(tr('Edit %s', widget:getText()), function()
        if widget then
            createEditWindow(widget)
        end
    end)
    menu:addOption(tr('Remove %s', widget:getText()), function()
        if widget then
            removeVip(widget)
        end
    end)
    menu:addSeparator()
    menu:addOption(tr('Copy Name'), function()
        g_window.setClipboardText(widget:getText())
    end)

    if modules.game_console.getOwnPrivateTab() then
        menu:addSeparator()
        menu:addOption(tr('Invite to private chat'), function()
            g_game.inviteToOwnChannel(widget:getText())
        end)
        menu:addOption(tr('Exclude from private chat'), function()
            g_game.excludeFromOwnChannel(widget:getText())
        end)
    end

    if not isHiddingOffline() then
        menu:addOption(tr('Hide Offline'), function()
            hideOffline(true)
        end)
    else
        menu:addOption(tr('Show Offline'), function()
            hideOffline(false)
        end)
    end

    if not (getSortedBy() == 'name') then
        menu:addOption(tr('Sort by name'), function()
            sortBy('name')
        end)
    end

    if not (getSortedBy() == 'status') then
        menu:addOption(tr('Sort by status'), function()
            sortBy('status')
        end)
    end

    menu:display(mousePos)

    return true
end

function createAddGroupWindow()
    local addGroupWindow = g_ui.createWidget('MainWindow', rootWidget)
    local isMaxGroups = groups.groupsAmountLeft == 0
    local windowSize = isMaxGroups and {width = 530, height = 100} or {width = 256, height = 128}
    
    addGroupWindow:setText(isMaxGroups and "Maximum of user-created groups reached" or 
        string.format('Add Vip groups (User created groups left: %d)', groups.groupsAmountLeft))
    addGroupWindow:setSize(windowSize)

    local label = g_ui.createWidget('Label', addGroupWindow)
    label:setText(isMaxGroups and 'You have already reached the maximum of groups you can create yourself.' or
        'Please enter a group name:')
    label:setTextWrap(isMaxGroups)
    label:addAnchor(AnchorTop, 'parent', AnchorTop)
    label:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    label:addAnchor(AnchorRight, 'parent', AnchorRight)

    local textEdit
    if not isMaxGroups then
        textEdit = g_ui.createWidget('TextEdit', addGroupWindow)
        textEdit:addAnchor(AnchorTop, 'prev', AnchorBottom)
        textEdit:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        textEdit:addAnchor(AnchorRight, 'parent', AnchorRight)
        textEdit:setMarginTop(4)
    end

    local separator = g_ui.createWidget('HorizontalSeparator', addGroupWindow)
    separator:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    separator:addAnchor(AnchorRight, 'parent', AnchorRight)
    separator:addAnchor(AnchorBottom, 'next', AnchorTop)
    separator:setMarginBottom(10)

    local cancelButton = g_ui.createWidget('Button', addGroupWindow)
    cancelButton:setText(isMaxGroups and 'Ok' or 'Cancel')
    cancelButton:setWidth(64)
    cancelButton:addAnchor(AnchorRight, 'parent', AnchorRight)
    cancelButton:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    cancelButton.onClick = function() addGroupWindow:destroy() end

    if not isMaxGroups then
        local okButton = g_ui.createWidget('Button', addGroupWindow)
        okButton:setText('Ok')
        okButton:setWidth(64)
        okButton:addAnchor(AnchorRight, 'next', AnchorLeft)
        okButton:addAnchor(AnchorBottom, 'parent', AnchorBottom)
        okButton:setMarginRight(10)
        okButton.onClick = function()
            g_game.editVipGroups(1,textEdit:getText())
            addGroupWindow:destroy()
        end
    end
end

function toggleViewMode()
    if viewMode == "default" then
        viewMode = "groups"
    else
        viewMode = "default"
    end
    refresh()
end

function onVipGroupChange(vipGroups, groupsAmountLeft)
    groups.groupsAmountLeft = groupsAmountLeft
    groups.groupsName = vipGroups
end

function getPlayerGroups(playerName)
    local playerGroups = {}
    for id, vip in pairs(g_game.getVips()) do
    
        if vip[1] == playerName then
            playerGroups = vip[6]
            break
        end
    end
    return playerGroups
end
