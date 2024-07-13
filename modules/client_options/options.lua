local options = dofile("data_options")

local panels = {
    generalPanel = nil,
    controlPanel = nil,
    consolePanel = nil,
    graphicsPanel = nil,
    soundPanel = nil,
    gameMapPanel = nil
}
-- LuaFormatter off
local buttons = {{

    text = "Controls",
    icon = "/images/icons/icon_controls",
    open = "graphicsPanel",
    subCategories = {{
        text = "General Hotkeys",
        open = "generalPanel"
    }, {
        text = "Action Bar Hotkeys",
        open = "controlPanel"
    }, {
        text = "Custom Hotkeys",
        open = "controlPanel"
    }}
}, {
    text = "Interface",
    icon = "/images/icons/icon_interface",
    open = "graphicsPanel",
    subCategories = {{
        text = "HUD",
        open = "consolePanel"
    }, {
        text = "Console",
        open = "graphicsPanel"
    }, {
        text = "Game Windows",
        open = "graphicsPanel"
    }, {
        text = "Action Bars",
        open = "graphicsPanel"
    }, {
        text = "Control Buttons",
        open = "graphicsPanel"
    }}
}, {
    text = "Graphics",
    icon = "/images/icons/icon_graphics",
    open = "graphicsPanel",
    subCategories = {{
        text = "Effects",
        open = "consolePanel"
    }}
}, {
    text = "Sound",
    icon = "/images/icons/icon_sound",
    open = "graphicsPanel",
    subCategories = {{
        text = "Battle Sounds",
        open = "consolePanel"
    }, {
        text = "UI Sounds",
        open = "graphicsPanel"
    }}
}, {
    text = "Misc.",
    icon = "/images/icons/icon_misc",
    open = "graphicsPanel",
    subCategories = {{
        text = "GamePlay",
        open = "consolePanel"
    }, {
        text = "Screenshots",
        open = "graphicsPanel"
    }, {
        text = "Help",
        open = "graphicsPanel"
    }}
} --[[     
-- single category
{
        text = "Console",
        icon = "/mods/game_cyclopedia/images/character_icons/icon-character-battleresults-recentpvpkills",
        open = "graphicsPanel"
    },
 ]] }
-- LuaFormatter on
local extraWidgets = {
    audioButton = nil,
    optionsButton = nil,
    optionsButtons = nil
}

local function toggleDisplays()
    if options['displayNames'].value and options['displayHealth'].value and options['displayMana'].value then
        setOption('displayNames', false)
    elseif options['displayHealth'].value then
        setOption('displayHealth', false)
        setOption('displayMana', false)
    else
        if not options['displayNames'].value and not options['displayHealth'].value then
            setOption('displayNames', true)
        else
            setOption('displayHealth', true)
            setOption('displayMana', true)
        end
    end
end

local function toggleOption(key)
    setOption(key, not getOption(key))
end

local function setupComboBox()
    local crosshairCombo = panels.generalPanel:recursiveGetChildById('crosshair')
    local antialiasingModeCombobox = panels.graphicsPanel:recursiveGetChildById('antialiasingMode')
    local floorViewModeCombobox = panels.graphicsPanel:recursiveGetChildById('floorViewMode')

    for k, v in pairs({ { 'Disabled', 'disabled' }, { 'Default', 'default' }, { 'Full', 'full' } }) do
        crosshairCombo:addOption(v[1], v[2])
    end

    crosshairCombo.onOptionChange = function(comboBox, option)
        setOption('crosshair', comboBox:getCurrentOption().data)
    end


    for k, t in pairs({ 'None', 'Antialiasing', 'Smooth Retro' }) do
        antialiasingModeCombobox:addOption(t, k - 1)
    end

    antialiasingModeCombobox.onOptionChange = function(comboBox, option)
        setOption('antialiasingMode', comboBox:getCurrentOption().data)
    end


    for k, t in pairs({ 'Normal', 'Fade', 'Locked', 'Always', 'Always with transparency' }) do
        floorViewModeCombobox:addOption(t, k - 1)
    end

    floorViewModeCombobox.onOptionChange = function(comboBox, option)
        setOption('floorViewMode', comboBox:getCurrentOption().data)
    end
