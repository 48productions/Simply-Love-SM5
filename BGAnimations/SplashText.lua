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
	"Here comes a new player!",
	"Stomp your feet forever!",
	"Left go right go right\ngo pick up the step!", --DDR/BEMANI references
	"Green black and blue make\nthe colors in the sky!",
	"Use your feet and\ndance to the beat!",
	"Feel the rhythm in your soul!",
	"Come on, let me hear\nyou say RIGHT!",
	"Ducking Hardcore Edition!",
	"We're going to have a party,\nhave a really great time!",
	"[Tribal chants]",
	"We are the Cartoon Heroes,\noh-WOAH-oh!",
	"Welcome to the toon town party!",
	"Feelin blue, I'm thinkin' of you!",
	"[bagpipe sounds]",
	"Come along and sing a song,\nand join the jamboree!",
	"shanrara, shanrara!",
	"Make the moves 'n' all\nwith the dance hall king!",
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
	"NotDDR!",
	"StepMania!\nGGGGGOOOOOLLLLLDDDDD!",
	"stepbeats REV. MOONRISE",
	"NOW LET ME SEE YOU DANCE!",
	"It's finally here!",
	"Thank your arcade staff!",
	"Support your local community!",
	"Participate in local events!",
	"This isn't even my final form,\nDA-DON!",
	"A new challenger approaches!",
	"Show me your moves!",
	"It's a Big Deal!",
	"It's a\nFreestyle Takeover!",
	"Rumble in the Desert!",
	"This was a mistake!",
	"Get dunked on!",
	"Half-baked!", --Idaho/Potato/Idaho Rhythm Group memes???
	"Potato EVOLVED!",
	"Potato Revolution!",
	"Kerning!",
	"H E Y  G O R G E",
	"Where the heck is Idaho anyways?",
	"Locally grown,\nfreshly baked!",
	"Just add pudding!",
	"Stomp With the Duck!",
	"It's finally here!", --SimplyPotato cab arrived at the arcade - 4/1/2020. The Idaho scene finally has a decent 4 panel cab :D
	"Smashing arrows since 2018!",
	"Naaa naaa na naa naa naaa!\nNaa naa naa nananaa naa naaa!", --Copypastas
	"Dariri Ram dariram dariram\nDarirari rariram\nDaririram dam!",
	"\"Your thundering sound become\nthe flash light that\npierces soul of crowd\"",
	"\"We're gonna make U dance!\nU can move your feet on the PUMP stage!\nU'll be the dancing hero in a minute.\nDon't U wanna feel the fever of dance?\nCome on everybody and let's just PUMP IT UP\"",
	"Oooooooo AAA E A A I A U\nJOooooo AA E O A A U U A\nEeeeeeeee AA E A E I E A\nJOooooo EE O A AA AAA",
	"A real-time\ndance music game!",
	"A real-time dance music\ngame hard and fat.\nThat's beat mania!\nIt's too cool!",
	--"\"Despite many people believing Idaho\nis a fictional location, it borders the\nstates of Washington and Oregon in the\nUnited States. Its most famous feature\nis being home to Nanahira's first US appearance.\"", --Rest in piece Anime Oasis 2020, cancelled by corona. Here's to hoping Nanahira shows up in Anime Oasis 2021 (in Idaho of all places lmao)
	"Also try beatmania!", --Also try [other game at Jeremy's] (because minecraft has a bunch of these too)
	"Also try crossbeats!",
	"Also try DDR Solo!",
	"Also try DanceEvolution!",
	"Also try Groove Coaster!",
	"Also try jubeat!",
	"Also try maimai!",
	"Also try Paca Paca Passion Special!",
	"Also try ParaParaParadise!",
	"Also try pop'n music!",
	"Also try Pump It Up!",
	"Also try Sound Voltex!",
	"Also try Taiko no Tatsujin!",
	"Also try Magical Truck Adventure!",
	"Also try Mahjong!",
	"Also try Hangly-Man!",
	"Also try Minecraft!",
}

local arg = ...

local minZoom = 0
local maxZoom = 0

return Def.BitmapText{
		Name="SplashBitmapText",
		Font="_wendy small", --Change the font, here!
		Text="...", --Set the displayed text to a random line from the above list
		InitCommand=function(self)
			local x = _screen.cx / 2
			local y = _screen.cy / -2

			if arg == 1 then --I LOVE VIDEO GAMEEES (yes with 3 e's)
				self:settext("I LOVE VIDEO GAMES!")
			elseif AllowThonk() then --THONK TIME
				self:settext("🤔🤔🤔🤔🤔")
				self:rainbowscroll(true):jitter(true):vibrate():effectmagnitude(1.1, 1.1, 1.1)
			elseif MonthOfYear()==9 and math.random(1, 5) == 1 then
				self:settext("Happy Halloween!")
			elseif HolidayCheer() and math.random(1, 5) == 1 then -- the best way to spread holiday cheer is singing loud for all to hear
				self:settext("Merry Christmas!")
			elseif MonthOfYear()==10 and DayOfMonth()==20 and math.random(1, 5) == 1 then
				self:settext("Happy 20,november!")
			else 
				self:settext(SplashList[math.random(1, #SplashList)])
			end

			-- If you need to test a string, do so here
			--self:settext("")
			
			if AllowThonk() then
				maxZoom = 1.5
				minZoom = 1.3
			else
				--Set zoom dynamically based on splash string length. That way the copypastas don't take up half the screen
				maxZoom = 0.45 - (string.len(self:GetText()) * 0.0005)
				minZoom = maxZoom - 0.05
			end
			
			self:Center():rotationz(20):xy(x, y):diffuse(GetHexColor(SL.Global.ActiveColorIndex)):zoom(maxZoom):diffusealpha(0) --Set rotation, position, and (diffuse) color
			if self:GetText() == "Now with extra\nR A I N B O W S !" then --Add some RAINBOWS!
				self:rainbowscroll(true)
			elseif self:GetText() == "Kerning!" then
				self:jitter(true)
			end
		end,
		OnCommand=function(self) --When the screen is ready, queue the zoom command
			self:queuecommand("Zoom"):smooth(0.5):diffusealpha(1)
		end,
		OffCommand=function(self) --When the screen is ready, queue the zoom command
			self:smooth(0.2):diffusealpha(0)
		end,
		ZoomCommand=function(self) --Zoom command: Smoothly zoom in and out, then queue the zoom command again
			self:smooth(2):zoom(minZoom):smooth(2):zoom(maxZoom):queuecommand("Zoom")
		end
}