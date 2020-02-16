-- SL's "dynamic" speedmod system is a horrible hack that works around the limitations of
-- the engine's OptionRows which don't offer any means of presenting different sets of
-- choices to each player within a single OptionRow.  We need this functionality when, for
-- example, P1 wants an xmod and P2 wants a Cmod; the choices presented in the SpeedMod
-- OptionRow present and behave differently for each player.
--
-- So, we do a lot of hackish work locally (here in ScreenPlayerOptions overlay/default.lua)
-- to manipulate the text being presented by the single BitmapText actor present in each
-- SpeedMod OptionRow.  This is not how any other OptionRow operates, and it is neither
-- flexible nor forward-thinking.

local speedmod_def = {
	x = { upper=20,   increment=0.05 },
	C = { upper=2000, increment=5 },
	M = { upper=2000, increment=5 }
}

local currentmods_frames = {}

------------------------------------------------------------
-- functions local to this file

-- use this to directly manipulate the SpeedMod numbers in the global SL table
--    first argument is either "P1" or "P2"
--    second argument is either -1 (MenuLeft was pressed) or 1 (MenuRight was pressed)
local ChangeSpeedMod = function(pn, direction)
	local mods = SL[pn].ActiveModifiers
	local speedmod = mods.SpeedMod
	local increment   = speedmod_def[mods.SpeedModType].increment
	local upper_bound = speedmod_def[mods.SpeedModType].upper

	-- increment/decrement and apply modulo to wrap around if we exceed the upper_bound or hit 0
	speedmod = ((speedmod+(increment*direction))-increment) % upper_bound + increment
	-- round the newly changed SpeedMod to the nearest appropriate increment
	speedmod = increment * math.floor(speedmod/increment + 0.5)

	mods.SpeedMod = speedmod
end


-- Use this function to find an OptionRow by name so that you can manipulate its text as needed.
--     first argument is a screen object provided by SCREENMAN:GetTopScreen()
--     second argument is a string that might match the name of an OptionRow somewhere on this screen
--
--     returns the 0-based index of that OptionRow within this screen

local FindOptionRowIndex = function(ScreenOptions, Name)
	if not ScreenOptions or not ScreenOptions.GetNumRows then return end

	local num_rows = ScreenOptions:GetNumRows()

	-- OptionRows on ScreenOptions are 0-indexed, so start counting from 0
	for i=0,num_rows-1 do
		if ScreenOptions:GetOptionRow(i):GetName() == Name then
			return i
		end
	end
end

------------------------------------------------------------

-- SpeedModBMTs is a table that will contain the BitmapText actors within the SpeedMod OptionRow for available players
local SpeedModBMTs = {}

local t = Def.ActorFrame{
	OnCommand=function(self) self:queuecommand("Capture") end,
	OffCommand=function(self) self:linear(0.2):diffusealpha(0) end,
	CaptureCommand=function(self)
		local ScreenOptions = SCREENMAN:GetTopScreen()

		for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
			local pn = ToEnumShortString(player)
			local SpeedModRowIndex = FindOptionRowIndex(ScreenOptions,"SpeedMod")

			if SpeedModRowIndex then
				-- The BitmapText actors for P1 and P2 speedmod are both named "Item", so we need to provide a 1 or 2 to index
				SpeedModBMTs[pn] = ScreenOptions:GetOptionRow(SpeedModRowIndex):GetChild(""):GetChild("Item")[ PlayerNumber:Reverse()[player]+1 ]
				self:playcommand("Set"..pn)
			end

			currentmods_frames[pn] = self:GetChild("CommonOverlay"):GetChild("ActiveMods"..pn)
		end
	end,
	MusicRateChangedMessageCommand=function(self)
		-- variables to be used for setting the text in the "Speed Mod" OptionRow title
		local screen = SCREENMAN:GetTopScreen()

		-- ScreenAttackMenu is both minimal (not many OptionRows) and buggy
		-- so if we're there, bail now
		if screen:GetName() == "ScreenAttackMenu" then return end

		-- update SpeedModHelper text to reflect the new music rate
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			if currentmods_frames[ToEnumShortString(player)] then
				currentmods_frames[ToEnumShortString(player)]:queuecommand("Refresh")
			end
		end

		-- find the index of the OptionRow for MusicRate so we can update
		-- the text of its title BitmapText as the MusicRate changes
		local MusicRateRowIndex = FindOptionRowIndex(screen, "MusicRate")

		if MusicRateRowIndex then
			local musicrate = SL.Global.ActiveModifiers.MusicRate
			local title_bmt = screen:GetOptionRow(MusicRateRowIndex):GetChild(""):GetChild("Title")

			local bpms = StringifyDisplayBPMs()
			title_bmt:settext( ("%s\nbpm: %s"):format(THEME:GetString("OptionTitles", "MusicRate"), bpms) )
		end
	end
}

