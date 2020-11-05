return Def.ActorFrame{
	Def.Quad{ InitCommand=function(self) self:xy(_screen.cx, _screen.cy):zoomto(_screen.w,200):diffuse(0,0,0,1) end },
	LoadFont("Common Normal")..{
		Text=ScreenString("Instructions"),
		InitCommand=function(self) self:xy(_screen.cx, _screen.cy+50) end
	}
}