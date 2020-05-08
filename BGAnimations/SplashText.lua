--48's Splash text thingy - Need more Minecraft with your Stepmania? Here you go!

--Add/remove lines of text from this list - it will randomly pick one to display when loaded
local SplashList = {
	"Get up and dance, man!", --Pump references
	"Stay in the groove!",
	"Party all day,\nparty all night!",
	"No need for a revolution,\nwe Ashura better solution!",
	"Join the party and\nclap your hands!",
	"Move your body\nto Infinity!",
	"Slam it, Jam it,\nPump it Up!",
	"Rave Until The Night Is Over!",
	"Dance the night away!",
	"Can your legs keep Up & Up?",
	"Here comes a new player!",
	"Stomp your feet forever!",
	"Beyond Evolution!",
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
	"Dive down the rabbit hole!", --Etc random garbage
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
	"Support your local arcades!",
	"Support your local community!",
	"Join your local community!",
	"Participate in local events!",
	"This isn't even my final form,\nDA-DON!",
	"A new challenger approaches!",
	"Show me your moves!",
	"It's a Big Deal!",
	"It's a\nFreestyle Takeover!",
	"Rumble in the Desert!",
	"This was a mistake!",
	"Link Up!",
	"Get dunked on!",
        "I bet you can't\n press Start!",
        "I bet you can't\n press Select!",
        "Half-baked!", --Idaho/Potato/Idaho Rhythm Group memes???
	"Potato EVOLVED!",
	"Potato Revolution!",
	"Kerning!",
	"H E Y  G O R G E",
	"Where the heck is Idaho anyways?",
	"Locally grown,\nfreshly baked!",
	"Just add pudding!",
	"Stomp With the Duck!",
	"Now slightly less\ncursed!",
	"It's finally here!", --SimplyPotato cab arrived at the arcade - 4/1/2020. The Idaho scene finally has a decent 4 panel cab :D
	"Smashing arrows since 2018!",
        "The Yukon Gold of dance games!",
        "Now with WiFi!",
        "Classic as a Russet,\nTasty as a tater tot!",
	"Naaa naaa na naa naa naaa!\nNaa naa naa nananaa naa naaa!", --Copypastas
	"Dariri Ram dariram dariram\nDarirari rariram\nDaririram dam!",
	"\"Your thundering sound become\nthe flash light that\npierces soul of crowd\"",
	"\"We're gonna make U dance!\nU can move your feet on the PUMP stage!\nU'll be the dancing hero in a minute.\nDon't U wanna feel the fever of dance?\nCome on everybody and let's just PUMP IT UP\"",
	"Oooooooo AAA E A A I A U\nJOooooo AA E O A A U U A\nEeeeeeeee AA E A E I E A\nJOooooo EE O A AA AAA",
	"A real-time\ndance music game!",
	"A real-time dance music\ngame hard and fat.\nThat's beat mania!\nIt's too cool!",
	--"\"Despite many people believing Idaho\nis a fictional location, it borders the\nstates of Washington and Oregon in the\nUnited States. Its most famous feature\nis being home to Nanahira's first US appearance.\"", --Rest in piece Anime Oasis 2020, cancelled by corona. Here's to hoping Nanahira shows up in Anime Oasis 2021 (in Idaho of all places lmao)
	"Not yet cancelled!",
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
	"Also try non-rhythm games!",
	"Also try Minecraft!", --Now let's try other games/play styles in general
	"Also try Terraria!",
	"Also try co-op!",
	"Also try routines!",
	"Also try modfiles",
	"Also try Mawaru!",
}

local arg = ...

local minZoom = 0
local maxZoom = 0

local function InputHandler(event)
	if (event.PlayerNumber and event.button and event.type == "InputEventType_Release" and event.GameButton == "Select") then  --The button is mapped to a player and a button, and the select button has been released, swap out the splash text
		MESSAGEMAN:Broadcast("SwitchSplash")
	end
end


return Def.BitmapText{
		Name="SplashBitmapText",
		Font="_wendy small", --Change the font, here!
		Text="...", --Use placeholder text for now, to be updated below
		InitCommand=function(self)
			local x = _screen.cx / 2
			local y = _screen.cy / -2

			self:Center():rotationz(20):zoom(0):xy(x, y):diffuse(GetHexColor(SL.Global.ActiveColorIndex)):diffusealpha(0):queuecommand("SetText") --Set rotation, position, and (diffuse) color
		end,
		
		OnCommand=function(self) --When the screen is ready, set initial zoom, queue the zoom command, and add the input callback
			SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
			self:queuecommand("FadeIn"):queuecommand("Zoom")
		end,
		
		OffCommand=function(self) --When we're transitioning to a new screen, fade out the text
			SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler) --This feels like a good idea, does it actually matter? - 48
			self:smooth(0.2):diffusealpha(0)
		end,
		
		FadeInCommand=function(self) --Fade in the text when starting the screen (implemented as a Command as a workaround with how SetText's zoom tween and the fade in interacted)
			self:smooth(0.3):diffusealpha(1)
		end,
		
		ZoomCommand=function(self) --Zoom command: Smoothly zoom in and out, then queue the zoom command again
			self:smooth(2):zoom(minZoom):smooth(2):zoom(maxZoom):queuecommand("Zoom")
		end,
		
		SetTextCommand=function(self) --Set text for the splash to use, checking the argument given to SplashText.lua, date, etc to see if we need to show a special splashes
		
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
				self:settext(SplashList[math.random(1, #SplashList)]) --Set the displayed text to a random line from the above list
			end
	
			-- If you need to test a string, do so here
			--self:settext("")
			
			if AllowThonk() then --Hard-code zoom if we're gonna be thonking
				maxZoom = 1.5
				minZoom = 1.3
			else
				--Set zoom dynamically based on splash string length. That way the copypastas don't clip off the screen
				maxZoom = 0.45 - (string.len(self:GetText()) * 0.0005)
				minZoom = maxZoom - 0.05
			end
			
			self:zoom(maxZoom) --Zoom to our newly-calculated max zoom
			
			if self:GetText() == "Now with extra\nR A I N B O W S !" then --Add some RAINBOW
				self:rainbowscroll(true)
			elseif self:GetText() == "Kerning!" then --Add some kerning!
				self:jitter(true)
			end
		end,
		
		SwitchSplashMessageCommand=function(self) 	--SwitchSplash: Switch to a new splash and play some funky animations while doing so (for updating the splash while the screen is being shown)
			self:jitter(false):rainbowscroll(false):finishtweening():bouncebegin(0.2):zoom(0) --Cancel previous animations/effects, zoom text out
			--SetText(self)
			self:queuecommand("SetText") --Set a new random splash
			self:bounceend(0.2):zoom(maxZoom):queuecommand("Zoom") --Zoom text back in and queue the looping zoom command again
		end
}
