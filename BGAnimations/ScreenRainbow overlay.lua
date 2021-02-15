--ScreenRainbow: Now displays configurable news!

local img = THEME:GetPathG("", "_blank.png") --The image to display - default to blank
local news_path = THEME:GetCurrentThemeDirectory() .. "Other/News/" --The path the news config/images are in
local config = nil --The news config file

local curDate = {Year(), MonthOfYear() + 1, DayOfMonth()} --The current date



--Parses a string for a date, returns a table formatted as {year, month, day}
local parseDate = function(opt_date)
    local ret = {}
    local i = 1
    for str in string.gmatch(opt_date, "[^/]+") do --Split our input string at each /, then convert each substring to a number and store it in a table
    
        ret[i] = tonumber(str)
        if ret[i] == nil then return nil end --Ensure the value we got from tonumber is actually a number
        i = i + 1
    end
    
    if #ret == 3 then --Simple validation: We should have three numbers here
        return {ret[3],ret[1],ret[2]}
    else
        return nil
    end
end



--Checks if a given news entry is valid today, given it's start/end dates
local newsValidOnDate = function(opt)
    local startDate = parseDate(opt.StartDate)
    local endDate = parseDate(opt.EndDate)
    
    if startDate == nil or endDate == nil then return false end --Check if we read the start/end dates from the config correctly
    
    --For each field (year/month/day), make sure the current date is between the start/end dates - if it isn't, return false
    for i = 1, 3 do
        if startDate[i] > curDate[i] or endDate[i] < curDate[i] then return false end
    end
    
    return true
end



if FILEMAN:DoesFileExist(news_path.."/news.ini") then --Does news.ini exist? Try loading it
	config = IniFile.ReadFile(news_path.."news.ini")
    if config then --Loaded the news config, now see what news exists:tm:
        
        for id, opt in pairs(config) do --Now iterate through the news entries to find news to display:
            if opt.File and opt.StartDate and opt.EndDate and FILEMAN:DoesFileExist(news_path .. opt.File) then --First: Does this entry have all the needed values (and does the image it specifies actually exist)?
            
                
                if newsValidOnDate(opt) then --Last: Is this news valid on the current date?
                    img = news_path .. opt.File
                    break
                end
                
            end
        end
        
    end
end

--local img = THEME:GetCurrentThemeDirectory() .. "Other/News/test.png"

return Def.Sprite{
    Texture=img,
    InitCommand=function(self) self:FullScreen():diffusealpha(0) end,
    OnCommand=function(self) self:smooth(1):diffusealpha(1) end,
    OffCommand=function(self) self:smooth(1):diffusealpha(0) end,
}