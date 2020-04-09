local term = require("term")
local logLib = require("logLib")
local drawLib = require("drawLib")

local drawer = drawLib.new()
local x = 2
local y = 2
local width = 45
local height = 45
local title = "This Title Can Be Changed"
local borderForeground = 0x00FFFF
local logger = logLib.new(drawer, x,y, width, height, {title = title, borderForeground = borderForeground})

term.clear()

logger.addLog("This log window is positioned at x"..tostring(x)..", y"..tostring(y)..", is "..tostring(width).." wide, "..tostring(height).." high, with an internal dimension of "..tostring(width - 2).."x"..tostring(height - 2))
logger.addLog("The log colors title colors, and border colors can all be customized")
logger.addLog("All colors use hexadecimal notation, for example: 0xFF0000")
logger.addLog("Adding a log entry is as simple as this syntax: logger.addLog(\"message\", foreground, background)")
logger.addLog("Log entries with small words wrap in their entirety to a new line")
logger.addLog("Log entries with words longer than the log window's internal width are chopped into appropriate pieces and wrapped as they fit. For example: 123456790123456790123456790123456790123456790")
logger.addLog("New lines get indented to make it clear what log entry they belong to")
logger.addLog("The log maintains a buffer of previous entries equal to the internal height of the log box")
logger.addLog("The foreground color of log entries can be changed", 0xFF0000)
logger.addLog("The background color of log entries can also be changed", drawer.defaultBackground, drawer.defaultForeground)
logger.addLog("The log window only gets redrawn if there are changes and the drawing library only commits to the screen any areas that get changed")
logger.addLog("I hope you enjoy this library!")

while true do
    logger.draw()
    os.sleep(0.001)
end