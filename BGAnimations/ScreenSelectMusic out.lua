return Def.ActorFrame{
	InitCommand=function(self) self:draworder(200) end,
    OffCommand=function(self) self:decelerate(0.6):addy(30) end,

	--[[Def.Quad{
		InitCommand=function(self) self:diffuse(0,0,0,0):FullScreen():cropbottom(1):fadebottom(0.5) end,
		OffCommand=function(self) self:linear(0.3):cropbottom(-0.5):diffusealpha(1) end
	},]]

	LoadFont("_upheaval_underline 80px")..{
		Text=THEME:GetString("ScreenSelectMusic", "Press Start for Options"),
		InitCommand=function(self) self:diffusealpha(0):Center():zoom(0.4) end,
		ShowPressStartForOptionsCommand=function(self) self:smooth(0.5):diffusealpha(1) end,
		ShowEnteringOptionsCommand=function(self) self:linear(0.125):diffusealpha(0):queuecommand("NewText") end,
		NewTextCommand=function(self) self:hibernate(0.1):settext(THEME:GetString("ScreenSelectMusic", "Entering Options...")):linear(0.125):diffusealpha(1):sleep(1) end
	},
    
    Def.Quad{
        InitCommand=function(self) self:diffuse(GetCurrentColor()):visible(false):xy(_screen.cx, _screen.cy+30):zoomto(2, 3) end,
        ShowPressStartForOptionsCommand=function(self)
            self:visible(true):smooth(0.5):diffusealpha(1):zoomto(420, 3):linear(1.5):zoomto(0, 3)
            if AllowThonk() then self:accelerate(0.5):zoomto(_screen.w, _screen.h / 3):diffuse(Color.Red):diffusealpha(0):addrotationz(45) end
        end,
    }
}