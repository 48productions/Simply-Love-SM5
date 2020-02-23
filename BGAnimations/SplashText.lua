--48's Splash text thingy - Need more Minecraft with your Stepmania? Here you go!

--Add/remove lines of text from this list - it will randomly pick one to display when loaded
local SplashList = {
	"Get up and dance, man!",
	"Stay in the groove!",
	"Party all day,\nparty all night!",
	"No need for a revolution,\nwe Ashura better solution!",
	"Join the party and\nclap your hands!",
	"Slam it, Jam it,\nPump it Up!",
	"Rave 'til The Nights Over!",
	"Dive down the rabbit hole!",
	"Part of a complete\nbreakfast!",
	"Almost like\nIn The Groove 3!",
	"Now sans-free!",
	"100% Open Source!",
	"Fork me on Github!",
	"Potato Revolution!",
	"ft. Terrible Jokes",
}

return Def.BitmapText{
		Name="SplashBitmapText",
		Font="_wendy small", --Change the font, here!
		Text=SplashList[math.random(1, #SplashList)], --Set the displayed text to a random line from the above list
		InitCommand=function(self)
			local x = _screen.cx + _screen.cx / 2
			local y = _screen.cy / 2
			self:Center():rotationz(25):xy(x, y):diffuse(GetHexColor(SL.Global.ActiveColorIndex)):zoom(0.5):diffusealpha(0) --Set rotation, position, and (diffuse) color
		end,
		OnCommand=function(self) --When the screen is ready, queue the zoom command
			self:queuecommand("Zoom"):linear(0.5):diffusealpha(1)
		end,
		ZoomCommand=function(self) --Zoom command: Smoothly zoom in and out, then queue the zoom command again
			self:smooth(2):zoom(0.4):smooth(2):zoom(0.5):queuecommand("Zoom")
		end
}