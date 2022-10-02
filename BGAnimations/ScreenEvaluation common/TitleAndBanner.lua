local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..ThemePrefs.Get("VisualTheme")
local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()

local banner = {
	directory = (FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")),
	width = 418,
	zoom = 0.7,
}

-- the Quad containing the bpm and music rate doesn't appear in Casual mode
-- so nudge the song title and banner down a bit when in Casual
local y_offset = SL.Global.GameMode=="Casual" and 50 or 46


local af = Def.ActorFrame{ InitCommand=function(self) self:xy(_screen.cx, y_offset) if AllowThonk() then self:spin():effectmagnitude(0,10,0) end end }

if SongOrCourse and SongOrCourse:HasBanner() then
	--song or course banner, if there is one
	af[#af+1] = Def.Banner{
		Name="Banner",
		InitCommand=function(self)
			if GAMESTATE:IsCourseMode() then
				self:LoadFromCourse( GAMESTATE:GetCurrentCourse() )
			else
				self:LoadFromSong( GAMESTATE:GetCurrentSong() )
			end
			self:y(66):setsize(banner.width, 164):zoom(banner.zoom)
		end,
	}
else
	--fallback banner
	af[#af+1] = LoadActor(banner.directory .. "/banner" .. SL.Global.ActiveColorIndex .. " (doubleres).png")..{
		InitCommand=function(self) self:y(66):zoom(banner.zoom) end
	}
end

-- quad behind the song/course title text
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(color_slate2):setsize(banner.width,25):zoom(banner.zoom) end,
}

-- song/course title text
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
        local songtitle
		if GAMESTATE:IsCourseMode() then
            songtitle = GAMESTATE:GetCurrentCourse():GetDisplayFullTitle()
            if songtitle then self:settext(songtitle) end
        else
            local song = GAMESTATE:GetCurrentSong()
            songtitle = song:GetDisplayFullTitle()
            if songtitle then
                self:settext(songtitle)
                if #song:GetDisplaySubTitle() > 0 then
                    self:AddAttribute(#song:GetDisplayMainTitle(), {Length = -1; Diffuse = color("#bbbbbb")})
                end
            end
        end
		self:maxwidth(banner.width*banner.zoom*0.95):maxheight(13):y(-1)
	end
}

return af
