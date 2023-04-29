local af = Def.ActorFrame{
    Name="StepsDisplayListAF",
    OnCommand=function(self) self:x(-450):sleep(0.8):decelerate(0.5):x(0) end,
}
local paneAF = Def.ActorFrame{
	Name="PaneAF",
    CurrentSongChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("Set") end,
	StepsHaveChangedCommand=function(self) self:queuecommand("Set") end,
}


if GAMESTATE:IsCourseMode() then
	af[#af+1] = LoadActor("./CourseContentsList.lua")
else
	af[#af+1] = LoadActor("./Grid.lua")
end

for player in ivalues({PLAYER_1, PLAYER_2}) do
    -- colored background for chart statistics
    paneAF[#paneAF+1] = LoadActor("./DetailsDisplay.lua", player)
end




-- This logic is from mainline Simply Love, where it's located in PaneDisplay.lua
-- We no longer have a PaneDisplay, so the stuff that's shared between the two players is put in here instead
-- DetailsDisplay.lua contains the player-specific logic for initiating chart parsing

-- Given actors for a high score and high score name, sets those two actors
local SetNameAndScore = function(name, score, nameActor, scoreActor)
	if not scoreActor or not nameActor then return end
	scoreActor:settext(score)
	nameActor:settext(name)
end

-- Gets the 4-letter machine tag from a given groovestats entry
local GetMachineTag = function(gsEntry)
	if not gsEntry then return end
	if gsEntry["machineTag"] then
		-- Make sure we only use up to 4 characters for space concerns.
		return gsEntry["machineTag"]:sub(1, 4):upper()
	end

	-- User doesn't have a machineTag set. We'll "make" one based off of
	-- their name.
	if gsEntry["name"] then
		-- 4 Characters is the "intended" length.
		return gsEntry["name"]:sub(1,4):upper()
	end

	return ""
end

-- Convenience function to return the SongOrCourse and StepsOrTrail for a
-- for a player.
local GetSongAndSteps = function(player)
	local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	return SongOrCourse, StepsOrTrail
end

-- Gets the score for a given song from a given profile
local GetScoreFromProfile = function(profile, SongOrCourse, StepsOrTrail)
	-- if we don't have everything we need, return nil
	if not (profile and SongOrCourse and StepsOrTrail) then return nil end

	return profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()[1]
end

-- Gets the score from a player's profile for the current song
local GetScoreForPlayer = function(player)
	local highScore
	if PROFILEMAN:IsPersistentProfile(player) then
		local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
		highScore = GetScoreFromProfile(PROFILEMAN:GetProfile(player), SongOrCourse, StepsOrTrail)
	end
	return highScore
end

-- Callback function for when the request for scores on a song has been returned
local GetScoresRequestProcessor = function(res, params)
	local master = params.master
	if master == nil then return end
	-- If we're not hovering over a song when we get the request, then we don't
	-- have to update anything. We don't have to worry about courses here since
	-- we don't run the RequestResponseActor in CourseMode.
	if GAMESTATE:GetCurrentSong() == nil then return end
	
	local data = res.statusCode == 200 and JsonDecode(res.body) or nil
	local requestCacheKey = params.requestCacheKey
	-- If we have data, and the requestCacheKey is not in the cache, cache it.
	if data ~= nil and SL.GrooveStats.RequestCache[requestCacheKey] == nil then
		SL.GrooveStats.RequestCache[requestCacheKey] = {
			Response=res,
			Timestamp=GetTimeSinceStart()
		}
	end

	for i=1,2 do
		local paneDisplay = master:GetChild("PaneAF"):GetChild("DetailsDisplayP"..i)
		local machineScoreAF = paneDisplay:GetChild("MachineHighScore")
		local machineScore = machineScoreAF:GetChild("HighScore")
		local machineName = machineScoreAF:GetChild("HighScoreName")
		local machineLabel = machineScoreAF:GetChild("HighScoreLabel")

		local playerScoreAF = paneDisplay:GetChild("PlayerHighScore")
		local playerScore = playerScoreAF:GetChild("HighScore")
		local playerName = playerScoreAF:GetChild("HighScoreName")

		local loadingText = paneDisplay:GetChild("Rival1HighScore"):GetChild("HighScoreLabel")

		local playerStr = "player"..i
		local rivalNum = 1
		local worldRecordSet = false
		local personalRecordSet = false

		-- First check to see if the leaderboard even exists.
		if data and data[playerStr] and data[playerStr]["gsLeaderboard"] then
			-- And then also ensure that the chart hash matches the currently parsed one.
			-- It's better to just not display anything than display the wrong scores.
			if SL["P"..i].Streams.Hash == data[playerStr]["chartHash"] then
				for gsEntry in ivalues(data[playerStr]["gsLeaderboard"]) do
					if gsEntry["rank"] == 1 then
						SetNameAndScore(
							GetMachineTag(gsEntry),
							string.format("%.2f%%", gsEntry["score"]/100),
							machineName,
							machineScore
						)
						machineLabel:settext(THEME:GetString("ScreenSelectMusic", "WorldHighScore"))
						worldRecordSet = true
					end

					if gsEntry["isSelf"] then
						-- Let's check if the GS high score is higher than the local high score
						local player = PlayerNumber[i]
						local localScore = GetScoreForPlayer(player)
						-- GS's score entry is a value like 9823, so we need to divide it by 100 to get 98.23
						local gsScore = gsEntry["score"] / 100

						-- GetPercentDP() returns a value like 0.9823, so we need to multiply it by 100 to get 98.23
						if not localScore or gsScore >= localScore:GetPercentDP() * 100 then
							-- It is! Let's use it instead of the local one.
							SetNameAndScore(
								GetMachineTag(gsEntry),
								string.format("%.2f%%", gsScore),
								playerName,
								playerScore
							)
							personalRecordSet = true
						end
					end

					if gsEntry["isRival"] then
						local rivalScoreAF = paneDisplay:GetChild("Rival"..rivalNum.."HighScore")
						local rivalScore = rivalScoreAF:GetChild("HighScore")
						local rivalName = rivalScoreAF:GetChild("HighScoreName")
						SetNameAndScore(
							GetMachineTag(gsEntry),
							string.format("%.2f%%", gsEntry["score"]/100),
							rivalName,
							rivalScore
						)
						rivalNum = rivalNum + 1
					end
				end
			end
		end

		-- Iterate over any remaining rivals and hide them.
		-- This also handles the failure case as rivalNum will never have been incremented.
		for j=rivalNum,3 do
			local rivalScoreAF = paneDisplay:GetChild("Rival"..j.."HighScore")
			local rivalScore = rivalScoreAF:GetChild("HighScore")
			local rivalName = rivalScoreAF:GetChild("HighScoreName")
			rivalScore:settext("??.??%")
			rivalName:settext("----")
		end

		if res.error or res.statusCode ~= 200 then
			local error = res.error and ToEnumShortString(res.error) or nil
			if error == "Timeout" then
				loadingText:settext(THEME:GetString("ScreenSelectMusic", "GSTimeout"))
			elseif error or (res.statusCode ~= nil and res.statusCode ~= 200) then
				loadingText:settext(THEME:GetString("ScreenSelectMusic", "GSFailed"))
			end
		else
			if data and data[playerStr] then
				if data[playerStr]["isRanked"] then
					loadingText:settext(THEME:GetString("ScreenSelectMusic", "GSLoaded"))
				else
					loadingText:settext(THEME:GetString("ScreenSelectMusic", "GSNotRanked"))
				end
			else
				-- Just hide the text
				--loadingText:queuecommand("Set")
				--loadingText:settext("HideMe")
			end
		end
	end
end



-- The loading icon and logic behind requesting scores
af[#af+1] = RequestResponseActor(-185, 95)..{
	Name="GetScoresRequester",
	OnCommand=function(self)
		-- Create variables for both players, even if they're not currently active.
		self.IsParsing = {false, false}
	end,
	-- Broadcasted from ./DetailsDisplay.lua
	P1ChartParsingMessageCommand=function(self)	self.IsParsing[1] = true end,
	P2ChartParsingMessageCommand=function(self)	self.IsParsing[2] = true end,
	P1ChartParsedMessageCommand=function(self)
		self.IsParsing[1] = false
		self:queuecommand("ChartParsed")
	end,
	P2ChartParsedMessageCommand=function(self)
		self.IsParsing[2] = false
		self:queuecommand("ChartParsed")
	end,
	ChartParsedCommand=function(self)
		local master = self:GetParent()

		if not IsServiceAllowed(SL.GrooveStats.GetScores) then
			if SL.GrooveStats.IsConnected then
				-- loadingText is made visible when requests complete.
				-- If we disable the service from a previous request, surface it to the user here.
				for i=1,2 do
					local loadingText = master:GetChild("PaneAF"):GetChild("DetailsDisplayP"..i):GetChild("Rival1HighScore"):GetChild("HighScoreLabel")
					loadingText:settext(THEME:GetString("ScreenSelectMusic", "GSDisabled"))
					--loadingText:visible(true)
				end
			end
			return
		end

		-- Make sure we're still not parsing either chart.
		if self.IsParsing[1] or self.IsParsing[2] then return end

		-- This makes sure that the Hash in the ChartInfo cache exists.
		local sendRequest = false
		local headers = {}
		local query = {}
		local requestCacheKey = ""

		for i=1,2 do
			local pn = "P"..i
			if SL[pn].ApiKey ~= "" and SL[pn].Streams.Hash ~= "" then
				query["chartHashP"..i] = SL[pn].Streams.Hash
				headers["x-api-key-player-"..i] = SL[pn].ApiKey
				requestCacheKey = requestCacheKey .. SL[pn].Streams.Hash .. SL[pn].ApiKey .. pn
				local loadingText = master:GetChild("PaneAF"):GetChild("DetailsDisplayP"..i):GetChild("Rival1HighScore"):GetChild("HighScoreLabel")
				--loadingText:visible(true)
				loadingText:settext(THEME:GetString("ScreenSelectMusic", "GSLoading"))
				sendRequest = true
			end
		end

		-- Only send the request if it's applicable.
		if sendRequest then
			requestCacheKey = CRYPTMAN:SHA256String(requestCacheKey.."-player-scores")
			local params = {requestCacheKey=requestCacheKey, master=master}
			RemoveStaleCachedRequests()
			-- If the data is still in the cache, run the request processor directly
			-- without making a request with the cached response.
			if SL.GrooveStats.RequestCache[requestCacheKey] ~= nil then
				local res = SL.GrooveStats.RequestCache[requestCacheKey].Response
				GetScoresRequestProcessor(res, params)
			else
				self:playcommand("MakeGrooveStatsRequest", {
					endpoint="player-scores.php?"..NETWORK:EncodeQueryParameters(query),
					method="GET",
					headers=headers,
					timeout=10,
					callback=GetScoresRequestProcessor,
					args=params,
				})
			end
		end
	end
}



af[#af+1] = paneAF
return af