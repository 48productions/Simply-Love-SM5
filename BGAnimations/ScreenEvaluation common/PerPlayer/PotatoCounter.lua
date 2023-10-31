-- This is the "progression system" for Simply Spud, as requested by a few players
-- Nothing fancy/complex, just for those who like seeing a number go up as they continue playing songs :)

local player = ...

local profile = PROFILEMAN:GetProfile(player)
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
if not profile or not stats then return end -- No profile or stage stats is probably a bad sign here...

return Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx * (player == PLAYER_1 and -0.49 or 0.49), _screen.h - 30):diffusealpha(0)
	end,
	OnCommand=function(self)
		self:sleep(1):smooth(0.25):diffusealpha(1)
	end,
	
	-- Main potato counter
	Def.RollingNumbers{
		Font="_wendy small",
		InitCommand=function(self) self:zoom(0.3):maxwidth(175):Load("RollingNumbersPotatoes"):horizalign(player == PLAYER_1 and "HorizAlign_Left" or "HorizAlign_Right"):shadowlength(1) end,
		OnCommand=function(self)
			self:targetnumber(profile:GetTotalDancePoints() - stats:GetActualDancePoints()):sleep(4.25):queuecommand("Increment")
		end,
		IncrementCommand=function(self)
			self:targetnumber(profile:GetTotalDancePoints())
		end,
	},
	
	-- Potatoes label
	LoadFont("_wendy small")..{
		Text="🥔",
		InitCommand=function(self)
			self:zoom(0.5):xy(player == PLAYER_1 and -3 or 3, -5):horizalign(player == PLAYER_1 and "HorizAlign_Right" or "HorizAlign_Left"):shadowlength(1)
		end,
	},
	
	-- +x label
	LoadFont("_wendy small")..{
		InitCommand=function(self) self:xy(player == PLAYER_1 and 16 or -16, -6):zoom(0.3):maxwidth(100):diffusealpha(0):shadowlength(1) end,
		OnCommand=function(self)
			self:settext("+"..stats:GetActualDancePoints()):sleep(3.25):decelerate(0.3):addy(-10):diffusealpha(1):sleep(2):accelerate(0.3):addy(10):diffusealpha(0)
		end,
	}
}