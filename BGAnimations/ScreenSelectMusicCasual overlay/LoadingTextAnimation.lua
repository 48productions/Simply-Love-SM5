--This is the second half of the loading text's animation, continued from ScreenProfileLoad
--This is also currently unused so that we can get a slick transition from mode select to select music

local NumWheelItems = 15
local TweenTime = 0.03

return Def.BitmapText{
    Font="_wendy small",
	Text=THEME:GetString("ScreenProfileLoad","Loading Profiles..."),
	InitCommand=function(self)
		self:diffuse( ThemePrefs.Get("RainbowMode") and Color.Black or Color.White ):zoom(0.6):diffusealpha(1):draworder(101):xy(_screen.cx, _screen.h / 6)
	end,
       OnCommand=function(self)
           self:accelerate(TweenTime * (NumWheelItems - 4)):y(0):diffusealpha(0)
       end
}