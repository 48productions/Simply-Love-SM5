-- There's a lot of Lua in ./BGAnimations/ScreenGameplay overlay
-- and a LOT of Lua in ./BGAnimations/ScreenGameplay underlay
--
-- I'm using files in overlay for logic that *does* stuff without directly drawing
-- any new actors to the screen.
--
-- I've tried to title each file helpfully and partition the logic found in each accordingly.
-- Inline comments in each should provide insight into the objective of each file.
--
-- Def.Actor will be used for each underlay file because I still need some way to listen
-- for events broadcast by the engine.
--
-- I'm using files in Gameplay's underlay for actors that get drawn to the screen.  You can
-- poke around in those to learn more.
------------------------------------------------------------

local af = Def.ActorFrame{}

af[#af+1] = LoadActor("./WhoIsCurrentlyWinning.lua")

for player in ivalues( GAMESTATE:GetHumanPlayers() ) do

	local pn = ToEnumShortString(player)

	-- Use this opportunity to create an empty table for this player's gameplay stats for this stage.
	-- We'll store all kinds of data in this table that would normally only exist in ScreenGameplay so that
	-- it can persist into ScreenEvaluation to eventually be processed, visualized, and complained about.
	-- For example, per-column judgments, judgment offset data, highscore data, and so on.
	--
	-- Sadly, this Stages.Stats[stage_index] data structure is not documented anywhere. :(
	SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame+1] = {}

	af[#af+1] = LoadActor("./TrackTimeSpentInGameplay.lua", player)
	af[#af+1] = LoadActor("./ReceptorArrowsPosition.lua", player)
	af[#af+1] = LoadActor("./JudgmentOffsetTracking.lua", player)

	-- FIXME: refactor PerColumnJudgmentTracking to not be inside this loop
	--        the Lua input callback logic shouldn't be duplicated for each player
	af[#af+1] = LoadActor("./PerColumnJudgmentTracking.lua", player)
end

-- Load the Mods Machine if the ThemePref says to.
-- If its README brought you here, you don't have to do anything! If you copied the folder to the right place, you can enable the Mods Machine in Simply Potato Options.
if ThemePrefs.Get("ModsMachine") and FILEMAN:DoesFileExist("/modsmachine") then
	af[#af+1] = LoadActor("/modsmachine")
end

--If we've specified to enable failing at a certain miss combo, load the lua for it
if ThemePrefs.Get("FailOnMissCombo") > 0 then
	af[#af+1] = LoadActor("./Fail30Misses.lua")
end

return af