end

local function setup()
    panels.gameMapPanel = modules.game_interface.getMapPanel()

    setupComboBox()

    -- load options
    for k, obj in pairs(options) do
        local v = obj.value

        if type(v) == 'boolean' then
            setOption(k, g_settings.getBoolean(k), true)
        elseif type(v) == 'number' then
            setOption(k, g_settings.getNumber(k), true)
        elseif type(v) == 'string' then
            setOption(k, g_settings.getString(k), true)
        end
    end
end
local function toggleSubCategories(parent, isOpen)
    for subId, _ in ipairs(parent.subCategories) do
        local subWidget = parent:getChildById(subId)
        if subWidget then
            subWidget:setVisible(isOpen)
        end
    end
    parent:setHeight(isOpen and parent.openedSize or parent.closedSize)
    parent.opened = isOpen
    parent.Button.Arrow:setVisible(not isOpen)
end

local function close(parent)
    if parent.subCategories then
        toggleSubCategories(parent, false)
    end
end

local function open(parent)
    local oldOpen = controller.ui.openedCategory
    if oldOpen and oldOpen ~= parent then
        close(oldOpen)
    end
    toggleSubCategories(parent, true)
    controller.ui.openedCategory = parent
end

function selectCharacterPage()
    local selectedOption = controller.ui.selectedOption
    if selectedOption then
        selectedOption:hide()
    end
    if controller.ui.InfoBase then
        controller.ui.InfoBase:setVisible(true)
        controller.ui.InfoBase:show()
    end
end

local function createSubWidget(parent, subId, subButton)
    local subWidget = g_ui.createWidget("CharacterCategoryItem", parent)
    subWidget:setId(subId)
    subWidget.Button.Icon:setIcon(subButton.icon)
    subWidget.Button.Title:setText(subButton.text)
    subWidget:setVisible(false)
    subWidget.open = subButton.open

    function subWidget.Button.onClick()
        local selectedOption = controller.ui.selectedOption
        closeCharacterButtons()
        parent.Button:setChecked(false)
        parent.Button.Arrow:setVisible(true)
        parent.Button.Arrow:setImageSource("")
        subWidget.Button:setChecked(true)
        subWidget.Button.Arrow:setVisible(true)
        subWidget.Button.Arrow:setImageSource("/images/ui/icon-arrow7x7-right")

        if selectedOption then
            selectedOption:hide()
        end

        local panelToShow = panels[subWidget.open]
        if panelToShow then
            panelToShow:show()
            panelToShow:setVisible(true)
            controller.ui.selectedOption = panelToShow
        else
            print("Error: panelToShow is nil or does not exist in panels")
        end
    end

    subWidget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
    if subId == 1 then
        subWidget:addAnchor(AnchorTop, "parent", AnchorTop)
        subWidget:setMarginTop(20)
    else
        subWidget:addAnchor(AnchorTop, "prev", AnchorBottom)
        subWidget:setMarginTop(-1)
    end

    return subWidget
end

