local UI = nil
local STAGES = {
    CREATURES = 2,
    SEARCH = 4,
    CATEGORY = 1,
    CREATURE = 3
}

function Cyclopedia.onParseBestiaryOverview(name, creatures)
    if name == "Result" then
        Cyclopedia.loadBestiarySearchCreatures(creatures)
    else
        Cyclopedia.loadBestiaryCreatures(creatures)
    end
end

bestiaryControllerCyclopedia = Controller:new()

function bestiaryControllerCyclopedia:onInit()
    bestiaryControllerCyclopedia:registerEvents(g_game, {
        onParseBestiaryGroups = Cyclopedia.LoadBestiaryCategories,
        onParseBestiaryOverview = Cyclopedia.onParseBestiaryOverview,
        onParseBestiaryMonster = Cyclopedia.loadBestiarySelectedCreature

    })

end

function bestiaryControllerCyclopedia:onGameStart()

end

function bestiaryControllerCyclopedia:onGameEnd()

end

function bestiaryControllerCyclopedia:onTerminate()

end

function showBestiary()

    UI = g_ui.loadUI("bestiary", contentContainer)
    UI:show()

    UI.ListBase.CategoryList:setVisible(true)
    UI.ListBase.CreatureList:setVisible(false)
    UI.ListBase.CreatureInfo:setVisible(false)

    Cyclopedia.Bestiary.Stage = STAGES.CATEGORY

    g_game.requestBestiary()
end

Cyclopedia.Bestiary = {}

Cyclopedia.Bestiary.Stage = STAGES.CATEGORY

function Cyclopedia.SetBestiaryProgress(currentValue, maxValue)
    local percent = currentValue / maxValue * 100
    local rect = {
        height = 20,
        x = 0,
        y = 0,
        width = percent / 100 * 193
    }

    if rect.width < 1 then
        rect.width = 1
    end

    UI.ListBase.CreatureInfo.ProgressFill:setImageClip(rect)
    UI.ListBase.CreatureInfo.ProgressFill:setImageRect(rect)
    UI.ListBase.CreatureInfo.ProgressValue:setText(comma_value(tonumber(currentValue)))
end

function Cyclopedia.SetBestiaryStars(Value)
    UI.ListBase.CreatureInfo.StarFill:setWidth(Value * 9)
end

function Cyclopedia.SetBestiaryDiamonds(Value)
    UI.ListBase.CreatureInfo.DiamondFill:setWidth(Value * 9)
end

function Cyclopedia.CreateCreatureItems(data)
    UI.ListBase.CreatureInfo.ItemsBase.Itemlist:destroyChildren()

    for index, _ in pairs(data) do
        local widget = g_ui.createWidget("BestiaryItemGroup", UI.ListBase.CreatureInfo.ItemsBase.Itemlist)

        widget:setId(index)

        if index == 0 then
            widget.Title:setText(tr("Common") .. ":")
        elseif index == 1 then
            widget.Title:setText(tr("Uncommon") .. ":")
        elseif index == 2 then
            widget.Title:setText(tr("Semi-Rare") .. ":")
        elseif index == 3 then
            widget.Title:setText(tr("Rare") .. ":")
        else
            widget.Title:setText(tr("Very Rare") .. ":")
        end

        for i = 1, 15 do
            local item = g_ui.createWidget("BestiaryItem", widget.Items)

            item:setId(i)
        end

        for itemIndex, itemData in ipairs(data[index]) do
            local thing = g_things.getThingType(itemData.id, ThingCategoryItem)
            local itemWidget = UI.ListBase.CreatureInfo.ItemsBase.Itemlist[index].Items[itemIndex]

            itemWidget:setItemId(itemData.id)

            itemWidget.id = itemData.id
            itemWidget.classification = thing:getClassification()

            if itemData.id == 0 then
                itemWidget.undefinedItem:setVisible(true)
            end

            if itemData.id > 0 then
                if itemData.stackable then
                    itemWidget.Stackable:setText("1+")
                else
                    itemWidget.Stackable:setText("1")
                end
            end

            local frame = g_game.getItemFrame(thing:getResultingValue())

            if frame > 0 then
                itemWidget.Rarity:setImageSource("/images/ui/frames")
                itemWidget.Rarity:setImageClip(torect(g_game.getRectFrame(frame)))
            end
        end
    end
end

function Cyclopedia.loadBestiarySelectedCreature(data)
    local occurence = {
        [0] = 1,
        2,
        3,
        4
    }

    UI.ListBase.CreatureInfo:setText(RACE[data.raceId].name:gsub("(%l)(%w*)", function(first, rest)
        return first:upper() .. rest
    end))
    Cyclopedia.SetBestiaryDiamonds(occurence[data.ocorrence])
    Cyclopedia.SetBestiaryStars(data.difficulty)
    UI.ListBase.CreatureInfo.LeftBase.Sprite:setOutfit(RACE[data.raceId].outfit)
    UI.ListBase.CreatureInfo.LeftBase.Sprite:setAnimate(true)
    Cyclopedia.SetBestiaryProgress(data.killCounter, data.thirdDifficulty)

    if data.killCounter >= data.thirdDifficulty then
        UI.ListBase.CreatureInfo.ProgressFill:setImageSource("/game_cyclopedia/images/bestiary/fill_completed")
        UI.ListBase.CreatureInfo.ProgressValue:setText(data.thirdDifficulty)
    else
        UI.ListBase.CreatureInfo.ProgressFill:setImageSource("/game_cyclopedia/images/bestiary/fill")
        UI.ListBase.CreatureInfo.ProgressValue:setText(comma_value(data.killCounter))
    end

    if data.currentLevel > 1 then
        UI.ListBase.CreatureInfo.Value1:setText(data.maxHealth)
        UI.ListBase.CreatureInfo.Value2:setText(data.experience)
        UI.ListBase.CreatureInfo.Value3:setText(data.speed)
        UI.ListBase.CreatureInfo.Value4:setText(data.armor)
        UI.ListBase.CreatureInfo.Value5:setText(data.mitigation .. "%")
        UI.ListBase.CreatureInfo.BonusValue:setText(data.charmValue)
    end

    local resists = {
        [0] = "PhysicalProgress",
        "FireProgress",
        "EarthProgress",
        "EnergyProgress",
        "IceProgress",
        "HolyProgress",
        "DeathProgress",
        "HealingProgress"
    }

    if not table.empty(data.combat) then
        for i = 0, 7 do
            local combat = Cyclopedia.calculateCombatValues(data.combat[i].value)

            UI.ListBase.CreatureInfo[resists[i]].Fill:setMarginRight(combat.margin)
            UI.ListBase.CreatureInfo[resists[i]].Fill:setBackgroundColor(combat.color)
            UI.ListBase.CreatureInfo[resists[i]]:setTooltip(string.format("Sensitive to %s : %s", string.gsub(
                resists[i], "Progress", ""):lower(), combat.tooltip))
        end
    else
        for i = 0, 7 do
            UI.ListBase.CreatureInfo[resists[i]].Fill:setMarginRight(65)
        end
    end

    local lootData = {}

    for _, value in ipairs(data.loot) do
        local loot = {
            name = value.name,
            id = value.itemId,
            type = value.type,
            difficulty = value.diffculty,
            stackable = value.stackable == 1 and true or false
        }

        if not lootData[value.diffculty] then
            lootData[value.diffculty] = {}
        end

        table.insert(lootData[value.diffculty], loot)
    end

    Cyclopedia.CreateCreatureItems(lootData)
    UI.ListBase.CreatureInfo.LocationField.Textlist.Text:setText(data.location)
end

function Cyclopedia.ShowBestiaryCreature()
    Cyclopedia.Bestiary.Stage = STAGES.CREATURE

    Cyclopedia.onStageChange()
end

function Cyclopedia.ShowBestiaryCreatures(Category)
    UI.ListBase.CreatureList:destroyChildren()
    UI.ListBase.CategoryList:setVisible(false)
    UI.ListBase.CreatureInfo:setVisible(false)
    UI.ListBase.CreatureList:setVisible(true)
    g_game.requestBestiaryOverview(Category)
end

function Cyclopedia.CreateBestiaryCategoryItem(Data)
    UI.BackPageButton:setEnabled(false)

    local widget = g_ui.createWidget("BestiaryCategory", UI.ListBase.CategoryList)

    widget:setText(Data.name)
    widget.ClassIcon:setImageSource("/game_cyclopedia/images/bestiary/creatures/" .. Data.name:lower():gsub(" ", "_"))

    widget.Category = Data.name

    widget:setColor("#C0C0C0")
    widget.TotalValue:setText(string.format("Total: %d", Data.amount))
    widget.KnownValue:setText(string.format("Known: %d", Data.know))

    function widget.ClassBase:onClick()
        UI.BackPageButton:setEnabled(true)
        Cyclopedia.ShowBestiaryCreatures(self:getParent().Category)

        Cyclopedia.Bestiary.Stage = STAGES.CREATURES

        Cyclopedia.onStageChange()
    end
end

