controllerFPS = Controller:new()
local csvFile = nil
-- Constants
local BUFFER_SIZE = 100

-- Graphs
local fpsGraph = nil
local ramGraph = nil
local ramLuaGraph = nil
-- Statistics
local fpsStats = {
    values = {},
    sum = 0,
    count = 0,
    min = math.huge,
    max = -math.huge,
    sumSquares = 0
}
local memoryStats = {
    values = {},
    sum = 0,
    count = 0,
    min = math.huge,
    max = -math.huge,
    sumSquares = 0
}
local luaMemoryStats = {
    values = {},
    sum = 0,
    count = 0,
    min = math.huge,
    max = -math.huge,
    sumSquares = 0
}

local function writeCSVData(timestamp, fpsValue, memoryUsage, luaMemoryUsage)
    if csvFile then
        csvFile:write(string.format("%d,%d,%d,%d\n", timestamp, fpsValue, memoryUsage, luaMemoryUsage))
        csvFile:flush()  -- Ensure data is written immediately
    end
end

-- Helper functions
local function generateFilename()
    return os.date(g_app.getName().. "_%Y_%m_%d_%H_%M.csv")
end

local function updateStats(stats, value)
    if value == nil then return end  -- Early return if value is nil
    if #stats.values == BUFFER_SIZE then
        local oldValue = table.remove(stats.values, 1)
        stats.sum = stats.sum - (oldValue or 0)  -- Use 0 if oldValue is nil
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
    if stats.count < 2 then return 0 end
    local variance = (stats.sumSquares - (stats.sum ^ 2) / stats.count) / (stats.count - 1)
    return math.sqrt(variance)
end

local function drawGraph(graph, value)
    graph:addValue(value)
end

controllerFPS:setUI('game_estadistica')
-- Controller functions
function controllerFPS:onInit()
    controllerFPS.ui:show()
    initializeUIElements()
    controllerFPS:registerEvents(g_app, {
        onFps = updateFps
    })
end

function controllerFPS:onTerminate()
    if csvFile then
        csvFile:close()
        csvFile = nil
    end
    destroy()
end

function initializeUIElements()
    -- Initialize labels
    local statLabels = {"Min", "Median", "Max", "Std"}
    for _, label in ipairs(statLabels) do
        for _, stat in ipairs({"FPS"}) do
            local widget = g_ui.createWidget("Label", controllerFPS.ui.panel_2)
            widget:setId(string.lower(label) .. stat)
            widget:setText(label)
        end
        for _, stat in ipairs({"LuaRam"}) do
            local widget = g_ui.createWidget("Label", controllerFPS.ui.panel_metrics_luaram)
            widget:setId(string.lower(label) .. stat)
            widget:setText(label)
        end
        for _, stat in ipairs({"Lua"}) do
            local widget = g_ui.createWidget("Label", controllerFPS.ui.panel_3)
            widget:setId(string.lower(label) .. stat)
            widget:setText(label)
        end
    end

    -- Initialize graphs
    fpsGraph = g_ui.createWidget("testGraph", controllerFPS.ui.panel_1)
    fpsGraph:fill('parent')
    fpsGraph:setTitle("FPS")

    ramGraph = g_ui.createWidget("testGraph", controllerFPS.ui.panel_4)
    ramGraph:fill('parent')
    ramGraph:setTitle("RAM Usage")

    ramLuaGraph = g_ui.createWidget("testGraph", controllerFPS.ui.panel_ram_lua)
    ramLuaGraph:fill('parent')
    ramLuaGraph:setTitle("RAM lua Usage")
    -- Initialize system info table
    local soloTable = controllerFPS.ui.panel_9.myBuyingTable
    soloTable:clearData()
    if not soloTable.dataSpace then
        soloTable:setRowStyle("TableRow")
        soloTable:setColumnStyle("TableColumn")
        soloTable:setTableData(controllerFPS.ui.panel_9.myBuyingTableData)
    end

    local systemInfo = {
        {"OTC", g_app.getName()},
        {"Compiler", g_app.getBuildCompiler()},
        {"Build Date", g_app.getBuildDate()},
        {"Build Arch", g_app.getBuildArch()},
        {"CPU", g_platform.getCPUName()},
        {"RAM", string.format("%.2f GB", g_platform.getTotalSystemMemory() / (1024 * 1024 * 1024))},
        {"OS", g_platform.getOSName()},
        {"GPU", "GetGPU 3080"}
    }

    for _, info in ipairs(systemInfo) do
        soloTable:addRow({{text = info[1]}, {text = info[2]}})
    end
