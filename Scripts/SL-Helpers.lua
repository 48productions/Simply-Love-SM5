local default_songs

-- -----------------------------------------------------------------------
-- call this to draw a Quad with a border
-- width of quad, height of quad, and border width, in pixels

function Border(width, height, bw)
	return Def.ActorFrame {
		Def.Quad { InitCommand=function(self) self:zoomto(width-2*bw, height-2*bw):MaskSource(true) end },
		Def.Quad { InitCommand=function(self) self:zoomto(width,height):MaskDest() end },
		Def.Quad { InitCommand=function(self) self:diffusealpha(0):clearzbuffer(true) end },
	}
end

-- -----------------------------------------------------------------------
-- SM5's d3d implementation does not support render to texture. The DISPLAY
-- singleton has a method to check this but it doesn't seem to be implemented
-- in RageDisplay_D3D which is, ironically, where it's most needed.  So, this.

-- SM5.3 alpha uses "glad" as the name of its OpenGL renderer.
-- Returns true if the first (6/4) characters of prefstring are "opengl" or "glad".

SupportsRenderToTexture = function()
	local prefstring = PREFSMAN:GetPreference("VideoRenderers"):lower()
	return (prefstring:sub(1,6) == "opengl") or (prefstring:sub(1,4) == "glad")
end

-- -----------------------------------------------------------------------
-- There's surely a better way to do this.  I need to research this more.

local is8bit = function(text)
	return text:len() == text:utf8len()
end


