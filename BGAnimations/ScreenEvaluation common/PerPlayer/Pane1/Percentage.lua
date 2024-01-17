local player = ...

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local PercentDP = stats:GetPercentDancePoints()
local percent = FormatPercentScore(PercentDP)
-- Format the Percentage string, removing the % symbol
percent = percent:gsub("%%", "")

local showEX = SL.Global.GameMode == "FA+"

return Def.ActorFrame{
	Name="PercentageContainer"..ToEnumShortString(player),
	OnCommand=function(self)
		self:y( _screen.cy - (showEX and 11 or 26))
	end,

	-- dark background quad behind player percent score
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color_slate5):zoomto(158.5, showEX and 90 or 60)
			self:horizalign(player==PLAYER_1 and left or right)
			self:x(150 * (player == PLAYER_1 and -1 or 1)):cropbottom(1)
		end,
		OnCommand=function(self)
			self:sleep(0.7):decelerate(0.2):cropbottom(0)
		end,
	},

	-- Percentage Score
	LoadFont("_wendy white")..{
		Name="Percent",
		Text=percent,
		InitCommand=function(self)
			self:horizalign(right):zoom(0.585)
			self:x( (player == PLAYER_1 and 1.5 or 141)):y(showEX and -16 or 0):diffusealpha(0)
            self:sleep(3.2):smooth(0.5):diffusealpha(1)
            if AllowThonk() then self:bob():effectmagnitude(1.5,0,0):effectoffset(-0.1) end
		end
	},
	
	-- EX Score Label
	LoadFont("_wendy white")..{
		Name="PercentEXLabel",
		Condition=showEX,
		Text="EX",
		InitCommand=function(self)
			self:horizalign(right):zoom(0.375)
			self:x( (player == PLAYER_1 and -100.5 or 39)):y(22):diffuse(SL.JudgmentColors[SL.Global.GameMode][1]):diffusealpha(0)
            self:sleep(3.3):smooth(0.5):diffusealpha(1)
            if AllowThonk() then self:bob():effectmagnitude(1.5,0,0):effectoffset(-0.2) end
		end
	},
	
	-- EX Score
	LoadFont("_wendy white")..{
		Name="PercentEX",
		Condition=showEX,
		Text=("%.2f"):format(CalculateExScore(player)),
		InitCommand=function(self)
			self:horizalign(right):zoom(0.375)
			self:x( (player == PLAYER_1 and 0 or 139.5)):y(22):diffuse(SL.JudgmentColors[SL.Global.GameMode][1]):diffusealpha(0)
            self:sleep(3.3):smooth(0.5):diffusealpha(1)
            if AllowThonk() then self:bob():effectmagnitude(1.5,0,0):effectoffset(-0.2) end
		end
	},
}
