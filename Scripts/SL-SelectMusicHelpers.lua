-- ----------------------------------------------------------------------------------------
-- functions used by ScreenSelectMusicCasual

-- used by SSMCasual to play preview music of the current song
-- this is invoked each time the custom MusicWheel changes focus
play_sample_music = function()
	if GAMESTATE:IsCourseMode() then return end
	local song = GAMESTATE:GetCurrentSong()

	if song then
		--local songpath = song:GetMusicPath()
        local songpath = song:GetPreviewMusicPath() --Let's obey custom music preview files (this function returns regular previews if needed, too!) - 48
		local sample_start = song:GetSampleStart()
		local sample_len = song:GetSampleLength()

		if songpath and sample_start and sample_len then
			SOUND:DimMusic(PREFSMAN:GetPreference("SoundVolume"), math.huge)
			SOUND:PlayMusicPart(songpath, sample_start,sample_len, 0.5, 1.5, false, true, false, song:GetTimingData()) --Let's not loop the sample music in case a casual walks away from the cab after a single song - 48
		else
			stop_music()
		end
        
	else
		stop_music()
	end
end

-- used by SSMCasual to stop playing preview music,
-- this is invoked every time the custom MusicWheel changes focus
-- if the new focus is on song item, play_sample_music() will be invoked immediately afterwards
-- ths is also invoked when the player closes the current group to choose some other group
stop_music = function()
	SOUND:PlayMusicPart("", 0, 0)
end


----------------------------------------------------------------------------------------
-- functions used by ScreenSelectMusic

-- TextBanner is an engine-defined ActorFrame that contains three BitmapText actors named
-- "Title", "Subtitle", and "Artist".  Simply Love's MusicWheel only uses the first two.
--
-- It has two unique Metrics, "AfterSetCommand" and "ArtistPrependString"
-- Simply Love is only concerned with "AfterSetCommand"
-- because the song Artist does not appear in each MusicWheelItem

TextBannerAfterSet = function(self)
	-- acquire handles to two of the BitmapText children of this TextBanner ActorFrame
	-- we'll use them to position each song's Title and Subtitle as they appear in the MusicWheel
	local Title = self:GetChild("Title")
	local Subtitle = self:GetChild("Subtitle")

	-- assume the song's Subtitle is an empty string by default and position the Title
	-- in the vertical middle of the MusicWheelItem
	Title:y(0)

	-- if the Subtitle isn't an empty string
	if Subtitle:GetText() ~= "" then
		-- offset the Title's y() by -6 pixels
		Title:y(-6)
		-- and offset the Subtitle's y() by 6 pixels
		Subtitle:y(6)
	end
end

----------------------------------------------------------------------------------------
-- functions used by both SSM and SSMCasual

SSM_Header_StageText = function()

	-- if the continue system is enabled, don't worry about determining "Final Stage"
	if ThemePrefs.Get("NumberOfContinuesAllowed") > 0 then
		return THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)
	end

	local topscreen = SCREENMAN:GetTopScreen()
	if topscreen then

		-- if we're on ScreenEval for normal gameplay
		-- we might want to display the text for StageFinal, or we might want to
		-- increment the Stages.PlayedThisGame by the cost of the song that was just played
		if topscreen:GetName() == "ScreenEvaluationStage" then
			local song = GAMESTATE:GetCurrentSong()
			local Duration = song:GetLastSecond()
			local DurationWithRate = Duration / SL.Global.ActiveModifiers.MusicRate

			local LongCutoff = PREFSMAN:GetPreference("LongVerSongSeconds")
			local MarathonCutoff = PREFSMAN:GetPreference("MarathonVerSongSeconds")

			local IsMarathon = (DurationWithRate/MarathonCutoff > 1)
			local IsLong 	 = (DurationWithRate/LongCutoff > 1)

			local SongCost = (IsMarathon and 3) or (IsLong and 2) or 1

			if SL.Global.Stages.PlayedThisGame + SongCost >= PREFSMAN:GetPreference("SongsPerPlay") then
				return THEME:GetString("Stage", "Final")
			else
				return THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + SongCost)
			end

		-- if we're on ScreenEval within Marathon Mode, generic text will suffice
		elseif topscreen:GetName() == "ScreenEvaluationNonstop" then
			return THEME:GetString("ScreenSelectPlayMode", "Marathon")

		-- if we're on ScreenSelectMusic, display the number of Stages.PlayedThisGame + 1
		-- the song the player actually selects may cost more than 1, but we cannot know that now
		else
			return THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)
		end
	end
