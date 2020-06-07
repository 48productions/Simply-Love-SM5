local args = ...
local af = args.af

local already_loaded = {}

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

for profile in ivalues(args.profile_data) do
	if profile.judgment ~= nil and profile.judgment ~= "" and not FindInTable(profile.judgment, already_loaded) then

		if GetJudgmentGraphicPath("ITG", profile.judgment) then -- this returns nil if the judgment is not found, no need to check twice
			af[#af+1] = LoadActor(GetJudgmentGraphicPath("ITG", profile.judgment))..{
				Name="JudgmentGraphic_"..StripSpriteHints(profile.judgment),
				InitCommand=function(self)
					self:y(-50):SetStateProperties(judgment_filename:match("2x6") and animframes12 or animframes6)
					-- why is the original Love judgment asset so... not aligned?
					-- it throws the aesthetic off as-is, so fudge a little
					if profile.judgment == "Love 2x6.png" then self:y(-55) end
				end
			}
			table.insert(already_loaded, profile.judgment)

		elseif GetJudgmentGraphicPath("FA+", profile.judgment) then
			af[#af+1] = LoadActor(GetJudgmentGraphicPath("FA+", profile.judgment))..{
				Name="JudgmentGraphic_"..StripSpriteHints(profile.judgment),
				InitCommand=function(self) self:y(-50):SetStateProperties(judgment_filename:match("2x6") and animframes12 or animframes6) end
			}
			table.insert(already_loaded, profile.judgment)

		elseif GetJudgmentGraphicPath("StomperZ", profile.judgment) then
			af[#af+1] = LoadActor(GetJudgmentGraphicPath("StomperZ", profile.judgment))..{
				Name="JudgmentGraphic_"..StripSpriteHints(profile.judgment),
				InitCommand=function(self) self:y(-50):SetStateProperties(judgment_filename:match("2x6") and animframes12 or animframes6) end
			}
			table.insert(already_loaded, profile.judgment)
		end
	end
end

af[#af+1] = Def.Actor{ Name="JudgmentGraphic_None", InitCommand=function(self) self:visible(false) end }