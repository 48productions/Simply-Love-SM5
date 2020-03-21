--48's Splash text thingy - Need more Minecraft with your Stepmania? Here you go!

--Add/remove lines of text from this list - it will randomly pick one to display when loaded
local SplashList = {
	"Get up and dance, man!", --Pump references
	"Stay in the groove!",
	"Party all day,\nparty all night!",
	"No need for a revolution,\nwe Ashura better solution!",
	"Join the party and\nclap your hands!",
	"Slam it, Jam it,\nPump it Up!",
	"Rave Until The Night Is Over!",
	"Dance the night away!",
	"Can your legs keep Up & Up?",
	"Left go right go right\ngo pick up the step!", --DDR references
	"Green black and blue make the colors\nin the sky!",
	"Use your feet and\ndance to the beat!",
	"Feel the rhythm in your soul!",
	"Come on, let me hear\nyou say RIGHT!",
	"Ducking Hardcore Edition!",
	"We're going to have a party,\nhave a really great time!",
	"[Tribal chants]",
	"We are the Cartoon Heroes, oh-WOAH-oh!",
	"Welcome to the toon town party!",
	"Feelin blue, I'm thinkin' of you!",
	"[bagpipe sounds]",
	"Come along and sing a song,\nand join the jamboree!",
	"Dive down the rabbit hole!", --Etc
	"Part of a complete\nbreakfast!",
	"Almost like\nIn The Groove 3!",
	"Now mostly sans-free!",
	"100% Open Source!",
	"Fork me on Github!",
	"ft. Terrible Jokes",
	"Now with extra\nR A I N B O W S !",
	"What do you mean this splash text\n reminds you of something?",
	"NotNotITG!",
	"StepMania!\nGGGGGOOOOOLLLLLDDDDD!",
	"stepbeats REV. MOONRISE",
	"Half-baked!", --Idaho/Potato/Idaho Rhythm Group memes???
	"Potato EVOLVED!",
	"Potato Revolution!",
	"Kerning!",
	"H E Y  G O R G E",
	"Where the heck is Idaho anyways?",
	"Locally grown,\nfreshly baked!",
	"Just add pudding!",
	"Stomp With the Duck!",
	"Naaa naaa na naa naa naaa!\nNaa naa naa nananaa naa naaa!", --Copypastas
	"Dariri Ram dariram dariram\nDarirari rariram\nDaririram dam!",
	"\"Your thundering sound become\nthe flash light that\npierces soul of crowd\"",
	"\"We're gonna make U dance!\nU can move your feet on the PUMP stage!\nU'll be the dancing hero in a minute.\nDon't U wanna feel the fever of dance?\nCome on everybody and let's just PUMP IT UP\"",
	"Oooooooo AAA E A A I A U\nJOooooo AA E O A A U U A\nEeeeeeeee AA E A E I E A\nJOooooo EE O A AA AAA",
	"\"Despite many people believing Idaho\nis a fictional location, it borders the\nstates of Washington and Oregon in the\nUnited States. Its most famous feature\nis being home to Nanahira's first US appearance.\"",
}

local minZoom = 0
local maxZoom = 0

return Def.BitmapText{
		Name="SplashBitmapText",
		Font="_wendy small", --Change the font, here!
		Text=SplashList[math.random(1, #SplashList)], --Set the displayed text to a random line from the above list
		InitCommand=function(self)
			local x = _screen.cx + _screen.cx / 2
			local y = _screen.cy / 2
			
			--Set zoom dynamically based on splash string length. That way the copypastas don't take up half the screen
			maxZoom = 0.45 - (string.len(self:GetText()) * 0.0005)
			minZoom = maxZoom - 0.05
			
			self:Center():rotationz(20):xy(x, y):diffuse(GetHexColor(SL.Global.ActiveColorIndex)):zoom(maxZoom):diffusealpha(0) --Set rotation, position, and (diffuse) color
			if self:GetText() == "Now with extra\nR A I N B O W S !" then --Add some RAINBOWS!
				self:rainbowscroll(true)
			elseif self:GetText() == "Kerning!" then
				self:jitter(true)
			end
		end,
		OnCommand=function(self) --When the screen is ready, queue the zoom command
			self:queuecommand("Zoom"):linear(0.5):diffusealpha(1)
		end,
		ZoomCommand=function(self) --Zoom command: Smoothly zoom in and out, then queue the zoom command again
			self:smooth(2):zoom(minZoom):smooth(2):zoom(maxZoom):queuecommand("Zoom")
		end
}