-- Here's what inline comments in BitmapText.cpp currently have to say about wrapwidthpixels
------
-- // Break sText into lines that don't exceed iWrapWidthPixels. (if only
-- // one word fits on the line, it may be larger than iWrapWidthPixels).
--
-- // This does not work in all languages:
-- /* "...I can add Japanese wrapping, at least. We could handle hyphens
-- * and soft hyphens and pretty easily, too." -glenn */
------
--
-- So, wrapwidthpixels does not have great support for East Asian Languages.
-- Without whitespace characters to break on, the text just... never wraps.  Neat.
--
-- Here are glenn's thoughts on the topic as of June 2019:
------
-- For Japanese specifically I'd convert the string to WString (so each character is one character),
-- then make it split "words" (potential word wrap points) based on each character type.  If you
-- were splitting "text あああ", it would split into "text " (including the space), "あ", "あ", "あ",
-- using a mapping to know which language each character is.  Then just follow the same line fitting
-- and recombine without reinserting spaces (since they're included in the array).
--
-- It wouldn't be great, you could end up with things like periods being wrapped onto a line by
-- themselves, ugly single-character lines, etc.  There are more involved language-specific word
-- wrapping algorithms that'll do a better job:
-- ( https://en.wikipedia.org/wiki/Line_breaking_rules_in_East_Asian_languages ),
-- or a line balancing algorithm that tries to generate lines of roughly even width instead of just
-- filling line by line, but those are more involved.
--
-- A simpler thing to do is implement zero-width spaces (&zwsp), which is a character that just
-- explicitly marks a place where word wrap is allowed, and then you can insert them strategically
-- to manually word-wrap text.  Takes more work to insert them, but if there isn't a ton of text
-- being wrapped, it might be simpler.
------
--
-- I have neither the native intellignce nor the brute-force-self-taught-CS-experience to achieve
-- any of the above, so here is some laughably bad code that is just barely good enough to meet the
-- needs of JP text in Simply Love.  Feel free to copy+paste this method to /r/shittyprogramming,
-- private Discord servers, etc., for didactic and comedic purposes alike.

BitmapText._wrapwidthpixels = function(bmt, w)
	local text = bmt:GetText()

	if not is8bit(text) then
		-- a range of bytes I'm considering to indicate JP characters,
		-- mostly derived from empirical observation and guesswork
		-- >= 240 seems to be emojis, the glyphs for which are as wide as Miso in SL, so don't include those
		-- FIXME: If you know more about how this actually works, please submit a pull request.
		local lower = 200
		local upper = 240
		bmt:settext("")

		for i=1, text:utf8len() do
			local c = text:utf8sub(i,i)
			local b = c:byte()

			-- if adding this character causes the displayed string to be wider than allowed
			if bmt:settext( bmt:GetText()..c ):GetWidth() > w then
				-- and if that character just added was in the jp range (...maybe)
				if b < upper and b >= lower then
					-- then insert a newline between the previous character and the current
					-- character that caused us to go over
					bmt:settext( bmt:GetText():utf8sub(1,-2).."\n"..c )
				else
					-- otherwise it's trickier, as romance languages only really allow newlines
					-- to be inserted between words, not in the middle of single words
					-- we'll have to "peel back" a character at a time until we hit whitespace
					-- or something in the jp range
					local _text = bmt:GetText()

					for j=i,1,-1 do
						local _c = _text:utf8sub(j,j)
						local _b = _c:byte()

						if _c:match("%s") or (_b < upper and _b >= lower) then
							bmt:settext( _text:utf8sub(1,j) .. "\n" .. _text:utf8sub(j+1) )
							break
						end
					end
				end
			end
		end
	else
		bmt:wrapwidthpixels(w)
	end

	-- return the BitmapText actor in case the theme is chaining actor commands
	return bmt
end

BitmapText.Truncate = function(bmt, m)
	local text = bmt:GetText()
	local l = text:len()

	-- With SL's Miso and JP fonts, english characters (Miso) tend to render 2-3x less wide
	-- than JP characters. If the text includes JP characters, it is (probably) desired to
	-- truncate the string earlier to achieve the same effect.
	-- Here, we are arbitrarily "weighting" JP characters to count 4x as much as one Miso
	-- character and then scaling the point at which we truncate accordingly.
	-- This is, of course, a VERY broad over-generalization, but It Works For Now™.
	if not is8bit(text) then
		l = 0

		local lower = 200
		local upper = 240

		for i=1, text:utf8len() do
			local b = text:utf8sub(i,i):byte()
			l = l + ((b < upper and b >= lower) and 4 or 1)
		end
		m = math.floor(m * (m/l))
	end

	-- if the length of the string is less than the specified truncate point, don't do anything
	if l <= m then return end
	-- otherwise, replace everything after the truncate point with an ellipsis
	bmt:settext( text:utf8sub(1, m) .. "…" )

	-- return the BitmapText actor in case the theme is chaining actor commands
	return bmt
end

-- -----------------------------------------------------------------------
-- game types like "kickbox" and "lights" aren't supported in Simply Love, so we
-- use this function to hardcode a list of game modes that are supported, and use it
-- in ScreenInit overlay.lua to redirect players to ScreenSelectGame if necessary.
--
-- (Because so many people have accidentally gotten themselves into lights mode without
-- having any idea they'd done so, and have then messaged me saying the theme was broken.)

CurrentGameIsSupported = function()
	-- a hardcoded list of games that Simply Love supports
	local support = {
		dance  = true,
		pump   = true,
		techno = true,
		para   = true,
		kb7    = true
	}
	-- return true or nil
	return support[GAMESTATE:GetCurrentGame():GetName()]
end

-- -----------------------------------------------------------------------
-- get timing window in milliseconds

GetTimingWindow = function(n, mode)
	local prefs = SL.Preferences[mode or SL.Global.GameMode]
	local scale = PREFSMAN:GetPreference("TimingWindowScale")
	return prefs["TimingWindowSecondsW"..n] * scale + prefs.TimingWindowAdd
end

-- -----------------------------------------------------------------------
-- determines which timing_window an offset value (number) belongs to
-- used by the judgment scatter plot and offset histogram in ScreenEvaluation

DetermineTimingWindow = function(offset)
	for i=1,NumJudgmentsAvailable() do
		if math.abs(offset) <= GetTimingWindow(i) then
			return i
		end
	end
	return 5
end

-- -----------------------------------------------------------------------
-- return number of available judgments

NumJudgmentsAvailable = function()
	return 5
end

-- -----------------------------------------------------------------------
-- some common information needed by ScreenSystemOverlay's credit display,
-- as well as ScreenTitleJoin overlay and ./Scripts/SL-Branches.lua regarding coin credits

GetCredits = function()
	local coins = GAMESTATE:GetCoins()
	local coinsPerCredit = PREFSMAN:GetPreference('CoinsPerCredit')
	local credits = math.floor(coins/coinsPerCredit)
	local remainder = coins % coinsPerCredit

	return { Credits=credits,Remainder=remainder, CoinsPerCredit=coinsPerCredit }
end

-- -----------------------------------------------------------------------
-- used in Metrics.ini for ScreenRankingSingle and ScreenRankingDouble

GetStepsTypeForThisGame = function(type)
	local game = GAMESTATE:GetCurrentGame():GetName()
	-- capitalize the first letter
	game = game:gsub("^%l", string.upper)

	return "StepsType_" .. game .. "_" .. type
end

-- -----------------------------------------------------------------------
-- return the x value for the center of a player's notefield
-- used to position various elements in ScreenGameplay

GetNotefieldX = function( player )
	local p = ToEnumShortString(player)
	local game = GAMESTATE:GetCurrentGame():GetName()

	local IsPlayingDanceSolo = (GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Solo")
	local NumPlayersEnabled = GAMESTATE:GetNumPlayersEnabled()
	local NumSidesJoined = GAMESTATE:GetNumSidesJoined()
	local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player') or IsPlayingDanceSolo or (NumSidesJoined==1 and (game=="techno" or game=="kb7"))

	if IsUsingSoloSingles and NumPlayersEnabled == 1 and NumSidesJoined == 1 then return _screen.cx end
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then return _screen.cx end

	local NumPlayersAndSides = ToEnumShortString( GAMESTATE:GetCurrentStyle():GetStyleType() )
	return THEME:GetMetric("ScreenGameplay","Player".. p .. NumPlayersAndSides .."X")
end

-- -----------------------------------------------------------------------
-- this is verbose, but it lets us manage what seem to be
-- quirks/oversights in the engine on a per-game + per-style basis

local NoteFieldWidth = {
	-- dance works and doesn't need modification (use the fallback width instead of overriding it here)
    
	-- the values returned by the engine for Pump are slightly too small(?), so... uh... pad it
	pump = {
		single  = function(p) return GAMESTATE:GetCurrentStyle():GetWidth(p) + 10 end,
		versus  = function(p) return GAMESTATE:GetCurrentStyle():GetWidth(p) + 10 end,
		double  = function(p) return GAMESTATE:GetCurrentStyle():GetWidth(p) + 10 end,
		routine = function(p) return GAMESTATE:GetCurrentStyle():GetWidth(p) + 10 end,
	},
	-- techno works for single8, needs to be smaller for versus8 and double8
	techno = {
		versus8 = function(p) return (GAMESTATE:GetCurrentStyle():GetWidth(p)/1.65) end,
		double8 = function(p) return (GAMESTATE:GetCurrentStyle():GetWidth(p)/1.65) end,
	},
	-- the values returned for para are also slightly too small, so... pad those, too
	para = {
		single = function(p) return GAMESTATE:GetCurrentStyle():GetWidth(p) + 10 end,
		versus = function(p) return GAMESTATE:GetCurrentStyle():GetWidth(p) + 10 end,
	},
	-- kb7 works for single, needs to be smaller for versus
	-- there is no kb7 double (would that be kb14?)
	kb7 = {
		versus = function(p) return GAMESTATE:GetCurrentStyle():GetWidth(p)/1.65 end,
	},
}

GetNotefieldWidth = function(player)
	if not player then return false end

	local game = GAMESTATE:GetCurrentGame():GetName()
	local style = GAMESTATE:GetCurrentStyle():GetName()
	
    -- Fallback to the engine-provided width in case our lookup table doesn't specify a new value for width
    if NoteFieldWidth[game] and NoteFieldWidth[game][style] then
        return NoteFieldWidth[game][style](player)
    else
        return GAMESTATE:GetCurrentStyle():GetWidth(player)
    end
end

-- -----------------------------------------------------------------------
-- noteskin_name is a string that matches some available NoteSkin for the current game
-- column is an (optional) string for the column you want returned, like "Left" or "DownRight"
--
-- if no errors are encountered, a full NoteSkin actor is returned
-- otherwise, a generic Def.Actor is returned
-- in both these cases, the Name of the returned actor will be ("NoteSkin_"..noteskin_name)

GetNoteSkinActor = function(noteskin_name, column)

	-- prepare a dummy Actor using the name of NoteSkin in case errors are
	-- encountered so that a valid (inert, not-drawing) actor still gets returned
	local dummy = Def.Actor{
		Name="NoteSkin_"..(noteskin_name or ""),
		InitCommand=function(self) self:visible(false) end
	}

	-- perform first check: does the NoteSkin exist for the current game?
	if not NOTESKIN:DoesNoteSkinExist(noteskin_name) then return dummy end

	local game_name = GAMESTATE:GetCurrentGame():GetName()
	local fallback_column = { dance="Up", pump="UpRight", techno="Up", kb7="Key1" }

	-- prefer the value for column if one was passed in, otherwise use a fallback value
	column = column or fallback_column[game_name] or "Up"

	-- most NoteSkins are free of errors, but we cannot assume they all are
	-- one error in one NoteSkin is enough to halt ScreenPlayerOptions overlay
	-- so, use pcall() to catch errors.  The first argument is the function we
	-- want to check for runtime errors, and the remaining arguments are what
	-- we would have passed to that function.
	--
	-- Using pcall() like this returns [multiple] values.  A boolean indicating that the
	-- function is error-free (true) or that errors were caught (false), and then whatever
	-- calling that function would have normally returned
	local okay, noteskin_actor = pcall(NOTESKIN.LoadActorForNoteSkin, NOTESKIN, column, "Tap Note", noteskin_name)

	-- if no errors were caught and we have a NoteSkin actor from NOTESKIN:LoadActorForNoteSkin()
	if okay and noteskin_actor then

		-- If we've made it this far, the screen will function without halting, but there
		-- may still be Lua errors in the NoteSkin's InitCommand that might cause the actor
		-- to display strangely (because Lua halted and sizing/positioning/etc. never happened).
		--
		-- There is some version of an "smx" NoteSkin that got passed around the community
		-- that attempts to use a nil constant "FIXUP" in its InitCommand that exhibits this.
		-- So, pcall() again, now specifically on the noteskin_actor's InitCommand if it has one.
		if noteskin_actor.InitCommand then
			okay = pcall(noteskin_actor.InitCommand)
		end

		if okay then
			return noteskin_actor..{
				Name="NoteSkin_"..noteskin_name,
				InitCommand=function(self) self:visible(false) end
			}
		end
	end

	-- if the user has ShowThemeErrors enabled, let them know about the Lua errors via SystemMessage
	if PREFSMAN:GetPreference("ShowThemeErrors") then
		SM( THEME:GetString("ScreenPlayerOptions", "NoteSkinErrors"):format(noteskin_name) )
	end

	return dummy
end

-- -----------------------------------------------------------------------
-- Define what is necessary to maintain and/or increment your combo, per Gametype.
-- For example, in dance Gametype, TapNoteScore_W3 (window #3) is commonly "Great"
-- so in dance, a "Great" will not only maintain a player's combo, it will also increment it.
--
-- We reference this function in Metrics.ini under the [Gameplay] section.
GetComboThreshold = function( MaintainOrContinue )
	local CurrentGame = GAMESTATE:GetCurrentGame():GetName()

	local ComboThresholdTable = {
		dance	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		pump	=	{ Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" },
		techno	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		kb7		=	{ Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" },
		-- these values are chosen to match Deluxe's PARASTAR
		para	=	{ Maintain = "TapNoteScore_W5", Continue = "TapNoteScore_W3" },

		-- I don't know what these values are supposed to actually be...
		popn	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		beat	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		kickbox	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },

		-- lights is not a playable game mode, but it is, oddly, a selectable one within the operator menu
		-- include dummy values here to prevent Lua errors in case players accidentally switch to lights
		lights =	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
	}


	if CurrentGame ~= "para" then
		if SL.Global.GameMode == "StomperZ" or SL.Global.GameMode=="FA+" then
			ComboThresholdTable.dance.Maintain = "TapNoteScore_W4"
			ComboThresholdTable.dance.Continue = "TapNoteScore_W4"
		end
	end

	return ComboThresholdTable[CurrentGame][MaintainOrContinue]
end

-- -----------------------------------------------------------------------

-- FailType is a PlayerOption that can be set using SM5's PlayerOptions interface.
-- If you wanted, you could set FailTyper per-player, prior to Gameplay like
--
-- GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Preferred"):FailSetting("FailType_ImmediateContinue")
-- GAMESTATE:GetPlayerState(PLAYER_2):GetPlayerOptions("ModsLevel_Preferred"):FailSetting("FailType_Off")
--
-- and then P1 and P2 would have different Fail settings during gameplay.
--
-- That sounds kind of chaotic, particularly with saving Machine HighScores, so Simply Love
-- enforces the same FailType for both players and allows machine operators to set a
-- "default FailType" within Advanced Options in the Operator Menu.
--
-- This "default FailType" is sort of handled by the engine, but not in a way that is
-- necessarily clear to me.  Whatever the history there was, it is lost to me now.
--
-- The engine's FailType enum has the following four values:
-- 'FailType_Immediate', 'FailType_ImmediateContinue', 'FailType_EndOfSong', and 'FailType_Off'
--
-- The conf-based OptionRow for "DefaultFailType" presents these^ as the following hardcoded English strings:
-- 'Immediate', 'ImmediateContinue', 'EndOfSong', and 'Off'
--
-- and whichever the machine operator chooses gets saved as a different hardcoded English string in
-- the DefaultModifiers Preference for the current game:
-- '', 'FailImmediateContinue', 'FailAtEnd', or 'FailOff'

-- It is worth pointing out that a default FailType of "FailType_Immediate" is saved to the DefaultModifiers
-- Preference as an empty string!
--
-- so this:
-- DefaultModifiers=FailOff, Overhead, Cel
-- would result in the engine applying FailType_Off to players when they join the game
--
-- while this:
-- DefaultModifiers=Overhead, Cel
-- would result in the engine applying FailType_Immediate to players when they join the game
--
-- Anyway, this is all convoluted enough that I wrote this global helper function to find the default
-- FailType setting in the current game's DefaultModifiers Preference and return it as an enum value
-- the PlayerOptions interface can accept.
--
-- Keeping track of the logical flow of which preference overrides which metrics
-- and attempting to extrapolate how that will play out over time in a community
-- where players expect to be able to modify the code that drives gameplay is so
-- convoluted that it seems unreasonable to expect any player to follow along.
--
-- I can barely follow along.
--
-- I'm pretty sure ZP Theart was wailing about such project bitrot in Lost Souls in Endless Time.

GetDefaultFailType = function()
	local default_mods = PREFSMAN:GetPreference("DefaultModifiers")

	local default_fail = ""
	local fail_strings = {}

	-- -------------------------------------------------------------------
	-- these mappings just recreate the if/else chain in PlayerOptions.cpp
	fail_strings.failarcade            = "FailType_Immediate"
	fail_strings.failimmediate         = "FailType_Immediate"
	fail_strings.failendofsong         = "FailType_ImmediateContinue"
	fail_strings.failimmediatecontinue = "FailType_ImmediateContinue"
	fail_strings.failatend             = "FailType_EndOfSong"
	fail_strings.failoff               = "FailType_Off"

	-- handle the "faildefault" string differently than the SM5 engine
	-- PlayerOptions.cpp will lookup GAMESTATE's DefaultPlayerOptions
	-- which applies, in sequence:
	--    DefaultModifiers from Preferences.ini
	--    DefaultModifers from [Common] in metrics.ini
	--    DefaultNoteSkinName from [Common] in metrics.ini
	--
	-- SM5.1's _fallback theme does not currently specify any FailType
	-- in DefaultModifiers under [Common] in its metrics.ini
	--
	-- This suggests that if a non-standard failstring (like "FailASDF")
	-- is found, the _fallback theme won't enforce anything, but the engine
	-- will enforce FailType_Immediate.  Brief testing seems to align with this
	-- theory, but I haven't dug through enough of the src to *know*.
	--
	-- So, anyway, if Simply Love finds "faildefault" as a DefaultModifier in
	-- Simply Love UserPrefs.ini, I'll go with "FailType_ImmediateContinue.
	-- ImmediateContinue will be Simply Love's default.
	fail_strings.faildefault           = "FailType_ImmediateContinue"
	-- -------------------------------------------------------------------

	for mod in string.gmatch(default_mods, "%w+") do
		if mod:lower():find("fail") then
			-- we found something matches "fail", so set our default_fail variable
			-- and keep looking; don't break from the loop immediately.
			-- I don't know if it's possible to have multiple FailType
			-- strings saved in a single DefaultModifiers string...
			default_fail = mod:lower()
		end
	end

	-- return the appropriate Enum string or "FailType_Immediate" if nothing was parsed out of DefaultModifiers
	return fail_strings[default_fail] or "FailType_Immediate"
end

-- -----------------------------------------------------------------------

SetGameModePreferences = function()
	-- apply the preferences associated with this GameMode
	for key,val in pairs(SL.Preferences[SL.Global.GameMode]) do
		PREFSMAN:SetPreference(key, val)
	end

	-- loop through human players and apply whatever mods need to be set now
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local pn = ToEnumShortString(player)
		-- If we're switching to Casual mode,
		-- we want to reduce the number of judgments,
		-- so turn Decents and WayOffs off now.
		if SL.Global.GameMode == "Casual" then
			SL[pn].ActiveModifiers.TimingWindows = {true,true,true,false,false}
		end

		-- Now that we've set the SL table for TimingWindows appropriately,
		-- use it to apply TimingWindows.
		local TW_OptRow = CustomOptionRow( "TimingWindows" )
		TW_OptRow:LoadSelections( TW_OptRow.Choices, player )


		local player_modslevel = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

		-- using PREFSMAN to set the preference for MinTNSToHideNotes apparently isn't
		-- enough when switching gamemodes because MinTNSToHideNotes is also a PlayerOption.
		-- so, set the PlayerOption version of it now, too, to ensure that arrows disappear
		-- at the appropriate judgments during gameplay for this gamemode.
		player_modslevel:MinTNSToHideNotes(SL.Preferences[SL.Global.GameMode].MinTNSToHideNotes)

		-- FailSetting is also a modifier that can be set per-player per-stage in SM5, but I'm
		-- opting to enforce it in Simply Love using what the machine operator sets
		-- as the default FailType in Advanced Options in the operator menu
		player_modslevel:FailSetting( GetDefaultFailType() )
	end

	-- these are the prefixes that are prepended to each custom Stats.xml, resulting in
	-- Stats.xml, ECFA-Stats.xml, StomperZ-Stats.xml, Casual-Stats.xml
	-- "FA+" mode is prefixed with "ECFA-" because the mode was previously known as "ECFA Mode"
	-- and I don't want to deal with renaming relatively critical files from the theme.
	-- Thus, scores from FA+ mode will continue to go into ECFA-Stats.xml.
	local prefix = {
		ITG = "",
		["FA+"] = "ECFA-",
		StomperZ = "StomperZ-",
		Casual = "Casual-"
	}

	if PROFILEMAN:GetStatsPrefix() ~= prefix[SL.Global.GameMode] then
		PROFILEMAN:SetStatsPrefix(prefix[SL.Global.GameMode])
	end
end

-- -----------------------------------------------------------------------
-- Call ResetPreferencesToStockSM5() to reset all the Preferences that SL silently
-- manages for you back to their stock SM5 values.  These "managed" Preferences are
-- listed in ./Scripts/SL_Init.lua per-gamemode (Casual, ITG, FA+, StomperZ), and
-- actively applied (and reapplied) for each new game using SetGameModePreferences()
--
-- SL normally calls ResetPreferencesToStockSM5() from
-- ./BGAnimations/ScreenPromptToResetPreferencesToStock overlay.lua
-- but people have requested that the functionality for resetting Preferences be
-- generally accessible (for example, switching themes via a pad code).
-- Thus, this global function.

ResetPreferencesToStockSM5 = function()
	-- loop through all the Preferences that SL forcibly manages and reset them
	for key, value in pairs(SL.Preferences[SL.Global.GameMode]) do
		PREFSMAN:SetPreferenceToDefault(key)
	end
	-- now that those Preferences are reset to default values, write Preferences.ini to disk now
	PREFSMAN:SavePreferences()
end

-- -----------------------------------------------------------------------
-- given a player, return a table of stepartist text for the current song or course
-- so that various screens (SSM, Eval) can cycle through these values and players
-- can see each for brief duration

GetStepsCredit = function(player)
	local t = {}

	if GAMESTATE:IsCourseMode() then
		local course = GAMESTATE:GetCurrentCourse()
		-- scripter
		if course:GetScripter() ~= "" then t[#t+1] = course:GetScripter() end
		-- description
		if course:GetDescription() ~= "" then t[#t+1] = course:GetDescription() end
	else
		local steps = GAMESTATE:GetCurrentSteps(player)
		-- credit
		if steps:GetAuthorCredit() ~= "" then t[#t+1] = steps:GetAuthorCredit() end
		-- description
		if steps:GetDescription() ~= "" then t[#t+1] = steps:GetDescription() end
		-- chart name
		if steps:GetChartName() ~= "" then t[#t+1] = steps:GetChartName() end
	end

	return t
end

-- -----------------------------------------------------------------------

-- the best way to spread holiday cheer is singing loud for all to hear
HolidayCheer = function()
	return (PREFSMAN:GetPreference("EasterEggs") and MonthOfYear()==11)
end

BrighterOptionRows = function()
	if ThemePrefs.Get("RainbowMode") then return true end
	if HolidayCheer() then return true end
	return false
end

-- -----------------------------------------------------------------------
-- account for the possibility that emojis shouldn't be diffused to Color.Black

DiffuseEmojis = function(bmt, text)
	text = text or bmt:GetText()
	
	-- loop through each char in the string, checking for emojis; if any are found
	-- don't diffuse that char to be any specific color by selectively diffusing it to be {1,1,1,1}
	for i=1, text:utf8len() do
		if text:utf8sub(i,i):byte() >= 240 then
			bmt:AddAttribute(i-1, { Length=1, Diffuse={1,1,1,1} } )
		end
	end
end

-- -----------------------------------------------------------------------
-- read the theme version from ThemeInfo.ini to display on ScreenTitleMenu underlay
-- this allows players to more easily identify what version of the theme they are currently using

GetThemeVersion = function()
	local file = IniFile.ReadFile( THEME:GetCurrentThemeDirectory() .. "ThemeInfo.ini" )
	if file then
		if file.ThemeInfo and file.ThemeInfo.Version then
			return file.ThemeInfo.Version
		end
	end
	return false
end

-- -----------------------------------------------------------------------
-- functions that attempt to handle the mess that is custom judgment graphic detection/loading

local function FilenameIsMultiFrameSprite(filename)
	-- look for the "[frames wide] x [frames tall]"
	-- and some sort of all-letters file extension
	-- Lua doesn't support an end-of-string regex marker...
	return string.match(filename, " %d+x%d+") and string.match(filename, "%.[A-Za-z]+")
end

local function FileHas6Rows(filename)
	-- 5.3 default supports 2x7 and 2x11 judgment graphics
	-- and we don't (yet)
	return string.match(filename, "x6")
end

function StripSpriteHints(filename)
	-- handle common cases here, gory details in /src/RageBitmapTexture.cpp
	-- hopefully nobody is putting stuff in brackets/parens for non-hint purposes...
	return filename:gsub(" %d+x%d+", ""):gsub(" %(doubleres%)", ""):gsub(".png", "")
end

function GetJudgmentGraphics()
	local path = THEME:GetPathG('', '_judgments')
	local files = FILEMAN:GetDirListing(path .. '/')
	-- in 5.3, check for "gamewide" custom judgments
	local files2
	if IsSM53() and FILEMAN:DoesFileExist("/Appearance/Judgments") then
		files2 = FILEMAN:GetDirListing("/Appearance/Judgments/")
	end
	local judgment_graphics = {}

	for i,filename in ipairs(files) do
		Trace(i..filename)
		-- Filter out files that aren't judgment graphics
		-- e.g. hidden system files like .DS_Store
		if FilenameIsMultiFrameSprite(filename) then

			-- use regexp to get only the name of the graphic, stripping out the extension
			local name = StripSpriteHints(filename)

			-- Fill the table, special-casing Love so that it comes first.
			if name == "Love" then
				table.insert(judgment_graphics, 1, filename)
			else
				judgment_graphics[#judgment_graphics+1] = filename
			end
		end
	end
	
	if files2 then -- naive assumption: it's probably safe to include these in all modes
		for i,filename in ipairs(files2) do
			if FilenameIsMultiFrameSprite(filename) and FileHas6Rows(filename) then
				-- use regexp to get only the name of the graphic, stripping out the extension
				local name = StripSpriteHints(filename)
				
				judgment_graphics[#judgment_graphics+1] = filename
			end
		end
	end

	-- "None" -> no graphic in Player judgment.lua
	judgment_graphics[#judgment_graphics+1] = "None"

	return judgment_graphics
end

-- because it may not be inside the theme now!
function GetJudgmentGraphicPath(name)
	local FiveThreePath = "/Appearance/Judgments/" .. name
	-- GetPathG() throws a warning dialog if the file doesn't exist, so we have to do this instead
	local ThemePath = "/" .. THEME:GetCurrentThemeDirectory() .. "/Graphics/_judgments/" .. name
	if FILEMAN:DoesFileExist(FiveThreePath) then return FiveThreePath
	elseif FILEMAN:DoesFileExist(ThemePath) then return ThemePath
	end
end
-- -----------------------------------------------------------------------
-- GetComboFonts returns a table of strings that match valid ComboFonts for use in Gameplay
--
-- a valid ComboFont must:
--   • have its assets in a unique directory at ./Fonts/_Combo Fonts/
--   • include the usual files needed for a StepMania BitmapText actor (a png and an ini)
--   • have its png and ini file both be named to match the directory they are in
--
-- a valid ComboFont should:
--   • include glyphs for 1234567890()/
--   • be open source or "100% free" on dafont.com


GetComboFonts = function()
	local path = THEME:GetCurrentThemeDirectory().."Fonts/_Combo Fonts/"
	local dirs = FILEMAN:GetDirListing(path, true, false)
	local fonts = {}
	local has_wendy_cursed = false

	for directory_name in ivalues(dirs) do
		local files = FILEMAN:GetDirListing(path..directory_name.."/")
		local has_png, has_ini = false, false

		for filename in ivalues(files) do
			if FilenameIsMultiFrameSprite(filename) and (StripSpriteHints(filename)==directory_name or directory_name == "Wendy (Cursed)") then has_png = true end --Stripping file hints on Wendy (Cursed) breaks this check - 48
			if filename:match(".ini") and filename:gsub(".ini","")==directory_name then has_ini = true end
		end

		if has_png and has_ini then
			-- special-case Upheaval to always appear first in the list
			if directory_name == "Upheaval" then
				table.insert(fonts, 1, directory_name)

			-- special-cased Wendy (Cursed) to always appear last in the last
			elseif directory_name == "Wendy (Cursed)" then
				has_wendy_cursed = true
			else
				table.insert(fonts, directory_name)
			end
		end
	end

	if has_wendy_cursed then table.insert(fonts, "Wendy (Cursed)") end
	return fonts
end


-- -----------------------------------------------------------------------
IsHumanPlayer = function(player)
	return GAMESTATE:GetPlayerState(player):GetPlayerController() == "PlayerController_Human"
end

-- -----------------------------------------------------------------------
IsAutoplay = function(player)
	return GAMESTATE:GetPlayerState(player):GetPlayerController() == "PlayerController_Autoplay"
end

-- -----------------------------------------------------------------------
-- Helper function to determine if a TNS falls within the W0 window.
-- Params are the params received from the JudgmentMessageCommand.
-- Returns true/false
IsW0Judgment = function(params, player)
	if params.Player ~= player then return false end
	if params.HoldNoteScore then return false end
	
	-- Only check/update FA+ count if we received a TNS in the top window.
	if params.TapNoteScore == "TapNoteScore_W1" and SL.Global.GameMode == "ITG"  then
		local prefs = SL.Preferences["FA+"]
		local scale = PREFSMAN:GetPreference("TimingWindowScale")
		local W0 = prefs["TimingWindowSecondsW1"] * scale + prefs["TimingWindowAdd"]

		local offset = math.abs(params.TapNoteOffset)
		if offset <= W0 then
			return true
		end
	end
	return false
end

-- -----------------------------------------------------------------------
-- Gets the fully populated judgment counts for a player.
-- This includes the FA+ window (W0). Decents/WayOffs (W4/W5) will only exist in the
-- resultant table if the windows were active.
--
-- Should NOT be used in casual mode.
--
-- Returns a table with the following keys:
-- {
--             "W0" -> the fantasticPlus count
--             "W1" -> the fantastic count
--             "W2" -> the excellent count
--             "W3" -> the great count
--             "W4" -> the decent count (may not exist if window is disabled)
--             "W5" -> the way off count (may not exist if window is disabled)
--           "Miss" -> the miss count
--     "totalSteps" -> the total number of steps in the chart (including hold heads)
--          "Holds" -> total number of holds held
--     "totalHolds" -> total number of holds in the chart
--          "Mines" -> total number of mines hit
--     "totalMines" -> total number of mines in the chart
--          "Rolls" -> total number of rolls held
--     "totalRolls" -> total number of rolls in the chart
-- }
GetExJudgmentCounts = function(player)
	local pn = ToEnumShortString(player)
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)

	local counts = {}

	local TNS = { "W1", "W2", "W3", "W4", "W5", "Miss" }
	
	if SL.Global.GameMode == "FA+" then
		for window in ivalues(TNS) do
			adjusted_window = window
			-- In FA+ mode, we need to shift the windows up 1 so that the key we're using is accurate.
			-- E.g. W1 window becomes W0, W2 becomes W1, etc.
			if window ~= "Miss" then
				adjusted_window = "W"..(tonumber(window:sub(-1))-1)
			end
			
			-- Get the count.
			local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
			-- For the last window (Decent) in FA+ mode...
			if window == "W5" then
				-- Only populate if the window is still active.
				if SL[pn].ActiveModifiers.TimingWindows[5] then
					counts[adjusted_window] = number
				end
			else
				counts[adjusted_window] = number
			end
		end
	elseif SL.Global.GameMode == "ITG" then
		for window in ivalues(TNS) do
			-- Get the count.
			local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
			-- We need to extract the W0 count in ITG mode.
			if window == "W1" then
				local faPlus = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts.W0_total
				-- Subtract white count from blue count
				number = number - faPlus
				-- Populate the two numbers.
				counts["W0"] = faPlus
				counts["W1"] = number
			else
				if ((window ~= "W4" and window ~= "W5") or
						-- Only populate decent and way off windows if they're active.
						(window == "W4" and SL[pn].ActiveModifiers.TimingWindows[4]) or
						(window == "W5" and SL[pn].ActiveModifiers.TimingWindows[5])) then
					counts[window] = number
				end
			end
		end
	end
	counts["totalSteps"] = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_TapsAndHolds" )
	
	local RadarCategory = { "Holds", "Mines", "Rolls" }

	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

	for RCType in ivalues(RadarCategory) do
		local number = stats:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		local possible = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_"..RCType )

		if RCType == "Mines" then
			-- NoMines still report the total number of mines that exist in a chart, even if they weren't played in the chart.
			-- If NoMines was set, report 0 for the number of mines as the chart actually didn't have any.
			-- TODO(teejusb): Track AvoidMine in the future. This is fine for now as ITL compares serverside.
			if po:NoMines() then
				counts[RCType] = 0
				counts["total"..RCType] = 0
			else
				-- We want to keep track of mines hit.
				counts[RCType] = possible - number
				counts["total"..RCType] = possible
			end
		else
			counts[RCType] = number
			counts["total"..RCType] = possible
		end
	end

	return counts
end

-- -----------------------------------------------------------------------
-- Calculate the EX score given for a given player.
--
-- The ex_counts default to those computed in BGAnimations/ScreenGameplay underlay/TrackExScoreJudgments.lua
-- They are computed from the HoldNoteScore and TapNotScore from the JudgmentMessageCommands.
-- We look for the following keys: 
-- {
--             "W0" -> the fantasticPlus count
--             "W1" -> the fantastic count
--             "W2" -> the excellent count
--             "W3" -> the great count
--             "W4" -> the decent count
--             "W5" -> the way off count
--           "Miss" -> the miss count
--           "Held" -> the number of holds/rolds held
--          "LetGo" -> the number of holds/rolds dropped
--        "HitMine" -> total number of mines hit
-- }
CalculateExScore = function(player, ex_counts)
	-- No EX scores in Casual mode, just return some dummy number early.
	if SL.Global.GameMode == "Casual" then return 0 end
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)

	local totalSteps = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_TapsAndHolds" )
	local totalHolds = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Holds" )
	local totalRolls = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Rolls" )

	local total_possible = totalSteps * SL.ExWeights["W0"] + (totalHolds + totalRolls) * SL.ExWeights["Held"]

	local total_points = 0

	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

	-- If mines are disabled, they should still be accounted for in EX Scoring based on the weight assigned to it.
	-- Stamina community does often play with no-mines on, but because EX scoring is more timing centric where mines
	-- generally have a negative weight, it's a better experience to make sure the EX score reflects that.
	if po:NoMines() then
		local totalMines = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Mines" )
		total_points = total_points + totalMines * SL.ExWeights["HitMine"];
	end

	local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss", "Held", "LetGo", "HitMine" }
	local counts = ex_counts or SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts
	-- Just for validation, but shouldn't happen in normal gameplay.
	if counts == nil then return 0 end

	for key in ivalues(keys) do
		local value = counts[key]
		if value ~= nil then		
			total_points = total_points + value * SL.ExWeights[key]
		end
	end

	return math.max(0, math.floor(total_points/total_possible * 10000) / 100)
end

-- -----------------------------------------------------------------------
-- Pass in a string from the engine's Difficulty enum like "Difficulty_Beginner"
-- or "Difficulty_Challenge" and this will return the index of that string within
-- the enum (or nil if not found).  This is used by SL's color system to dynamically
-- color theme elements based on difficulty as the primary color scheme changes.

GetDifficultyIndex = function(difficulty)
	-- if we weren't passed a string, return nil now
	if type(difficulty) ~= "string" then return nil end

	-- FIXME: Why is this hardcoded to 5?  I need to look into this and either change
	-- it or leave a note explaining why it's this way.
	if difficulty == "Difficulty_Edit" then return 5 end

	-- Use Enum's reverse lookup functionality to find difficulty by index
	-- note: this is 0 indexed, so Beginner is 0, Challenge is 4, and Edit is 5
	-- for our purposes, increment by 1 here
	local difficulty_index = Difficulty:Reverse()[difficulty]
	if type(difficulty_index) == "number" then return (difficulty_index + 1) end
end


---------------------------------------------------------------------------
-- helper function used by GetGroups() and GetDefaultSong()
-- returns the contents of a txt file as an indexed table, split on newline

function GetFileContents(path)
	local contents = ""

	if FILEMAN:DoesFileExist(path) then
		-- create a generic RageFile that we'll use to read the contents
		local file = RageFileUtil.CreateRageFile()
		-- the second argument here (the 1) signifies
		-- that we are opening the file in read-only mode
		if file:Open(path, 1) then
			contents = file:Read()
		end

		-- destroy the generic RageFile now that we have the contents
		file:destroy()
	end

	-- split the contents of the file on newline
	-- to create a table of lines as strings
	local lines = {}
	for line in contents:gmatch("[^\r\n]+") do
		if line[0] ~= '#' then lines[#lines+1] = line end
	end

	return lines
end


---------------------------------------------------------------------------
-- Parse a given text file for a list of songs in that file
-- Returns the list of songs if present/valid, or nil if not

local GetSongsFromFile = function(groups, path)
    local path = THEME:GetCurrentThemeDirectory() .. path
	local preliminary_songs = GetFileContents(path)

	-- the file was empty or doesn't exist, return nil
	if preliminary_songs == nil or #preliminary_songs == 0 then
		return nil
	end
    
	-- verify that the song(s) specified actually exist
	local songs = {}
	for prelim_song in ivalues(preliminary_songs) do
		-- parse the group out of the prelim_song string to verify this song
		-- exists within a permitted group
		--local _group = prelim_song:gsub("/[%w%s]*", "") --The original gsub pattern doesn't work on songs with special characters in it's name (-, (, etc) - 48
        --local _group = string.match(prelim_song, "[^/]+")
        local prelim_simfile = string.match(prelim_song, "/(.*)") --Remove the initial folder (Songs/AdditionalSongs/etc) from our path (SONGMAN:FindSong doesn't want it)

		-- if this song exists and is part of a group returned by PruneGroups()
		--if SONGMAN:FindSong( prelim_song ) and FindInTable(_group, groups) then
        if prelim_simfile ~= nil and SONGMAN:FindSong( prelim_simfile ) then
			-- add this prelim_song to the table of songs that do exist
			songs[#songs+1] = prelim_song
		end
	end
    
    return songs
end


-- -----------------------------------------------------------------------
-- Reloads the default song list from file
-- (In it's own function so it can be easily called from Arctic's lua console)

RefreshDefaultSongs = function()
    default_songs = GetSongsFromFile(nil, AllowThonk() and "Other/DefaultSongsAprilFools.txt" or "Other/DefaultSongs.txt")
end


-- -----------------------------------------------------------------------
-- Returns the default song to select on the music wheel
-- Now used for both Beginner and Pro mode

GetDefaultSong=function()
    
    -- Default song list doesn't exist yet, try loading the default songs (needs to happen at least once on startup)
    if default_songs == nil or #default_songs == 0 then
        RefreshDefaultSongs()
        
        -- Still no default songs, abort! ABORT!
        if default_songs == nil or #default_songs == 0 then
            --SM("No default songs found!")
            return nil
        end
        
    -- Should've found at least one (maybe more) valid songs
    else
		if #default_songs == 1 then
			return default_songs[1]
		else
			local song = default_songs[math.random(1, #default_songs)]
			return song
		end
    end
end


-- -----------------------------------------------------------------------
-- Whether or not to show the gameplay tutorial just before a song starts

ShowTutorial=function()
	return SL.Global.GameMode == "Casual" and SL.Global.Stages.PlayedThisGame == 0 and not GAMESTATE:IsDemonstration()
end