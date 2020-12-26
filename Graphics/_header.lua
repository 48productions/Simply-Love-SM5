return Def.ActorFrame{
	Name="Header",

	Def.Quad{
		InitCommand=function(self)
			self:zoomto(_screen.w, 32):vertalign(top):x(_screen.cx)
			if ThemePrefs.Get("DarkMode") then
				self:diffuse(header_dark)
			else
				self:diffuse(header_light)
			end
		end,
		ScreenChangedMessageCommand=function(self)
			local topscreen = SCREENMAN:GetTopScreen():GetName()
			if SL.Global.GameMode == "Casual" and (topscreen == "ScreenEvaluationStage" or topscreen == "ScreenEvaluationSummary") then
				self:diffuse(header_dark)
			end
		end,
	},

	LoadFont("_upheaval_underline 80px")..{
		Name="HeaderText",
		Text=string.upper(ScreenString("HeaderText")),
		InitCommand=function(self) self:diffusealpha(0):zoom(WideScale(0.305,0.365)):horizalign(left):xy(10, 12) end,
		OnCommand=function(self) self:sleep(0.1):decelerate(0.33):diffusealpha(1) end,
		OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end
	}
}
