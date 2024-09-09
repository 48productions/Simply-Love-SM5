-- It's possible for players to edit their Simply Love UserPrefs.ini file
-- in various ways that might break the theme.  Also, sometimes theme-specific mods
-- are deprecated or change their internal name, leaving old values behind in player profiles
-- that might break the theme as well. Use this table to validate settings read in
-- from and written out to player profiles.
--
-- For now, this table is local to this file, but might be moved into the SL table (or something)
-- in the future to facilitate type checking in ./Scripts/SL-PlayerOptions.lua and elsewhere.

local profile_whitelist = {
	SpeedModType = "string",
	SpeedMod = "number",
	Mini = "string",
	NoteSkin = "string",
	JudgmentGraphic = "string",
	ComboFont = "string",
	BackgroundFilter = "string",

	HideTargets = "boolean",
	HideSongBG = "boolean",
	HideCombo = "boolean",
	HideLifebar = "boolean",
	HideScore = "boolean",
	HideDanger = "boolean",
	HideComboExplosions = "boolean",

	LifeMeterType = "string",
	DataVisualizations = "string",
	TargetScore = "number",
	ActionOnMissedTarget = "string",

	MeasureCounter = "string",
	MeasureCounterLeft = "boolean",
	MeasureCounterUp = "boolean",
	HideRestCounts = "boolean",
	
	MeasureLines = "string",

	ColumnFlashOnMiss = "boolean",
	ColumnCues = "boolean",
	SubtractiveScoring = "boolean",
	Pacemaker = "boolean",
	MissBecauseHeld = "boolean",
	NPSGraphAtTop = "boolean",
	JudgmentTilt = "boolean",
	
	ShowFaPlusWindow = "boolean",

	Vocalization = "string",
	ReceptorArrowsPosition = "string",
	
	PlayerSeenModfileWarning = "boolean",
    MaxNewsSeen = "number",
	
	VisualDelay = "string",
	
	PlayerOptionsString = "string"
}

-- ------------------------------------------

local theme_name = THEME:GetThemeDisplayName()
local filename =  theme_name .. " UserPrefs.ini"

-- Hook called during profile load
function LoadProfileCustom(profile, dir)

	local path =  dir .. filename
	local player, pn, filecontents

	-- we've been passed a profile object as the variable "profile"
	-- see if it matches against anything returned by PROFILEMAN:GetProfile(player)
	for p in ivalues( GAMESTATE:GetHumanPlayers() ) do
		if profile == PROFILEMAN:GetProfile(p) then
			player = p
			pn = ToEnumShortString(p)
			break
		end
	end

	if pn then
		-- SL has other functionality in here... I think it's only used for fast profile switching?
		-- Spud doesn't yet implement this, so it's gone for now - 48
		ParseGrooveStatsIni(player)
	end

	if pn and FILEMAN:DoesFileExist(path) then
		filecontents = IniFile.ReadFile(path)[theme_name]

		-- for each key/value pair read in from the player's profile
		for k,v in pairs(filecontents) do
			-- ensure that the key has a corresponding key in profile_whitelist
			if profile_whitelist[k]
			--  ensure that the datatype of the value matches the datatype specified in profile_whitelist
			and type(v)==profile_whitelist[k] then
				-- if the datatype is string and this key corresponds with an OptionRow in ScreenPlayerOptions
				-- ensure that the string read in from the player's profile
				-- is a valid value (or choice) for the corresponding OptionRow
				if type(v) == "string" and CustomOptionRow(k) and FindInTable(v, CustomOptionRow(k).Values or CustomOptionRow(k).Choices)
				or type(v) ~= "string" then
					SL[pn].ActiveModifiers[k] = v
				end

				-- special-case PlayerOptionsString for now
				-- it is saved to and read from profile as a string, but doesn't have a corresponding
				-- OptionRow in ScreenPlayerOptions, so it will fail validation above
				-- we want engine-defined mods (e.g. dizzy) to be applied as well, not just SL-defined mods
				if k=="PlayerOptionsString" and type(v)=="string" then
					-- v here is the comma-delimited set of modifiers the engine's PlayerOptions interface understands

					-- update the SL table so that this PlayerOptionsString value is easily accessible throughout the theme
					SL[pn].PlayerOptionsString = v

					-- use the engine's SetPlayerOptions() method to set a whole bunch of mods in the engine all at once
					GAMESTATE:GetPlayerState(player):SetPlayerOptions("ModsLevel_Preferred", v)

					-- However! It's quite likely that a FailType mod could be in that^ string, meaning a player could
					-- have their own setting for FailType saved to their profile.  I think it makes more sense to let
					-- machine operators specify a default FailType at a global/machine level, so use this opportunity to
					-- use the PlayerOptions interface to set FailSetting() using the default FailType setting from
					-- the operator menu's Advanced Options
					GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred"):FailSetting( GetDefaultFailType() )
				end
			end
		end
	end

	return true
end

-- Hook called during profile save
function SaveProfileCustom(profile, dir)

	local path =  dir .. filename

	for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
		if profile == PROFILEMAN:GetProfile(player) then
			local pn = ToEnumShortString(player)
			local output = {}
			for k,v in pairs(SL[pn].ActiveModifiers) do
				if profile_whitelist[k] and type(v)==profile_whitelist[k] then
					output[k] = v
				end
			end

			-- PlayerOptionsString is saved outside the SL[pn].ActiveModifiers tables
			-- and thus won't be handled in the loop above
			output.PlayerOptionsString = SL[pn].PlayerOptionsString

			IniFile.WriteFile( path, {[theme_name]=output} )
			break
		end
	end

	return true
end

-- for when you just want to retrieve profile data from disk without applying it to the SL table
function ReadProfileCustom(profile, dir)
	local path = dir .. filename
	if FILEMAN:DoesFileExist(path) then
		return IniFile.ReadFile(path)[theme_name]
	end
	return false
end