end

function updateFps(fpsValue)
    if not controllerFPS.ui:isVisible() then return end

    local memoryUsage = g_platform.getMemoryUsage()
    local luaMemoryUsage = gcinfo()/ 1024 
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

    updateUI(meanFps, meanMemory, meanLuaMemory, medianFps, medianMemory, medianLuaMemory, 
             fpsStats.min, fpsStats.max, memoryStats.min, memoryStats.max, 
             luaMemoryStats.min, luaMemoryStats.max, stdDevFps, stdDevMemory, stdDevLuaMemory)

    -- Log to file
    writeCSVData(timestamp, fpsValue, memoryUsage, luaMemoryUsage)
end

function cleanData()
    fpsStats = {
        values = {},
        sum = 0,
        count = 0,
        min = math.huge,
        max = -math.huge,
        sumSquares = 0
    }
    memoryStats = {
        values = {},
        sum = 0,
        count = 0,
        min = math.huge,
        max = -math.huge,
        sumSquares = 0
    }
    luaMemoryStats = {
        values = {},
        sum = 0,
        count = 0,
        min = math.huge,
        max = -math.huge,
        sumSquares = 0
    }
    -- Reset graphs if needed
    if fpsGraph then fpsGraph:clear() end
    if ramGraph then ramGraph:clear() end
    if ramLuaGraph then ramLuaGraph:clear() end
    -- Reset UI elements
    updateUI(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

function updateUI(meanFps, meanMemory, meanLuaMemory, medianFps, medianMemory, medianLuaMemory, 
                  minFps, maxFps, minMemory, maxMemory, minLuaMemory, maxLuaMemory, 
                  stdDevFps, stdDevMemory, stdDevLuaMemory)
    controllerFPS.ui.panel_10.fps_Avg:setText(string.format("%.1f ms", meanFps))
    controllerFPS.ui.panel_11.ram_Avg:setText(string.format("%.1f [MB]", meanMemory))
    controllerFPS.ui.panel_13.ram_lua_Avg:setText(string.format("%.2f [MB]", meanLuaMemory))
    -- FPS
    controllerFPS.ui.panel_2.minFPS:setText(string.format("Min:\n %.1f", minFps))
    controllerFPS.ui.panel_2.medianFPS:setText(string.format("Median:\n %.1f", medianFps))
    controllerFPS.ui.panel_2.maxFPS:setText(string.format("Max:\n %.1f", maxFps))
    controllerFPS.ui.panel_2.stdFPS:setText(string.format("Std:\n %.1f", stdDevFps))

    -- RAM
    controllerFPS.ui.panel_3.minLua:setText(string.format("Min:\n %.1f", minMemory))
    controllerFPS.ui.panel_3.medianLua:setText(string.format("Median:\n %.1f", medianMemory))
    controllerFPS.ui.panel_3.maxLua:setText(string.format("Max:\n %.1f", maxMemory))
    controllerFPS.ui.panel_3.stdLua:setText(string.format("Std:\n %.1f", stdDevMemory))

    -- Lua RAM
    controllerFPS.ui.panel_metrics_luaram.minLuaRam:setText(string.format("Min:\n %.1f", minLuaMemory))
    controllerFPS.ui.panel_metrics_luaram.medianLuaRam:setText(string.format("Median:\n %.1f", medianLuaMemory))
    controllerFPS.ui.panel_metrics_luaram.maxLuaRam:setText(string.format("Max:\n %.1f", maxLuaMemory))
    controllerFPS.ui.panel_metrics_luaram.stdLuaRam:setText(string.format("Std:\n %.1f", stdDevLuaMemory))
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
    g_logger.info("CSV exported successfully: " .. filename)
end

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
    digPanel = g_ui.createWidget('DigPanel', controllerFPS.ui.Barra)

    digBar = digPanel:getChildById('digBar')
    digText = digPanel:getChildById('digText')

    local startTime = g_clock.millis()
    local endTime = startTime + (timer * 1000)

    update(endTime, timer)
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
    if not controllerFPS.ui then
        return
    end
    controllerFPS.ui:hide()
end

function show()
    if not controllerFPS.ui then
        return
    end

    controllerFPS.ui:show()
    controllerFPS.ui:raise()
    controllerFPS.ui:focus()
end

function toggle()
    if not controllerFPS.ui then
        return
    end

    if controllerFPS.ui:isVisible() then
        return hide()
    end
    show()
end