-- modified from 5.3 default

-- max height, max width
local maxh, maxw = 70, 70


local t = Def.ActorFrame{
    InitCommand=function(self) self:diffusealpha(0) end,
    OnCommand=function(self) self:sleep(1.25):smooth(0.5):diffusealpha(1) end,
    Def.Sprite {
        Name="CDTitle",
        OnCommand=function(self) self:x(120):y(150):diffuseshift():effectperiod(5):effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.5) end,
        CurrentSongChangedMessageCommand=function(self) self:playcommand("Set") end,
        CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
        SetCommand=function(self)
            local song = GAMESTATE:GetCurrentSong()
            local cdtitle = self
            local height = cdtitle:GetHeight()
            local width = cdtitle:GetWidth()

            if song then
                if song:HasCDTitle() then
                    cdtitle:stoptweening():diffusealpha(0)
                    cdtitle:Load(song:GetCDTitlePath())
                        -- Zoom weird (large) CDTitles to maxh or maxw
                    if height >= maxh and width >= maxw then
                        if height >= width then
                                cdtitle:zoom(maxh/height)
                        else
                            cdtitle:zoom(maxw/width)
                        end;
                    elseif height >= maxh then
                        cdtitle:zoom(maxh/height)
                    elseif width >= maxw then
                        cdtitle:zoom(maxw/width)
                    else 
                        cdtitle:zoom(1)
                    end
                    cdtitle:smooth(0.03):diffusealpha(1)
                    
                else -- No CD title
                    cdtitle:smooth(0.03):diffusealpha(0)
                end
                
            else -- No song
                cdtitle:smooth(0.03):diffusealpha(0)
            end
        end,
    }
}

return t