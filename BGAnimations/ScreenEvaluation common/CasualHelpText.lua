if SL.Global.GameMode ~= "Casual" then return end

return Def.BitmapText{
	Font="_upheaval_underline 80px",
	Text=THEME:GetString("ScreenEvaluation", "PressStartToContinue"),
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy + 170):zoom(0.35)
			:diffusealpha(0):shadowlength(0.5)
	end,
	OnCommand=function(self)
		self:sleep(2):diffusealpha(1)
			:diffuseshift():effectperiod(3)
			:effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.25)
	end
}