function configureCharacterCategories()
    controller.ui.optionsTabBar:destroyChildren()

    for id, button in ipairs(buttons) do
        local widget = g_ui.createWidget("CharacterCategoryItem", controller.ui.optionsTabBar)
        widget:setId(id)
        widget.Button.Icon:setIcon(button.icon)
        widget.Button.Title:setText(button.text)
        widget.open = button.open

        if button.subCategories then
            widget.subCategories = button.subCategories
            widget.subCategoriesSize = #button.subCategories
            widget.Button.Arrow:setVisible(true)

            for subId, subButton in ipairs(button.subCategories) do
                local subWidget = createSubWidget(widget, subId, subButton)
                if button.text == "Controls" then
                    subWidget.Button.Title:setMarginLeft(-5)
                end
            end
        end

        widget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
        if id == 1 then
            widget:addAnchor(AnchorTop, "parent", AnchorTop)
            widget:setMarginTop(10)
        else
            widget:addAnchor(AnchorTop, "prev", AnchorBottom)
            widget:setMarginTop(10)
        end

        function widget.Button.onClick()
            local parent = widget
            local oldOpen = controller.ui.openedCategory

            if parent.subCategoriesSize then
                parent.closedSize = parent.closedSize or parent:getHeight() / (parent.subCategoriesSize + 1) + 15
                parent.openedSize = parent.openedSize or parent:getHeight() * (parent.subCategoriesSize + 1) - 6

                if not parent.opened then
                    open(parent)
                    widget.Button:setChecked(true)
                    widget.Button.Arrow:setImageSource("/images/ui/icon-arrow7x7-right")
                    widget.Button.Arrow:setVisible(true)
                else
          
                    if controller.ui.selectedOption then
                        controller.ui.selectedOption:hide()
                    end
                    if parent.open then
                        local panelToShow = panels[parent.open]
                        if panelToShow then
                            closeCharacterButtons()
                            widget.Button:setChecked(true)
                            widget.Button.Arrow:setImageSource("/images/ui/icon-arrow7x7-right")
                            widget.Button.Arrow:setVisible(true)
                            panelToShow:show()
                            panelToShow:setVisible(true)
                            controller.ui.selectedOption = panelToShow
                        else
                            print("Error: panelToShow is nil or does not exist in panels")
                        end
                    end
                end
            end

            if oldOpen and oldOpen:getId() ~= parent:getId() then
                closeCharacterButtons()
                oldOpen.Button:setChecked(false)
                oldOpen.Button.Arrow:setImageSource("/images/ui/icon-arrow7x7-down")
                local selectedOption = controller.ui.selectedOption
                if selectedOption then
                    selectedOption:hide()
                end
                local panelToShow = panels[parent.open]
                if panelToShow then
                    panelToShow:show()
                    panelToShow:setVisible(true)
                    controller.ui.selectedOption = panelToShow
                else
                    print("Error: panelToShow is nil or does not exist in panels")
                end
            end
        end
    end
end

function closeCharacterButtons()
    for i = 1, controller.ui.optionsTabBar:getChildCount() do
        local widget = controller.ui.optionsTabBar:getChildByIndex(i)
        if widget and widget.subCategories then
            for subId, _ in ipairs(widget.subCategories) do
                local subWidget = widget:getChildById(subId)
                if subWidget then
                    subWidget.Button:setChecked(false)
                    subWidget.Button.Arrow:setVisible(false)
                end
            end
        end
    end
end

controller = Controller:new()
controller:setUI('options')
controller:bindKeyDown('Ctrl+Shift+F', function() toggleOption('fullscreen') end)
controller:bindKeyDown('Ctrl+N', toggleDisplays)

function controller:onInit()
    for k, obj in pairs(options) do
        if type(obj) ~= "table" then
            obj = { value = obj }
            options[k] = obj
        end
        g_settings.setDefault(k, obj.value)
    end

    extraWidgets.optionsButton = modules.client_topmenu.addTopRightToggleButton('optionsButton', tr('Options'),
        '/images/topbuttons/button_options', toggle)
    extraWidgets.audioButton = modules.client_topmenu.addTopRightToggleButton('audioButton', tr('Audio'),
        '/images/topbuttons/button_mute_up', function() toggleOption('enableAudio') end)

    panels.generalPanel = g_ui.loadUI('general',controller.ui.optionsTabContent)
    panels.controlPanel = g_ui.loadUI('control',controller.ui.optionsTabContent)
    panels.consolePanel = g_ui.loadUI('console',controller.ui.optionsTabContent)
    panels.graphicsPanel = g_ui.loadUI('graphics',controller.ui.optionsTabContent)
    panels.soundPanel = g_ui.loadUI('audio',controller.ui.optionsTabContent)
    self.ui:hide()

    configureCharacterCategories()
    addEvent(setup)
end

function controller:onTerminate()
    extraWidgets.optionsButton:destroy()
    extraWidgets.audioButton:destroy()
    panels = nil
    extraWidgets = nil
end

