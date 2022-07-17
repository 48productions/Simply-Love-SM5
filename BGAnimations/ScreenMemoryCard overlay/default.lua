local TopString = ScreenString("Top")  --Default the first string to an alternate prompt for when memory cards arne't enabled
local BottomerString = ""

local af = Def.ActorFrame{
	InitCommand=function(self) self:Center() SL.Global.GameplayReloadCheck = false end -- Reset GameplayReloadCheck so that the next ScreenDemonstration loop has the proper intro animation
}

--SCREENMAN:SystemMessage(PREFSMAN:GetPreference("MemoryCards"))
if PREFSMAN:GetPreference("MemoryCards") ~= true then --Memory cards aren't enabled, display alternate prompts
	TopString = ScreenString("TopNoMC")
	BottomerString = ScreenString("LocalProfileInfo")
elseif PREFSMAN:GetPreference("CustomSongsEnable") then --Memory cards are enabled and custom songs are enabled, display an extra prompt
	BottomerString = ScreenString("CustomSongs")
end

af[#af+1] = LoadActor("usbicon.png")..{ --USB drive icon
	InitCommand=function(self) self:shadowlength(1) end,
	OnCommand=function(self) self:zoom(0.6):glow(1,1,1,1):glowshift():diffusealpha(0):sleep(1):decelerate(2):diffusealpha(1):sleep(6):linear(0.75):diffusealpha(0) end,
}

af[#af+1] = LoadFont("Common Normal")..{ --Top text (create a profile or a use a USB drive)
	Text=TopString,
	InitCommand=function(self) self:shadowlength(1):y(-60):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(2.0):decelerate(1):diffusealpha(1):sleep(6):linear(0.75):diffusealpha(0) end,
}

af[#af+1] = LoadFont("Common Normal")..{ --Bottom text (...to save scores/prefs)
	Text=ScreenString("Bottom"),
	InitCommand=function(self) self:shadowlength(1):y(60):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(3.0):decelerate(1):diffusealpha(1):sleep(5):linear(0.75):diffusealpha(0) end,
}

af[#af+1] = LoadFont("Common Normal")..{ --Bottomer text (local profile/custom songs)
	Text=BottomerString,
	InitCommand=function(self) self:shadowlength(1):y(90):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(4.0):decelerate(1):diffusealpha(1):sleep(4):linear(0.75):diffusealpha(0) end,
}

return af