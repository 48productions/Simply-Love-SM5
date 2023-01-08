-- Max thresholds to consider "Easy" vs "Medium" vs "Hard" songs
local difficultyMax = ThemePrefs.Get("CasualMaxMeter")
local difficultyHard = difficultyMax * 0.66
local difficultyMedium = difficultyMax * 0.33

-- Return a table with the difficulty string, meter, and color presented to the player for a given steps
local GetDifficulty = function(steps)
	-- "Novice 10" is a misnomer. A BAD misnomer.
	-- In Casual mode, I'm going to override the engine-provided difficulty names with ones that actually reflect the difficulty of the steps, instead of the difficulty slot the steps are in
	local difficulty
	local meter = steps:GetMeter()
	if meter >= difficultyHard then
		difficulty = "Difficulty_Hard"
	elseif meter >= difficultyMedium then
		difficulty = "Difficulty_Medium"
	else
		difficulty = "Difficulty_Beginner"
	end
	return {THEME:GetString( "CustomDifficulty", difficulty:gsub("Difficulty_", "") ), steps:GetMeter(), DifficultyNameColor(difficulty)}
end

-- ------------------------------------------------------
local OptionRows = {
	{
		Name = "Charts",
		HelpText = THEME:GetString("ScreenSelectMusicCasual", "SelectDifficulty"),
		Choices = function(self) return map(GetDifficulty, self.Values()) end,
		Values = function()
			local steps = {}
			-- prune out charts whose meter exceeds the specified max
			for chart in ivalues(SongUtil.GetPlayableSteps( GAMESTATE:GetCurrentSong() )) do
				if chart:GetMeter() <= ThemePrefs.Get("CasualMaxMeter") then
					steps[#steps+1] = chart
				end
			end
			return steps
		end,
		OnLoad=function(actor, pn, choices, values)
			local index = 1
			local current_meter = GAMESTATE:IsHumanPlayer(pn) and GAMESTATE:GetCurrentSteps(pn) and GAMESTATE:GetCurrentSteps(pn):GetMeter() or 1

			-- if the player has a chart set (from a previous round, picking a song but then canceling, etc.),
			-- set this OptionRow's starting choice to the chart whose meter is closest without exceeding
			-- previous chart's meter.  I attempting to match by numerical Meter makes more sense for Casual mode than
			-- attempting to match by difficulty. It mitagates scenarios in which the previous song had a Medium 4
			-- but the current song has a Medium 10.
			for i,chart in ipairs(values) do
				if chart:GetMeter() <= current_meter then
					if current_meter-chart:GetMeter() < current_meter-values[index]:GetMeter() then
						index = i
					end
				end
			end
			actor:set_info_set(choices, index)
		end,
		OnSave=function(self, pn, choice)
			local index = 1
			for i,v in ipairs(self:Choices()) do
				if choice[1]==v[1] and choice[2]==v[2] then index=i; break end
			end
			GAMESTATE:SetCurrentSteps(pn, self:Values()[index])
		end
	},
}
-- ------------------------------------------------------

-- add Exit row last
OptionRows[#OptionRows + 1] = {
	Name = "Exit",
	HelpText = "",
}

return OptionRows