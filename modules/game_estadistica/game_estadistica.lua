local ComboWindow
local timee = 60
local OTC = ""
local updateEvent, csvFile, logoutButton = nil, nil, nil
local fpsGraph, ramGraph, ramLuaGraph = nil, nil, nil
local FPS, FPSButton = nil, nil
local BUFFER_SIZE = 100

-- Statistics Tables
local function initializeStats()
    return {values = {}, sum = 0, count = 0, min = math.huge, max = -math.huge, sumSquares = 0}
end

local fpsStats, memoryStats, luaMemoryStats = initializeStats(), initializeStats(), initializeStats()

local function writeCSVData(timestamp, fpsValue, memoryUsage, luaMemoryUsage)
    if csvFile then
        csvFile:write(string.format("%d,%d,%d,%d\n", timestamp, fpsValue, memoryUsage, luaMemoryUsage))
        csvFile:flush() -- Ensure data is written immediately
    end
end

local function generateFilename()
    return os.date(g_app.getName() .. "_%Y_%m_%d_%H_%M.csv")
end

local function updateStats(stats, value)
    if not value then return end
    if #stats.values == BUFFER_SIZE then
        local oldValue = table.remove(stats.values, 1)
        stats.sum = stats.sum - oldValue
        stats.sumSquares = stats.sumSquares - (oldValue ^ 2)
    end
    table.insert(stats.values, value)
    stats.sum = stats.sum + value
    stats.sumSquares = stats.sumSquares + (value ^ 2)
    stats.count = #stats.values
    stats.min = math.min(stats.min, value)
    stats.max = math.max(stats.max, value)
end