function setOption(key, value, force)
    if not modules.game_interface then
        return
    end

    local option = options[key]
    if option == nil or not force and option.value == value then
        return
    end

    if option.action then
        option.action(value, options, controller, panels, extraWidgets)
    end

    -- change value for keybind updates

    for _, panel in pairs(panels) do

        local widget = panel:recursiveGetChildById(key)
        if widget then
            if widget:getStyle().__class == 'UICheckBox' then
                widget:setChecked(value)
            elseif widget:getStyle().__class == 'UIScrollBar' then
                widget:setValue(value)
            elseif widget:recursiveGetChildById('valueBar') then
                widget:recursiveGetChildById('valueBar'):setValue(value)
            end
            break
        end

    end

    option.value = value
    g_settings.set(key, value)
end

function setupOptionsMainButton()
    if extraWidgets.optionsButtons then
        return
    end

    extraWidgets.optionsButtons = modules.game_mainpanel.addSpecialToggleButton('optionsMainButton', tr('Options'),
        '/images/options/button_options', toggle, true)
end

function getOption(key)
    return options[key].value
end

function show()
    controller.ui:show()
    controller.ui:raise()
    controller.ui:focus()
end

function hide()
    controller.ui:hide()
end

function toggle()
    if controller.ui:isVisible() then
        hide()
        return
    end

    if not controller.ui.openedCategory then
        local firstCategory = controller.ui.optionsTabBar:getChildByIndex(1)
        controller.ui.openedCategory = firstCategory
        firstCategory.Button:onClick()

        local panelToShow = panels[firstCategory.open]
        if panelToShow then
            panelToShow:show()

            controller.ui.selectedOption = panelToShow

        end
    end

    show()
end

function addTab(name, panel, icon)
    --controller.ui.optionsTabBar:addTab(name, panel, icon)

end

function removeTab(v)
    if type(v) == 'string' then
        v = controller.ui.optionsTabBar:getTab(v)
    end

    controller.ui.optionsTabBar:removeTab(v)
end

function addButton(name, func, icon)
    --controller.ui.optionsTabBar:addButton(name, func, icon)
end

local function findCategory(categoryText)
    for i, category in ipairs(buttons) do
        if category.text == categoryText then
            return category, i
        end
    end
    return nil
end

local function findSubcategory(category, subcategoryText)
    for i, subcategory in ipairs(category.subCategories or {}) do
        if subcategory.text == subcategoryText then
            return subcategory, i
        end
    end
    return nil
end

function addCategory(newCategory)
    table.insert(buttons, newCategory)
    configureCharacterCategories()
end

function removeCategory(categoryText)
    local _, index = findCategory(categoryText)
    if index then
        table.remove(buttons, index)
        configureCharacterCategories()
    else
        print("Category not found: " .. categoryText)
    end
end

function removeButtonFromCategory(categoryText, buttonText)
    local category = findCategory(categoryText)
    if category then
        local _, index = findSubcategory(category, buttonText)
        if index then
            table.remove(category.subCategories, index)
            configureCharacterCategories()
        else
            print("Subcategory not found: " .. buttonText)
        end
    else
        print("Category not found: " .. categoryText)
    end
end

function addButtonToCategory(categoryText, newButton)
    local category = findCategory(categoryText)
    if category then
        table.insert(category.subCategories or {}, newButton)
        configureCharacterCategories()
    else
        print("Category not found: " .. categoryText)
    end
end

function addSubcategoryToCategory(categoryText, newSubcategory)
    addButtonToCategory(categoryText, newSubcategory)
end


--[[ modules.client_options.addCategory({
    text = "Sound2",
    icon = "/images/icons/icon_sound",
    open = "generalPanel",
    subCategories = {
        { text = "Volume3", open = "controlPanel" },
        { text = "Effects3", open = "graphicsPanel" }
    }
})

-- Remover una categoría existente
modules.client_options.removeCategory("Graphics")--

-- Remover un botón específico de una categoría
modules.client_options.removeButtonFromCategory("Controls", "General Hotkeys")--

-- Añadir un nuevo botón a una categoría existente
modules.client_options.addButtonToCategory("Sound", { text = "Microphone", open = "consolePanel" })--

-- Añadir una nueva subcategoría a una categoría existente
modules.client_options.addSubcategoryToCategory("Controls", { text = "Gamepad", open = "graphicsPanel" })-- ]]