-- attach NoteSkin actors and Judgment graphic sprites and Combo bitmaptexts to
-- this overlay ActorFrame; they'll each be hidden immediately via visible(false)
-- and referred to as needed via ActorProxy in ./Graphics/OptionRow Frame.lua
LoadActor("./NoteSkinPreviews.lua", t)
LoadActor("./JudgmentGraphicPreviews.lua", t)
LoadActor("./ComboFontPreviews.lua", t)

-- some functionality needed in both PlayerOptions, PlayerOptions2, and PlayerOptions3
t[#t+1] = LoadActor(THEME:GetPathB("ScreenPlayerOptions", "CommonOverlay"))


for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	local pn = ToEnumShortString(player)
	local bpms = GetDisplayBPMs(player)

	t[#t+1] = Def.Actor{

		["CurrentSteps" .. pn .. "ChangedMessageCommand"]=function(self) self:queuecommand("RefreshBPMs") end,
		["CurrentTrail" .. pn .. "ChangedMessageCommand"]=function(self)  self:queuecommand("RefreshBPMs") end,
		RefreshBPMsCommand=function(self)
			bpms = GetDisplayBPMs(player)
		end,

		-- the player wants to change their SpeedModType (x, M, C)
		["SpeedModType" .. pn .. "SetMessageCommand"]=function(self,params)

			local oldtype = SL[pn].ActiveModifiers.SpeedModType
			local newtype = params.SpeedModType

			if oldtype ~= newtype then

				local speedmod = SL[pn].ActiveModifiers.SpeedMod
				local increment = speedmod_def[newtype].increment

				-- round to the nearest speed increment in the new mode
				-- if we have an active rate mod, then we have to undo/redo
				-- our automatic rate mod compensation

				if oldtype == "x" then
					-- apply rate compensation now
					speedmod = speedmod * SL.Global.ActiveModifiers.MusicRate
					speedmod = (round((speedmod * bpms[2]) / increment)) * increment

				elseif newtype == "x" then
					-- revert rate compensation since it's handled for XMod
					speedmod = speedmod / SL.Global.ActiveModifiers.MusicRate
					speedmod = (round(speedmod / bpms[2] / increment)) * increment
				end

				-- it's possible for the procedure above to cause the player's speedmod to exceed
				-- the upper bound of the new Mmod or Cmod; clamp to prevent that
				speedmod = clamp(speedmod, increment, speedmod_def[newtype].upper)

				SL[pn].ActiveModifiers.SpeedMod     = speedmod
				SL[pn].ActiveModifiers.SpeedModType = newtype

				self:queuecommand("Set" .. pn)
			end
		end,

		["Set" .. pn .. "Command"]=function(self)
			local text = ""

			if  SL[pn].ActiveModifiers.SpeedModType == "x" then
				text = string.format("%.2f" , SL[pn].ActiveModifiers.SpeedMod ) .. "x"

			elseif  SL[pn].ActiveModifiers.SpeedModType == "C" then
				text = "C" .. tostring(SL[pn].ActiveModifiers.SpeedMod)

			elseif  SL[pn].ActiveModifiers.SpeedModType == "M" then
				text = "M" .. tostring(SL[pn].ActiveModifiers.SpeedMod)
			end

			SpeedModBMTs[pn]:settext( text )
			if currentmods_frames[pn] then
				currentmods_frames[pn]:queuecommand("Refresh")
			end
		end,

		["MenuLeft" .. pn .. "MessageCommand"]=function(self)
			local topscreen = SCREENMAN:GetTopScreen()
			local row_index = topscreen:GetCurrentRowIndex(player)

			if row_index == FindOptionRowIndex(topscreen, "SpeedMod") then
				ChangeSpeedMod( pn, -1 )
				self:queuecommand("Set"..pn)
			end
		end,
		["MenuRight" .. pn .. "MessageCommand"]=function(self)
			local topscreen = SCREENMAN:GetTopScreen()
			local row_index = topscreen:GetCurrentRowIndex(player)

			if row_index == FindOptionRowIndex(topscreen, "SpeedMod") then
				ChangeSpeedMod( pn, 1 )
				self:queuecommand("Set"..pn)
			end
		end
	}
end

return t
