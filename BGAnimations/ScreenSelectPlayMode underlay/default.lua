local choices, choice_actors = {}, {}
local TopScreen = nil
-- give this a value now, before the TopScreen has been prepared and we can fetch its name
-- we'll reassign it appropriately below, once the TopScreen is available
local ScreenName = "ScreenSelectPlayMode"

local cursor = {
	h = 40,
	index = 0,
	-- the width of the cursor will be clamped to exist between these two values
	min_w = 90, max_w = 170,
}

local Update = function(af, delta)
	local index = TopScreen:GetSelectionIndex( GAMESTATE:GetMasterPlayerNumber() )
	if index ~= cursor.index then
		cursor.index = index

		-- queue the appropiate command to the faux playfield, if needed
		--if choices[cursor.index+1] == "Marathon" or choices[cursor.index+1] == "Regular" then
		--	af:queuecommand("FirstLoop"..choices[cursor.index+1])
		--end

		-- queue an "Update" to the AF containing the cursor, description text, score, and lifemeter actors
		-- since they are children of that AF, they will also listen for that command
		af:queuecommand("Update")
	end
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:SetUpdateFunction( Update )
	end,
	OnCommand=function(self)
		-- Get the Topscreen and its name, now that that TopScreen itself actually exists
		TopScreen = SCREENMAN:GetTopScreen()
		ScreenName = TopScreen:GetName()

		-- now that we have the TopScreen's name, get the single string containing this
		-- screen's choices from Metrics.ini, and split it on commas; store those choices
		-- in the choices table, and do similarly with actors associated with those choices
		for choice in THEME:GetMetric(ScreenName, "ChoiceNames"):gmatch('([^,]+)') do
			choices[#choices+1] = choice
			choice_actors[#choice_actors+1] = TopScreen:GetChild("IconChoice"..choice)
		end

        self:queuecommand("Update")
	end,
	OffCommand=function(self)
		if ScreenName=="ScreenSelectPlayMode" or ScreenName=="ScreenSelectPlayModeThonk" then
			-- set the GameMode now; we'll use it throughout the theme
			-- to set certain Gameplay settings and determine which screen comes next
			SL.Global.GameMode = choices[cursor.index+1]
			-- now that a GameMode has been selected, set related preferences
			SetGameModePreferences()
            
            if SL.Global.GameMode == "Casual" then --In casual mode? Update remaining stages to our Casual-specific songs per play setting
                SL.Global.Stages.Remaining = ThemePrefs.Get("CasualSongsPerPlay") or PREFSMAN:GetPreference("SongsPerPlay")
            end
            
			-- and reload the theme's Metrics
			THEME:ReloadMetrics()
		end
	end,
}

t[#t+1] = LoadFont("Common Normal")..{
    Name="Legal",
    Text=THEME:GetString("ScreenSelectStyle", "Legal"),
    InitCommand=function(self)
        self:shadowlength(1):xy(_screen.cx, _screen.h * 0.87):zoom(0.8):diffuseshift():effectcolor1(1,1,1,0.6):effectcolor2(1,1,1,0.5):effectperiod(2):diffusealpha(0)
    end,
    OnCommand=function(self) self:smooth(0.3):diffusealpha(1) end,
    OffCommand=function(self) self:smooth(0.3):diffusealpha(0) end,
}

return t