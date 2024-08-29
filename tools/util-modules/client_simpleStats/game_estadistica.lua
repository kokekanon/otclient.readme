-- LuaFormatter off
-- @ config
local ArrayDefaultConfig = {
    OTC = "",
    timer = 60,
    view = { height = 8, width = 6 },
    BUFFER_SIZE = 100,
    Version = "0.1",
    LastUpdated = "29-08-2024 11:52AM"
}
local arrayProgresBarconfig = {
    fadeOutDuration = 300, -- milliseconds
    barUpdateDelay = 10, -- milliseconds
    widgets = {
        progresBarStats= nil,
    }
}
-- LuaFormatter on
-- @ Widgets
local ComboWindow = nil
local FPS = nil
local FPSButton = nil
-- @ Widgets graph
local fpsGraph = nil
local ramGraph = nil
local ramLuaGraph = nil
-- @ scheduleEvent
local updateEvent = nil
-- @ csv
local csvFile = nil

local function initializeStats()
    return {
        values = {},
        sum = 0,
        count = 0,
        min = math.huge,
        max = -math.huge,
        sumSquares = 0
    }
end

local function getViewportSize()
    if g_app.getName() == "OTClient - Redemption" then
        if g_gameConfig and g_gameConfig.getViewPort then
            local view = g_gameConfig.getViewPort()
            return view.height, view.width
        end
    elseif g_app.getName() == "OTCv8" then
        if g_map and g_map.getAwareRange then
            local awareRange = g_map.getAwareRange()
            return (awareRange.height / 2) - 1, (awareRange.width / 2) - 1
        end
    end
    return ArrayDefaultConfig.view.height, ArrayDefaultConfig.view.width
end

local fpsStats, memoryStats, luaMemoryStats = initializeStats(), initializeStats(), initializeStats()

local function writeCSVData(timestamp, fpsValue, memoryUsage, luaMemoryUsage)
    if csvFile then
        csvFile:write(string.format("%d,%d,%d,%d\n", timestamp, fpsValue, memoryUsage, luaMemoryUsage))
        csvFile:flush()
    end
end

local function generateFilename()
    return "mods/client_simpleStats/csv/" .. os.date(g_app.getName() .. "_%Y_%m_%d_%H_%M.csv")
end

local function updateStats(stats, value)
    if value == nil then
        return
    end

    if #stats.values == ArrayDefaultConfig.BUFFER_SIZE then
        local oldValue = table.remove(stats.values, 1)
        stats.sum = stats.sum - (oldValue or 0)
        stats.sumSquares = stats.sumSquares - ((oldValue or 0) ^ 2)
        stats.count = stats.count - 1
    end

    table.insert(stats.values, value)
    stats.sum = stats.sum + value
    stats.sumSquares = stats.sumSquares + (value ^ 2)
    stats.count = stats.count + 1
    stats.min = math.min(stats.min, value)
    stats.max = math.max(stats.max, value)
end

