return Def.Quad{
	InitCommand=function(self) self:FullScreen():diffuse(1,1,1,0) end,
	OnCommand=function(self) self:decelerate(0.75):diffusealpha(1) end
}