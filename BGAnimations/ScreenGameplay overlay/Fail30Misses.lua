--
--Here lies a custom implementation of Fail 30/51/etc Misses
--
--If enabled in the theme prefs, players can fail a song if they get a certain miss combo
--If both players have failed, the song is *immediately* failed regardless of the default fail type
--This is intended for public machines where casual players might walk away from the game mid-song 
--

local stage_stats = {}
local fail_count = ThemePrefs.Get("FailOnMissCombo")

for player in ivalues({PLAYER_1, PLAYER_2}) do --Get an instance of each joined player's stage stats, save them for later
	if GAMESTATE:IsSideJoined(player) then
		stage_stats[player] = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	end
end

return Def.Actor{
	JudgmentMessageCommand=function(self, params) --Called whenever either player gets a judgement
		--SM(params.Player)
		if (stage_stats[params.Player]:GetCurrentMissCombo() >= fail_count and not stage_stats[params.Player]:GetFailed()) then --Player has over the specified miss combo and hasn't failed? Fail 'em!
			--SM("FAIL " .. params.Player)
			stage_stats[params.Player]:FailPlayer()
			
			if (STATSMAN:GetCurStageStats():AllFailed()) then --All players have failed, *immediately* leave gameplay regardless of whether we'd normally want to fail at the end of the song
				if (ThemePrefs.Get("MissComboFailsSet")) then SL.Global.MissComboFail = true end --Make sure that the eval screen goes into game over instead of select music (if the miss combo is also supposed to fail the set)
				SCREENMAN:GetTopScreen():PostScreenMessage("SM_BeginFailed", 0)
			end
		end
	end,
}