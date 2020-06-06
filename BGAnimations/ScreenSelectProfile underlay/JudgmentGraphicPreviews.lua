local args = ...
local af = args.af

local already_loaded = {}

for profile in ivalues(args.profile_data) do
	if profile.judgment ~= nil and profile.judgment ~= "" and not FindInTable(profile.judgment, already_loaded) then

		if FILEMAN:DoesFileExist(GetJudgmentGraphicPath("ITG", profile.judgment)) then
			af[#af+1] = LoadActor(GetJudgmentGraphicPath("ITG", profile.judgment))..{
				Name="JudgmentGraphic_"..StripSpriteHints(profile.judgment),
				InitCommand=function(self)
					self:y(-50):animate(false)
					-- why is the original Love judgment asset so... not aligned?
					-- it throws the aesthetic off as-is, so fudge a little
					if profile.judgment == "Love 2x6.png" then self:y(-55) end
				end
			}
			table.insert(already_loaded, profile.judgment)

		elseif FILEMAN:DoesFileExist(GetJudgmentGraphicPath("FA+", profile.judgment)) then
			af[#af+1] = LoadActor(GetJudgmentGraphicPath("FA+", profile.judgment))..{
				Name="JudgmentGraphic_"..StripSpriteHints(profile.judgment),
				InitCommand=function(self) self:y(-50):animate(false) end
			}
			table.insert(already_loaded, profile.judgment)

		elseif FILEMAN:DoesFileExist(GetJudgmentGraphicPath("StomperZ", profile.judgment)) then
			af[#af+1] = LoadActor(GetJudgmentGraphicPath("StomperZ", profile.judgment))..{
				Name="JudgmentGraphic_"..StripSpriteHints(profile.judgment),
				InitCommand=function(self) self:y(-50):animate(false) end
			}
			table.insert(already_loaded, profile.judgment)
		end
	end
end

af[#af+1] = Def.Actor{ Name="JudgmentGraphic_None", InitCommand=function(self) self:visible(false) end }