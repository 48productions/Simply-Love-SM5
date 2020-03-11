return Def.ActorFrame{
	LoadFont("Common Normal")..{
		Text=ScreenString("USBReminder"),
		InitCommand=function(self) self:xy(_screen.cx,_screen.cy+120) end,
		OnCommand=function(self) self:queuecommand("Pulse") end,
		PulseCommand=function(self) self:smooth(1.5):zoom(1.2):smooth(1.5):zoom(1):queuecommand("Pulse") end,
	},
	LoadActor("usbicon.png")..{
		InitCommand=function(self) self:xy(_screen.cx,_screen.cy+180):zoom(0.35) end,
		OnCommand=function(self) self:glow(1,1,1,1):glowshift():queuecommand("Rotate") end,
		RotateCommand=function(self) self:smooth(1):rotationz(10):smooth(1):rotationz(-10):queuecommand("Rotate") end,
	}
}