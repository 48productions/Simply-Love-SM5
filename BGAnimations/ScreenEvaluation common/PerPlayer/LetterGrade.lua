if SL.Global.GameMode == "StomperZ" then return end

local player = ...

local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local grade = playerStats:GetGrade()

local style = ThemePrefs.Get("VisualTheme")
local c = GetCurrentColor()

-- "I passd with a q though."
local title = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
if title == "D" then grade = "Grade_Tier99" end

local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/"..grade..".lua"), playerStats)..{
	InitCommand=function(self)
		self:x(70 * (player==PLAYER_1 and -1 or 1))
		self:y(_screen.cy-134):diffusealpha(0):zoom(0.45)
        if AllowThonk() then self:bob():effectmagnitude(0,3,0) end
	end,
	OnCommand=function(self) self:diffusealpha(0):sleep(2.25):smooth(0.1):zoom(0.4):diffusealpha(1) end
}
t[#t+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/Combo 100milestone splode"))..{
    InitCommand=function(self) self:xy(70 * (player==PLAYER_1 and -1 or 1), _screen.cy - 134):diffusealpha(0):blend("BlendMode_Add") end,
    OnCommand=function(self) self:sleep(2.35):diffuse(c):rotationz(10):zoom(0.25):diffusealpha(.6):decelerate(0.6):rotationz(0):zoom(2):diffusealpha(0) end
}

t[#t+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/Combo 100milestone splode"))..{
    InitCommand=function(self) self:xy(70 * (player==PLAYER_1 and -1 or 1), _screen.cy - 134):diffusealpha(0):blend("BlendMode_Add") end,
    OnCommand=function(self) self:sleep(2.35):diffuse(c):rotationz(40):zoom(0.25):diffusealpha(.6):decelerate(0.6):rotationz(20):zoom(1):diffusealpha(0) end
}

t[#t+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/Combo 100milestone minisplode"))..{
    InitCommand=function(self) self:xy(70 * (player==PLAYER_1 and -1 or 1), _screen.cy - 134):diffusealpha(0):blend("BlendMode_Add") end,
    OnCommand=function(self) self:sleep(2.35):diffuse(c):rotationz(10):zoom(0.25):diffusealpha(1):decelerate(0.4):rotationz(0):zoom(1.8):diffusealpha(0) end
}

return t