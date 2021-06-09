local player = ...
local profile = PROFILEMAN:GetProfile(player)
local playerName = profile:GetLastUsedHighScoreName()
local calories = round(profile:GetCaloriesBurnedToday())
local totalSongs = profile:GetNumTotalSongsPlayed()

local lines = {
	ScreenString("LastUsedHighScoreName") .. playerName,
    string.format(ScreenString("TotalSongsPlayed"), totalSongs),
	string.format(ScreenString("CaloriesBurned"), calories),
}

-- if the player has opted to ignore the engine's sense of Calories burned
-- in favor of the HeartRate entry screen, then remove the line regarding
-- calories burned, which relies on the engine.
if profile:GetIgnoreStepCountCalories() then
	lines[2] = ""
end

return lines