return Def.Quad{
	Name="Footer",
	InitCommand=function(self)
		self:draworder(90):zoomto(_screen.w, 32):vertalign(bottom):y(32)
		
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
}
