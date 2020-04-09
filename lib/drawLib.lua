local term = require("term")
local component = require("component")
local gpu = component.gpu

local draw = {}

function draw.new(foreground, background)
    local interface = {}
    interface.x = 1
    interface.y = 1
    interface.defaultForeground = foreground or 0xFFFFFF
    interface.defaultBackground = background or 0x000000
    local w,h=gpu.getViewport()
    interface.width = w
    interface.height = h

    interface.cellList = {}
    interface.cellList.committed = {}
    interface.cellList.temp = {}

    function interface.convertToString(x, y)
        return tostring(x).." "..tostring(y)
    end

    function interface.convertToNumbers(input)
        local numbers = {}
        for word in string.gmatch(input, "%d+") do
            table.insert(numbers, tonumber(word))
        end
        return numbers
    end

    function interface.isCellsSame(key)
        local tempCell = {}
        if interface.cellList.temp[key] == nil then return false end

        if interface.cellList.temp == "blank" then
            tempCell[1] = nil
            tempCell[2] = interface.defaultForeground
            tempCell[3] = interface.defaultBackground
        else
            tempCell[1] = interface.cellList.temp[key]
        end

        if interface.cellList.temp[key] == "blank" and interface.cellList.committed[key] then return true
        else if interface.cellList.committed[key] == nil then return false end

        end
        local char = {interface.cellList.committed[key][1], interface.cellList.temp[key][1]}
        local foreground = {interface.cellList.committed[key][2], interface.cellList.temp[key][2]}
        local background = {interface.cellList.committed[key][3], interface.cellList.temp[key][3]}

        char[1] = char[1] or nil
        char[2] = char[2] or nil
        foreground[1] = foreground[1] or interface.defaultForeground
        foreground[2] = foreground[2] or interface.defaultForeground
        background[1] = background[1] or interface.defaultBackground
        background[2] = background[2] or interface.defaultBackground
        if char[1] ~= char[2] or foreground[1] ~= foreground[2] or background[1] ~= background[2] then return false end
        return true
    end

    function interface.isNotCellsSame(key)
        if interface.isCellsSame(key) then return false
        else return true end
    end

    function interface.commit()
        for k,v in pairs(interface.cellList.temp) do
            if interface.isNotCellsSame(k) then
                local char
                local foreground
                local background

                if v == "blank" then
                    char = " "
                    foreground = interface.defaultForeground
                    background = interface.defaultBackground
                else
                    char = v[1] or " "
                    foreground = v[2] or interface.defaultForeground
                    background = v[3] or interface.defaultBackground
                end

                interface.cellList.committed[k] = v
                local oldForeground = gpu.getForeground()
                local oldBackground = gpu.getBackground()
                gpu.setForeground(foreground)
                gpu.setBackground(background)
                local coords = interface.convertToNumbers(k)
                gpu.set(coords[1], coords[2], char)
                gpu.setForeground(oldForeground)
                gpu.setBackground(oldBackground)
            end
            if v == "blank" then interface.cellList.committed[k] = nil end
        end
        interface.cellList.temp = {}
    end

    function interface.drawCell(x, y, cell)
        local key = interface.convertToString(x,y)
        if cell == "blank" or (cell[1] == nil and cell[2] == nil and cell[3] == nil) then cell = "blank" end
        interface.cellList.temp[key] = cell
    end

    function interface.eraseCell(x, y)
        interface.drawCell(x, y, "blank")
    end

    function interface.clear()
        term.clear()
        for k, _ in pairs(interface.cellList.committed) do interface.eraseCell(interface.convertToNumbers(k)) end
        gpu.set(1, 1, " ")
    end

    function interface.drawRect(x, y, width, height, cell)
        for i = 0, width - 1 do
            for j = 0, height - 1 do
                interface.drawCell(x + i, y + j, cell)
            end
        end
    end

    function interface.eraseLine(y)
        for i = 1, interface.width do
            local key = interface.convertToString(i, y)
            if interface.cellList.committed[key] ~= nil or interface.cellList.temp[key] ~= nil then
                interface.eraseCell(i, y)
            end
        end
    end

    function interface.eraseRect(x, y, width, height)
        for i = 0, width - 1 do
            for j = 0, height - 1 do
                local key = interface.convertToString(x + i, y + j)
                if interface.cellList.committed[key] ~= nil or interface.cellList.temp[key] ~= nil then
                    interface.eraseCell(x + i, y + j)
                end
            end
        end
    end

    function interface.drawString(x, y, string, foreground, background, width, height)
        local foreground = foreground or interface.defaultForeground
        local background = background or interface.defaultBackground
        local width = width or interface.width
        local height = height or interface.height
        local i = x
        local j = y

        for c in string:gmatch(".") do
            interface.drawCell(i, j, {c, foreground, background})
            i = i + 1
            if i > width then
                i = 2
                j = j + 1
                if j > height then return end
            end
        end
    end

    return interface
end

return draw
