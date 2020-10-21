-- This transition is mostly needed when going from ScreenDemonstration -> ScreenTitleMenu, but imo also *kinda* helps from ScreenLogo, ScreenRanking, etc
return Def.Quad{
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,1) end,
	OnCommand=function(self) self:decelerate(0.25):diffusealpha(0) end
}