local function calculateMedian(values)
    local sorted = table.copy(values)
    table.sort(sorted)
    return sorted[math.ceil(#sorted / 2)]
end

local function calculateMode(values)
    local frequency, maxFreq, mode = {}, 0, nil
    for _, v in ipairs(values) do
        frequency[v] = (frequency[v] or 0) + 1
        if frequency[v] > maxFreq then
            maxFreq, mode = frequency[v], v
        end
    end
    return mode
end

local function calculateStandardDeviation(stats)
    if stats.count < 2 then return 0 end
    local variance = (stats.sumSquares - (stats.sum ^ 2) / stats.count) / (stats.count - 1)
    return math.sqrt(variance)
end

local function drawGraph(graph, value)
    if graph then graph:addValue(value) end
end

function init()
    if not FPS then
        FPS = g_ui.displayUI('game_estadistica')
    end
    logoutButton = modules.client_topmenu.addTopRightToggleButton('logoutButton222', tr('E2xit'), 'images/ico', toggle, true)
    FPS:hide()
    OTC = g_app.getName()

    local label = OTC == "OTClient - Redemption" and "Simple Stats - {" .. OTC .. ", #FF0000}" or {"Simple Stats ", "#afafaf", OTC, "#FF0000"}
    FPS:setColoredText(label)
    initializeUIElements()

    FPS.button_13.onClick = onClickSettings
end

function terminate()
    if updateEvent then removeEvent(updateEvent) end
    if csvFile then csvFile:close() end
    if FPSButton then FPSButton:destroy() end
    if FPS then FPS:destroy() end
    if ComboWindow then ComboWindow:destroy() end
    if logoutButton then logoutButton:destroy() end
    destroy()
end

function initializeUIElements()
    local panels = {
        { "panel_2", "FPS" },
        { "panel_metrics_luaram", "LuaRam" },
        { "panel_3", "Lua" }
    }
    for _, stat in ipairs({"Min", "Median", "Max", "Std"}) do
        for _, panel in ipairs(panels) do
            local widget = g_ui.createWidget("Label", FPS[panel[1]])
            widget:setId(string.lower(stat) .. panel[2])
            widget:setText(stat)
        end
    end

    fpsGraph = createGraph("testGraph", "FPS", FPS.panel_1)
    ramGraph = createGraph("testGraph", "RAM Usage", FPS.panel_4)
    ramLuaGraph = createGraph("testGraph", "RAM lua Usage", FPS.panel_ram_lua)

    -- Initialize system info table
    local soloTable = FPS.panel_9.myBuyingTable
    soloTable:clearData()
    if not soloTable.dataSpace then
        soloTable:setRowStyle("PlayersTableRow")
        soloTable:setColumnStyle("PlayersTableColumn")
        soloTable:setTableData(FPS.panel_9.myBuyingTableData)
    end
    loadSystemInfo(soloTable)
end

function createGraph(widgetType, title, parent)
    local graph = g_ui.createWidget(widgetType, parent)
    graph:fill('parent')
    graph:setTitle(title)
    return graph
end

function loadSystemInfo(tableWidget)
    local aux = g_app.getName()
    local height, width = 8, 6

    local view = (OTC == "OTClient - Redemption") and g_gameConfig.getViewPort() or g_map.getAwareRange()
    height, width = view.height or height, view.width or width
  -- LuaFormatter off
    local systemInfo = {
        {"OTC", aux},
        {"Compiler", g_app.getBuildCompiler()},
        {"Build Date", g_app.getBuildDate()},
        {"Build Arch", g_app.getBuildArch()},
        {"CPU", g_platform.getCPUName()},
        {"RAM", string.format("%.2f GB", g_platform.getTotalSystemMemory() / (1024 * 1024 * 1024))},
        {"OS",  g_app.getOs()},
        {"GPU", g_graphics.getRenderer()},
        {"View", string.format("%d x %d", height, width)}
    }

    for _, info in ipairs(systemInfo) do
        tableWidget:addRow({{text = info[1] }, {text = info[2]}})
    end
      -- LuaFormatter on
end

function updateFps()
    if not FPS or not FPS:isVisible() then
        if updateEvent then removeEvent(updateEvent) end
        return
    end

    local fpsValue = g_app.getFps()
    local memoryUsage, luaMemoryUsage = g_platform.getMemoryUsage() / (1024 * 1024), gcinfo() / 1024
    local timestamp = os.time()

    -- Update statistics
    for _, data in ipairs({{fpsStats, fpsValue}, {memoryStats, memoryUsage}, {luaMemoryStats, luaMemoryUsage}}) do
        updateStats(data[1], data[2])
    end

    -- Update UI and Log to file
    drawGraph(fpsGraph, fpsValue)
    drawGraph(ramGraph, memoryUsage)
    drawGraph(ramLuaGraph, luaMemoryUsage)
    writeCSVData(timestamp, fpsValue, memoryUsage, luaMemoryUsage)
    
    updateUI(
        fpsStats, memoryStats, luaMemoryStats
    )

    updateEvent = scheduleEvent(updateFps, 1000)
end

function updateUI(fpsStats, memoryStats, luaMemoryStats)
    -- Helper function to update the text of a widget safely
    local function setPanelText(widget, formatString, value)
        if widget and value then  -- Check if widget exists and value is not nil
            widget:setText(string.format(formatString, value))
        else
            widget:setText("N/A")  -- Set default text if value is nil
        end
    end

    -- Function to calculate mean safely
    local function calculateMean(stats)
        return (stats.count > 0) and (stats.sum / stats.count) or 0
    end

    -- FPS Statistics
    local meanFps = calculateMean(fpsStats)
    local medianFps = (fpsStats.count > 0) and calculateMedian(fpsStats.values) or 0
    local stdDevFps = calculateStandardDeviation(fpsStats)

    -- Update FPS UI
    setPanelText(FPS.panel_10.fps_Avg, "%.1f ms", meanFps)
    setPanelText(FPS.panel_2.minFPS, "Min:\n %.1f", fpsStats.min)
    setPanelText(FPS.panel_2.medianFPS, "Median:\n %.1f", medianFps)
    setPanelText(FPS.panel_2.maxFPS, "Max:\n %.1f", fpsStats.max)
    setPanelText(FPS.panel_2.stdFPS, "Std:\n %.1f", stdDevFps)

    -- RAM Statistics
    local meanMemory = calculateMean(memoryStats)
    local medianMemory = (memoryStats.count > 0) and calculateMedian(memoryStats.values) or 0
    local stdDevMemory = calculateStandardDeviation(memoryStats)

    -- Update RAM UI
    setPanelText(FPS.panel_11.ram_Avg, "%.1f [MB]", meanMemory)
    setPanelText(FPS.panel_3.minLua, "Min:\n %.1f", memoryStats.min)
    setPanelText(FPS.panel_3.medianLua, "Median:\n %.1f", medianMemory)
    setPanelText(FPS.panel_3.maxLua, "Max:\n %.1f", memoryStats.max)
    setPanelText(FPS.panel_3.stdLua, "Std:\n %.1f", stdDevMemory)

    -- Lua RAM Statistics
    local meanLuaMemory = calculateMean(luaMemoryStats)
    local medianLuaMemory = (luaMemoryStats.count > 0) and calculateMedian(luaMemoryStats.values) or 0
    local stdDevLuaMemory = calculateStandardDeviation(luaMemoryStats)

    -- Update Lua RAM UI
    setPanelText(FPS.panel_13.ram_lua_Avg, "%.2f [MB]", meanLuaMemory)
    setPanelText(FPS.panel_metrics_luaram.minLuaRam, "Min:\n %.1f", luaMemoryStats.min)
    setPanelText(FPS.panel_metrics_luaram.medianLuaRam, "Median:\n %.1f", medianLuaMemory)
    setPanelText(FPS.panel_metrics_luaram.maxLuaRam, "Max:\n %.1f", luaMemoryStats.max)
    setPanelText(FPS.panel_metrics_luaram.stdLuaRam, "Std:\n %.1f", stdDevLuaMemory)
end



function cleanData()
    fpsStats, memoryStats, luaMemoryStats = initializeStats(), initializeStats(), initializeStats()
    if fpsGraph then fpsGraph:clear() end
    if ramGraph then ramGraph:clear() end
    if ramLuaGraph then ramLuaGraph:clear() end
    updateUI(fpsStats, memoryStats, luaMemoryStats)
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
        file:write(string.format("%.2f,%.2f,%.2f\n", fpsStats.values[i], memoryStats.values[i], luaMemoryStats.values[i]))
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

    local function calculateMean(stats)
        return stats.sum / stats.count
    end

    local function calculateStd(stats)
        if stats.count < 2 then
            return 0
        end
        local variance = (stats.sumSquares - (stats.sum ^ 2) / stats.count) / (stats.count - 1)
        return math.sqrt(variance)
    end
  -- LuaFormatter off
    local systemInfo = {
        {"Min", string.format("%.2f", fpsStats.min), string.format("%.2f", memoryStats.min), string.format("%.2f", luaMemoryStats.min)},
        {"Mean", string.format("%.2f", calculateMean(fpsStats)), string.format("%.2f", calculateMean(memoryStats)), string.format("%.2f", calculateMean(luaMemoryStats))},
        {"Median", string.format("%.2f", calculateMedian(fpsStats.values)), string.format("%.2f", calculateMedian(memoryStats.values)), string.format("%.2f", calculateMedian(luaMemoryStats.values))},
        {"Max", string.format("%.2f", fpsStats.max), string.format("%.2f", memoryStats.max), string.format("%.2f", luaMemoryStats.max)},
        {"Std", string.format("%.2f", calculateStd(fpsStats)), string.format("%.2f", calculateStd(memoryStats)), string.format("%.2f", calculateStd(luaMemoryStats))}
    }

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
end

  -- LuaFormatter on
local digPanel = nil
local digBar = nil
local digText = nil
local config = {
    fadeOutDuration = 300, -- milliseconds
    barUpdateDelay = 10 -- milliseconds
}

function test(timer)
    cleanData()
    if not timer then
        timer = 60
    end
    digPanel = g_ui.createWidget('DigPanel', FPS.Barra)

    digBar = digPanel:getChildById('digBar')
    digText = digPanel:getChildById('digText')

    local startTime = g_clock.millis()
    local endTime = startTime + (timer * 1000)

    update(endTime, timer)
    FPS.abort:enable()
end

function update(endTime, digTime)
    if not digPanel then
        return
    end

    local currentTime = g_clock.millis()
    local timeLeft = endTime - currentTime
    local progressPercent = timeLeft / (digTime * 1000)

    local barPercent = digBar:getWidth() * progressPercent
    local rect = {
        x = 0,
        y = 0,
        width = math.max(1, barPercent),
        height = digBar:getHeight()
    }

    digBar:setImageRect(rect)
    digText:setText(string.format("%0.1f", math.max(0, timeLeft / 1000)) .. '/' .. digTime .. 'S')

    if timeLeft <= 0 then
        exportCSV()
        disable(false)
        FPS.abort:disable()
        if digBar then
            digBar:setVisible(false)
        end
        g_effects.fadeOut(digPanel, config.fadeOutDuration)
        scheduleEvent(function()
            destroy()
        end, config.fadeOutDuration)
        return
    end
    scheduleEvent(function()
        update(endTime, digTime)
    end, config.barUpdateDelay)
end

function destroy()
    if digPanel then
        digPanel:destroy()
        digPanel = nil
        digBar = nil
        digText = nil
    end
end

function hide()
    if not FPS then
        return
    end
    FPS:hide()

    if updateEvent then
        removeEvent(updateEvent)
        updateEvent = nil
    end
end

function show()
    if not FPS then
        return
    end

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
    test(timee)
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

        timee = tonumber(ComboWindow.Time:getText())
        FPS.button_3:setText(string.format("Start Recording %d s time", timee))
        ComboWindow:destroy()

    end
end

function abort()
    disable(false)
    if digBar then
        digBar:setVisible(false)
    end
    g_effects.fadeOut(digPanel, config.fadeOutDuration)
    scheduleEvent(function()
        destroy()
    end, config.fadeOutDuration)
    FPS.abort:disable()
    FPS.status:setText("analysis aborted, csv not saved")
end
