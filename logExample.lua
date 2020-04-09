local term = require("term")
local logLib = require("logLib")
local drawLib = require("drawLib")

--the drawing lib's api is as follows:
--drawLib.new(foreground: Number, background: Number): Table
  --Returns a drawLib object, foreground and background refer to the default colors to use, in hexadecimal 0xFFFFFF format
--local drawer = drawLib.new(0x000000, 0xFFFFFF)
  --example draw object creation
--when seen elsewhere, cell refers to a table where the first entry is a string representing a character, and two colors in hexadecimal format
--drawer.drawCell(x, y, cell)
  --adds a cell to the draw buffer
--drawer.eraseCell(x, y)
  --adds an erase command to the draw buffer
--drawer.clear()
  --adds erase commands to the entire draw buffer
--drawer.drawRect(x, y, width, height, cell)
  --adds a rectangular grouping of cells to the draw buffer
--drawer.eraseLine(y)
  --adds a line of erase commands to the draw buffer
--drawer.eraseRect(x, y, width, height)
  --adds a rectangular group of erase commands to the draw buffer
--drawer.drawString(x, y, string, foreground, background, width, height)
  --adds a string of cells to the draw buffer
--drawer..commit()
  --commits the draw buffer to the screen

--the logging lib's api is as follows:
--logLib.new(drawLibObject: Table, x: Number, y: Number, width: Number[, opts: Table]): Table
  --returns a logger object. It accepts a drawing object, an X and a Y location,
  --a width and a height for the window, and a table full of the following fields:
    --title: String --title of the log window, defaults to 'Log'
    --foreground: Nunmber --the default text foreground color, defaults to drawLib's default foreground color
    --background: Number --the default text background color, defaults to drawLib's default background color
    --borderForeground: Number --the border foreground color, defaults to foreground color
    --borderBackground: Number --the border background color, defaults to background color
    --titleForeground: Number --the title foreground color, defaults to foreground color
    --titleBackground: Number --the title background color, defaults to background color
--local log = logLib.new(drawer, x, y, width, height)
  --example of making a logLib object
--log.addLog(message :String, foreground: Number, background: Number)
  --foreground and background refer to hexadecimal color codes in 0xFFFFFF format, both are optional
--log.draw()
  --draws the logging object

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
