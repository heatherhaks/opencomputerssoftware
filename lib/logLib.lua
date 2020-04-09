local logger = {}

function logger.new(drawingLib, x, y, width, height, opts)
    local interface = {}
    interface.drawer = drawingLib
    interface.x = x
    interface.y = y
    interface.width = width
    interface.height = height

    interface.opts = opts or {}
    interface.opts.title = opts.title or nil
    interface.opts.foreground = opts.foreground or interface.drawer.foreground
    interface.opts.background = opts.background or interface.drawer.background
    interface.opts.borderForeground = opts.borderForeground or opts.foreground
    interface.opts.borderBackground = opts.borderBackground or opts.background
    interface.opts.titleForeground = opts.titleForeground or opts.foreground
    interface.opts.titleBackground = opts.titleBackground or opts.background

    interface.logBuffer = {}
    interface.isDirty = true
    function interface.addLog(message, foreground, background)
        local foreground = foreground or interface.opts.foreground
        local background = background or interface.opts.background

        function addToBuffer(words, first)
            interface.isDirty = true
            if #words == 0 then return end
            local word = table.remove(words)

            if first == true then
                if word:len() > interface.width - 2 then
                    local firstPart = word:sub(1, interface.width - 2)
                    local secondPart = word:sub(interface.width - 1, word:len())
                    table.insert(interface.logBuffer, 1, {firstPart, foreground, background})
                    table.insert(words, secondPart)
                    return addToBuffer(words, "new line", foreground, background)
                end
                table.insert(interface.logBuffer, 1, {word, foreground, background})
                return addToBuffer(words, foreground, background)
            else
                if first == "new line" then
                    if word:len() + 2 > interface.width - 2 then
                        local firstPart = "  "..word:sub(1, interface.width - 4)
                        local secondPart = word:sub(interface.width - 3, word:len())
                        table.insert(interface.logBuffer, 1, {firstPart, foreground, background})
                        table.insert(words, secondPart)
                        return addToBuffer(words, "new line", foreground, background)
                    end

                    table.insert(interface.logBuffer, 1, {"  "..word, foreground, background})
                    return addToBuffer(words, "", foreground, background)
                else
                    if word:len() + 2 > interface.width - 2 then
                        local firstPart = word:sub(1, interface.width - 3 - interface.logBuffer[1][1]:len())
                        local secondPart = word:sub(interface.width - 2 - interface.logBuffer[1][1]:len(), word:len())
                        interface.logBuffer[1][1] = interface.logBuffer[1][1].." "..firstPart
                        table.insert(words, secondPart)
                        return addToBuffer(words, "new line", foreground, background)
                    end
                    if word:len() + 1 > interface.width - 3 - interface.logBuffer[1][1]:len() then
                        table.insert(words, word)
                        return addToBuffer(words, "new line", foreground, background)
                    end
                    interface.logBuffer[1] = {interface.logBuffer[1][1].." "..word, foreground, background}
                    return addToBuffer(words)
                end
            end
        end

        local words = {}
        for word in message:gmatch("%S+") do
            table.insert(words, 1, word)
        end
        addToBuffer(words, true)

        while #interface.logBuffer > interface.height -2 do table.remove(interface.logBuffer) end
    end

    function interface.draw()
        function drawRect()
            interface.drawer.drawCell(interface.x, interface.y, {"╔", interface.opts.borderForeground, interface.opts.borderBackground})
            interface.drawer.drawCell(interface.x + interface.width - 1, interface.y, {"╗", interface.opts.borderForeground, interface.opts.borderBackground})
            interface.drawer.drawCell(interface.x, interface.y + interface.height - 1, {"╚", interface.opts.borderForeground, interface.opts.borderBackground})
            interface.drawer.drawCell(interface.x + interface.width - 1, interface.y + interface.height - 1, {"╝", interface.opts.borderForeground, interface.opts.borderBackground})
            for i = interface.x + 1, interface.x + interface.width - 2 do
                interface.drawer.drawCell(i, interface.y, {"═", interface.opts.borderForeground, interface.opts.borderBackground})
                interface.drawer.drawCell(i, interface.y + interface.height - 1, {"═", interface.opts.borderForeground, interface.opts.borderBackground})
            end
            for i = interface.y + 1, interface.y + interface.height - 2 do
                interface.drawer.drawCell(interface.x, i, {"║", interface.opts.borderForeground, interface.opts.borderBackground})
                interface.drawer.drawCell(interface.x + interface.width - 1, i, {"║", interface.opts.borderForeground, interface.opts.borderBackground})
            end
            interface.drawer.drawRect(interface.x + 1, interface.y + 1, interface.width - 2, interface.height - 2, {" ", interface.opts.background, interface.opts.background})

            interface.drawer.drawCell(interface.x + 2, interface.y, {"╡", interface.opts.borderForeground, interface.opts.borderBackground})
            interface.drawer.drawCell(interface.x + 2 + interface.opts.title:len() + 1, interface.y, {"╞", interface.opts.borderForeground, interface.opts.borderBackground})
            interface.drawer.drawString(interface.x + 3, interface.y, interface.opts.title, interface.opts.titleForeground, interface.opts.titleBackground)
        end

        function drawLogEntries()
            for i = 1, #interface.logBuffer do
                if interface.logBuffer[i] ~= nil then
                    interface.drawer.drawString(interface.x + 1, interface.y + interface.height - 1 - i,
                            interface.logBuffer[i][1], interface.logBuffer[i][2], interface.logBuffer[i][3])
                end
            end
        end

        if interface.isDirty then
            drawRect()
            drawLogEntries()

            interface.drawer.commit()
            interface.isDirty = false
        end
    end
    return interface
end


return logger