local function calculateMedian(values)
    local sorted = table.copy(values)
    table.sort(sorted)
    return sorted[math.ceil(#sorted / 2)]
end

local function calculateMode(values)
    local frequency = {}
    local maxFreq, mode = 0, nil
    for _, v in ipairs(values) do
        frequency[v] = (frequency[v] or 0) + 1
        if frequency[v] > maxFreq then
            maxFreq, mode = frequency[v], v
        end
    end
    return mode
end

local function calculateStandardDeviation(stats)
    if stats.count < 2 then
        return 0
    end
    local variance = (stats.sumSquares - (stats.sum ^ 2) / stats.count) / (stats.count - 1)
    return math.sqrt(variance)
end

local function drawGraph(graph, value)
    graph:addValue(value)
end

function init()
    if not FPS then
        FPS = g_ui.displayUI('game_estadistica')
    end
    FPSButton = modules.client_topmenu.addTopRightToggleButton('SimpleStats', tr('SimpleStats'), 'images/ico', toggle,
        true)
    FPS:hide()
    ArrayDefaultConfig.OTC = g_app.getName()
    if ArrayDefaultConfig.OTC == "OTClient - Redemption" then
        FPS:setColoredText("Simple Stats - {" .. ArrayDefaultConfig.OTC .. ", #FF0000}")
    else
        FPS:setColoredText({"Simple Stats ", "#afafaf", ArrayDefaultConfig.OTC .. "", "#FF0000"})
    end

    FPS.buttonSettings.onClick = onClickSettings

end

function terminate()
    stopAllScheduleEvent()
    closeCsv()
    destroyWidgets("all")
end

function initializeUIElements()
    -- Initialize labels
    local statLabels = {"Min", "Median", "Max", "Std"}
    for _, label in ipairs(statLabels) do
        for _, stat in ipairs({"FPS"}) do
            local widget = g_ui.createWidget("Label", FPS.statsFPS)
            widget:setId(string.lower(label) .. stat)
            widget:setText(label)
        end
        for _, stat in ipairs({"LuaRam"}) do
            local widget = g_ui.createWidget("Label", FPS.statsLuaRAM)
            widget:setId(string.lower(label) .. stat)
            widget:setText(label)
        end
        for _, stat in ipairs({"Lua"}) do
            local widget = g_ui.createWidget("Label", FPS.statsRAM)
            widget:setId(string.lower(label) .. stat)
            widget:setText(label)
        end
    end

    -- Initialize graphs
    fpsGraph = g_ui.createWidget("testGraph", FPS.fpsGraph)
    fpsGraph:fill('parent')
    fpsGraph:setTitle("FPS")

    ramGraph = g_ui.createWidget("testGraph", FPS.ramGraph)
    ramGraph:fill('parent')
    ramGraph:setTitle("RAM Usage")

    ramLuaGraph = g_ui.createWidget("testGraph", FPS.ramLuaGraph)
    ramLuaGraph:fill('parent')
    ramLuaGraph:setTitle("RAM lua Usage")
    -- Initialize system info table
    local soloTable = FPS.panel_9.myBuyingTable
    soloTable:clearData()
    if not soloTable.dataSpace then
        soloTable:setRowStyle("PlayersTableRow")
        soloTable:setColumnStyle("PlayersTableColumn")
        soloTable:setTableData(FPS.panel_9.myBuyingTableData)
    end

    -- LuaFormatter off
    local widthview, heightview = getViewportSize()
    local systemInfo = {
        {"OTC", ArrayDefaultConfig.OTC},
        {"Compiler", g_app.getBuildCompiler()},
        {"Build Date", g_app.getBuildDate()},
        {"Build Arch", g_app.getBuildArch()},
        {"CPU", g_platform.getCPUName()},
        {"RAM", string.format("%.2f GB", g_platform.getTotalSystemMemory() / (1024 * 1024 * 1024))},
        {"OS",  g_app.getOs()},
        {"GPU", g_graphics.getRenderer()},
        {"View", string.format("%d x %d", widthview, heightview)},
        {"Mode", "isGL() or isDX()??"},
        {"Monitor*", string.format("%d x %d", g_window:getSize().height, g_window:getSize().width)},

    }
    for _, info in ipairs(systemInfo) do
        soloTable:addRow({{text = info[1] }, {text = info[2]}})
    end

    -- LuaFormatter on

end

function updateFps()
    if not FPS or not FPS:isVisible() then
        stopAllScheduleEvent()
        return
    end

    local fpsValue = g_app.getFps()
    updateEvent = scheduleEvent(updateFps, 1000)

    local memoryUsage = 0
    if g_platform and g_platform.getMemoryUsage then
        memoryUsage = g_platform.getMemoryUsage() / (1024 * 1024)
    end
    local luaMemoryUsage = gcinfo() / 1024
    local timestamp = os.time()

    -- Update statistics
    updateStats(fpsStats, fpsValue)
    updateStats(memoryStats, memoryUsage)
    updateStats(luaMemoryStats, luaMemoryUsage)

    -- Calculate statistics
    local meanFps = fpsStats.sum / fpsStats.count
    local meanMemory = memoryStats.sum / memoryStats.count
    local meanLuaMemory = luaMemoryStats.sum / luaMemoryStats.count
    local medianFps = calculateMedian(fpsStats.values)
    local medianMemory = calculateMedian(memoryStats.values)
    local medianLuaMemory = calculateMedian(luaMemoryStats.values)
    local stdDevFps = calculateStandardDeviation(fpsStats)
    local stdDevMemory = calculateStandardDeviation(memoryStats)
    local stdDevLuaMemory = calculateStandardDeviation(luaMemoryStats)

    -- Update UI
    drawGraph(fpsGraph, fpsValue)
    drawGraph(ramGraph, memoryUsage)
    drawGraph(ramLuaGraph, luaMemoryUsage)

    updateUI(meanFps, meanMemory, meanLuaMemory, medianFps, medianMemory, medianLuaMemory, fpsStats.min, fpsStats.max,
        memoryStats.min, memoryStats.max, luaMemoryStats.min, luaMemoryStats.max, stdDevFps, stdDevMemory,
        stdDevLuaMemory)

    -- Log to file
    writeCSVData(timestamp, fpsValue, memoryUsage, luaMemoryUsage)
end

function cleanData()
    local fpsStats, memoryStats, luaMemoryStats = initializeStats(), initializeStats(), initializeStats()

    -- Reset graphs if needed
    if fpsGraph then
        fpsGraph:clear()
    end
    if ramGraph then
        ramGraph:clear()
    end
    if ramLuaGraph then
        ramLuaGraph:clear()
    end
    -- Reset UI elements
    updateUI(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

function updateUI(meanFps, meanMemory, meanLuaMemory, medianFps, medianMemory, medianLuaMemory, minFps, maxFps,
    minMemory, maxMemory, minLuaMemory, maxLuaMemory, stdDevFps, stdDevMemory, stdDevLuaMemory)
    FPS.panelFPSaverage.fpsAvg:setText(string.format("%.1f ms", meanFps))
    FPS.panelRamUsage.ramAvg:setText(string.format("%.1f [MB]", meanMemory))
    FPS.panelLuaRamUsage.ramLuaAvg:setText(string.format("%.2f [MB]", meanLuaMemory))
    -- FPS
    FPS.statsFPS.minFPS:setText(string.format("Min:\n %.1f", minFps))
    FPS.statsFPS.medianFPS:setText(string.format("Median:\n %.1f", medianFps))
    FPS.statsFPS.maxFPS:setText(string.format("Max:\n %.1f", maxFps))
    FPS.statsFPS.stdFPS:setText(string.format("Std:\n %.1f", stdDevFps))

    -- RAM
    FPS.statsRAM.minLua:setText(string.format("Min:\n %.1f", minMemory))
    FPS.statsRAM.medianLua:setText(string.format("Median:\n %.1f", medianMemory))
    FPS.statsRAM.maxLua:setText(string.format("Max:\n %.1f", maxMemory))
    FPS.statsRAM.stdLua:setText(string.format("Std:\n %.1f", stdDevMemory))

    -- Lua RAM
    FPS.statsLuaRAM.minLuaRam:setText(string.format("Min:\n %.1f", minLuaMemory))
    FPS.statsLuaRAM.medianLuaRam:setText(string.format("Median:\n %.1f", medianLuaMemory))
    FPS.statsLuaRAM.maxLuaRam:setText(string.format("Max:\n %.1f", maxLuaMemory))
    FPS.statsLuaRAM.stdLuaRam:setText(string.format("Std:\n %.1f", stdDevLuaMemory))
end

function exportCSV()
    local filename = generateFilename()
    local file = io.open(filename, "w")
    if not file then
        g_logger.error("Failed to open CSV file for export")
        return
    end

    file:write("FPS,Memory (MB),Lua Memory (KB)\n")
    for i = 1, math.min(#fpsStats.values, #memoryStats.values, #luaMemoryStats.values) do
        file:write(
            string.format("%.2f,%.2f,%.2f\n", fpsStats.values[i], memoryStats.values[i], luaMemoryStats.values[i]))
    end

    file:close()
    FPS.status:setText("CSV exported successfully: " .. filename)

    local soloTable = FPS.Stadistics.myBuyingTable
    soloTable:clearData()
    if not soloTable.dataSpace then
        soloTable:setRowStyle("TableRow")
        soloTable:setColumnStyle("TableColumn")
        soloTable:setTableData(FPS.Stadistics.myBuyingTableData)
    end

    -- Calculate statistics
    local function calculateMean(stats)
        return stats.sum / stats.count
    end

    local function calculateMedian(values)
        local sorted = table.copy(values)
        table.sort(sorted)
        return sorted[math.ceil(#sorted / 2)]
    end

    local function calculateStd(stats)
        if stats.count < 2 then
            return 0
        end
        local variance = (stats.sumSquares - (stats.sum ^ 2) / stats.count) / (stats.count - 1)
        return math.sqrt(variance)
    end
    -- LuaFormatter on
    local systemInfo = {{"Min", string.format("%.2f", fpsStats.min), string.format("%.2f", memoryStats.min),
                         string.format("%.2f", luaMemoryStats.min)},
                        {"Mean", string.format("%.2f", calculateMean(fpsStats)),
                         string.format("%.2f", calculateMean(memoryStats)),
                         string.format("%.2f", calculateMean(luaMemoryStats))},
                        {"Median", string.format("%.2f", calculateMedian(fpsStats.values)),
                         string.format("%.2f", calculateMedian(memoryStats.values)),
                         string.format("%.2f", calculateMedian(luaMemoryStats.values))},
                        {"Max", string.format("%.2f", fpsStats.max), string.format("%.2f", memoryStats.max),
                         string.format("%.2f", luaMemoryStats.max)},
                        {"Std", string.format("%.2f", calculateStd(fpsStats)),
                         string.format("%.2f", calculateStd(memoryStats)),
                         string.format("%.2f", calculateStd(luaMemoryStats))}}

    for _, info in ipairs(systemInfo) do
        soloTable:addRow({{
            text = info[1],
            width = 80
        }, {
            text = info[2],
            width = 80
        }, {
            text = info[3],
            width = 80
        }, {
            text = info[4],
            width = 80
        }}, 15)
    end
    -- LuaFormatter on

end

function runTest(timer)
    cleanData()
    if not timer then
        timer = 60
    end
    arrayProgresBarconfig.widgets.progresBarStats = g_ui.createWidget('progresBarStats', FPS.Barra)


    local startTime = g_clock.millis()
    local endTime = startTime + (timer * 1000)

    update(endTime, timer)
    FPS.buttonabort:enable()
end

function update(endTime, digTime)
    if not arrayProgresBarconfig.widgets.progresBarStats then
        return
    end

    local currentTime = g_clock.millis()
    local timeLeft = endTime - currentTime
    local progressPercent = timeLeft / (digTime * 1000)

    local barPercent = arrayProgresBarconfig.widgets.progresBarStats.progresBar:getWidth() * progressPercent
    local rect = {
        x = 0,
        y = 0,
        width = math.max(1, barPercent),
        height = arrayProgresBarconfig.widgets.progresBarStats.progresBar:getHeight()
    }

    arrayProgresBarconfig.widgets.progresBarStats.progresBar:setImageRect(rect)
    arrayProgresBarconfig.widgets.progresBarStats.progresText:setText(string.format("%0.1f", math.max(0, timeLeft / 1000)) .. '/' .. digTime .. 'S')

    if timeLeft <= 0 then
        exportCSV()
        FPS.Stadistics:setText("Last Summary Statistics "..ArrayDefaultConfig.timer.." segunds")
        disable(false)
        FPS.buttonabort:disable()
        if arrayProgresBarconfig.widgets.progresBarStats.progresBar then
            arrayProgresBarconfig.widgets.progresBarStats.progresBar:setVisible(false)
        end
        g_effects.fadeOut(arrayProgresBarconfig.widgets.progresBarStats, arrayProgresBarconfig.fadeOutDuration)
        scheduleEvent(function()
            destroyWidgets("bar")
        end, arrayProgresBarconfig.fadeOutDuration)
        return
    end
    scheduleEvent(function()
        update(endTime, digTime)
    end, arrayProgresBarconfig.barUpdateDelay)
end

function hide()
    if not FPS then
        return
    end
    FPS:hide()

    stopAllScheduleEvent()

end

function show()
    if not FPS then
        return
    end
    initializeUIElements()
    FPS:show()
    FPS:raise()
    FPS:focus()

    updateEvent = scheduleEvent(updateFps, 1000)

end

function toggle()
    if not FPS then
        return
    end

    if FPS:isVisible() then
        return hide()
    end
    show()
end

function disable(boolean)
    for i, child in ipairs(FPS:getChildren()) do
        if child:getStyle().__class == 'UIButton' then
            if boolean then
                child:disable()
            else
                child:enable()
            end
        end
    end
end

function starRecord()
    disable(true)
    runTest(ArrayDefaultConfig.timer)
    FPS.status:setText("wait 60 seg")
    FPS.status:setVisible(true)
end

function onClickSettings()
    ComboWindow = g_ui.createWidget("MainWindow", rootWidget)
    ComboWindow:setText(tr('Settings'))
    ComboWindow:setSize("300 320")
    ComboWindow.onEscape = function()
        ComboWindow:hide()
    end

    local function createTextEditWithLabel(parent, id, topMargin, labelText, text)
        local textEdit = g_ui.createWidget("TextEdit", parent)
        textEdit:setId(id)
        textEdit:addAnchor(AnchorTop, 'parent', AnchorTop)
        textEdit:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        textEdit:setMarginLeft(10)
        textEdit:setMarginTop(topMargin)
        textEdit:setSize("150 20")
        textEdit:setText(text)

        local label = g_ui.createWidget("Label", parent)
        label:setColoredText(labelText)
        label:addAnchor(AnchorLeft, textEdit:getId(), AnchorRight)
        label:addAnchor(AnchorTop, textEdit:getId(), AnchorTop)
        label:setMarginLeft(5)
    end

    createTextEditWithLabel(ComboWindow, "Time", 10, tr("Time In Seg"), 60)

    local closeButton = g_ui.createWidget("Button", ComboWindow)
    closeButton:setText(tr('Close'))

    closeButton:addAnchor(AnchorRight, 'parent', AnchorRight)
    closeButton:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    closeButton:setMarginTop(15)
    closeButton:setMarginRight(5)
    closeButton.onClick = function()
        ComboWindow:destroy()
    end
    local sendButton = g_ui.createWidget("Button", ComboWindow)
    sendButton:setText(tr('Save Settings'))

    sendButton:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    sendButton:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    sendButton:setMarginTop(15)
    sendButton:setMarginLeft(5)
    sendButton.onClick = function()

        local timeText = ComboWindow.Time:getText()
        local timeNumber = tonumber(timeText)

        if timeNumber and timeNumber > 0 and timeNumber <= 600 then
            ArrayDefaultConfig.timer = timeNumber
            FPS.button_3:setText(string.format("Start Recording %d s time", ArrayDefaultConfig.timer))
        
        else
            FPS.status:setText(("Invalid Number"))
            FPS.status:setVisible(true)
        end

        ComboWindow:destroy()

    end
end

function abort()
    disable(false)
    if arrayProgresBarconfig.widgets.progresBarStats.progresBar then
        arrayProgresBarconfig.widgets.progresBarStats.progresBar:setVisible(false)
    end
    g_effects.fadeOut(arrayProgresBarconfig.widgets.progresBarStats, arrayProgresBarconfig.fadeOutDuration)
    scheduleEvent(function()
        destroyWidgets("bar")
    end, arrayProgresBarconfig.fadeOutDuration)
    FPS.buttonabort:disable()
    FPS.status:setText("analysis aborted, csv not saved")
    closeCsv()
end

function stopAllScheduleEvent()
    if updateEvent then
        removeEvent(updateEvent)
        updateEvent = nil
    end
end

function destroyWidgets(type)
    local widgetsToDestroy = {
        FPSButton,
        FPS,
        ComboWindow
    }

    if type == "all" then
        for _, widget in ipairs(widgetsToDestroy) do
            if widget then
                widget:destroy()
                widget = nil
            end
        end
    end

    if type == "all" or type == "bar" then
        if arrayProgresBarconfig.widgets.progresBarStats then
            arrayProgresBarconfig.widgets.progresBarStats:destroy()
            arrayProgresBarconfig.widgets.progresBarStats = {}
            arrayProgresBarconfig.widgets.progresBarStats = nil
        end
    end
end


function closeCsv()
    if csvFile then
        csvFile:close()
        csvFile = nil
    end
end