end

----------------------------------------------------------------------------------------
-- Preload the info.ini data for each group.
-- Doing this every time the MusicWheel scrolls by a group would surely be bad for performance.

group_descriptions = {} -- A string description of each group, or 0 if missing
group_ratings = {} -- A string rating scale for each group, or 0 if missing
group_rating_types = {} -- An int of what type of rating scale we're using. 0 = Missing, 1 = DDR/X/New, 2=ITG/Old, 3 = Mods group
group_tags = {} -- A table of tables with tags we've applied to groups

reloadGroupInfo = function()
    for _,group in ipairs(SONGMAN:GetSongGroupNames()) do
        local desc = 0
        local rates = nil
        local rates_type = 0
        local file = nil
		local split
		local tags = nil
		local tags_table = {}
        
        -- open info.ini if it exists
        if FILEMAN:DoesFileExist("./Songs/"..group.."/info.ini") then
            file = IniFile.ReadFile("./Songs/"..group.."/info.ini")
        -- check AdditionalSongs, too (this was easier than i thought it would be)
        elseif FILEMAN:DoesFileExist("./AdditionalSongs/"..group.."/info.ini") then
            file = IniFile.ReadFile("./AdditionalSongs/"..group.."/info.ini")
        end
        -- read info.ini if it loaded
        if file then
            if file.GroupInfo then
                if file.GroupInfo.Description then
                    desc = file.GroupInfo.Description
                end
			if file.GroupInfo.Ratings then
                    rates = file.GroupInfo.Ratings
                    if rates ~= "" then -- If rating info was found, parse it for clues to set our rating type
                        if rates:match("X") or rates:match("DDR") then rates_type = 1
                        elseif rates:match("ITG") or rates:match("Old") then rates_type = 2
                        end
                    end
                end
            end
			
			-- Tags can specify either one or two tags, separated by a comma
			if file.GroupInfo.Tags then
				tags = file.GroupInfo.Tags
				split, _ = tags:find(",")
				if split then -- If we found a comma there's two tags. Parse both.
					tags_table[0] = tags:sub(0, split - 1)
					tags_table[1] = tags:sub(split + 1)
				else -- No comma = one tag
					tags_table[0] = tags
				end
			end
        end
        -- copy to the arrays, leaving a 0 in place of nil or empty strings
        group_descriptions[group] = desc ~= "" and desc or 0
        group_ratings[group] = rates ~= "" and rates or 0
        group_rating_types[group] = group:match("%[Mods%]") and 3 or rates_type -- Set the rating info type based on clues above, but let [Mods] groups override this
        group_tags[group] = tags_table
    end
end

-- Song titles can be recolored in Simply Spud based on a few criteria:
--  - Song "DVNO" gets a special color (handled in metrics)
--  - Songs in groups titled "[Mods]" are colored orange
--  - Songs in groups rated as "X-Scale" or "DDR Scale" are colored green for beginners
--  - Songs in groups rated as "ITG Scale" are colored yellow for pros
getSongTitleColor = function(groupName)
    if group_rating_types[groupName] == 1 then return ThemePrefs.Get("RainbowMode") and color("#345431") or color("#72FF66") end
    if group_rating_types[groupName] == 2 then return ThemePrefs.Get("RainbowMode") and color("#515130") or color("#FFFF66") end
    if group_rating_types[groupName] == 3 then return ThemePrefs.Get("RainbowMode") and color("#563F32") or color("#FF9B66") end
    
    return ThemePrefs.Get("RainbowMode") and color("#0a141b") or Color.White -- Default to white (black in rainbow mode)
end