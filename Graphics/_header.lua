local dark = {0,0,0,0.9}
local light = {0.65,0.65,0.65,0.9}

return Def.ActorFrame{
	Name="Header",

	Def.Quad{
		InitCommand=function(self)
			self:zoomto(_screen.w, 32):vertalign(top):x(_screen.cx)
			if ThemePrefs.Get("RainbowMode") then
				self:diffuse(dark)
			else
				self:diffuse(light)
			end
		end,
		ScreenChangedMessageCommand=function(self)
			local topscreen = SCREENMAN:GetTopScreen():GetName()
			if SL.Global.GameMode == "Casual" and (topscreen == "ScreenEvaluationStage" or topscreen == "ScreenEvaluationSummary") then
				self:diffuse(dark)
			end
		end,
	},

	LoadFont("_upheaval_underline 80px")..{
		Name="HeaderText",
		Text=ScreenString("HeaderText"),
		InitCommand=function(self) self:diffusealpha(0):zoom(0.35):horizalign(left):xy(10, 12) end,
		OnCommand=function(self) self:sleep(0.1):decelerate(0.33):diffusealpha(1) end,
		OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end
	}
}
