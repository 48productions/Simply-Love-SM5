-- ----------------------------------------------------------------------------------------
-- This file contains code for Simply Spud's (probably flawed) progression system, Potatoes
-- Potatoes are rebranded TotalDancePoints - They're displayed on ScreenEvaluation, and the number of potatoes will determine your player's name color as well
-- It's a laid-back progression system for those who want to see a number go up as they play, as has been requested by some players :)

-- Given a number of dance points, returns the corresponding level this player is at
GetPlayerLevel = function(points)
	-- Modeled by: level = 0.06x^0.47, rounded down
	return math.floor(0.06*math.pow(points, 0.47))
end

-- Given a number of dance points, returns a table of two colors (left and right, for gradients) for the corresponding color this player is at
GetPlayerLevelColor = function(points)
	local level = GetPlayerLevel(points)
	-- SM(points.."-"..level)
	if level >= 24 then return {SL.Colors[11], SL.Colors[10]}
	elseif level == 23 then return {SL.Colors[11], SL.Colors[11]}
	elseif level == 22 then return {SL.Colors[12], SL.Colors[11]}
	elseif level == 21 then return {SL.Colors[12], SL.Colors[12]}
	elseif level == 20 then return {SL.Colors[1], SL.Colors[12]}
	elseif level == 19 then return {SL.Colors[1], SL.Colors[1]}
	elseif level == 18 then return {SL.Colors[2], SL.Colors[1]}
	elseif level == 17 then return {SL.Colors[2], SL.Colors[2]}
	elseif level == 16 then return {SL.Colors[3], SL.Colors[2]}
	elseif level == 15 then return {SL.Colors[3], SL.Colors[3]}
	elseif level == 14 then return {SL.Colors[4], SL.Colors[3]}
	elseif level == 13 then return {SL.Colors[4], SL.Colors[4]}
	elseif level == 12 then return {SL.Colors[5], SL.Colors[4]}
	elseif level == 11 then return {SL.Colors[5], SL.Colors[5]}
	elseif level == 10 then return {SL.Colors[6], SL.Colors[5]}
	elseif level == 9 then return {SL.Colors[6], SL.Colors[6]}
	elseif level == 8 then return {SL.Colors[7], SL.Colors[6]}
	elseif level == 7 then return {SL.Colors[7], SL.Colors[7]}
	elseif level == 6 then return {SL.Colors[8], SL.Colors[7]}
	elseif level == 5 then return {SL.Colors[8], SL.Colors[8]}
	elseif level == 4 then return {SL.Colors[9], SL.Colors[8]}
	elseif level == 3 then return {SL.Colors[9], SL.Colors[9]}
	elseif level == 2 then return {SL.Colors[10], SL.Colors[9]}
	elseif level == 1 then return {SL.Colors[10], SL.Colors[10]} end
	return {"#eeeeee", "#eeeeee"}
end