function Cyclopedia.loadBestiarySearchCreatures(data)
    UI.ListBase.CategoryList:setVisible(false)
    UI.ListBase.CreatureInfo:setVisible(false)
    UI.ListBase.CreatureList:setVisible(true)
    UI.BackPageButton:setEnabled(true)

    Cyclopedia.Bestiary.Stage = STAGES.SEARCH

    Cyclopedia.onStageChange()

    local maxCategoriesPerPage = 15

    Cyclopedia.Bestiary.Search = {}
    Cyclopedia.Bestiary.Page = 1
    Cyclopedia.Bestiary.TotalSearchPages = math.ceil(#data / maxCategoriesPerPage)

    UI.PageValue:setText(string.format("%d / %d", Cyclopedia.Bestiary.Page, Cyclopedia.Bestiary.TotalSearchPages))

    local page = 1

    Cyclopedia.Bestiary.Search[page] = {}

    for i = 0, #data do
        if i % maxCategoriesPerPage == 0 and i > 0 then
            page = page + 1
            Cyclopedia.Bestiary.Search[page] = {}
        end

        local creature = {
            id = data[i].id,
            currentLevel = data[i].currentLevel
        }

        table.insert(Cyclopedia.Bestiary.Search[page], creature)
    end

    Cyclopedia.Bestiary.Stage = STAGES.SEARCH

    Cyclopedia.loadBestiaryCreature(Cyclopedia.Bestiary.Page, true)
    Cyclopedia.verifyBestiaryButtons()
end

function Cyclopedia.loadBestiaryCreatures(data)
    local maxCategoriesPerPage = 15

    Cyclopedia.Bestiary.Creatures = {}
    Cyclopedia.Bestiary.Page = 1
    Cyclopedia.Bestiary.TotalCreaturesPages = math.ceil(#data / maxCategoriesPerPage)

    UI.PageValue:setText(string.format("%d / %d", Cyclopedia.Bestiary.Page, Cyclopedia.Bestiary.TotalCreaturesPages))

    local page = 1

    Cyclopedia.Bestiary.Creatures[page] = {}

    for i = 0, #data do
        if i % maxCategoriesPerPage == 0 and i > 0 then
            page = page + 1
            Cyclopedia.Bestiary.Creatures[page] = {}
        end

        local creature = {
            id = data[i].id,
            currentLevel = data[i].currentLevel
        }

        table.insert(Cyclopedia.Bestiary.Creatures[page], creature)
    end

    Cyclopedia.loadBestiaryCreature(Cyclopedia.Bestiary.Page, false)
    Cyclopedia.verifyBestiaryButtons()
end

function Cyclopedia.BestiarySearch()
    local text = UI.SearchEdit:getText()
    local creatures = {}

    for id, data in pairs(RACE) do
        if string.find(data.name, text) then
            table.insert(creatures, id)
        end
    end

    g_game.requestBestiarySearch(creatures)
    UI.SearchEdit:setText("")
end

function Cyclopedia.BestiarySearchText(text)
    if text ~= "" then
        UI.SearchButton:enable(true)
    else
        UI.SearchButton:disable(false)
    end
end

function Cyclopedia.CreateBestiaryCreaturesItem(data)
    if not RACE[data.id] then
        error(string.format("Race id: %d not found.", data.id))
    end

    local function verify(name)
        if #name > 18 then
            return name:sub(1, 15) .. "..."
        else
            return name
        end
    end

    local widget = g_ui.createWidget("BestiaryCreature", UI.ListBase.CreatureList)

    widget:setId(data.id)

    local formattedName = RACE[data.id].name:gsub("(%l)(%w*)", function(first, rest)
        return first:upper() .. rest
    end)

    widget.Name:setText(verify(formattedName))
    widget.Sprite:setOutfit(RACE[data.id].outfit)
    widget.Sprite:setAnimate(true)

    local level = {0, 1, 2}

    if data.currentLevel > 3 then
        widget.Finalized:setVisible(true)
        widget.KillsLabel:setVisible(false)
    else
        widget.KillsLabel:setText(string.format("%d / 3", level[data.currentLevel]))
    end

    function widget.ClassBase:onClick()
        UI.BackPageButton:setEnabled(true)
        g_game.requestBestiaryMonster(widget:getId())
        Cyclopedia.ShowBestiaryCreature()
    end
end

function Cyclopedia.loadBestiaryCreature(page, search)
    local state = "Creatures"

    if search then
        state = "Search"
    end

    if not Cyclopedia.Bestiary[state][page] then
        return
    end

    UI.ListBase.CreatureList:destroyChildren()

    for _, data in ipairs(Cyclopedia.Bestiary[state][page]) do
        Cyclopedia.CreateBestiaryCreaturesItem(data)
    end
end

function Cyclopedia.LoadBestiaryCategories(data)

    local maxCategoriesPerPage = 15

    Cyclopedia.Bestiary.Categories = {}
    Cyclopedia.Bestiary.Page = 1
    Cyclopedia.Bestiary.TotalCategoriesPages = math.ceil(#data / maxCategoriesPerPage)

    UI.PageValue:setText(string.format("%d / %d", Cyclopedia.Bestiary.Page, Cyclopedia.Bestiary.TotalCategoriesPages))

    local page = 1

    Cyclopedia.Bestiary.Categories[page] = {}

    for i = 1, #data do
        if (i - 1) % maxCategoriesPerPage == 0 and i > 1 then
            page = page + 1
            Cyclopedia.Bestiary.Categories[page] = {}
        end

        local category = {
            name = data[i].bestClass,
            amount = data[i].unlockedCount,
            know = data[i].count
        }

        table.insert(Cyclopedia.Bestiary.Categories[page], category)
    end

    Cyclopedia.loadBestiaryCategory(Cyclopedia.Bestiary.Page)
    Cyclopedia.verifyBestiaryButtons()
end

function Cyclopedia.loadBestiaryCategory(page)
    if not Cyclopedia.Bestiary.Categories[page] then
        return
    end

    UI.ListBase.CategoryList:destroyChildren()

    for _, data in ipairs(Cyclopedia.Bestiary.Categories[page]) do
        Cyclopedia.CreateBestiaryCategoryItem(data)
    end
end

function Cyclopedia.onStageChange()
    Cyclopedia.Bestiary.Page = 1

    if Cyclopedia.Bestiary.Stage == STAGES.CATEGORY then
        UI.BackPageButton:setEnabled(false)
        UI.ListBase.CategoryList:setVisible(true)
        UI.ListBase.CreatureList:setVisible(false)
        UI.ListBase.CreatureInfo:setVisible(false)
    end

    if Cyclopedia.Bestiary.Stage == STAGES.CREATURES then
        UI.BackPageButton:setEnabled(true)
        UI.ListBase.CategoryList:setVisible(false)
        UI.ListBase.CreatureList:setVisible(true)
        UI.ListBase.CreatureInfo:setVisible(false)

        function UI.BackPageButton.onClick()
            Cyclopedia.Bestiary.Stage = STAGES.CATEGORY

            Cyclopedia.onStageChange()
        end
    end

    if Cyclopedia.Bestiary.Stage == STAGES.SEARCH then
        UI.BackPageButton:setEnabled(true)
        UI.ListBase.CategoryList:setVisible(false)
        UI.ListBase.CreatureList:setVisible(true)
        UI.ListBase.CreatureInfo:setVisible(false)

        function UI.BackPageButton.onClick()
            Cyclopedia.Bestiary.Stage = STAGES.CATEGORY

            Cyclopedia.onStageChange()
        end
    end

    if Cyclopedia.Bestiary.Stage == STAGES.CREATURE then
        UI.BackPageButton:setEnabled(true)
        UI.ListBase.CategoryList:setVisible(false)
        UI.ListBase.CreatureList:setVisible(false)
        UI.ListBase.CreatureInfo:setVisible(true)

        function UI.BackPageButton.onClick()
            Cyclopedia.Bestiary.Stage = STAGES.CREATURES

            Cyclopedia.onStageChange()
        end
    end

    Cyclopedia.verifyBestiaryButtons()
end

function Cyclopedia.changeBestiaryPage(prev, next)
    local stage = Cyclopedia.Bestiary.Stage

    if next then
        Cyclopedia.Bestiary.Page = Cyclopedia.Bestiary.Page + 1
    end

    if prev then
        Cyclopedia.Bestiary.Page = Cyclopedia.Bestiary.Page - 1
    end

    if stage == STAGES.CATEGORY then
        Cyclopedia.loadBestiaryCategory(Cyclopedia.Bestiary.Page)
    elseif stage == STAGES.CREATURES then
        Cyclopedia.loadBestiaryCreature(Cyclopedia.Bestiary.Page, false)
    elseif stage == STAGES.SEARCH then
        Cyclopedia.loadBestiaryCreature(Cyclopedia.Bestiary.Page, true)
    end

    Cyclopedia.verifyBestiaryButtons()
end

function Cyclopedia.verifyBestiaryButtons()
    local page = Cyclopedia.Bestiary.Page
    local totalCategoriesPages = Cyclopedia.Bestiary.TotalCategoriesPages
    local totalCreaturesPages = Cyclopedia.Bestiary.TotalCreaturesPages
    local totalSearchPages = Cyclopedia.Bestiary.TotalSearchPages
    local stage = Cyclopedia.Bestiary.Stage

    local function updateButtonState(button, condition)
        if condition then
            button:enable()
        else
            button:disable()
        end
    end

    local function updatePageValue(currentPage, totalPages)
        UI.PageValue:setText(string.format("%d / %d", currentPage, totalPages))
    end

    updateButtonState(UI.SearchButton, UI.SearchEdit:getText() ~= "")

    if stage == STAGES.SEARCH and totalSearchPages then
        local totalPages = totalSearchPages

        updateButtonState(UI.PrevPageButton, page > 1)
        updateButtonState(UI.NextPageButton, page < totalPages)
        updatePageValue(page, totalPages)

        return
    end

    if stage == STAGES.CREATURE then
        UI.PrevPageButton:disable()
        UI.NextPageButton:disable()
        updatePageValue(1, 1)

        return
    end

    if stage == STAGES.CATEGORY and totalCategoriesPages or stage == STAGES.CREATURES and totalCreaturesPages then
        local totalPages = stage == STAGES.CATEGORY and totalCategoriesPages or totalCreaturesPages

        updateButtonState(UI.PrevPageButton, page > 1)
        updateButtonState(UI.NextPageButton, page < totalPages)
        updatePageValue(page, totalPages)
    end
end

function requestBestiaryCategoryData(catName)

    local protocolGame = g_game.getProtocolGame()
    if protocolGame then
        local msg = OutputMessage.create()
        msg:addU8(0xE2)
        msg:addU8(0x02)
        msg:addString(catName)
        protocolGame:send(msg)
    end

end

function requestBestiaryMonsterData(raceId)

    local protocolGame = g_game.getProtocolGame()
    if protocolGame then
        local msg = OutputMessage.create()
        msg:addU8(0xE3)
        msg:addU16(raceId)
        protocolGame:send(msg)
    end
end

function sendRequestBestiary()

    local protocolGame = g_game.getProtocolGame()
    if protocolGame then
        local msg = OutputMessage.create()
        msg:addU8(0xE1)
        protocolGame:send(msg)
    end
end

-- LuaFormatter off
protoData = {
	[0] = {name = "nothing", type = 0, head = 0, body = 0, legs = 0, feet = 0},
	[2] = {name = "orc warlord", type = 2, head = 0, body = 0, legs = 0, feet = 0},
	[3] = {name = "war wolf", type = 3, head = 0, body = 0, legs = 0, feet = 0},
	[4] = {name = "orc rider", type = 4, head = 0, body = 0, legs = 0, feet = 0},
	[5] = {name = "orc", type = 5, head = 0, body = 0, legs = 0, feet = 0},
	[6] = {name = "orc shaman", type = 6, head = 0, body = 0, legs = 0, feet = 0},
	[7] = {name = "orc warrior", type = 7, head = 0, body = 0, legs = 0, feet = 0},
	[8] = {name = "orc berserker", type = 8, head = 0, body = 0, legs = 0, feet = 0},
	[9] = {name = "necromancer", type = 9, head = 0, body = 0, legs = 0, feet = 0},
	[10] = {name = "warlock", type = 130, head = 0, body = 52, legs = 128, feet = 95},
	[11] = {name = "hunter", type = 129, head = 95, body = 116, legs = 120, feet = 115},
	[12] = {name = "valkyrie", type = 139, head = 113, body = 38, legs = 76, feet = 96},
	[13] = {name = "black sheep", type = 13, head = 0, body = 0, legs = 0, feet = 0},
	[14] = {name = "sheep", type = 14, head = 0, body = 0, legs = 0, feet = 0},
	[15] = {name = "troll", type = 15, head = 0, body = 0, legs = 0, feet = 0},
	[16] = {name = "bear", type = 16, head = 0, body = 0, legs = 0, feet = 0},
	[17] = {name = "bonelord", type = 17, head = 0, body = 0, legs = 0, feet = 0},
	[18] = {name = "ghoul", type = 18, head = 0, body = 0, legs = 0, feet = 0},
	[19] = {name = "slime", type = 19, head = 0, body = 0, legs = 0, feet = 0},
	[20] = {name = "squidgy slime", type = 19, head = 0, body = 0, legs = 0, feet = 0},
	[21] = {name = "rat", type = 21, head = 0, body = 0, legs = 0, feet = 0},
	[22] = {name = "cyclops", type = 22, head = 0, body = 0, legs = 0, feet = 0},
	[23] = {name = "minotaur mage", type = 23, head = 0, body = 0, legs = 0, feet = 0},
	[24] = {name = "minotaur archer", type = 24, head = 0, body = 0, legs = 0, feet = 0},
	[25] = {name = "minotaur", type = 25, head = 0, body = 0, legs = 0, feet = 0},
	[26] = {name = "rotworm", type = 26, head = 0, body = 0, legs = 0, feet = 0},
	[27] = {name = "wolf", type = 27, head = 0, body = 0, legs = 0, feet = 0},
	[28] = {name = "snake", type = 28, head = 0, body = 0, legs = 0, feet = 0},
	[29] = {name = "minotaur guard", type = 29, head = 0, body = 0, legs = 0, feet = 0},
	[30] = {name = "spider", type = 30, head = 0, body = 0, legs = 0, feet = 0},
	[31] = {name = "deer", type = 31, head = 0, body = 0, legs = 0, feet = 0},
	[32] = {name = "dog", type = 32, head = 0, body = 0, legs = 0, feet = 0},
	[33] = {name = "skeleton", type = 33, head = 0, body = 0, legs = 0, feet = 0},
	[34] = {name = "dragon", type = 34, head = 0, body = 0, legs = 0, feet = 0},
	[351] = {name = "dark dragon", type = 315, head = 0, body = 0, legs = 0, feet = 0},
	[35] = {name = "demon", type = 35, head = 0, body = 0, legs = 0, feet = 0},
	[36] = {name = "poison spider", type = 36, head = 0, body = 0, legs = 0, feet = 0},
	[37] = {name = "demon skeleton", type = 37, head = 0, body = 0, legs = 0, feet = 0},
	[38] = {name = "giant spider", type = 38, head = 0, body = 0, legs = 0, feet = 0},
	[39] = {name = "dragon lord", type = 39, head = 0, body = 0, legs = 0, feet = 0},
	[40] = {name = "fire devil", type = 40, head = 0, body = 0, legs = 0, feet = 0},
	[41] = {name = "lion", type = 41, head = 0, body = 0, legs = 0, feet = 0},
	[42] = {name = "polar bear", type = 42, head = 0, body = 0, legs = 0, feet = 0},
	[43] = {name = "scorpion", type = 43, head = 0, body = 0, legs = 0, feet = 0},
	[44] = {name = "wasp", type = 44, head = 0, body = 0, legs = 0, feet = 0},
	[45] = {name = "bug", type = 45, head = 0, body = 0, legs = 0, feet = 0},
	[47] = {name = "wild warrior", type = 131, head = 38, body = 38, legs = 38, feet = 38},
	[48] = {name = "ghost", type = 48, head = 0, body = 0, legs = 0, feet = 0},
	[49] = {name = "fire elemental", type = 49, head = 0, body = 0, legs = 0, feet = 0},
	[50] = {name = "orc spearman", type = 50, head = 0, body = 0, legs = 0, feet = 0},
	[51] = {name = "green djinn", type = 51, head = 0, body = 0, legs = 0, feet = 0},
	[52] = {name = "winter wolf", type = 52, head = 0, body = 0, legs = 0, feet = 0},
	[53] = {name = "frost troll", type = 53, head = 0, body = 0, legs = 0, feet = 0},
	[54] = {name = "witch", type = 54, head = 0, body = 0, legs = 0, feet = 0},
	[55] = {name = "behemoth", type = 55, head = 0, body = 0, legs = 0, feet = 0},
	[56] = {name = "cave rat", type = 56, head = 0, body = 0, legs = 0, feet = 0},
	[57] = {name = "monk", type = 57, head = 0, body = 0, legs = 0, feet = 0},
	[58] = {name = "priestess", type = 58, head = 0, body = 0, legs = 0, feet = 0},
	[59] = {name = "orc leader", type = 59, head = 0, body = 0, legs = 0, feet = 0},
	[60] = {name = "pig", type = 60, head = 0, body = 0, legs = 0, feet = 0},
	[61] = {name = "goblin", type = 61, head = 0, body = 0, legs = 0, feet = 0},
	[62] = {name = "elf", type = 62, head = 0, body = 0, legs = 0, feet = 0},
	[63] = {name = "elf arcanist", type = 63, head = 0, body = 0, legs = 0, feet = 0},
	[64] = {name = "elf scout", type = 64, head = 0, body = 0, legs = 0, feet = 0},
	[65] = {name = "mummy", type = 65, head = 0, body = 0, legs = 0, feet = 0},
	[66] = {name = "dwarf geomancer", type = 66, head = 0, body = 0, legs = 0, feet = 0},
	[67] = {name = "stone golem", type = 67, head = 0, body = 0, legs = 0, feet = 0},
	[68] = {name = "vampire", type = 68, head = 0, body = 0, legs = 0, feet = 0},
	[69] = {name = "dwarf", type = 69, head = 0, body = 0, legs = 0, feet = 0},
	[70] = {name = "dwarf guard", type = 70, head = 0, body = 0, legs = 0, feet = 0},
	[71] = {name = "dwarf soldier", type = 71, head = 0, body = 0, legs = 0, feet = 0},
	[72] = {name = "stalker", type = 128, head = 97, body = 116, legs = 95, feet = 95},
	[73] = {name = "hero", type = 73, head = 0, body = 0, legs = 0, feet = 0},
	[74] = {name = "rabbit", type = 74, head = 0, body = 0, legs = 0, feet = 0},
	[76] = {name = "swamp troll", type = 76, head = 0, body = 0, legs = 0, feet = 0},
	[77] = {name = "amazon", type = 137, head = 113, body = 120, legs = 95, feet = 115},
	[78] = {name = "banshee", type = 78, head = 0, body = 0, legs = 0, feet = 0},
	[79] = {name = "ancient scarab", type = 79, head = 0, body = 0, legs = 0, feet = 0},
	[80] = {name = "blue djinn", type = 80, head = 0, body = 0, legs = 0, feet = 0},
	[81] = {name = "cobra", type = 81, head = 0, body = 0, legs = 0, feet = 0},
	[82] = {name = "larva", type = 82, head = 0, body = 0, legs = 0, feet = 0},
	[83] = {name = "scarab", type = 83, head = 0, body = 0, legs = 0, feet = 0},
	[94] = {name = "hyaena", type = 94, head = 0, body = 0, legs = 0, feet = 0},
	[95] = {name = "gargoyle", type = 95, head = 0, body = 0, legs = 0, feet = 0},
	[99] = {name = "lich", type = 99, head = 0, body = 0, legs = 0, feet = 0},
	[100] = {name = "crypt shambler", type = 100, head = 0, body = 0, legs = 0, feet = 0},
	[101] = {name = "bonebeast", type = 101, head = 0, body = 0, legs = 0, feet = 0},
	[103] = {name = "efreet", type = 103, head = 0, body = 0, legs = 0, feet = 0},
	[104] = {name = "marid", type = 104, head = 0, body = 0, legs = 0, feet = 0},
	[105] = {name = "badger", type = 105, head = 0, body = 0, legs = 0, feet = 0},
	[106] = {name = "skunk", type = 106, head = 0, body = 0, legs = 0, feet = 0},
	[108] = {name = "elder bonelord", type = 108, head = 0, body = 0, legs = 0, feet = 0},
	[109] = {name = "gazer", type = 109, head = 0, body = 0, legs = 0, feet = 0},
	[110] = {name = "yeti", type = 110, head = 0, body = 0, legs = 0, feet = 0},
	[111] = {name = "chicken", type = 111, head = 0, body = 0, legs = 0, feet = 0},
	[112] = {name = "crab", type = 112, head = 0, body = 0, legs = 0, feet = 0},
	[113] = {name = "lizard templar", type = 113, head = 0, body = 0, legs = 0, feet = 0},
	[114] = {name = "lizard sentinel", type = 114, head = 0, body = 0, legs = 0, feet = 0},
	[115] = {name = "lizard snakecharmer", type = 115, head = 0, body = 0, legs = 0, feet = 0},
	[116] = {name = "kongra", type = 116, head = 0, body = 0, legs = 0, feet = 0},
	[117] = {name = "merlkin", type = 117, head = 0, body = 0, legs = 0, feet = 0},
	[118] = {name = "sibang", type = 118, head = 0, body = 0, legs = 0, feet = 0},
	[119] = {name = "crocodile", type = 119, head = 0, body = 0, legs = 0, feet = 0},
	[120] = {name = "carniphila", type = 120, head = 0, body = 0, legs = 0, feet = 0},
	[121] = {name = "hydra", type = 121, head = 0, body = 0, legs = 0, feet = 0},
	[122] = {name = "bat", type = 122, head = 0, body = 0, legs = 0, feet = 0},
	[123] = {name = "panda", type = 123, head = 0, body = 0, legs = 0, feet = 0},
	[124] = {name = "centipede", type = 124, head = 0, body = 0, legs = 0, feet = 0},
	[125] = {name = "tiger", type = 125, head = 0, body = 0, legs = 0, feet = 0},
	[211] = {name = "elephant", type = 211, head = 0, body = 0, legs = 0, feet = 0},
	[212] = {name = "flamingo", type = 212, head = 0, body = 0, legs = 0, feet = 0},
	[213] = {name = "butterfly", type = 213, head = 0, body = 0, legs = 0, feet = 0},
	[214] = {name = "dworc voodoomaster", type = 214, head = 0, body = 0, legs = 0, feet = 0},
	[215] = {name = "dworc fleshhunter", type = 215, head = 0, body = 0, legs = 0, feet = 0},
	[216] = {name = "dworc venomsniper", type = 216, head = 0, body = 0, legs = 0, feet = 0},
	[217] = {name = "parrot", type = 217, head = 0, body = 0, legs = 0, feet = 0},
	[218] = {name = "terror bird", type = 218, head = 0, body = 0, legs = 0, feet = 0},
	[219] = {name = "tarantula", type = 219, head = 0, body = 0, legs = 0, feet = 0},
	[220] = {name = "serpent spawn", type = 220, head = 0, body = 0, legs = 0, feet = 0},
	[221] = {name = "spit nettle", type = 221, head = 0, body = 0, legs = 0, feet = 0},
	[222] = {name = "smuggler", type = 134, head = 95, body = 0, legs = 113, feet = 115},
	[223] = {name = "bandit", type = 129, head = 58, body = 40, legs = 24, feet = 95},
	[224] = {name = "assassin", type = 152, head = 95, body = 95, legs = 95, feet = 95},
	[225] = {name = "dark monk", type = 225, head = 0, body = 0, legs = 0, feet = 0},
	[227] = {name = "butterfly", type = 227, head = 0, body = 0, legs = 0, feet = 0},
	[228] = {name = "butterfly", type = 228, head = 0, body = 0, legs = 0, feet = 0},
	[236] = {name = "water elemental", type = 286, head = 0, body = 0, legs = 0, feet = 0},
	[237] = {name = "quara predator", type = 20, head = 0, body = 0, legs = 0, feet = 0},
	[238] = {name = "quara predator scout", type = 20, head = 0, body = 0, legs = 0, feet = 0},
	[239] = {name = "quara constrictor", type = 46, head = 0, body = 0, legs = 0, feet = 0},
	[240] = {name = "quara constrictor scout", type = 46, head = 0, body = 0, legs = 0, feet = 0},
	[241] = {name = "quara mantassin", type = 72, head = 0, body = 0, legs = 0, feet = 0},
	[242] = {name = "quara mantassin scout", type = 72, head = 0, body = 0, legs = 0, feet = 0},
	[243] = {name = "quara hydromancer", type = 47, head = 0, body = 0, legs = 0, feet = 0},
	[244] = {name = "quara hydromancer scout", type = 47, head = 0, body = 0, legs = 0, feet = 0},
	[245] = {name = "quara pincher", type = 77, head = 0, body = 0, legs = 0, feet = 0},
	[246] = {name = "quara pincher scout", type = 77, head = 0, body = 0, legs = 0, feet = 0},
	[247] = {name = "pirate marauder", type = 93, head = 0, body = 0, legs = 0, feet = 0},
	[248] = {name = "pirate cutthroat", type = 96, head = 0, body = 0, legs = 0, feet = 0},
	[249] = {name = "pirate buccaneer", type = 97, head = 0, body = 0, legs = 0, feet = 0},
	[250] = {name = "pirate corsair", type = 98, head = 0, body = 0, legs = 0, feet = 0},
	[251] = {name = "carrion worm", type = 192, head = 0, body = 0, legs = 0, feet = 0},
	[252] = {name = "enlightened of the cult", type = 193, head = 0, body = 0, legs = 0, feet = 0},
	[253] = {name = "acolyte of the cult", type = 194, head = 95, body = 100, legs = 100, feet = 19},
	[254] = {name = "adept of the cult", type = 194, head = 95, body = 94, legs = 94, feet = 19},
	[255] = {name = "novice of the cult", type = 133, head = 114, body = 114, legs = 76, feet = 114},
	[256] = {name = "pirate skeleton", type = 195, head = 0, body = 0, legs = 0, feet = 0},
	[257] = {name = "pirate ghost", type = 196, head = 0, body = 0, legs = 0, feet = 0},
	[258] = {name = "tortoise", type = 197, head = 0, body = 0, legs = 0, feet = 0},
	[259] = {name = "thornback tortoise", type = 198, head = 0, body = 0, legs = 0, feet = 0},
	[260] = {name = "mammoth", type = 199, head = 0, body = 0, legs = 0, feet = 0},
	[261] = {name = "blood crab", type = 200, head = 0, body = 0, legs = 0, feet = 0},
	[264] = {name = "seagull", type = 223, head = 0, body = 0, legs = 0, feet = 0},
	[265] = {name = "son of verminor", type = 19, head = 0, body = 0, legs = 0, feet = 0},
	[277] = {name = "island troll", type = 282, head = 0, body = 0, legs = 0, feet = 0},
	[279] = {name = "massive water elemental", type = 11, head = 0, body = 0, legs = 0, feet = 0},
	[281] = {name = "hand of cursed fate", type = 230, head = 0, body = 0, legs = 0, feet = 0},
	[282] = {name = "undead dragon", type = 231, head = 0, body = 0, legs = 0, feet = 0},
	[283] = {name = "lost soul", type = 232, head = 0, body = 0, legs = 0, feet = 0},
	[284] = {name = "betrayed wraith", type = 233, head = 0, body = 0, legs = 0, feet = 0},
	[285] = {name = "dark torturer", type = 234, head = 0, body = 0, legs = 0, feet = 0},
	[286] = {name = "spectre", type = 235, head = 0, body = 0, legs = 0, feet = 0},
	[287] = {name = "destroyer", type = 236, head = 0, body = 0, legs = 0, feet = 0},
	[288] = {name = "diabolic imp", type = 237, head = 0, body = 0, legs = 0, feet = 0},
	[289] = {name = "defiler", type = 238, head = 0, body = 0, legs = 0, feet = 0},
	[290] = {name = "wyvern", type = 239, head = 0, body = 0, legs = 0, feet = 0},
	[291] = {name = "fury", type = 149, head = 94, body = 77, legs = 78, feet = 79},
	[292] = {name = "phantasm", type = 241, head = 0, body = 0, legs = 0, feet = 0},
	[294] = {name = "hellhound", type = 240, head = 0, body = 0, legs = 0, feet = 0},
	[295] = {name = "hellfire fighter", type = 243, head = 0, body = 0, legs = 0, feet = 0},
	[296] = {name = "juggernaut", type = 244, head = 0, body = 0, legs = 0, feet = 0},
	[298] = {name = "blightwalker", type = 246, head = 0, body = 0, legs = 0, feet = 0},
	[299] = {name = "nightmare", type = 245, head = 0, body = 0, legs = 0, feet = 0},
	[310] = {name = "nomad", type = 146, head = 97, body = 39, legs = 40, feet = 3},
	[313] = {name = "massive fire elemental", type = 242, head = 0, body = 0, legs = 0, feet = 0},
	[314] = {name = "plaguesmith", type = 247, head = 0, body = 0, legs = 0, feet = 0},
	[317] = {name = "frost dragon", type = 248, head = 0, body = 0, legs = 0, feet = 0},
	[318] = {name = "penguin", type = 250, head = 0, body = 0, legs = 0, feet = 0},
	[319] = {name = "chakoya tribewarden", type = 249, head = 0, body = 0, legs = 0, feet = 0},
	[321] = {name = "braindeath", type = 256, head = 0, body = 0, legs = 0, feet = 0},
	[322] = {name = "barbarian skullhunter", type = 254, head = 0, body = 77, legs = 96, feet = 114},
	[323] = {name = "barbarian bloodwalker", type = 255, head = 114, body = 113, legs = 132, feet = 94},
	[324] = {name = "frost giant", type = 257, head = 0, body = 0, legs = 0, feet = 0},
	[325] = {name = "husky", type = 258, head = 0, body = 0, legs = 0, feet = 0},
	[326] = {name = "ice golem", type = 261, head = 0, body = 0, legs = 0, feet = 0},
	[327] = {name = "silver rabbit", type = 262, head = 0, body = 0, legs = 0, feet = 0},
	[328] = {name = "chakoya toolshaper", type = 259, head = 0, body = 0, legs = 0, feet = 0},
	[329] = {name = "chakoya windcaller", type = 260, head = 0, body = 0, legs = 0, feet = 0},
	[330] = {name = "crystal spider", type = 263, head = 0, body = 0, legs = 0, feet = 0},
	[331] = {name = "ice witch", type = 149, head = 0, body = 9, legs = 86, feet = 86},
	[332] = {name = "barbarian brutetamer", type = 264, head = 78, body = 97, legs = 95, feet = 121},
	[333] = {name = "barbarian headsplitter", type = 253, head = 115, body = 86, legs = 119, feet = 113},
	[334] = {name = "frost giantess", type = 265, head = 0, body = 0, legs = 0, feet = 0},
	[335] = {name = "dire penguin", type = 250, head = 0, body = 0, legs = 0, feet = 0},
	[371] = {name = "dark magician", type = 133, head = 58, body = 95, legs = 51, feet = 131},
	[372] = {name = "dark apprentice", type = 133, head = 78, body = 57, legs = 95, feet = 115},
	[376] = {name = "poacher", type = 129, head = 60, body = 118, legs = 118, feet = 116},
	[377] = {name = "goblin leader", type = 61, head = 0, body = 0, legs = 0, feet = 0},
	[379] = {name = "dwarf henchman", type = 160, head = 115, body = 77, legs = 93, feet = 114},
	[383] = {name = "dryad", type = 137, head = 99, body = 41, legs = 5, feet = 102},
	[384] = {name = "squirrel", type = 274, head = 0, body = 0, legs = 0, feet = 0},
	[385] = {name = "dragon hatchling", type = 271, head = 0, body = 0, legs = 0, feet = 0},
	[386] = {name = "dragon lord hatchling", type = 272, head = 0, body = 0, legs = 0, feet = 0},
	[387] = {name = "cat", type = 276, head = 0, body = 0, legs = 0, feet = 0},
	[388] = {name = "undead jester", type = 273, head = 0, body = 0, legs = 114, feet = 0},
	[389] = {name = "cyclops smith", type = 277, head = 0, body = 0, legs = 0, feet = 0},
	[391] = {name = "cyclops drone", type = 280, head = 0, body = 0, legs = 0, feet = 0},
	[392] = {name = "troll champion", type = 281, head = 0, body = 0, legs = 0, feet = 0},
	[393] = {name = "grynch clan goblin", type = 61, head = 0, body = 0, legs = 0, feet = 0},
	[402] = {name = "frost dragon hatchling", type = 283, head = 0, body = 0, legs = 0, feet = 0},
	[437] = {name = "deepsea blood crab", type = 200, head = 0, body = 0, legs = 0, feet = 0},
	[438] = {name = "sea serpent", type = 275, head = 0, body = 0, legs = 0, feet = 0},
	[439] = {name = "young sea serpent", type = 317, head = 0, body = 0, legs = 0, feet = 0},
	[446] = {name = "skeleton warrior", type = 298, head = 0, body = 0, legs = 0, feet = 0},
	[455] = {name = "massive earth elemental", type = 285, head = 0, body = 0, legs = 0, feet = 0},
	[456] = {name = "massive energy elemental", type = 290, head = 0, body = 0, legs = 0, feet = 0},
	[457] = {name = "energy elemental", type = 293, head = 0, body = 0, legs = 0, feet = 0},
	[458] = {name = "earth elemental", type = 301, head = 0, body = 0, legs = 0, feet = 0},
	[460] = {name = "bog raider", type = 299, head = 0, body = 0, legs = 0, feet = 0},
	[461] = {name = "wyrm", type = 291, head = 0, body = 0, legs = 0, feet = 0},
	[462] = {name = "wisp", type = 294, head = 0, body = 0, legs = 0, feet = 0},
	[463] = {name = "goblin assassin", type = 296, head = 0, body = 0, legs = 0, feet = 0},
	[464] = {name = "goblin scavenger", type = 297, head = 0, body = 0, legs = 0, feet = 0},
	[465] = {name = "grim reaper", type = 300, head = 0, body = 0, legs = 0, feet = 0},
	[483] = {name = "vampire bride", type = 312, head = 0, body = 0, legs = 0, feet = 0},
	[502] = {name = "mutated rat", type = 305, head = 0, body = 0, legs = 0, feet = 0},
	[503] = {name = "worker golem", type = 304, head = 0, body = 0, legs = 0, feet = 0},
	[508] = {name = "undead gladiator", type = 306, head = 0, body = 0, legs = 0, feet = 0},
	[509] = {name = "mutated bat", type = 307, head = 0, body = 0, legs = 0, feet = 0},
	[510] = {name = "werewolf", type = 308, head = 0, body = 0, legs = 0, feet = 0},
	[511] = {name = "haunted treeling", type = 310, head = 0, body = 0, legs = 0, feet = 0},
	[512] = {name = "zombie", type = 311, head = 0, body = 0, legs = 0, feet = 0},
	[513] = {name = "acid blob", type = 314, head = 0, body = 0, legs = 0, feet = 0},
	[514] = {name = "death blob", type = 315, head = 0, body = 0, legs = 0, feet = 0},
	[515] = {name = "mercury blob", type = 316, head = 0, body = 0, legs = 0, feet = 0},
	[516] = {name = "mutated tiger", type = 318, head = 0, body = 0, legs = 0, feet = 0},
	[518] = {name = "nightmare scion", type = 321, head = 0, body = 0, legs = 0, feet = 0},
	[519] = {name = "hellspawn", type = 322, head = 0, body = 0, legs = 0, feet = 0},
	[520] = {name = "nightstalker", type = 320, head = 0, body = 0, legs = 0, feet = 0},
	[521] = {name = "mutated human", type = 323, head = 0, body = 0, legs = 0, feet = 0},
	[523] = {name = "gozzler", type = 313, head = 0, body = 0, legs = 0, feet = 0},
	[524] = {name = "damaged worker golem", type = 304, head = 0, body = 0, legs = 0, feet = 0},
	[525] = {name = "crazed beggar", type = 153, head = 40, body = 19, legs = 21, feet = 97},
	[526] = {name = "gang member", type = 151, head = 114, body = 19, legs = 23, feet = 40},
	[527] = {name = "gladiator", type = 131, head = 78, body = 3, legs = 79, feet = 114},
	[528] = {name = "mad scientist", type = 133, head = 39, body = 0, legs = 19, feet = 20},
	[529] = {name = "infernalist", type = 130, head = 78, body = 76, legs = 94, feet = 39},
	[533] = {name = "war golem", type = 326, head = 0, body = 0, legs = 0, feet = 0},
	[540] = {name = "furious troll", type = 281, head = 0, body = 0, legs = 0, feet = 0},
	[541] = {name = "troll legionnaire", type = 53, head = 0, body = 0, legs = 0, feet = 0},
	[555] = {name = "evil sheep", type = 14, head = 0, body = 0, legs = 0, feet = 0},
	[556] = {name = "evil sheep lord", type = 13, head = 0, body = 0, legs = 0, feet = 0},
	[557] = {name = "hot dog", type = 32, head = 0, body = 0, legs = 0, feet = 0},
	[558] = {name = "vampire pig", type = 60, head = 0, body = 0, legs = 0, feet = 0},
	[559] = {name = "doom deer", type = 31, head = 0, body = 0, legs = 0, feet = 0},
	[560] = {name = "killer rabbit", type = 74, head = 0, body = 0, legs = 0, feet = 0},
	[561] = {name = "berserker chicken", type = 111, head = 0, body = 0, legs = 0, feet = 0},
	[562] = {name = "demon parrot", type = 217, head = 0, body = 0, legs = 0, feet = 0},
	[563] = {name = "infernal frog", type = 224, head = 0, body = 0, legs = 0, feet = 0},
	[570] = {name = "medusa", type = 330, head = 0, body = 0, legs = 0, feet = 0},
	[578] = {name = "acolyte of darkness", type = 9, head = 0, body = 0, legs = 0, feet = 0},
	[579] = {name = "nightslayer", type = 152, head = 95, body = 95, legs = 95, feet = 95},
	[580] = {name = "bane of light", type = 68, head = 0, body = 0, legs = 0, feet = 0},
	[581] = {name = "duskbringer", type = 300, head = 0, body = 0, legs = 0, feet = 0},
	[582] = {name = "shadow hound", type = 322, head = 0, body = 0, legs = 0, feet = 0},
	[583] = {name = "doomsday cultist", type = 194, head = 95, body = 76, legs = 95, feet = 76},
	[584] = {name = "midnight spawn", type = 315, head = 0, body = 0, legs = 0, feet = 0},
	[585] = {name = "midnight warrior", type = 268, head = 95, body = 95, legs = 95, feet = 95},
	[586] = {name = "herald of gloom", type = 320, head = 0, body = 0, legs = 0, feet = 0},
	[587] = {name = "bride of night", type = 58, head = 0, body = 0, legs = 0, feet = 0},
	[594] = {name = "undead mine worker", type = 33, head = 0, body = 0, legs = 0, feet = 0},
	[595] = {name = "undead prospector", type = 18, head = 0, body = 0, legs = 0, feet = 0},
	[614] = {name = "orc marauder", type = 342, head = 0, body = 0, legs = 0, feet = 0},
	[615] = {name = "eternal guardian", type = 345, head = 0, body = 0, legs = 0, feet = 0},
	[616] = {name = "lizard zaogun", type = 343, head = 0, body = 0, legs = 0, feet = 0},
	[617] = {name = "draken warmaster", type = 334, head = 0, body = 0, legs = 0, feet = 0},
	[618] = {name = "draken spellweaver", type = 340, head = 0, body = 0, legs = 0, feet = 0},
	[620] = {name = "lizard chosen", type = 344, head = 0, body = 0, legs = 0, feet = 0},
	[621] = {name = "insect swarm", type = 349, head = 0, body = 0, legs = 0, feet = 0},
	[623] = {name = "lizard dragon priest", type = 339, head = 0, body = 0, legs = 0, feet = 0},
	[624] = {name = "lizard legionnaire", type = 338, head = 0, body = 0, legs = 0, feet = 0},
	[625] = {name = "lizard high guard", type = 337, head = 0, body = 0, legs = 0, feet = 0},
	[627] = {name = "killer caiman", type = 358, head = 0, body = 0, legs = 0, feet = 0},
	[630] = {name = "gnarlhound", type = 341, head = 0, body = 0, legs = 0, feet = 0},
	[631] = {name = "terramite", type = 346, head = 0, body = 0, legs = 0, feet = 0},
	[632] = {name = "wailing widow", type = 347, head = 0, body = 0, legs = 0, feet = 0},
	[633] = {name = "lancer beetle", type = 348, head = 0, body = 0, legs = 0, feet = 0},
	[641] = {name = "sandcrawler", type = 350, head = 0, body = 0, legs = 0, feet = 0},
	[643] = {name = "ghastly dragon", type = 351, head = 0, body = 0, legs = 0, feet = 0},
	[655] = {name = "lizard magistratus", type = 115, head = 0, body = 0, legs = 0, feet = 0},
	[656] = {name = "lizard noble", type = 115, head = 0, body = 0, legs = 0, feet = 0},
	[672] = {name = "draken elite", type = 362, head = 0, body = 0, legs = 0, feet = 0},
	[673] = {name = "draken abomination", type = 357, head = 0, body = 0, legs = 0, feet = 0},
	[674] = {name = "brimstone bug", type = 352, head = 0, body = 0, legs = 0, feet = 0},
	[675] = {name = "souleater", type = 355, head = 0, body = 0, legs = 0, feet = 0},
	[679] = {name = "bane bringer", type = 310, head = 0, body = 0, legs = 0, feet = 0},
	[691] = {name = "berrypest", type = 349, head = 0, body = 0, legs = 0, feet = 0},
	[693] = {name = "boar", type = 380, head = 0, body = 0, legs = 0, feet = 0},
	[694] = {name = "stampor", type = 381, head = 0, body = 0, legs = 0, feet = 0},
	[695] = {name = "draptor", type = 382, head = 0, body = 0, legs = 0, feet = 0},
	[696] = {name = "undead cavebear", type = 384, head = 0, body = 0, legs = 0, feet = 0},
	[697] = {name = "crustacea gigantica", type = 383, head = 0, body = 0, legs = 0, feet = 0},
	[698] = {name = "midnight panther", type = 385, head = 0, body = 0, legs = 0, feet = 0},
	[700] = {name = "iron servant", type = 395, head = 0, body = 0, legs = 0, feet = 0},
	[701] = {name = "golden servant", type = 396, head = 0, body = 0, legs = 0, feet = 0},
	[702] = {name = "diamond servant", type = 397, head = 0, body = 0, legs = 0, feet = 0},
	[704] = {name = "ghoulish hyaena", type = 94, head = 0, body = 0, legs = 0, feet = 0},
	[705] = {name = "sandstone scorpion", type = 398, head = 0, body = 0, legs = 0, feet = 0},
	[706] = {name = "clay guardian", type = 333, head = 0, body = 0, legs = 0, feet = 0},
	[707] = {name = "grave guard", type = 234, head = 0, body = 0, legs = 0, feet = 0},
	[708] = {name = "tomb servant", type = 100, head = 0, body = 0, legs = 0, feet = 0},
	[709] = {name = "sacred spider", type = 219, head = 0, body = 0, legs = 0, feet = 0},
	[710] = {name = "death priest", type = 99, head = 0, body = 0, legs = 0, feet = 0},
	[711] = {name = "elder mummy", type = 65, head = 0, body = 0, legs = 0, feet = 0},
	[712] = {name = "honour guard", type = 298, head = 0, body = 0, legs = 0, feet = 0},
	[717] = {name = "yielothax", type = 408, head = 0, body = 0, legs = 0, feet = 0},
	[719] = {name = "feverish citizen", type = 425, head = 0, body = 0, legs = 0, feet = 0},
	[720] = {name = "white deer", type = 400, head = 0, body = 0, legs = 0, feet = 0},
	[723] = {name = "starving wolf", type = 27, head = 0, body = 0, legs = 0, feet = 0},
	[724] = {name = "shaburak demon", type = 417, head = 0, body = 0, legs = 0, feet = 0},
	[725] = {name = "shaburak lord", type = 409, head = 0, body = 0, legs = 0, feet = 0},
	[726] = {name = "shaburak prince", type = 418, head = 0, body = 0, legs = 0, feet = 0},
	[727] = {name = "askarak demon", type = 420, head = 0, body = 0, legs = 0, feet = 0},
	[728] = {name = "askarak lord", type = 410, head = 0, body = 0, legs = 0, feet = 0},
	[729] = {name = "askarak prince", type = 419, head = 0, body = 0, legs = 0, feet = 0},
	[730] = {name = "wild horse", type = 393, head = 0, body = 0, legs = 0, feet = 0},
	[731] = {name = "slug", type = 407, head = 0, body = 0, legs = 0, feet = 0},
	[732] = {name = "insectoid scout", type = 403, head = 0, body = 0, legs = 0, feet = 0},
	[733] = {name = "dromedary", type = 404, head = 0, body = 0, legs = 0, feet = 0},
	[734] = {name = "deepling scout", type = 413, head = 0, body = 0, legs = 0, feet = 0},
	[737] = {name = "firestarter", type = 159, head = 94, body = 77, legs = 78, feet = 79},
	[738] = {name = "bog frog", type = 412, head = 0, body = 0, legs = 0, feet = 0},
	[739] = {name = "thornfire wolf", type = 414, head = 0, body = 0, legs = 0, feet = 0},
	[740] = {name = "crystal wolf", type = 391, head = 0, body = 0, legs = 0, feet = 0},
	[741] = {name = "elf overseer", type = 159, head = 21, body = 76, legs = 95, feet = 116},
	[745] = {name = "troll guard", type = 281, head = 0, body = 0, legs = 0, feet = 0},
	[750] = {name = "horse", type = 434, head = 0, body = 0, legs = 0, feet = 0},
	[751] = {name = "horse", type = 436, head = 0, body = 0, legs = 0, feet = 0},
	[752] = {name = "horse", type = 435, head = 0, body = 0, legs = 0, feet = 0},
	[769] = {name = "deepling warrior", type = 441, head = 0, body = 0, legs = 0, feet = 0},
	[770] = {name = "deepling guard", type = 442, head = 0, body = 0, legs = 0, feet = 0},
	[772] = {name = "deepling spellsinger", type = 443, head = 0, body = 0, legs = 0, feet = 0},
	[776] = {name = "nomad", type = 146, head = 104, body = 48, legs = 49, feet = 3},
	[777] = {name = "nomad", type = 150, head = 96, body = 39, legs = 40, feet = 3},
	[778] = {name = "ladybug", type = 448, head = 0, body = 0, legs = 0, feet = 0},
	[779] = {name = "manta ray", type = 449, head = 0, body = 0, legs = 0, feet = 0},
	[780] = {name = "calamary", type = 451, head = 0, body = 0, legs = 0, feet = 0},
	[781] = {name = "jellyfish", type = 452, head = 0, body = 0, legs = 0, feet = 0},
	[782] = {name = "shark", type = 453, head = 0, body = 0, legs = 0, feet = 0},
	[783] = {name = "northern pike", type = 454, head = 0, body = 0, legs = 0, feet = 0},
	[784] = {name = "fish", type = 455, head = 0, body = 0, legs = 0, feet = 0},
	[786] = {name = "crawler", type = 456, head = 0, body = 0, legs = 0, feet = 0},
	[787] = {name = "spidris", type = 457, head = 0, body = 0, legs = 0, feet = 0},
	[788] = {name = "kollos", type = 458, head = 0, body = 0, legs = 0, feet = 0},
	[790] = {name = "swarmer", type = 460, head = 0, body = 0, legs = 0, feet = 0},
	[791] = {name = "spitter", type = 461, head = 0, body = 0, legs = 0, feet = 0},
	[792] = {name = "waspoid", type = 462, head = 0, body = 0, legs = 0, feet = 0},
	[795] = {name = "deepling worker", type = 470, head = 0, body = 0, legs = 0, feet = 0},
	[796] = {name = "insectoid worker", type = 403, head = 0, body = 0, legs = 0, feet = 0},
	[797] = {name = "spidris elite", type = 457, head = 0, body = 0, legs = 0, feet = 0},
	[801] = {name = "hive overseer", type = 458, head = 0, body = 0, legs = 0, feet = 0},
	[859] = {name = "deepling brawler", type = 470, head = 0, body = 0, legs = 0, feet = 0},
	[860] = {name = "deepling master librarian", type = 443, head = 0, body = 0, legs = 0, feet = 0},
	[861] = {name = "deepling tyrant", type = 442, head = 0, body = 0, legs = 0, feet = 0},
	[862] = {name = "deepling elite", type = 441, head = 0, body = 0, legs = 0, feet = 0},
	[867] = {name = "grave robber", type = 146, head = 57, body = 95, legs = 57, feet = 19},
	[868] = {name = "crypt defiler", type = 146, head = 62, body = 132, legs = 42, feet = 75},
	[869] = {name = "crystalcrusher", type = 511, head = 0, body = 0, legs = 0, feet = 0},
	[870] = {name = "mushroom sniffer", type = 60, head = 0, body = 0, legs = 0, feet = 0},
	[872] = {name = "water buffalo", type = 523, head = 0, body = 0, legs = 0, feet = 0},
	[873] = {name = "enraged crystal golem", type = 508, head = 0, body = 0, legs = 0, feet = 0},
	[874] = {name = "damaged crystal golem", type = 508, head = 0, body = 0, legs = 0, feet = 0},
	[877] = {name = "modified gnarlhound", type = 515, head = 0, body = 0, legs = 0, feet = 0},
	[878] = {name = "drillworm", type = 527, head = 0, body = 0, legs = 0, feet = 0},
	[879] = {name = "stone devourer", type = 486, head = 0, body = 0, legs = 0, feet = 0},
	[880] = {name = "armadile", type = 487, head = 0, body = 0, legs = 0, feet = 0},
	[881] = {name = "humongous fungus", type = 488, head = 0, body = 0, legs = 0, feet = 0},
	[882] = {name = "weeper", type = 489, head = 0, body = 0, legs = 0, feet = 0},
	[883] = {name = "orewalker", type = 490, head = 0, body = 0, legs = 0, feet = 0},
	[884] = {name = "lava golem", type = 491, head = 0, body = 0, legs = 0, feet = 0},
	[885] = {name = "magma crawler", type = 492, head = 0, body = 0, legs = 0, feet = 0},
	[886] = {name = "enslaved dwarf", type = 494, head = 0, body = 0, legs = 0, feet = 0},
	[888] = {name = "lost berserker", type = 496, head = 0, body = 0, legs = 0, feet = 0},
	[889] = {name = "cliff strider", type = 497, head = 0, body = 0, legs = 0, feet = 0},
	[890] = {name = "ironblight", type = 498, head = 0, body = 0, legs = 0, feet = 0},
	[891] = {name = "hideous fungus", type = 499, head = 0, body = 0, legs = 0, feet = 0},
	[894] = {name = "dragonling", type = 505, head = 0, body = 0, legs = 0, feet = 0},
	[897] = {name = "infected weeper", type = 489, head = 0, body = 0, legs = 0, feet = 0},
	[898] = {name = "vulcongra", type = 509, head = 0, body = 0, legs = 0, feet = 0},
	[899] = {name = "wiggler", type = 510, head = 0, body = 0, legs = 0, feet = 0},
	[912] = {name = "emerald damselfly", type = 528, head = 0, body = 0, legs = 0, feet = 0},
	[913] = {name = "salamander", type = 529, head = 0, body = 0, legs = 0, feet = 0},
	[914] = {name = "marsh stalker", type = 530, head = 0, body = 0, legs = 0, feet = 0},
	[915] = {name = "pigeon", type = 531, head = 0, body = 0, legs = 0, feet = 0},
	[916] = {name = "corym charlatan", type = 532, head = 0, body = 78, legs = 59, feet = 0},
	[917] = {name = "corym skirmisher", type = 533, head = 0, body = 76, legs = 83, feet = 0},
	[918] = {name = "corym vanguard", type = 534, head = 0, body = 19, legs = 121, feet = 0},
	[919] = {name = "swampling", type = 535, head = 0, body = 0, legs = 0, feet = 0},
	[920] = {name = "little corym charlatan", type = 532, head = 0, body = 79, legs = 80, feet = 0},
	[922] = {name = "adventurer", type = 129, head = 93, body = 15, legs = 72, feet = 80},
	[924] = {name = "lost husher", type = 537, head = 0, body = 0, legs = 0, feet = 0},
	[925] = {name = "lost basher", type = 538, head = 0, body = 0, legs = 0, feet = 0},
	[926] = {name = "lost thrower", type = 539, head = 0, body = 0, legs = 0, feet = 0},
	[958] = {name = "vampire viscount", type = 555, head = 0, body = 0, legs = 0, feet = 0},
	[959] = {name = "vicious manbat", type = 554, head = 0, body = 0, legs = 0, feet = 0},
	[960] = {name = "shadow pupil", type = 551, head = 0, body = 0, legs = 0, feet = 0},
	[961] = {name = "blood priest", type = 553, head = 0, body = 0, legs = 0, feet = 0},
	[962] = {name = "white shade", type = 560, head = 0, body = 0, legs = 0, feet = 0},
	[963] = {name = "elder wyrm", type = 561, head = 0, body = 0, legs = 0, feet = 0},
	[973] = {name = "nightfiend", type = 556, head = 0, body = 0, legs = 0, feet = 0},
	[974] = {name = "blood hand", type = 552, head = 0, body = 0, legs = 0, feet = 0},
	[975] = {name = "gravedigger", type = 558, head = 0, body = 0, legs = 0, feet = 0},
	[976] = {name = "tarnished spirit", type = 566, head = 0, body = 0, legs = 0, feet = 0},
	[978] = {name = "rorc", type = 550, head = 0, body = 0, legs = 0, feet = 0},
	[979] = {name = "leaf golem", type = 567, head = 0, body = 0, legs = 0, feet = 0},
	[980] = {name = "forest fury", type = 569, head = 0, body = 0, legs = 0, feet = 0},
	[981] = {name = "roaring lion", type = 570, head = 0, body = 0, legs = 0, feet = 0},
	[982] = {name = "wilting leaf golem", type = 573, head = 0, body = 0, legs = 0, feet = 0},
	[1000] = {name = "furious fire elemental", type = 49, head = 0, body = 0, legs = 0, feet = 0},
	[1004] = {name = "shock head", type = 579, head = 0, body = 0, legs = 0, feet = 0},
	[1012] = {name = "sight of surrender", type = 583, head = 0, body = 0, legs = 0, feet = 0},
	[1013] = {name = "guzzlemaw", type = 584, head = 0, body = 0, legs = 0, feet = 0},
	[1014] = {name = "silencer", type = 585, head = 0, body = 0, legs = 0, feet = 0},
	[1015] = {name = "choking fear", type = 586, head = 0, body = 0, legs = 0, feet = 0},
	[1016] = {name = "terrorsleep", type = 587, head = 0, body = 0, legs = 0, feet = 0},
	[1018] = {name = "retching horror", type = 588, head = 0, body = 0, legs = 0, feet = 0},
	[1019] = {name = "demon outcast", type = 590, head = 0, body = 0, legs = 0, feet = 0},
	[1021] = {name = "feversleep", type = 593, head = 0, body = 0, legs = 0, feet = 0},
	[1022] = {name = "frazzlemaw", type = 594, head = 0, body = 0, legs = 0, feet = 0},
	[1038] = {name = "glooth golem", type = 600, head = 0, body = 0, legs = 0, feet = 0},
	[1039] = {name = "metal gargoyle", type = 601, head = 0, body = 0, legs = 0, feet = 0},
	[1040] = {name = "blood beast", type = 602, head = 0, body = 0, legs = 0, feet = 0},
	[1041] = {name = "rustheap golem", type = 603, head = 0, body = 0, legs = 0, feet = 0},
	[1042] = {name = "glooth anemone", type = 604, head = 0, body = 0, legs = 0, feet = 0},
	[1043] = {name = "walker", type = 605, head = 0, body = 0, legs = 0, feet = 0},
	[1044] = {name = "moohtant", type = 607, head = 0, body = 0, legs = 0, feet = 0},
	[1045] = {name = "minotaur amazon", type = 608, head = 0, body = 0, legs = 0, feet = 0},
	[1046] = {name = "execowtioner", type = 609, head = 0, body = 0, legs = 0, feet = 0},
	[1051] = {name = "mooh'tah warrior", type = 611, head = 0, body = 0, legs = 0, feet = 0},
	[1052] = {name = "minotaur hunter", type = 612, head = 0, body = 0, legs = 0, feet = 0},
	[1053] = {name = "worm priestess", type = 613, head = 0, body = 0, legs = 0, feet = 0},
	[1054] = {name = "glooth blob", type = 614, head = 0, body = 0, legs = 0, feet = 0},
	[1055] = {name = "rot elemental", type = 615, head = 0, body = 0, legs = 0, feet = 0},
	[1056] = {name = "devourer", type = 617, head = 0, body = 0, legs = 0, feet = 0},
	[1096] = {name = "seacrest serpent", type = 675, head = 0, body = 0, legs = 0, feet = 0},
	[1097] = {name = "renegade quara constrictor", type = 46, head = 0, body = 0, legs = 0, feet = 0},
	[1098] = {name = "renegade quara hydromancer", type = 47, head = 0, body = 0, legs = 0, feet = 0},
	[1099] = {name = "renegade quara mantassin", type = 72, head = 0, body = 0, legs = 0, feet = 0},
	[1100] = {name = "renegade quara pincher", type = 77, head = 0, body = 0, legs = 0, feet = 0},
	[1101] = {name = "renegade quara predator", type = 20, head = 0, body = 0, legs = 0, feet = 0},
	[1105] = {name = "abyssal calamary", type = 451, head = 0, body = 0, legs = 0, feet = 0},
	[1109] = {name = "minotaur invader", type = 29, head = 0, body = 0, legs = 0, feet = 0},
	[1116] = {name = "high voltage elemental", type = 293, head = 0, body = 0, legs = 0, feet = 0},
	[1118] = {name = "noble lion", type = 570, head = 0, body = 0, legs = 0, feet = 0},
	[1119] = {name = "glooth bandit", type = 129, head = 115, body = 80, legs = 114, feet = 114},
	[1120] = {name = "glooth brigand", type = 137, head = 114, body = 114, legs = 110, feet = 114},
	[1121] = {name = "raging fire", type = 242, head = 0, body = 0, legs = 0, feet = 0},
	[1134] = {name = "dawnfire asura", type = 150, head = 114, body = 94, legs = 78, feet = 79},
	[1135] = {name = "midnight asura", type = 150, head = 0, body = 114, legs = 90, feet = 90},
	[1137] = {name = "tainted soul", type = 712, head = 0, body = 0, legs = 0, feet = 0},
	[1138] = {name = "redeemed soul", type = 714, head = 0, body = 0, legs = 0, feet = 0},
	[1139] = {name = "gloom wolf", type = 716, head = 0, body = 0, legs = 0, feet = 0},
	[1141] = {name = "omnivora", type = 717, head = 0, body = 0, legs = 0, feet = 0},
	[1142] = {name = "werebear", type = 720, head = 0, body = 0, legs = 0, feet = 0},
	[1143] = {name = "wereboar", type = 721, head = 0, body = 0, legs = 0, feet = 0},
	[1144] = {name = "werebadger", type = 729, head = 0, body = 0, legs = 0, feet = 0},
	[1145] = {name = "vicious squire", type = 131, head = 97, body = 24, legs = 73, feet = 116},
	[1146] = {name = "renegade knight", type = 268, head = 97, body = 113, legs = 76, feet = 98},
	[1147] = {name = "vile grandmaster", type = 268, head = 59, body = 19, legs = 95, feet = 94},
	[1148] = {name = "ghost wolf", type = 730, head = 0, body = 0, legs = 0, feet = 0},
	[1157] = {name = "elder forest fury", type = 569, head = 0, body = 0, legs = 0, feet = 0},
	[1161] = {name = "ogre brute", type = 857, head = 0, body = 0, legs = 0, feet = 0},
	[1162] = {name = "ogre savage", type = 858, head = 0, body = 0, legs = 0, feet = 0},
	[1163] = {name = "ogre shaman", type = 859, head = 0, body = 0, legs = 0, feet = 0},
	[1174] = {name = "clomp", type = 860, head = 0, body = 0, legs = 0, feet = 0},
	[1196] = {name = "grimeleech", type = 855, head = 0, body = 0, legs = 0, feet = 0},
	[1197] = {name = "vexclaw", type = 854, head = 0, body = 0, legs = 0, feet = 0},
	[1198] = {name = "hellflayer", type = 856, head = 0, body = 0, legs = 0, feet = 0},
	[1224] = {name = "reality reaver", type = 879, head = 0, body = 0, legs = 0, feet = 0},
	[1234] = {name = "sparkion", type = 877, head = 0, body = 0, legs = 0, feet = 0},
	[1235] = {name = "breach brood", type = 878, head = 0, body = 0, legs = 0, feet = 0},
	[1260] = {name = "dread intruder", type = 882, head = 0, body = 0, legs = 0, feet = 0},
	[1264] = {name = "instable sparkion", type = 877, head = 0, body = 0, legs = 0, feet = 0},
	[1265] = {name = "instable breach brood", type = 878, head = 0, body = 0, legs = 0, feet = 0},
	[1266] = {name = "stabilizing reality reaver", type = 879, head = 0, body = 0, legs = 0, feet = 0},
	[1267] = {name = "stabilizing dread intruder", type = 882, head = 0, body = 0, legs = 0, feet = 0},
	[1307] = {name = "cave parrot", type = 217, head = 0, body = 0, legs = 0, feet = 0},
	[1314] = {name = "orclops doomhauler", type = 934, head = 0, body = 0, legs = 0, feet = 0},
	[1320] = {name = "orclops ravager", type = 935, head = 94, body = 1, legs = 80, feet = 94},
	[1321] = {name = "broken shaper", type = 932, head = 94, body = 76, legs = 0, feet = 82},
	[1322] = {name = "twisted shaper", type = 932, head = 105, body = 0, legs = 0, feet = 94},
	[1325] = {name = "iron servant replica", type = 395, head = 0, body = 0, legs = 0, feet = 0},
	[1326] = {name = "diamond servant replica", type = 397, head = 0, body = 0, legs = 0, feet = 0},
	[1327] = {name = "golden servant replica", type = 396, head = 0, body = 0, legs = 0, feet = 0},
	[1376] = {name = "haunted dragon", type = 231, head = 0, body = 0, legs = 0, feet = 0},
	[1380] = {name = "ice dragon", type = 947, head = 0, body = 9, legs = 0, feet = 0},
	[1394] = {name = "shaper matriarch", type = 933, head = 0, body = 0, legs = 0, feet = 0},
	[1395] = {name = "stone rhino", type = 936, head = 0, body = 0, legs = 0, feet = 0},
	[1412] = {name = "misguided bully", type = 159, head = 58, body = 21, legs = 41, feet = 76},
	[1413] = {name = "misguided thief", type = 684, head = 58, body = 40, legs = 60, feet = 116},
	[1415] = {name = "putrid mummy", type = 976, head = 0, body = 0, legs = 0, feet = 0},
	[1434] = {name = "faun", type = 980, head = 61, body = 96, legs = 95, feet = 62},
	[1435] = {name = "pooka", type = 977, head = 0, body = 0, legs = 0, feet = 0},
	[1436] = {name = "twisted pooka", type = 978, head = 0, body = 0, legs = 0, feet = 0},
	[1437] = {name = "swan maiden", type = 138, head = 0, body = 0, legs = 114, feet = 78},
	[1438] = {name = "pixie", type = 982, head = 0, body = 0, legs = 0, feet = 0},
	[1439] = {name = "boogy", type = 981, head = 0, body = 0, legs = 0, feet = 0},
	[1442] = {name = "weakened frazzlemaw", type = 594, head = 0, body = 0, legs = 0, feet = 0},
	[1443] = {name = "enfeebled silencer", type = 585, head = 0, body = 0, legs = 0, feet = 0},
	[1481] = {name = "goldhanded cultist", type = 132, head = 114, body = 79, legs = 62, feet = 94},
	[1482] = {name = "goldhanded cultist bride", type = 140, head = 114, body = 79, legs = 62, feet = 94},
	[1485] = {name = "nymph", type = 989, head = 0, body = 0, legs = 0, feet = 0},
	[1486] = {name = "barkless devotee", type = 990, head = 0, body = 0, legs = 0, feet = 0},
	[1488] = {name = "barkless fanatic", type = 990, head = 0, body = 0, legs = 0, feet = 0},
	[1496] = {name = "dark faun", type = 980, head = 94, body = 95, legs = 0, feet = 94},
	[1503] = {name = "orc cultist", type = 7, head = 0, body = 0, legs = 0, feet = 0},
	[1504] = {name = "orc cult priest", type = 6, head = 0, body = 0, legs = 0, feet = 0},
	[1505] = {name = "orc cult inquisitor", type = 8, head = 0, body = 0, legs = 0, feet = 0},
	[1506] = {name = "orc cult fanatic", type = 59, head = 0, body = 0, legs = 0, feet = 0},
	[1507] = {name = "orc cult minion", type = 50, head = 0, body = 0, legs = 0, feet = 0},
	[1508] = {name = "minotaur cult follower", type = 25, head = 0, body = 0, legs = 0, feet = 0},
	[1509] = {name = "minotaur cult prophet", type = 23, head = 0, body = 0, legs = 0, feet = 0},
	[1510] = {name = "minotaur cult zealot", type = 29, head = 0, body = 0, legs = 0, feet = 0},
	[1512] = {name = "cult believer", type = 132, head = 98, body = 96, legs = 39, feet = 38},
	[1513] = {name = "cult enforcer", type = 134, head = 95, body = 19, legs = 57, feet = 76},
	[1514] = {name = "cult scholar", type = 145, head = 19, body = 77, legs = 3, feet = 20},
	[1525] = {name = "stonerefiner", type = 1032, head = 0, body = 0, legs = 0, feet = 0},
	[1529] = {name = "lost exile", type = 537, head = 0, body = 0, legs = 0, feet = 0},
	[1531] = {name = "deepworm", type = 1033, head = 0, body = 0, legs = 0, feet = 0},
	[1532] = {name = "diremaw", type = 1034, head = 0, body = 0, legs = 0, feet = 0},
	[1544] = {name = "cave devourer", type = 1036, head = 0, body = 0, legs = 0, feet = 0},
	[1545] = {name = "tunnel tyrant", type = 1035, head = 0, body = 0, legs = 0, feet = 0},
	[1546] = {name = "chasm spawn", type = 1037, head = 0, body = 0, legs = 0, feet = 0},
	[1548] = {name = "fox", type = 1029, head = 0, body = 0, legs = 0, feet = 0},
	[1549] = {name = "werefox", type = 1030, head = 0, body = 0, legs = 0, feet = 0},
	[1563] = {name = "lava lurker", type = 1041, head = 0, body = 0, legs = 0, feet = 0},
	[1569] = {name = "ravenous lava lurker", type = 1041, head = 0, body = 0, legs = 0, feet = 0},
	[1570] = {name = "mole", type = 1048, head = 0, body = 0, legs = 0, feet = 0},
	[1619] = {name = "frost flower asura", type = 150, head = 0, body = 0, legs = 0, feet = 86},
	[1620] = {name = "true dawnfire asura", type = 1068, head = 114, body = 94, legs = 79, feet = 121},
	[1621] = {name = "true midnight asura", type = 1068, head = 0, body = 76, legs = 53, feet = 0},
	[1622] = {name = "true frost flower asura", type = 1068, head = 9, body = 0, legs = 86, feet = 9},
	[1626] = {name = "arctic faun", type = 980, head = 85, body = 0, legs = 0, feet = 85},
	[1637] = {name = "floating savant", type = 1063, head = 113, body = 94, legs = 78, feet = 78},
	[1646] = {name = "falcon knight", type = 1071, head = 57, body = 96, legs = 38, feet = 105},
	[1647] = {name = "falcon paladin", type = 1071, head = 57, body = 96, legs = 38, feet = 105},
	[1653] = {name = "brain squid", type = 1059, head = 17, body = 41, legs = 77, feet = 57},
	[1654] = {name = "flying book", type = 1060, head = 0, body = 0, legs = 0, feet = 0},
	[1655] = {name = "cursed book", type = 1061, head = 79, body = 81, legs = 93, feet = 0},
	[1656] = {name = "biting book", type = 1066, head = 0, body = 0, legs = 0, feet = 0},
	[1658] = {name = "ink blob", type = 1064, head = 0, body = 0, legs = 0, feet = 0},
	[1659] = {name = "guardian of tales", type = 1063, head = 92, body = 52, legs = 0, feet = 79},
	[1663] = {name = "burning book", type = 1061, head = 79, body = 113, legs = 78, feet = 112},
	[1664] = {name = "icecold book", type = 1061, head = 87, body = 85, legs = 79, feet = 0},
	[1665] = {name = "energetic book", type = 1061, head = 15, body = 91, legs = 85, feet = 0},
	[1666] = {name = "energuardian of tales", type = 1063, head = 86, body = 85, legs = 82, feet = 93},
	[1667] = {name = "deathling scout", type = 1073, head = 0, body = 0, legs = 0, feet = 0},
	[1668] = {name = "rage squid", type = 1059, head = 94, body = 78, legs = 79, feet = 57},
	[1669] = {name = "squid warden", type = 1059, head = 9, body = 21, legs = 3, feet = 57},
	[1670] = {name = "knowledge elemental", type = 1065, head = 0, body = 0, legs = 0, feet = 0},
	[1671] = {name = "animated feather", type = 1058, head = 0, body = 0, legs = 0, feet = 0},
	[1674] = {name = "skeleton elite warrior", type = 298, head = 0, body = 0, legs = 0, feet = 0},
	[1675] = {name = "undead elite gladiator", type = 306, head = 0, body = 0, legs = 0, feet = 0},
	[1677] = {name = "deathling spellsinger", type = 1088, head = 0, body = 0, legs = 0, feet = 0},
	[1721] = {name = "lumbering carnivor", type = 1133, head = 0, body = 59, legs = 67, feet = 85},
	[1722] = {name = "spiky carnivor", type = 1139, head = 79, body = 121, legs = 23, feet = 86},
	[1723] = {name = "menacing carnivor", type = 1138, head = 86, body = 51, legs = 83, feet = 91},
	[1724] = {name = "ripper spectre", type = 1122, head = 81, body = 78, legs = 61, feet = 94},
	[1725] = {name = "gazer spectre", type = 1122, head = 94, body = 21, legs = 77, feet = 78},
	[1726] = {name = "burster spectre", type = 1122, head = 9, body = 10, legs = 86, feet = 79},
	[1728] = {name = "thanatursus", type = 1134, head = 0, body = 0, legs = 0, feet = 0},
	[1729] = {name = "arachnophobica", type = 1135, head = 0, body = 0, legs = 0, feet = 0},
	[1730] = {name = "crazed winter vanguard", type = 1137, head = 8, body = 67, legs = 8, feet = 1},
	[1731] = {name = "crazed winter rearguard", type = 1136, head = 47, body = 7, legs = 0, feet = 85},
	[1732] = {name = "crazed summer vanguard", type = 1137, head = 114, body = 93, legs = 3, feet = 83},
	[1733] = {name = "crazed summer rearguard", type = 1136, head = 114, body = 94, legs = 3, feet = 121},
	[1734] = {name = "soul-broken harbinger", type = 1137, head = 85, body = 10, legs = 16, feet = 83},
	[1735] = {name = "insane siren", type = 1136, head = 72, body = 94, legs = 79, feet = 4},
	[1736] = {name = "lacewing moth", type = 1148, head = 0, body = 0, legs = 0, feet = 0},
	[1737] = {name = "hibernal moth", type = 1149, head = 0, body = 0, legs = 0, feet = 0},
	[1740] = {name = "percht", type = 1161, head = 95, body = 42, legs = 21, feet = 20},
	[1741] = {name = "schiach", type = 1162, head = 0, body = 10, legs = 38, feet = 57},
	[1742] = {name = "baleful bunny", type = 1157, head = 0, body = 0, legs = 0, feet = 0},
	[1751] = {name = "animated snowman", type = 1159, head = 0, body = 0, legs = 0, feet = 0},
	[1775] = {name = "cobra assassin", type = 1217, head = 2, body = 2, legs = 77, feet = 19},
	[1776] = {name = "cobra scout", type = 1217, head = 1, body = 1, legs = 102, feet = 78},
	[1798] = {name = "burning gladiator", type = 541, head = 95, body = 113, legs = 3, feet = 3},
	[1799] = {name = "priestess of the wild sun", type = 1199, head = 95, body = 78, legs = 94, feet = 3},
	[1800] = {name = "black sphinx acolyte", type = 1200, head = 95, body = 95, legs = 94, feet = 95},
	[1805] = {name = "crypt warden", type = 1190, head = 41, body = 38, legs = 0, feet = 0},
	[1806] = {name = "lamassu", type = 1190, head = 50, body = 2, legs = 0, feet = 76},
	[1807] = {name = "feral sphinx", type = 1188, head = 76, body = 75, legs = 57, feet = 0},
	[1808] = {name = "sphinx", type = 1188, head = 0, body = 39, legs = 0, feet = 3},
	[1816] = {name = "manticore", type = 1189, head = 116, body = 97, legs = 113, feet = 20},
	[1817] = {name = "young goanna", type = 1196, head = 0, body = 0, legs = 0, feet = 0},
	[1818] = {name = "adult goanna", type = 1195, head = 0, body = 0, legs = 0, feet = 0},
	[1819] = {name = "gryphon", type = 1220, head = 0, body = 0, legs = 0, feet = 0},
	[1820] = {name = "ogre ruffian", type = 1212, head = 0, body = 0, legs = 0, feet = 0},
	[1821] = {name = "ogre rowdy", type = 1213, head = 0, body = 0, legs = 0, feet = 0},
	[1822] = {name = "ogre sage", type = 1214, head = 0, body = 0, legs = 0, feet = 0},
	[1824] = {name = "cobra vizier", type = 1217, head = 19, body = 19, legs = 67, feet = 78},
	[1841] = {name = "orger", type = 1255, head = 79, body = 6, legs = 94, feet = 2},
	[1855] = {name = "roast pork", type = 1256, head = 0, body = 0, legs = 0, feet = 0},
	[1856] = {name = "cow", type = 1253, head = 0, body = 0, legs = 0, feet = 0},
	[1857] = {name = "loricate orger", type = 1255, head = 79, body = 6, legs = 94, feet = 2},
	[1858] = {name = "bellicose orger", type = 1255, head = 79, body = 6, legs = 94, feet = 2},
	[1864] = {name = "flimsy lost soul", type = 1268, head = 0, body = 6, legs = 0, feet = 116},
	[1865] = {name = "mean lost soul", type = 1268, head = 0, body = 14, legs = 0, feet = 83},
	[1866] = {name = "freakish lost soul", type = 1268, head = 0, body = 74, legs = 0, feet = 83},
	[1880] = {name = "cursed prospector", type = 1268, head = 0, body = 19, legs = 0, feet = 38},
	[1885] = {name = "evil prospector", type = 1268, head = 0, body = 14, legs = 0, feet = 34},
	[1926] = {name = "bony sea devil", type = 1294, head = 0, body = 0, legs = 0, feet = 0},
	[1927] = {name = "many faces", type = 1296, head = 0, body = 0, legs = 0, feet = 0},
	[1928] = {name = "cloak of terror", type = 1295, head = 0, body = 0, legs = 0, feet = 0},
	[1929] = {name = "vibrant phantom", type = 1298, head = 85, body = 85, legs = 88, feet = 91},
	[1930] = {name = "brachiodemon", type = 1299, head = 0, body = 0, legs = 0, feet = 0},
	[1931] = {name = "branchy crawler", type = 1297, head = 0, body = 0, legs = 0, feet = 0},
	[1932] = {name = "capricious phantom", type = 1298, head = 81, body = 114, legs = 85, feet = 83},
	[1933] = {name = "infernal phantom", type = 1298, head = 114, body = 80, legs = 94, feet = 78},
	[1938] = {name = "infernal demon", type = 1313, head = 0, body = 0, legs = 0, feet = 0},
	[1939] = {name = "rotten golem", type = 1312, head = 0, body = 0, legs = 0, feet = 0},
	[1940] = {name = "turbulent elemental", type = 1314, head = 0, body = 0, legs = 0, feet = 0},
	[1941] = {name = "courage leech", type = 1315, head = 0, body = 0, legs = 0, feet = 0},
	[1945] = {name = "mould phantom", type = 1298, head = 106, body = 60, legs = 131, feet = 116},
	[1946] = {name = "druid's apparition", type = 148, head = 114, body = 48, legs = 114, feet = 95},
	[1947] = {name = "knight's apparition", type = 131, head = 19, body = 76, legs = 74, feet = 114},
	[1948] = {name = "paladin's apparition", type = 129, head = 57, body = 42, legs = 114, feet = 114},
	[1949] = {name = "sorcerer's apparition", type = 138, head = 95, body = 114, legs = 52, feet = 76},
	[1962] = {name = "distorted phantom", type = 1298, head = 113, body = 94, legs = 132, feet = 76},
	[1963] = {name = "werehyaena", type = 1300, head = 57, body = 77, legs = 1, feet = 1},
	[1964] = {name = "werehyaena shaman", type = 1300, head = 0, body = 0, legs = 94, feet = 95},
	[1965] = {name = "werelion", type = 1301, head = 58, body = 2, legs = 94, feet = 10},
	[1966] = {name = "werelioness", type = 1301, head = 0, body = 2, legs = 0, feet = 94},
	[1967] = {name = "white lion", type = 1290, head = 0, body = 0, legs = 0, feet = 0},
	[1972] = {name = "usurper knight", type = 1316, head = 76, body = 57, legs = 76, feet = 95},
	[1973] = {name = "usurper archer", type = 1316, head = 76, body = 57, legs = 76, feet = 95},
	[1974] = {name = "usurper warlock", type = 1316, head = 57, body = 2, legs = 21, feet = 95},
	[1979] = {name = "agrestic chicken", type = 111, head = 0, body = 0, legs = 0, feet = 0},
	[2024] = {name = "exotic cave spider", type = 1344, head = 0, body = 0, legs = 0, feet = 0},
	[2036] = {name = "pirat cutthroat", type = 1346, head = 2, body = 96, legs = 78, feet = 96},
	[2037] = {name = "pirat scoundrel", type = 1346, head = 97, body = 119, legs = 80, feet = 80},
	[2038] = {name = "pirat bombardier", type = 1346, head = 57, body = 125, legs = 86, feet = 67},
	[2039] = {name = "pirat mate", type = 1346, head = 0, body = 95, legs = 95, feet = 113},
	[2051] = {name = "exotic bat", type = 1373, head = 0, body = 0, legs = 0, feet = 0},
	[2052] = {name = "death book", type = 1061, head = 114, body = 114, legs = 113, feet =114},
	[2053] = {name = "lil devol", type = 1666, head = 0, body = 0, legs = 0, feet = 0},
	[2054] = {name = "Elite Guard", type = 1438, head = 0, body = 0, legs = 0, feet = 0},
	[2055] = {name = "Orc Smasher", type = 1422, head = 0, body = 0, legs = 0, feet = 0},
    [2056] = {name = "Tiny Head", type = 1423, head = 0, body = 0, legs = 0, feet = 0},
    [2057] = {name = "skele pirate mage", type = 1221, head = 0, body = 0, legs = 0, feet = 0},
	[2058] = {name = "skele pirate ranger", type = 1222, head = 0, body = 0, legs = 0, feet = 0},
    [2059] = {name = "skele pirate warrior", type = 1223, head = 0, body = 0, legs = 0, feet = 0},
	[2061] = {name = "pirate captain", type = 98, head = 0, body = 0, legs = 0, feet = 0},
	[2062] = {name = "pirate bane", type = 1122, head = 0, body = 0, legs = 0, feet = 0},
	[2063] = {name = "orclops savage", type = 935, head = 0, body = 0, legs = 0, feet = 0},
	[2064] = {name = "orclops doom", type = 934, head = 0, body = 0, legs = 0, feet = 0},
    [2066] = {name = "killer gator", type = 358, head = 0, body = 0, legs = 0, feet = 0},
    [2067] = {name = "haunted wolf", type = 716, head = 0, body = 0, legs = 0, feet = 0},
    [2068] = {name = "maskt demon", type = 1588, head = 0, body = 0, legs = 0, feet = 0},
	[2069] = {name = "grim hound", type = 1591, head = 0, body = 0, legs = 0, feet = 0},
    [2070] = {name = "lava djinn", type = 1592, head = 0, body = 0, legs = 0, feet = 0},
    [2071] = {name = "lava viper", type = 1590, head = 0, body = 0, legs = 0, feet = 0},
	[2072] = {name = "razorbac", type = 1587, head = 0, body = 0, legs = 0, feet = 0},
    [2073] = {name = "stompy", type = 1589, head = 0, body = 0, legs = 0, feet = 0},
    [2074] = {name = "holy book", type = 1061, head = 113, body = 79, legs = 113, feet = 79},
	[2075] = {name = "Spike Crawler", type = 1553, head = 113, body = 79, legs = 113, feet = 79},
	[2076] = {name = "jungle djinn", type = 1758, head = 0, body = 0, legs = 0, feet = 0},
	[2077] = {name = "jungle hero", type = 1771, head = 0, body = 0, legs = 0, feet = 0},
    [2078] = {name = "jungle mage", type = 1769, head = 0, body = 0, legs = 0, feet = 0},
    [2084] = {name = "jungle dragon", type = 1770, head = 0, body = 0, legs = 0, feet = 0},
    [2080] = {name = "daemon", type = 1774, head = 0, body = 0, legs = 0, feet = 0},
	[2081] = {name = "demon gator", type = 1722, head = 77, body = 94, legs = 94, feet = 57},
    [2082] = {name = "frenzy gator", type = 1722, head = 85, body = 86, legs = 85, feet = 58},
    [2083] = {name = "icey behemoth", type = 1775, head = 0, body = 0, legs = 0, feet = 0},
    [2085] = {name = "boarc", type = 1810, head = 0, body = 0, legs = 0, feet = 0},
	[2086] = {name = "boarc bersker", type = 1814, head = 77, body = 94, legs = 94, feet = 57},
    [2087] = {name = "boarc guard", type = 1813, head = 85, body = 86, legs = 85, feet = 58},
    [2088] = {name = "boarc packer", type = 1811, head = 0, body = 0, legs = 0, feet = 0},
    [2089] = {name = "boarc shaman", type = 1815, head = 0, body = 0, legs = 0, feet = 0},
	[2090] = {name = "boarc spearman", type = 1812, head = 77, body = 94, legs = 94, feet = 57},
    [2091] = {name = "cave beholder", type = 1800, head = 85, body = 86, legs = 85, feet = 58},
    [2092] = {name = "cave crawler ", type = 1798, head = 0, body = 0, legs = 0, feet = 0},
    [2093] = {name = "cave parrot", type = 217, head = 85, body = 86, legs = 85, feet = 58},
    [2094] = {name = "cave stalker ", type = 1808, head = 0, body = 0, legs = 0, feet = 0},
    [2095] = {name = "ghouly", type = 18, head = 85, body = 86, legs = 85, feet = 58},
    [2096] = {name = "shadow reaper", type = 300, head = 0, body = 0, legs = 0, feet = 0},
    [2097] = {name = "Hydromancer", type = 121, head = 0, body = 0, legs = 0, feet = 0},
      [2098] = {name = "the dragon king", type = 927, head = 0, body = 0, legs = 0, feet = 0},
       [2099] = {name = "Morgaroth", type = 12, head = 0, body = 94, legs = 79, feet = 79},
     [2100] = {name = "Ancient Spawn", type = 1055, head = 0, body = 94, legs = 79, feet = 79},
     [2101] = {name = "Old giant spider", type = 910, head = 0, body = 94, legs = 79, feet = 79},
     [2102] = {name = "The oz", type = 844, head = 0, body = 94, legs = 79, feet = 79},
     [2103] = {name = "The Book Master", type = 939, head = 0, body = 94, legs = 79, feet = 79},
     [2104] = {name = "Spike Stomper", type = 1755, head = 0, body = 94, legs = 79, feet = 79},
     [2105] = {name = "King Zelos", type = 1224, head = 0, body = 94, legs = 79, feet = 79},
     [2106] = {name = "Tower Guardian ", type = 1593, head = 0, body = 94, legs = 79, feet = 79},
     [2107] = {name = "Dark Spider", type = 1752, head = 0, body = 94, legs = 79, feet = 79},
     [2108] = {name = "Jungle Stomper", type = 1757, head = 0, body = 94, legs = 79, feet = 79},
     [2109] = {name = "Infernal Rot", type = 1776, head = 0, body = 94, legs = 79, feet = 79},
     [2110] = {name = "Cave Guardian", type = 1790, head = 0, body = 94, legs = 79, feet = 79},
     [2111] = {name = "Apox", type = 1761, head = 0, body = 94, legs = 79, feet = 79},
	 [2113] = {name = "Jungle Stomper", type = 1757, head = 0, body = 94, legs = 79, feet = 79},
     [2112] = {name = "Drume", type = 1317, head = 0, body = 0, legs = 0, feet = 77, addons = 2},
	[2221] = {name = "crab hands", type = 1699, head = 0, body = 0, legs = 0, feet = 0},
	[2222] = {name = "deadface", type = 1276, head = 0, body = 0, legs = 0, feet = 0},
    [2223] = {name = "deerman", type = 1704, head = 0, body = 0, legs = 0, feet = 0},
    [2224] = {name = "demon crawler", type = 1720, head = 0, body = 0, legs = 0, feet = 0},
    [2225] = {name = "Demon Rat", type = 1698, head = 0, body = 0, legs = 0, feet = 0},
	[2226] = {name = "firey floater", type = 1728, head = 77, body = 94, legs = 94, feet = 57},
    [2227] = {name = "flame head", type = 1726, head = 85, body = 86, legs = 85, feet = 58},
    [2228] = {name = "giant spider X", type = 38, head = 0, body = 0, legs = 0, feet = 0},
    [2229] = {name = "killer goanna", type = 1195, head = 0, body = 0, legs = 0, feet = 0},
	[2230] = {name = "light dragon", type = 1751, head = 77, body = 94, legs = 94, feet = 57},
    [2231] = {name = "light floater", type = 1268, head = 85, body = 86, legs = 85, feet = 58},
    [2232] = {name = "lionspawn", type = 1760, head = 0, body = 0, legs = 0, feet = 0},
    [2233] = {name = "posion crawler", type = 1399, head = 0, body = 0, legs = 0, feet = 0},
	[2234] = {name = "yo eyez", type = 1747, head = 77, body = 94, legs = 94, feet = 57},
    [2235] = {name = "yo goanna", type = 1196, head = 85, body = 86, legs = 85, feet = 58},
    [2236] = {name = "zombielion ", type = 1700, head = 0, body = 0, legs = 0, feet = 0}
	
}
-- LuaFormatter on
