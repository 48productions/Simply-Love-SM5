local t = ...

local delay = 0.15
local animframes6 = {
	{Frame = 0, Delay = delay*2},
	{Frame = 1, Delay = delay*2},
	{Frame = 2, Delay = delay*2},
	{Frame = 3, Delay = delay*2},
	{Frame = 4, Delay = delay*2},
	{Frame = 5, Delay = delay*2}
}
local animframes12= {
	{Frame = 0, Delay = delay},
	{Frame = 1, Delay = delay},
	{Frame = 2, Delay = delay},
	{Frame = 3, Delay = delay},
	{Frame = 4, Delay = delay},
	{Frame = 5, Delay = delay},
	{Frame = 6, Delay = delay},
	{Frame = 7, Delay = delay},
	{Frame = 8, Delay = delay},
	{Frame = 9, Delay = delay},
	{Frame = 10, Delay = delay},
	{Frame = 11, Delay = delay}
}

for judgment_filename in ivalues( GetJudgmentGraphics(SL.Global.GameMode) ) do
	if judgment_filename ~= "None" then
		t[#t+1] = LoadActor( GetJudgmentGraphicPath(SL.Global.GameMode, judgment_filename) )..{
			Name="JudgmentGraphic_"..StripSpriteHints(judgment_filename),
			InitCommand=function(self) self:visible(false):SetStateProperties(judgment_filename:match("2x6") and animframes12 or animframes6) end
		}
	else
		t[#t+1] = Def.Actor{ Name="JudgmentGraphic_None", InitCommand=function(self) self:visible(false) end }
	end
end