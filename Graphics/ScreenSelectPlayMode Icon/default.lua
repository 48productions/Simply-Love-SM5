local gc = Var("GameCommand")
local index = gc:GetIndex()
local text = gc:GetName()

local t = Def.ActorFrame{}

--Outline
t[#t+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(232, 302):diffuse(1,1,1,1):cropbottom(1) end,
    OnCommand=function(self) self:linear(0.2):cropbottom(0) end,
    GainFocusCommand=function(self) self:stoptweening():linear(0.1):zoomto(232, 302) end,
	LoseFocusCommand=function(self) self:stoptweening():linear(0.1):zoomto(192, 249) end,
	OffCommand=function(self) self:sleep(0.15):linear(0.2):cropbottom(1) end
}



--Background
t[#t+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(230, 300):diffuse(0,0,0,1):cropbottom(1) end,
    OnCommand=function(self) self:linear(0.2):cropbottom(0) end,
    GainFocusCommand=function(self) self:stoptweening():linear(0.1):zoomto(230, 300) end,
	LoseFocusCommand=function(self) self:stoptweening():linear(0.1):zoomto(190, 247) end,
	OffCommand=function(self) self:sleep(0.15):linear(0.2):cropbottom(1) end
}


--Beginner Icon
t[#t+1] = LoadActor("beginner-icon.png")..{
    Condition=text == "Casual" or text == "Regular", --Only show the beginner mode icon in casual mode
    InitCommand=function(self) self:bob():effecttiming(1.5, 0, 1.5, 0, 0) end,
    OnCommand=function(self) self:diffusealpha(0):sleep(0.07):linear(0.2):diffusealpha(1) end,
    GainFocusCommand=function(self) self:stoptweening():decelerate(0.1):xy(90, -70):zoom(0.6):diffuse(color("#FFFFFF")):addrotationz(15):effectmagnitude(-2, 5, 0) end,
	LoseFocusCommand=function(self) self:stoptweening():decelerate(0.1):xy(75, -80):zoom(0.4):diffuse(color("#808080")):addrotationz(-15):effectmagnitude(0, 0, 0) end,
    OffCommand=function(self) self:linear(0.2):diffusealpha(0) end
}


--Icon
t[#t+1] = LoadActor("icon-" .. text .. ".png")..{
    InitCommand=function(self) self:bob() end,
    OnCommand=function(self) self:diffusealpha(0):sleep(0.11):linear(0.2):diffusealpha(1) end,
    GainFocusCommand=function(self) self:stoptweening():decelerate(0.1):zoom(0.6):diffuse(color("#FFFFFF")):effectmagnitude(0, 8, 0) end,
	LoseFocusCommand=function(self) self:stoptweening():decelerate(0.1):zoom(0.4):diffuse(color("#808080")):effectmagnitude(0, 0, 0) end,
    OffCommand=function(self) self:linear(0.2):diffusealpha(0) end
}


-- Mode title
t[#t+1] = LoadFont("_wendy small")..{
	Name="ModeName"..index,
	Text=ScreenString(text),

	InitCommand=function(self) self:maxwidth(230):valign(1.3):y(-90) end,
    OnCommand=function(self) self:diffusealpha(0):sleep(0.02):linear(0.2):diffusealpha(1) end,
	GainFocusCommand=function(self) self:stoptweening():linear(0.1):zoom(0.9):diffuse(PlayerColor(PLAYER_1)) end,
	LoseFocusCommand=function(self) self:stoptweening():linear(0.1):zoom(0.5):diffuse(color("#888888")) end,
	OffCommand=function(self) self:linear(0.2):diffusealpha(0) end
}


--Mode description
t[#t+1] = Def.BitmapText{
	Font="Common Normal",
	InitCommand=function(self)
		self:zoom(0.825):valign(-0.8):y(60)
        self:settext(THEME:GetString("ScreenSelectPlayMode", text .. "Description"))
	end,
    OnCommand=function(self) self:diffusealpha(0):sleep(0.17):linear(0.2):diffusealpha(1) end,
    GainFocusCommand=function(self) self:stoptweening():linear(0.1):zoom(1.05):diffuse(color("#FFFFFF")) end,
	LoseFocusCommand=function(self) self:stoptweening():linear(0.1):zoom(0.7):diffuse(color("#666666")) end,
	OffCommand=function(self) self:linear(0.2):diffusealpha(0) end
}

return t