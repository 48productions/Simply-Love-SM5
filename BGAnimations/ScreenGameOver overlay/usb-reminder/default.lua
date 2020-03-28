local new_profile_written = PROFILEMAN:ProfileFromMemoryCardIsNew('PlayerNumber_P1') or PROFILEMAN:ProfileFromMemoryCardIsNew('PlayerNumber_P2') --If either player has a *new* memory card profile, note it

return Def.ActorFrame{
	LoadFont("Common Normal")..{
		Text="...",
		InitCommand=function(self) self:xy(_screen.cx,_screen.cy+120):glow(1,1,1,1):glowshift() end,
		OnCommand=function(self)
			self:queuecommand("Pulse")
			if new_profile_written then --Display different messages if a new memory card profile was written
				self:settext(ScreenString("NewProfile"))
			else
				self:settext(ScreenString("USBReminder"))
			end
		end,
		PulseCommand=function(self) self:smooth(1.5):zoom(1.1):smooth(1.5):zoom(1):queuecommand("Pulse") end,
	},
	LoadActor("usbicon.png")..{
		InitCommand=function(self) self:xy(_screen.cx,_screen.cy+180):zoom(0.35) end,
		OnCommand=function(self) self:glow(1,1,1,1):glowshift():queuecommand("Rotate") end,
		RotateCommand=function(self) self:smooth(1):rotationz(8):smooth(1):rotationz(-8):queuecommand("Rotate") end,
	}
}