local player = ...

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local PercentDP = stats:GetPercentDancePoints()
local percent = FormatPercentScore(PercentDP)
-- Format the Percentage string, removing the % symbol
percent = percent:gsub("%%", "")

return Def.ActorFrame{
	Name="PercentageContainer"..ToEnumShortString(player),
	OnCommand=function(self)
		self:y( _screen.cy-26 )
	end,

	-- dark background quad behind player percent score
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color_slate5):zoomto(158.5, 60)
			self:horizalign(player==PLAYER_1 and left or right)
			self:x(150 * (player == PLAYER_1 and -1 or 1)):cropbottom(1)
		end,
		OnCommand=function(self)
			self:sleep(0.7):decelerate(0.2):cropbottom(0)
		end,
	},

	LoadFont("_wendy white")..{
		Name="Percent",
		Text=percent,
		InitCommand=function(self)
			self:horizalign(right):zoom(0.585)
			self:x( (player == PLAYER_1 and 1.5 or 141)):diffusealpha(0)
            self:sleep(3.2):smooth(0.5):diffusealpha(1)
            if AllowThonk() then self:bob():effectmagnitude(1.5,0,0):effectoffset(-0.1) end
		end
	}
}
