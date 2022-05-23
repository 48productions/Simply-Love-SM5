-- Footer to be used across several screens

-- For certain screens, also show a rotating selection of footer texts to help with menu navigation
local screenName -- Cache the current screen name for when we fetch help text lines
local footerTextCategory = "Songs" -- The "Category" of help texts we're showing (are we selecting a song? A group? A difficulty?)
local footerTextId = 1 -- For categories with multiple lines of text, which line are we showing?
local footerMaxTextId = 2 -- How many lines are there to show?

return Def.ActorFrame{
    -- Footer quad
    Def.Quad{
        Name="Footer",
        InitCommand=function(self)
            self:draworder(90):zoomto(_screen.w, 32):vertalign(bottom):y(0)
            
            if ThemePrefs.Get("DarkMode") then
                self:diffuse(header_dark)
            else
                self:diffuse(header_light)
            end
        end,
        ScreenChangedMessageCommand=function(self)
            if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusicCasual" then
                self:diffuse(header_dark)
            end	
        end
    },
    
    -- Help Text
    LoadFont("Common Normal")..{
        InitCommand=function(self)
            self:diffusealpha(0):draworder(91):y(-16):zoom(0.7)
        end,
        OnCommand=function(self)
            -- Don't load on screens where helptext isn't needed
            screenName = SCREENMAN:GetTopScreen():GetName()
            if screenName ~= "ScreenSelectMusicCasual" and screenName ~= "ScreenSelectMusic" then return end
            self:queuecommand("ChangeText")
        end,
        OffCommand=function(self) self:stoptweening():smooth(0.15):diffusealpha(0) end,
        
        -- ScreenSelectMusicCasual - three categories: Groups, Songs, SingleSong
        SwitchFocusToGroupsMessageCommand=function(self)
            footerTextCategory = "Groups"
            footerTextId = 1
            footerMaxTextId = 1
            self:finishtweening():queuecommand("ChangeText")
        end,
        SwitchFocusToSongsMessageCommand=function(self)
            footerTextCategory = "Songs"
            footerTextId = 1
            footerMaxTextId = 2
            self:finishtweening():queuecommand("ChangeText")
        end,
        SwitchFocusToSingleSongMessageCommand=function(self)
            footerTextCategory = "SingleSong"
            footerTextId = 1
            self:finishtweening():queuecommand("ChangeText")
        end,
        
        -- ScreenSelectMusic - two categories: Songs, Difficulty
        SongChosenMessageCommand=function(self)
            footerTextCategory = "Difficulty"
            footerTextId = 1
            self:finishtweening():queuecommand("ChangeText")
        end,
        SongUnchosenMessageCommand=function(self)
            footerTextCategory = "Songs"
            footerTextId = 1
            self:finishtweening():queuecommand("ChangeText")
        end,
        SortMenuOpenedMessageCommand=function(self)
            footerTextCategory = "Sort"
            footerTextId = 1
            self:finishtweening():queuecommand("ChangeText")
        end,
        SortMenuClosedMessageCommand=function(self)
            footerTextCategory = "Songs"
            footerTextId = 1
            self:finishtweening():queuecommand("ChangeText")
        end,
        
        -- Where the Magic happens
        ChangeTextCommand=function(self)
            footerTextId = (footerTextId + 1) % footerMaxTextId
            self:diffusealpha(0):settext(THEME:GetString(screenName, "FooterText"..footerTextCategory..footerTextId)):linear(0.15):diffusealpha(1):sleep(3):queuecommand("ChangeText")
        end,
    }
}
