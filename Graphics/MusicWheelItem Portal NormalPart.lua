return Def.ActorFrame{
	InitCommand=function(self) self:x(26) end,

	Def.Quad{ InitCommand=function(self) self:diffuse(color_black):zoomto(_screen.w/2.1675, _screen.h/15) end },
	Def.Quad{ InitCommand=function(self) self:diffuse(color_slate):zoomto(_screen.w/2.1675, _screen.h/15 - 1) end }
}
