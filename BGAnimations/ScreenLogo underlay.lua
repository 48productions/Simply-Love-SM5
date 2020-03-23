local style = ThemePrefs.Get("VisualTheme")
local game = GAMESTATE:GetCurrentGame():GetName()
if game ~= "dance" and game ~= "pump" then
	game = "techno"
end

--Do you like video games?
local video_games = 0
if SPLovesVideoGames() then video_games = 1 end

--Simply AltText!
local image = "TitleMenu"

-- see: watch?v=wxBO6KX9qTA etc.
if FILEMAN:DoesFileExist("/Themes/"..THEME:GetCurThemeName().."/Graphics/_VisualStyles/"..ThemePrefs.Get("VisualTheme").."/TitleMenuAlt (doubleres).png") then
	if math.random(1,100) <= 5 then image="TitleMenuAlt" end
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:Center()
	end,
}

t[#t+1] = LoadActor(THEME:GetPathG("", "_logos"), video_games)..{
	InitCommand=function(self)
		self:y(-16):zoom(0.55):cropright(1)
	end,
	OnCommand=function(self) self:linear(0.33):cropright(0) end
}

t[#t+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/".. image .." (doubleres).png"))..{
	InitCommand=function(self)
		self:x(2):diffusealpha(0):zoom(0.7)
			:shadowlength(1)
	end,
	OnCommand=function(self) self:linear(0.5):diffusealpha(1) end
}

t[#t+1] = LoadActor("./SplashText.lua", video_games)

return t