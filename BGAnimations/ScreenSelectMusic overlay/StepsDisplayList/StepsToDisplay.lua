-- Given the engine's list of charts available for a song,
-- Returns a list of 5 charts to show in difficulty selection, and where charts in the list had to be hidden (if any)

function findChartsToReturn(charts, firstIndex)
  local frIndex = 1
  local finalReturn = {}
  for i=firstIndex, firstIndex+5 do
		finalReturn[frIndex] = charts[i]
		frIndex = frIndex + 1
  end
  return finalReturn
end

return function(AllAvailableSteps)

	--gather any edit charts into a table
	local charts = {}

	for k,chart in ipairs(AllAvailableSteps) do

		local difficulty = chart:GetDifficulty()
		--  Unlike SM5, Outfox supports multiple charts of the same difficulty (and several new difficulty slots)
		--  We'll populate a big ol list of charts to show, only placing charts of a certain difficulty after their intended difficulty slot
		-- (challenge charts only appear after the 5th slot, etc)
		-- We'll then take a selection (or two) of that list later to actually show to the player
		local index = GetDifficultyIndex(difficulty)
		if #charts < index then -- The last chart in the list is before the minimum slot for this difficulty 
				charts[index] = chart -- Add this chart at the position for its difficulty 
		else -- The last chart in the list is after the minimum slot for this difficulty
			charts[#charts+1] = chart -- Add this chart to the end of the chart list
		end
	end

	-- if there are 5 or fewer charts we can safely bail now
	if #charts <= 5 then return {charts, {false, false, false}} end


	--THERE ARE ~~EDITS~~ CHARTS, OH NO!
	--"LOGIC" BELOW

	-- We want to scroll as far "up" in the chart list as we can, while still showing the charts the players have selected
	-- This way, the lower difficulties get consistent positioning and the displayed chart list only scrolls one chart at a time when the player scrolls down the list
	local currentStepsP1, currentStepsP2
	local firstChartToShow = 1 -- What we need to find (in most cases) is what chart index should be in the first slot
	local chartIndexSplit = {false, false, false} -- If there's more than 5 charts to display, we need to hide something. To visually show this in the chart list later, store where in the list charts are hidden (if any)
	local finalReturn = {}

	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		currentStepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1)
	end

	if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		currentStepsP2 = GAMESTATE:GetCurrentSteps(PLAYER_2)
	end

	-- if only one player is joined
	if (currentStepsP1 and not currentStepsP2) or (currentStepsP2 and not currentStepsP1) then

		if (currentStepsP1 and not currentStepsP2) then
			currentSteps = currentStepsP1
		elseif (currentStepsP2 and not currentStepsP1) then
			currentSteps = currentStepsP2
		end

		local currentIndex

		-- We've used GAMESTATE:GetCurrentSteps(pn) to get the current chart
		-- use a for loop to match that "current chart" against each chart
		-- in our charts table; we want the index of the current chart
		for k,chart in pairs(charts) do
			if chart:GetChartName()==currentSteps:GetChartName() then
				currentIndex = tonumber(k)
			end
		end

		-- Check if the player has selected a chart index > 5, and scroll down however much is needed to get the selected chart into the last slot
		if currentIndex > 5 then
			firstChartToShow = currentIndex - 4
			chartIndexSplit[1] = true
		else -- Player has selected one of the first 5 charts, all we need to do here is flag that there are charts hidden after index 5
			chartIndexSplit[3] = true
		end
		finalReturn = findChartsToReturn(charts, firstChartToShow)
    
			


	-- elseif both players are joined
	-- This can get complicated if P1 is on beginner and P2 is on an edit
	-- AND there is a full range of charts between
	-- we'll have to hide SOMETHING...
	elseif (currentStepsP1 and currentStepsP2) then

		local currentIndexP1, currentIndexP2

		-- how far apart are P1 and P2 currently?

		for k,chart in pairs(charts) do

			if chart == currentStepsP1 then
				currentIndexP1 = k
			end

			if chart == currentStepsP2 then
				currentIndexP2 = k
			end
		end

		if (currentIndexP1 and currentIndexP2) then

			local difference = math.abs(currentIndexP1-currentIndexP2)

			local greaterIndex, lesserIndex
			if currentIndexP1 > currentIndexP2 then
				greaterIndex = currentIndexP1
				lesserIndex = currentIndexP2
			else
				greaterIndex = currentIndexP2
				lesserIndex = currentIndexP1
			end

			-- We can't fit both P1 and P2's chart in the list without hiding charts between the two
			if difference > 4 then

				-- The first 3 charts should be the lower selected chart and the two charts after it
				local frIndex = 1
				for i=lesserIndex, lesserIndex+2 do
					finalReturn[frIndex] = charts[i]
					frIndex = frIndex + 1
				end
				-- The last two charts should be the higher selected chart and the chart before it
				for i=greaterIndex-1, greaterIndex do
					finalReturn[frIndex] = charts[i]
					frIndex = frIndex + 1
				end

				-- Next, find out where we're hiding charts so chartIndexSplit can be set
				chartIndexSplit[2] = true -- We're always hiding after slot 3 at this point
				if lesserIndex > 1 then -- Hiding charts before the first shown chart
					chartIndexSplit[1] = true
				end
				if greaterIndex < #charts then -- Hiding charts after the last shown chart
					chartIndexSplit[3] = true
				end

			else -- We can fit both P1 and P2's chart in the list while only hiding charts at the top/bottom!
				-- Handle this similarly to single player play, where we scroll down as much as needed if the greater chart index is > 5
				if greaterIndex > 5 then
					firstChartToShow = greaterIndex - 4
					chartIndexSplit[1] = true
					-- Check if we're ALSO hiding charts after the charts we're showing
					if greaterIndex < #charts then
						chartIndexSplit[3] = true
					end
				else --  Within the first 5 charts - flag that there are charts hidden after index 5
					chartIndexSplit[3] = true
				end
				finalReturn = findChartsToReturn(charts, firstChartToShow)
			end
		end
	end

	return {finalReturn, chartIndexSplit}
end